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
#import "CDEPersistentStoreEnsemble+Private.h"
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
        CDEStoreModificationEvent *baseline = [CDEStoreModificationEvent fetchBaselineEventInManagedObjectContext:context];
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
        BOOL hasManyEvents = [self countOfStoreModificationEvents] > 100;
        BOOL hasAdequateChanges = [self countOfAllObjectChanges] >= 500;
        
        [self estimateEventStoreCompactionFollowingRebaseWithCompletion:^(float compaction) {
            BOOL compactionIsAdequate = compaction > 0.5f;
            BOOL result = hasManyEvents || (hasAdequateChanges && compactionIsAdequate);
            
            // Include a stochastic component to reduce likelihood that two devices rebase at the same time
            if (result) {
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
        CDEStoreModificationEvent *existingBaseline = [CDEStoreModificationEvent fetchBaselineEventInManagedObjectContext:context];
        NSArray *eventsToMerge = [CDEStoreModificationEvent fetchNonBaselineEventsUpToGlobalCount:newBaselineGlobalCount inManagedObjectContext:context];

        // Keep only integrable events
        CDERevisionManager *revisionManager = [[CDERevisionManager alloc] initWithEventStore:self.eventStore];
        revisionManager.managedObjectModelURL = self.ensemble.managedObjectModelURL;
        eventsToMerge = [revisionManager integrableEventsFromEvents:eventsToMerge];
        
        // If no events, return
        if (eventsToMerge.count == 0) {
            [context reset];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil);
            });
            return;
        }
        
        // Determine what the new revisions will be
        NSArray *revisionedEvents = eventsToMerge;
        revisionedEvents = [revisionedEvents arrayByAddingObject:existingBaseline];
        CDERevisionSet *newRevisionSet = [CDERevisionSet revisionSetByTakingStoreWiseMaximumOfRevisionSets:[revisionedEvents valueForKeyPath:@"revisionSet"]];
    
        // Merge events into baseline, but don't delete the events yet.
        CDEStoreModificationEvent *newBaseline = existingBaseline;
        NSArray *eventIDs = [eventsToMerge valueForKeyPath:@"objectID"];
        NSManagedObjectID *newBaselineID = newBaseline.objectID;
        NSError *error = nil;
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
        newBaseline.modelVersion = self.ensemble.modelVersionHash;
        
        // Update store revisions by taking the maximum for each store, and the baseline
        // Do this before deleting events, so that if there is a crash,
        // there will be no missing dependency errors generated.
        NSString *persistentStoreId = self.eventStore.persistentStoreIdentifier;
        newBaseline = (id)[context existingObjectWithID:newBaselineID error:&error];
        [newBaseline setRevisionSet:newRevisionSet forPersistentStoreIdentifier:persistentStoreId];
        if (newBaseline.eventRevision.revisionNumber == -1) newBaseline.eventRevision.revisionNumber = 0;
        
        // Delete events
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", eventIDs];
        NSArray *eventsToDelete = [context executeFetchRequest:fetch error:&error];
        if (!eventsToDelete) {
            CDELog(CDELoggingLevelError, @"Couldn't retrieve events: %@", error);
        }
        
        [CDEStoreModificationEvent prefetchRelatedObjectsForStoreModificationEvents:eventsToDelete];
        for (CDEStoreModificationEvent *event in eventsToDelete) [context deleteObject:event];

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
                
                [self mergeChange:change intoBaselineChange:existingChange withBaseline:baseline objectChangeIDsByGlobalIdentifierIDs:objectChangesByGlobalId];
                
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

- (void)mergeChange:(CDEObjectChange *)change intoBaselineChange:(CDEObjectChange *)baselineChange withBaseline:(CDEStoreModificationEvent *)baseline objectChangeIDsByGlobalIdentifierIDs:(NSMapTable *)objectChangeIDsByGlobalIdentifierIDs
{
    NSManagedObjectContext *context = change.managedObjectContext;
    switch (change.type) {
        case CDEObjectChangeTypeDelete:
            if (baselineChange) {
                [objectChangeIDsByGlobalIdentifierIDs removeObjectForKey:change.globalIdentifier.objectID];
                [context deleteObject:baselineChange];
            }
            break;
            
        case CDEObjectChangeTypeInsert:
            if (baselineChange) {
                [baselineChange mergeValuesFromObjectChange:change treatChangeAsSubordinate:NO];
            }
            else {
                CDEObjectChange *newChange = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:context];
                newChange.type = CDEObjectChangeTypeInsert;
                newChange.globalIdentifier = change.globalIdentifier;
                newChange.nameOfEntity = change.nameOfEntity;
                newChange.propertyChangeValues = change.propertyChangeValues;
                newChange.storeModificationEvent = baseline;
                
                NSError *error;
                if (![context obtainPermanentIDsForObjects:@[newChange] error:&error]) {
                    CDELog(CDELoggingLevelError, @"Error obtaining permananet id: %@", error);
                }
                
                [objectChangeIDsByGlobalIdentifierIDs setObject:newChange.objectID forKey:newChange.globalIdentifier.objectID];
            }
            break;
            
        case CDEObjectChangeTypeUpdate:
            if (baselineChange) {
                [baselineChange mergeValuesFromObjectChange:change treatChangeAsSubordinate:NO];
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
    CDERevisionSet *latestRevisionSet = [revisionManager revisionSetOfMostRecentIntegrableEvents];
    
    // We will remove any store that hasn't updated since the existing baseline
    NSManagedObjectContext *context = eventStore.managedObjectContext;
    __block CDERevisionSet *baselineRevisionSet;
    __block CDEGlobalCount currentBaselineCount;
    [context performBlockAndWait:^{
        CDEStoreModificationEvent *baselineEvent = [CDEStoreModificationEvent fetchBaselineEventInManagedObjectContext:context];
        baselineRevisionSet = baselineEvent.revisionSet;
        currentBaselineCount = baselineEvent.globalCount;
    }];
    
    // Max global count in our range is the minimum of global count from all devices
    CDEGlobalCount baselineCount = NSNotFound;
    for (CDERevision *revision in latestRevisionSet.revisions) {
        // Ignore stores that haven't updated since the baseline
        // They will have to do a full integration to catch up
        NSString *storeId = revision.persistentStoreIdentifier;
        CDERevision *baselineRevision = [baselineRevisionSet revisionForPersistentStoreIdentifier:storeId];
        if (baselineRevision && baselineRevision.revisionNumber >= revision.revisionNumber) continue;

        // Find the minimum global count.
        baselineCount = MIN(baselineCount, revision.globalCount);
    }
    
    if (baselineCount == NSNotFound) {
        baselineCount = 0;
    }
    else {
        // Choose the new global count to be in the range from the baseline to the new count
        // leaving some events around, to avoid unnecessary full integrations
        CDEGlobalCount low = MIN(currentBaselineCount, baselineCount);
        baselineCount = low + (baselineCount - low) * 0.80f;
        baselineCount = MAX(baselineCount, 0);
        if (baselineCount - low == 0) baselineCount++; // Make sure it moves forward
    }
    
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
