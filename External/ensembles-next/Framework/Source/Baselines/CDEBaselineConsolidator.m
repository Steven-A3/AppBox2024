//
//  CDEBaselineConsolidator.m
//  Ensembles
//
//  Created by Drew McCormack on 27/11/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import "CDEBaselineConsolidator.h"
#import "CDEFoundationAdditions.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "CDEPersistentStoreEnsemble+Private.h"
#import "NSMapTable+CDEAdditions.h"
#import "CDEPersistentStoreEnsemble.h"
#import "CDERevisionManager.h"
#import "CDEEventStore.h"
#import "CDEStoreModificationEvent.h"
#import "CDERevisionSet.h"
#import "CDEEventRevision.h"
#import "CDERevision.h"
#import "CDEObjectChange.h"
#import "CDEGlobalIdentifier.h"
#import "CDEPropertyChangeValue.h"

@implementation CDEBaselineConsolidator {
}

@synthesize eventStore = eventStore;
@synthesize ensemble = ensemble;

- (instancetype)initWithEventStore:(CDEEventStore *)newEventStore
{
    self = [super init];
    if (self) {
        eventStore = newEventStore;
    }
    return self;
}

+ (NSFetchRequest *)baselineFetchRequest
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
    NSArray *baselineTypes = @[@(CDEStoreModificationEventTypeBaseline), @(CDEStoreModificationEventTypeBaselineMissingDependencies)];
    fetch.predicate = [NSPredicate predicateWithFormat:@"type IN %@", baselineTypes];
    return fetch;
}

- (BOOL)baselineNeedsConsolidation
{
    __block BOOL result = NO;
    [self.eventStore.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        NSFetchRequest *fetch = [self.class baselineFetchRequest];
        NSUInteger count = [self.eventStore.managedObjectContext countForFetchRequest:fetch error:&error];
        if (error) {
            CDELog(CDELoggingLevelError, @"Failed to get baseline count: %@", error);
        }
        else {
            result = count > 1;
        }
    }];
    return result;
}

- (void)consolidateBaselineWithCompletion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Consolidating baselines");

    NSManagedObjectContext *context = self.eventStore.managedObjectContext;
    [context performBlock:^{
        // Fetch existing baselines, ordered beginning with most recent
        NSError *error = nil;
        NSMutableArray *baselineEvents = [[self baselinesDecreasingInRecencyInManagedObjectContext:context error:&error] mutableCopy];
        if (!baselineEvents) {
            [self failWithCompletion:completion error:error];
            return;
        }
        CDELog(CDELoggingLevelVerbose, @"Found baselines with unique ids: %@", [baselineEvents valueForKeyPath:@"uniqueIdentifier"]);
        
        // Check that all baselines pass dependency checks
        CDERevisionManager *revisionManager = [[CDERevisionManager alloc] initWithEventStore:self.eventStore];
        revisionManager.managedObjectModelURL = self.ensemble.managedObjectModelURL;
        for (CDEStoreModificationEvent *baseline in [baselineEvents copy]) {
            // Don't check baselines created locally
            if ([baseline.eventRevision.persistentStoreIdentifier isEqualToString:self.eventStore.persistentStoreIdentifier]) continue;
            
            BOOL passes = [revisionManager checkDependenciesOfBaseline:baseline];
            if (passes && baseline.type == CDEStoreModificationEventTypeBaselineMissingDependencies) {
                baseline.type = CDEStoreModificationEventTypeBaseline;
            }
            else if (!passes && baseline.type == CDEStoreModificationEventTypeBaseline) {
                baseline.type = CDEStoreModificationEventTypeBaselineMissingDependencies;
            }
            
            if (!passes) [baselineEvents removeObject:baseline];
            
            NSError *error = nil;
            if (context.hasChanges && ![context save:&error]) {
                CDELog(CDELoggingLevelError, @"Could not change baseline type. Save failed: %@", error);
            }
        }
        
        // Determine which baselines should be eliminated
        NSSet *baselinesToEliminate = [self redundantBaselinesInBaselines:baselineEvents];
        NSMutableArray *survivingBaselines = [NSMutableArray arrayWithArray:baselineEvents];
        [survivingBaselines removeObjectsInArray:baselinesToEliminate.allObjects];
        NSMutableArray *survivingBaselineIDs = [[survivingBaselines valueForKeyPath:@"objectID"] mutableCopy];

        // Use object ids, so we can reset to keep memory low
        NSSet *baselineIDsToEliminate = [baselinesToEliminate valueForKeyPath:@"objectID"];
        
        // Delete redundant baselines. Resets the context.
        BOOL success = [self deleteBaselinesWithIDs:baselineIDsToEliminate error:&error];
        if (!success) {
            [self failWithCompletion:completion error:error];
            return;
        }
        
        // Merge surviving baselines
        CDELog(CDELoggingLevelVerbose, @"Baselines remaining that need merging: %lu", (unsigned long)survivingBaselineIDs.count);
        NSManagedObjectID *newBaselineID = [self mergedBaselineFromOrderedBaselineEventIDs:survivingBaselineIDs error:&error];
        if (!newBaselineID) {
            [self failWithCompletion:completion error:error];
            return;
        }
        
        // Delete old baselines
        [survivingBaselineIDs removeObject:newBaselineID];
        success = [self deleteBaselinesWithIDs:survivingBaselineIDs error:&error];
        if (!success) {
            [self failWithCompletion:completion error:error];
            return;
        }
        
        // Save
        if (context.hasChanges) success = [context save:&error];
        if (!success) {
            [self failWithCompletion:completion error:error];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CDELog(CDELoggingLevelTrace, @"Finishing baseline consolidation");
            if (completion) completion(nil);
        });
    }];
}

- (BOOL)deleteBaselinesWithIDs:(id <NSFastEnumeration>)baselineIDs error:(NSError * __autoreleasing *)error
{
    NSManagedObjectContext *context = self.eventStore.managedObjectContext;
    __block NSError *localError = nil;
    __block BOOL success = YES;
    
    for (NSManagedObjectID *baselineID in baselineIDs) {
        @autoreleasepool {
            CDEStoreModificationEvent *baseline = (id)[context objectWithID:baselineID];
            CDELog(CDELoggingLevelVerbose, @"Deleting redundant baseline with unique id: %@", baseline.uniqueIdentifier);

            BOOL hasMore = YES;
            while (hasMore && success) {
                @autoreleasepool {
                    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
                    fetch.predicate = [NSPredicate predicateWithFormat:@"storeModificationEvent = %@", baselineID];
                    fetch.relationshipKeyPathsForPrefetching = @[@"globalIdentifier", @"dataFiles"];
                    fetch.returnsObjectsAsFaults = NO;
                    fetch.fetchLimit = 1000;
                    
                    NSArray *objectChanges = [context executeFetchRequest:fetch error:NULL];
                    for (CDEObjectChange *change in objectChanges) {
                        [context deleteObject:change];
                    }
                    
                    hasMore = !(objectChanges.count < fetch.fetchLimit);
                    
                    success = [context save:&localError];
                    [context reset];
                }
            }
            
            if (!success) break;
            
            baseline = (id)[context objectWithID:baselineID];
            [context deleteObject:baseline];
            success = [context save:&localError];
            [context reset];
        }
        
        if (!success) break;
    }
    
    if (!success) *error = localError;
    return success;
}

- (void)failWithCompletion:(CDECompletionBlock)completion error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) completion(error);
    });
}

- (NSArray *)decreasingRecencySortDescriptors
{
    NSArray *sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"globalCount" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"eventRevision.persistentStoreIdentifier" ascending:NO]
    ];
    return sortDescriptors;
}

- (NSArray *)baselinesDecreasingInRecencyInManagedObjectContext:(NSManagedObjectContext *)context error:(NSError * __autoreleasing *)error
{
    NSFetchRequest *fetch = [self.class baselineFetchRequest];
    fetch.sortDescriptors = [self decreasingRecencySortDescriptors];
    NSArray *baselineEvents = [context executeFetchRequest:fetch error:error];
    return baselineEvents;
}

- (NSSet *)redundantBaselinesInBaselines:(NSArray *)allBaselines
{
    NSMutableSet *baselinesToEliminate = [NSMutableSet setWithCapacity:allBaselines.count];
    for (NSUInteger i = 0; i < allBaselines.count; i++) {
        CDEStoreModificationEvent *firstEvent = allBaselines[i];
        
        for (NSUInteger j = 0; j < i; j++) {
            CDEStoreModificationEvent *secondEvent = allBaselines[j];
            
            // Compare revisions
            CDERevisionSet *firstSet = firstEvent.revisionSet;
            CDERevisionSet *secondSet = secondEvent.revisionSet;
            NSComparisonResult comparison = [firstSet compare:secondSet];
            
            if (comparison == NSOrderedDescending) {
                [baselinesToEliminate addObject:secondEvent];
            }
            else if (comparison == NSOrderedAscending) {
                [baselinesToEliminate addObject:firstEvent];
            }
            else if ([firstSet isEqualToRevisionSet:secondSet]) {
                // If exactly the same, eliminate the oldest
                NSArray *events = @[firstEvent, secondEvent];
                events = [events sortedArrayUsingDescriptors:[self decreasingRecencySortDescriptors]];
                [baselinesToEliminate addObject:events.lastObject];
            }
        }
    }
    return baselinesToEliminate;
}

- (NSManagedObjectID *)mergedBaselineFromOrderedBaselineEventIDs:(NSArray *)baselineIDs error:(NSError * __autoreleasing *)error
{
    if (baselineIDs.count == 1) return baselineIDs.lastObject;
    if (baselineIDs.count == 0) {
        if (error) *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey : @"No baselines found"}];
        return nil;
    }
    
    NSManagedObjectContext *context = self.eventStore.managedObjectContext;
    NSArray *baselines = [baselineIDs cde_arrayByTransformingObjectsWithBlock:^id(NSManagedObjectID *objectID) {
        return [context objectWithID:objectID];
    }];
    
    CDELog(CDELoggingLevelVerbose, @"Merging baselines with unique ids: %@", [baselines valueForKeyPath:@"uniqueIdentifier"]);
    
    // Determine which baselines to eliminate and which is the
    // most-recent. That will become the new baseline.
    NSManagedObjectID *mergedBaselineID = baselineIDs[0];
    NSMutableArray *otherBaselineIDsRequiringMerging = [baselineIDs mutableCopy];
    [otherBaselineIDsRequiringMerging removeObjectAtIndex:0];
    
    // Change the first baseline into our new baseline
    __block CDEStoreModificationEvent *mergedBaseline = (id)[context objectWithID:mergedBaselineID];

    // Retrieve all global identifiers. Map global ids to object changes.
    [CDEStoreModificationEvent prefetchRelatedObjectsForStoreModificationEvents:@[mergedBaseline]];
    NSMapTable *objectChangeIDsByGlobalIdentifierIDs = [NSMapTable cde_strongToStrongObjectsMapTable];
    
    NSExpressionDescription *changeIDDesc = [[NSExpressionDescription alloc] init];
    changeIDDesc.name = @"changeID";
    changeIDDesc.expression = [NSExpression expressionForEvaluatedObject];
    changeIDDesc.expressionResultType = NSObjectIDAttributeType;
    
    NSExpressionDescription *globalIDDesc = [[NSExpressionDescription alloc] init];
    globalIDDesc.name = @"globalID";
    globalIDDesc.expression = [NSExpression expressionForKeyPath:@"globalIdentifier"];
    globalIDDesc.expressionResultType = NSObjectIDAttributeType;
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"storeModificationEvent = %@", mergedBaselineID];
    fetch.resultType = NSDictionaryResultType;
    fetch.propertiesToFetch = @[changeIDDesc, globalIDDesc];
    
    __block NSError *localError = nil;
    NSArray *fetchResults = [context executeFetchRequest:fetch error:&localError];
    if (!fetchResults) {
        *error = localError;
        return nil;
    }
    
    for (NSDictionary *resultDict in fetchResults) {
        NSManagedObjectID *changeID = resultDict[@"changeID"];
        NSManagedObjectID *globalID = resultDict[@"globalID"];
        [objectChangeIDsByGlobalIdentifierIDs setObject:changeID forKey:globalID];
    }
    
    // Apply changes from others
    __block BOOL success = YES;
    for (NSManagedObjectID *baselineID in otherBaselineIDsRequiringMerging) {
        __block CDEStoreModificationEvent *baseline = (id)[context objectWithID:baselineID];
        
        CDELog(CDELoggingLevelVerbose, @"Merging in baseline with unique id: %@", baseline.uniqueIdentifier);

        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"storeModificationEvent = %@", baselineID];
        fetch.resultType = NSManagedObjectIDResultType;
        NSArray *changeIDs = [context executeFetchRequest:fetch error:&localError];
        if (!changeIDs) {
            success = NO;
            break;
        }
        
        [CDEStoreModificationEvent prefetchRelatedObjectsForStoreModificationEvents:@[baseline]];
        
        __block NSUInteger count = 0;
        [changeIDs cde_enumerateObjectsInBatchesWithBatchSize:500 usingBlock:^(NSArray *batchChangeIDs, NSUInteger batchesRemaining, BOOL *stop) {
            for (NSManagedObjectID *changeID in batchChangeIDs) {
                CDEObjectChange *change = (id)[context objectWithID:changeID];
                NSManagedObjectID *existingChangeID = [objectChangeIDsByGlobalIdentifierIDs objectForKey:change.globalIdentifier.objectID];
                CDEObjectChange *existingChange = existingChangeID ? (id)[context objectWithID:existingChangeID] : nil;
                if (!existingChange) {
                    // Move change to new baseline
                    change.storeModificationEvent = mergedBaseline;
                    [objectChangeIDsByGlobalIdentifierIDs setObject:changeID forKey:change.globalIdentifier.objectID];
                }
                else {
                    [existingChange mergeValuesFromObjectChange:change treatChangeAsSubordinate:YES];
                }
            }
            
            count += batchChangeIDs.count;
            CDELog(CDELoggingLevelVerbose, @"Objects merged into baseline: %lu", (unsigned long)count);
            
            success = [context save:&localError];
            [context reset];
            mergedBaseline = (id)[context objectWithID:mergedBaselineID];
            baseline = (id)[context objectWithID:baselineID];
            if (!success) *stop = YES;
        }];
    }
    
    if (success) {
        CDELog(CDELoggingLevelVerbose, @"Updating revisions of merged baseline");

        // Update the revisions of each store in the baseline.
        // Do this last, so if a crash occurs, it will just continue the merge next time.
        // Doing this first would cause the incomplete baseline to not be concurrent with other baselines,
        // and thus not get merged.
        NSArray *baselines = [baselineIDs cde_arrayByTransformingObjectsWithBlock:^id(NSManagedObjectID *objectID) {
            return [context objectWithID:objectID];
        }];
        
        // Change baseline id.
        NSString *persistentStoreId = self.eventStore.persistentStoreIdentifier;
        mergedBaseline.uniqueIdentifier = [[NSProcessInfo processInfo] globallyUniqueString];
        
        // Update timestamps and global counts
        // Global count should be maximum.
        // A baseline global count is not required to preceed save/merge events, and assigning the
        // maximum will give this new baseline precedence over older baselines.
        mergedBaseline.timestamp = [NSDate timeIntervalSinceReferenceDate];
        mergedBaseline.modelVersion = self.ensemble.modelVersionHash;
        mergedBaseline.globalCount = [[baselines valueForKeyPath:@"@max.globalCount"] unsignedIntegerValue];
        
        // Update revisions
        CDERevisionSet *newRevisionSet = [CDERevisionSet revisionSetByTakingStoreWiseMaximumOfRevisionSets:[baselines valueForKeyPath:@"revisionSet"]];
        [mergedBaseline setRevisionSet:newRevisionSet forPersistentStoreIdentifier:persistentStoreId];
        if (mergedBaseline.eventRevision.revisionNumber == -1) mergedBaseline.eventRevision.revisionNumber = 0;
        
        success = [context save:&localError];
    }

    if (error) *error = localError;
    
    return success ? mergedBaselineID : nil;
}

@end

