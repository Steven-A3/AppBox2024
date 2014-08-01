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
    fetch.predicate = [NSPredicate predicateWithFormat:@"type = %d", CDEStoreModificationEventTypeBaseline];
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
        NSArray *baselineEvents = [self baselinesDecreasingInRecencyInManagedObjectContext:context error:&error];
        if (!baselineEvents) {
            [self failWithCompletion:completion error:error];
            return;
        }
        CDELog(CDELoggingLevelVerbose, @"Found baselines with unique ids: %@", [baselineEvents valueForKeyPath:@"uniqueIdentifier"]);
        
        // Check that all baseline model versions are known
        CDERevisionManager *revisionManager = [[CDERevisionManager alloc] initWithEventStore:self.eventStore];
        revisionManager.managedObjectModelURL = self.ensemble.managedObjectModelURL;
        BOOL hasAllModelVersions = [revisionManager checkModelVersionsOfStoreModificationEvents:baselineEvents];
        if (!hasAllModelVersions) {
            NSError *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeUnknownModelVersion userInfo:nil];
            [self failWithCompletion:completion error:error];
            return;
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
        CDELog(CDELoggingLevelVerbose, @"Baselines remaining that need merging");
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
    if (baselineIDs.count == 0) return nil;
    if (baselineIDs.count == 1) return baselineIDs.lastObject;
    
    NSManagedObjectContext *context = self.eventStore.managedObjectContext;
    NSArray *baselines = [baselineIDs cde_arrayByTransformingObjectsWithBlock:^id(NSManagedObjectID *objectID) {
        return [context objectWithID:objectID];
    }];
    
    CDELog(CDELoggingLevelVerbose, @"Merging baselines with unique ids: %@", [baselines valueForKeyPath:@"uniqueIdentifier"]);
    
    // Change the first baseline into our new baseline by assigning a different unique id
    // Global count should be maximum, ie, just keep the count of the existing first baseline.
    // A baseline global count is not required to preceed save/merge events, and assigning the
    // maximum will give this new baseline precedence over older baselines.
    __block CDEStoreModificationEvent *firstBaseline = baselines[0];
    NSManagedObjectID *firstBaselineID = firstBaseline.objectID;
    firstBaseline.timestamp = [NSDate timeIntervalSinceReferenceDate];
    firstBaseline.modelVersion = [self.ensemble.managedObjectModel cde_entityHashesPropertyList];

    // Retrieve all global identifiers. Map global ids to object changes.
    [CDEStoreModificationEvent prefetchRelatedObjectsForStoreModificationEvents:@[firstBaseline]];
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
    fetch.predicate = [NSPredicate predicateWithFormat:@"storeModificationEvent = %@", firstBaselineID];
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
    
    // Get other baselines
    NSMutableArray *otherBaselineIDs = [baselineIDs mutableCopy];
    [otherBaselineIDs removeObject:firstBaseline.objectID];
    
    // Apply changes from others
    __block BOOL success = YES;
    __block BOOL baselineModified = NO;
    for (NSManagedObjectID *baselineID in otherBaselineIDs) {
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
                    change.storeModificationEvent = firstBaseline;
                    [objectChangeIDsByGlobalIdentifierIDs setObject:changeID forKey:change.globalIdentifier.objectID];
                    baselineModified = YES;
                }
                else {
                    BOOL changed = NO;
                    [existingChange mergeValuesFromSubordinateObjectChange:change isModified:(baselineModified ? NULL : &changed)];
                    if (changed) baselineModified = YES;
                }
            }
            
            count += batchChangeIDs.count;
            CDELog(CDELoggingLevelVerbose, @"Objects merged into baseline: %lu", (unsigned long)count);
            
            success = [context save:&localError];
            [context reset];
            firstBaseline = (id)[context objectWithID:firstBaselineID];
            baseline = (id)[context objectWithID:baselineID];
            if (!success) *stop = YES;
        }];
    }
    
    if (success) {
        // Update the revisions of each store in the baseline.
        // Do this last, so if a crash occurs, it will just continue the merge next time.
        // Doing this first would cause the incomplete baseline to not be concurrent with other baselines,
        // and thus not get merged.
        NSArray *baselines = [baselineIDs cde_arrayByTransformingObjectsWithBlock:^id(NSManagedObjectID *objectID) {
            return [context objectWithID:objectID];
        }];
        
        // Change baseline id if it was actually changed. If unchanged, avoid exporting a new baseline
        // by leaving id the same.
        NSString *persistentStoreId = firstBaseline.eventRevision.persistentStoreIdentifier;
        if (baselineModified) {
            persistentStoreId = self.eventStore.persistentStoreIdentifier;
            firstBaseline.uniqueIdentifier = [[NSProcessInfo processInfo] globallyUniqueString];
        }
        
        CDERevisionSet *newRevisionSet = [CDERevisionSet revisionSetByTakingStoreWiseMaximumOfRevisionSets:[baselines valueForKeyPath:@"revisionSet"]];
        [firstBaseline setRevisionSet:newRevisionSet forPersistentStoreIdentifier:persistentStoreId];
        if (firstBaseline.eventRevision.revisionNumber == -1) firstBaseline.eventRevision.revisionNumber = 0;
        
        success = [context save:&localError];
    }

    if (error) *error = localError;
    
    return success ? firstBaselineID : nil;
}

@end

