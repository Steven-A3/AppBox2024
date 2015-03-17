//
//  CDERebaser.m
//  Ensembles
//
//  Created by Drew McCormack on 05/01/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import "CDERebaser.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "NSManagedObjectContext+CDEAdditions.h"
#import "NSMapTable+CDEAdditions.h"
#import "CDEFoundationAdditions.h"
#import "NSMapTable+CDEAdditions.h"
#import "CDEDefines.h"
#import "CDEEventStore.h"
#import "CDEPersistentStoreEnsemble.h"
#import "CDEStoreModificationEvent.h"
#import "CDEObjectChange.h"
#import "CDEGlobalIdentifier.h"
#import "CDEEventRevision.h"
#import "CDERevisionManager.h"
#import "CDERevisionSet.h"
#import "CDERevision.h"

@interface CDERebaser ()

@end

@implementation CDERebaser

@synthesize eventStore = eventStore;
@synthesize ensemble = ensemble;
@synthesize forceRebase = forceRebase;

+ (void)initialize
{
    if (self == [CDERebaser class]) {
    }
}

- (instancetype)initWithEventStore:(CDEEventStore *)newStore
{
    self = [super init];
    if (self) {
        eventStore = newStore;
        forceRebase = NO;
    }
    return self;
}


#pragma mark Removing Out-of-Date Events

- (void)deleteEventsPreceedingBaselineWithCompletion:(CDECompletionBlock)completion
{
    NSManagedObjectContext *context = eventStore.managedObjectContext;
    [context performBlock:^{
        CDEStoreModificationEvent *baseline = [CDEStoreModificationEvent fetchMostRecentBaselineStoreModificationEventInManagedObjectContext:context];
        CDERevisionSet *baselineRevisionSet = baseline.revisionSet;
        NSSet *storeIds = baselineRevisionSet.persistentStoreIdentifiers;
        NSArray *types = @[@(CDEStoreModificationEventTypeMerge), @(CDEStoreModificationEventTypeSave)];
        for (NSString *storeId in storeIds) {
            CDERevision *baseRevision = [baselineRevisionSet revisionForPersistentStoreIdentifier:storeId];
            
            NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
            NSPredicate *storePredicate = [CDEStoreModificationEvent predicateForAllowedTypes:types persistentStoreIdentifier:storeId];
            NSPredicate *revisionPredicate = [NSPredicate predicateWithFormat:@"eventRevision.revisionNumber <= %lld", baseRevision.revisionNumber];
            fetch.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[storePredicate, revisionPredicate]];
            
            NSError *error;
            NSArray *events = [context executeFetchRequest:fetch error:&error];
            if (!events) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(error);
                });
                return;
            }
            
            [CDEStoreModificationEvent prefetchRelatedObjectsForStoreModificationEvents:events];
            for (CDEStoreModificationEvent *event in events) {
                [context deleteObject:event];
            }
        }
        
        NSError *error = nil;
        BOOL saved = [context save:&error];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(saved ? nil : error);
        });
    }];
}

#pragma mark Determining When to Rebase

- (void)estimateEventStoreCompactionFollowingRebaseWithCompletion:(void(^)(float compaction))completion
{
    NSParameterAssert(completion);
    [self.eventStore.managedObjectContext performBlock:^{
        // Determine size of baseline
        NSInteger currentBaselineCount = [self countOfBaseline];
        
        // Determine inserted, deleted, and updated changes outside baseline
        NSInteger deletedCount = [self countOfNonBaselineObjectChangesOfType:CDEObjectChangeTypeDelete];
        NSInteger insertedCount = [self countOfNonBaselineObjectChangesOfType:CDEObjectChangeTypeInsert];
        NSInteger updatedCount = [self countOfNonBaselineObjectChangesOfType:CDEObjectChangeTypeUpdate];
        
        // Estimate size of event store after rebasing.
        // Assume that an insertion is 1 data unit.
        // A deletion removes at least one insertion, so it is worth 1 data unit.
        // An update is usually to some subset of properties. Assume it has weight 0.1 data units.
        float postRebaseSize = currentBaselineCount + insertedCount - deletedCount;
        
        // Estimate compaction
        float currentSize = currentBaselineCount + insertedCount + 0.1*updatedCount;
        float compaction = 1.0f - ( postRebaseSize / (float)MAX(1,currentSize) );
        compaction = MIN( MAX(compaction, 0.0f), 1.0f);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(compaction);
        });
    }];
}

- (void)shouldRebaseWithCompletion:(void(^)(BOOL result))completion
{
    NSParameterAssert(completion);
    
    if (self.forceRebase) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(YES);
        });
        return;
    }

    // Rebase if there are more than 500 object changes, and we can reduce data by more than 50%,
    // or if there is no baseline at all
    NSManagedObjectContext *context = eventStore.managedObjectContext;
    [context performBlock:^{
        BOOL hasBaseline = NO;
        CDERevisionSet *baselineRevisionSet = nil;
        CDEStoreModificationEvent *baseline = [CDEStoreModificationEvent fetchMostRecentBaselineStoreModificationEventInManagedObjectContext:context];
        hasBaseline = baseline != nil;
        baselineRevisionSet = baseline.revisionSet;
        
        // Rebase if the baseline doesn't include all stores
        CDERevisionManager *revisionManager = [[CDERevisionManager alloc] initWithEventStore:self.eventStore];
        NSSet *allStores = revisionManager.allPersistentStoreIdentifiers;
        BOOL hasAllDevicesInBaseline = [baselineRevisionSet.persistentStoreIdentifiers isEqualToSet:allStores];
        
        BOOL hasManyEvents = [self countOfStoreModificationEvents] > 100;
        BOOL hasAdequateChanges = [self countOfAllObjectChanges] >= 500;
        
        [self estimateEventStoreCompactionFollowingRebaseWithCompletion:^(float compaction) {
            BOOL compactionIsAdequate = compaction > 0.5f;
            BOOL result = !hasBaseline || !hasAllDevicesInBaseline || hasManyEvents || (hasAdequateChanges && compactionIsAdequate);
            
            // Include a stochastic component to reduce likelihood that two devices rebase at the same time
            if (result && hasBaseline && hasAllDevicesInBaseline) {
                const float PercentageAcceptance = 20.0f;
                float randomUpToOne = arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
                BOOL stochasticTestPassed = randomUpToOne < PercentageAcceptance/100.0f;
                result = result && stochasticTestPassed;
            }

            if (completion) completion(result);
        }];
    }];
}


#pragma mark Rebasing

- (void)rebaseWithCompletion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Starting rebase");
    
    CDEGlobalCount newBaselineGlobalCount = [self globalCountForNewBaseline];
    CDELog(CDELoggingLevelVerbose, @"New baseline global count: %lld", newBaselineGlobalCount);
    
    NSManagedObjectContext *context = eventStore.managedObjectContext;
    [context performBlock:^{
        // Fetch objects
        CDEStoreModificationEvent *existingBaseline = [CDEStoreModificationEvent fetchMostRecentBaselineStoreModificationEventInManagedObjectContext:context];
        NSArray *eventsToMerge = [CDEStoreModificationEvent fetchNonBaselineEventsUpToGlobalCount:newBaselineGlobalCount inManagedObjectContext:context];
        if (existingBaseline && eventsToMerge.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil);
            });
            return;
        }
        
        // Check that events can be integrated, ie, pass all checks.
        NSError *error = nil;
        CDERevisionManager *revisionManager = [[CDERevisionManager alloc] initWithEventStore:self.eventStore];
        revisionManager.managedObjectModelURL = self.ensemble.managedObjectModelURL;
        BOOL passedChecks = [revisionManager checkRebasingPrerequisitesForEvents:eventsToMerge error:&error];
        if (!passedChecks) {
            CDELog(CDELoggingLevelWarning, @"Failed rebasing prerequisite checks. Aborting rebase");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(error);
            });
            return;
        }
        
        // Determine what the new revisions will be
        NSArray *revisionedEvents = eventsToMerge;
        if (existingBaseline) revisionedEvents = [revisionedEvents arrayByAddingObject:existingBaseline];
        CDERevisionSet *newRevisionSet = [CDERevisionSet revisionSetByTakingStoreWiseMaximumOfRevisionSets:[revisionedEvents valueForKeyPath:@"revisionSet"]];
        NSString *persistentStoreId = self.eventStore.persistentStoreIdentifier;
        
        // If no baseline exists, create one.
        CDEStoreModificationEvent *newBaseline = existingBaseline;
        if (!existingBaseline) {
            CDEEventRevision *eventRevision = [NSEntityDescription insertNewObjectForEntityForName:@"CDEEventRevision" inManagedObjectContext:context];
            eventRevision.persistentStoreIdentifier = persistentStoreId;
            eventRevision.revisionNumber = 0;
            
            newBaseline = [NSEntityDescription insertNewObjectForEntityForName:@"CDEStoreModificationEvent" inManagedObjectContext:context];
            newBaseline.type = CDEStoreModificationEventTypeBaseline;
            newBaseline.timestamp = 0.0;
            eventRevision.storeModificationEvent = newBaseline;
            [context obtainPermanentIDsForObjects:@[newBaseline] error:&error];
        }
    
        // Merge events into baseline
        NSArray *eventIDs = [eventsToMerge valueForKeyPath:@"objectID"];
        NSManagedObjectID *newBaselineID = newBaseline.objectID;
        BOOL success = [self mergeOrderedEventsWithIDs:eventIDs intoBaselineWithID:newBaselineID error:&error];
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CDELog(CDELoggingLevelError, @"Failed to merge in rebase: %@", error);
                if (completion) completion(error);
            });
            return;
        }
        
        // Set new count and other properties
        newBaseline = (id)[context existingObjectWithID:newBaselineID error:&error];
        if (!newBaseline) CDELog(CDELoggingLevelError, @"Couldn't retrieve baseline: %@", error);
        newBaseline.globalCount = newBaselineGlobalCount;
        newBaseline.timestamp = [NSDate timeIntervalSinceReferenceDate];
        newBaseline.modelVersion = [self.ensemble.managedObjectModel cde_entityHashesPropertyList];
        
        // Update store revisions by taking the maximum for each store, and the baseline
        // Do this before deleting events, so that if there is a crash,
        // there will be no missing dependency errors generated.
        newBaseline = (id)[context existingObjectWithID:newBaselineID error:&error];
        [newBaseline setRevisionSet:newRevisionSet forPersistentStoreIdentifier:persistentStoreId];
        if (newBaseline.eventRevision.revisionNumber == -1) newBaseline.eventRevision.revisionNumber = 0;
        
        // Delete events
        for (NSManagedObjectID *eventID in eventIDs) {
            @autoreleasepool {
                CDEStoreModificationEvent *event = (id)[context existingObjectWithID:eventID error:&error];
                if (event) {
                    [CDEStoreModificationEvent prefetchRelatedObjectsForStoreModificationEvents:@[event]];
                    [context deleteObject:event];
                    [context save:&error];
                    [context reset];
                }
                else {
                    CDELog(CDELoggingLevelError, @"Couldn't retrieve event: %@", error);
                }
            }
        }

        // Save
        BOOL saved = [context save:&error];
        [context reset];
        if (!saved) CDELog(CDELoggingLevelError, @"Failed to save rebase: %@", error);
        
        // Complete
        dispatch_async(dispatch_get_main_queue(), ^{
            CDELog(CDELoggingLevelTrace, @"Finishing rebase");
            if (completion) completion(saved ? nil : error);
        });
    }];
}

- (BOOL)mergeOrderedEventsWithIDs:(NSArray *)eventIDs intoBaselineWithID:(NSManagedObjectID *)baselineID error:(NSError * __autoreleasing *)error
{
    if (error) *error = nil;
    
    __block NSError *localError = nil;
    NSManagedObjectContext *context = self.eventStore.managedObjectContext;
    
    __block CDEStoreModificationEvent *baseline = (id)[context existingObjectWithID:baselineID error:&localError];
    if (!baseline) {
        if (error) *error = localError;
        return NO;
    }

    // Create map of existing object changes
    [CDEStoreModificationEvent prefetchRelatedObjectsForStoreModificationEvents:@[baseline]];
    NSMapTable *objectChangesByGlobalId = [NSMapTable cde_strongToStrongObjectsMapTable];
    NSSet *objectChanges = baseline.objectChanges;
    for (CDEObjectChange *change in objectChanges) {
        [objectChangesByGlobalId setObject:change.objectID forKey:change.globalIdentifier.objectID];
    }
    
    // Loop through events, merging them in the baseline
    for (NSManagedObjectID *eventID in eventIDs) {
        @autoreleasepool {
            // Prefetch for performance
            __block CDEStoreModificationEvent *event = (id)[context objectWithID:eventID];
            [CDEStoreModificationEvent prefetchRelatedObjectsForStoreModificationEvents:@[event]];
            
            // Loop through object changes
            __block NSUInteger count = 0;
            NSArray *objectChangeIDs = [event.objectChanges.allObjects valueForKeyPath:@"objectID"];
            [objectChangeIDs cde_enumerateObjectsDrainingEveryIterations:100 usingBlock:^(NSManagedObjectID *changeID, NSUInteger index, BOOL *stop) {
                CDEObjectChange *change = (id)[context objectWithID:changeID];
                NSManagedObjectID *existingChangeID = [objectChangesByGlobalId objectForKey:change.globalIdentifier.objectID];
                CDEObjectChange *existingChange = existingChangeID ? (id)[context objectWithID:existingChangeID] : nil;
                [self mergeChange:change withSubordinateChange:existingChange addToBaseline:baseline withObjectChangeIDsByGlobalIdentifierIDs:objectChangesByGlobalId];
                
                if (count++ % 500 == 0) {
                    if (![context save:&localError]) {
                        *stop = YES;
                        return;
                    }
                    [context reset];
                    baseline = (id)[context objectWithID:baselineID];
                    event = (id)[context objectWithID:eventID];
                }
            }];
            
            if (localError) {
                if (error) *error = localError;
                return NO;
            }
        }
    }
    
    if (![context save:&localError]) {
        if (error) *error = localError;
        return NO;
    }
    [context reset];
    
    return YES;
}

- (void)mergeChange:(CDEObjectChange *)change withSubordinateChange:(CDEObjectChange *)subordinateChange addToBaseline:(CDEStoreModificationEvent *)baseline withObjectChangeIDsByGlobalIdentifierIDs:(NSMapTable *)objectChangeIDsByGlobalIdentifierIDs
{
    NSManagedObjectContext *context = change.managedObjectContext;
    switch (change.type) {
        case CDEObjectChangeTypeDelete:
            if (subordinateChange) {
                [objectChangeIDsByGlobalIdentifierIDs removeObjectForKey:change.globalIdentifier.objectID];
                [context deleteObject:subordinateChange];
            }
            break;
            
        case CDEObjectChangeTypeInsert:
            if (subordinateChange) {
                [change mergeValuesFromSubordinateObjectChange:subordinateChange];
                [context deleteObject:subordinateChange];
            }
            change.storeModificationEvent = baseline;
            [objectChangeIDsByGlobalIdentifierIDs setObject:change.objectID forKey:change.globalIdentifier.objectID];
            break;
            
        case CDEObjectChangeTypeUpdate:
            if (subordinateChange) {
                [change mergeValuesFromSubordinateObjectChange:subordinateChange];
                [context deleteObject:subordinateChange];
                change.type = CDEObjectChangeTypeInsert;
                change.storeModificationEvent = baseline;
                [objectChangeIDsByGlobalIdentifierIDs setObject:change.objectID forKey:change.globalIdentifier.objectID];
            }
            break;
            
        default:
            @throw [NSException exceptionWithName:CDEException reason:@"Invalid object change type" userInfo:nil];
            break;
    }
}

- (CDEGlobalCount)globalCountForNewBaseline
{
    CDERevisionManager *revisionManager = [[CDERevisionManager alloc] initWithEventStore:self.eventStore];
    CDERevisionSet *latestRevisionSet = [revisionManager revisionSetOfMostRecentEvents];
    
    // We will remove any store that hasn't updated since the existing baseline
    NSManagedObjectContext *context = eventStore.managedObjectContext;
    __block CDERevisionSet *baselineRevisionSet;
    __block CDEGlobalCount currentBaselineCount;
    [context performBlockAndWait:^{
        CDEStoreModificationEvent *baselineEvent = [CDEStoreModificationEvent fetchMostRecentBaselineStoreModificationEventInManagedObjectContext:context];
        baselineRevisionSet = baselineEvent.revisionSet;
        currentBaselineCount = baselineEvent.globalCount;
    }];
    
    // Baseline count is minimum of global count from all devices
    CDEGlobalCount baselineCount = NSNotFound;
    for (CDERevision *revision in latestRevisionSet.revisions) {
        // Ignore stores that haven't updated since the baseline
        // They will have to do a full integration to catch up
        NSString *storeId = revision.persistentStoreIdentifier;
        CDERevision *baselineRevision = [baselineRevisionSet revisionForPersistentStoreIdentifier:storeId];
        if (baselineRevision && baselineRevision.revisionNumber >= revision.revisionNumber) continue;
        
        // Find the minimum global count. We try to leave at least one
        // event for each store. This prevents unnecessary full-integrations.
        // But the baseline must progress, so some devices could be left behind
        // and have to do a full integration.
        if (revision.globalCount <= currentBaselineCount+1) continue;
        baselineCount = MIN(baselineCount, revision.globalCount-1);
    }
    
    if (baselineCount == NSNotFound) baselineCount = 0;
    
    return baselineCount;
}


#pragma mark Fetching Counts

- (NSUInteger)countOfStoreModificationEvents
{
    __block NSUInteger count = 0;
    NSManagedObjectContext *context = eventStore.managedObjectContext;
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
        count = [context countForFetchRequest:fetch error:&error];
        if (error) CDELog(CDELoggingLevelError, @"Couldn't fetch count of events: %@", error);
    }];
    return count;
}

- (NSUInteger)countOfAllObjectChanges
{
    __block NSUInteger count = 0;
    NSManagedObjectContext *context = eventStore.managedObjectContext;
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
        count = [context countForFetchRequest:fetch error:&error];
        if (error) CDELog(CDELoggingLevelError, @"Couldn't fetch count of object changes: %@", error);
    }];
    return count;
}

- (NSUInteger)countOfNonBaselineObjectChangesOfType:(CDEObjectChangeType)type
{
    __block NSUInteger count = 0;
    NSManagedObjectContext *context = eventStore.managedObjectContext;
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
        NSPredicate *eventTypePredicate = [NSPredicate predicateWithFormat:@"storeModificationEvent.type != %d && storeModificationEvent.type != %d", CDEStoreModificationEventTypeBaseline, CDEStoreModificationEventTypeIncomplete];
        NSPredicate *changeTypePredicate = [NSPredicate predicateWithFormat:@"type = %d", type];
        fetch.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[eventTypePredicate, changeTypePredicate]];
        count = [context countForFetchRequest:fetch error:&error];
        if (error) CDELog(CDELoggingLevelError, @"Couldn't fetch count of non-baseline objects: %@", error);
    }];
    return count;
}

- (NSUInteger)countOfBaseline
{
    __block NSUInteger count = 0;
    NSManagedObjectContext *context = eventStore.managedObjectContext;
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"storeModificationEvent.type = %d", CDEStoreModificationEventTypeBaseline];
        count = [context countForFetchRequest:fetch error:&error];
        if (error) CDELog(CDELoggingLevelError, @"Couldn't fetch count of baseline: %@", error);
    }];
    return count;
}

@end
