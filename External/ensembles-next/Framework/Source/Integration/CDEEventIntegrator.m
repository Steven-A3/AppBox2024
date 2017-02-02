//
//  CDEEventIntegrator.m
//  Test App iOS
//
//  Created by Drew McCormack on 4/23/13.
//  Copyright (c) 2013 The Mental Faculty B.V. All rights reserved.
//

#import "CDEEventIntegrator.h"
#import "CDEInsertStage.h"
#import "CDEUpdateStage.h"
#import "CDEDeleteStage.h"
#import "CDEFoundationAdditions.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "CDEEventBuilder.h"
#import "CDEPersistentStoreEnsemble.h"
#import "CDEPersistentStoreEnsemble+Private.h"
#import "NSMapTable+CDEAdditions.h"
#import "CDEEventStore.h"
#import "CDEStoreModificationEvent.h"
#import "CDEObjectChange.h"
#import "CDEGlobalIdentifier.h"
#import "CDEEventRevision.h"
#import "CDERevisionSet.h"
#import "CDERevision.h"
#import "CDEPropertyChangeValue.h"
#import "CDERevisionManager.h"


@interface CDEObjectChangeDescriptor : NSObject

@property (nonatomic) NSManagedObjectID *changeID;
@property (nonatomic) NSManagedObjectID *globalIdentifierID;

@end

@implementation CDEObjectChangeDescriptor

@end


@interface CDEEventIntegrator ()

@property (readwrite) NSManagedObjectContext *managedObjectContext;

@end

@implementation CDEEventIntegrator {
    NSDictionary *saveInfoDictionary;
    NSOperationQueue *queue;
    id eventStoreChildContextSaveObserver;
    NSString *newEventUniqueId;
    CDEEventBuilder *eventBuilder;
    BOOL saveOccurredDuringMerge;
}

@synthesize storeURL = storeURL;
@synthesize managedObjectContext = managedObjectContext;
@synthesize managedObjectModel = managedObjectModel;
@synthesize eventStore = eventStore;
@synthesize shouldSaveBlock = shouldSaveBlock;
@synthesize didSaveBlock = didSaveBlock;
@synthesize failedSaveBlock = failedSaveBlock;
@synthesize willBeginMergingEntityBlock = willBeginMergingEntityBlock;
@synthesize didFinishMergingEntityBlock = didFinishMergingEntityBlock;
@synthesize ensemble = ensemble;
@synthesize progressUnitsCompletionBlock;

#pragma mark Initialization

- (instancetype)initWithStoreURL:(NSURL *)newStoreURL managedObjectModel:(NSManagedObjectModel *)model eventStore:(CDEEventStore *)newEventStore
{
    self = [super init];
    if (self) {
        storeURL = [newStoreURL copy];
        managedObjectModel = model;
        eventStore = newEventStore;
        shouldSaveBlock = NULL;
        didSaveBlock = NULL;
        failedSaveBlock = NULL;
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        if ([queue respondsToSelector:@selector(setQualityOfService:)]) {
            [queue setQualityOfService:NSQualityOfServiceUserInitiated];
        }
    }
    return self;
}

- (void)dealloc
{
    [queue cancelAllOperations];
    [[NSNotificationCenter defaultCenter] removeObserver:eventStoreChildContextSaveObserver];
    [self stopMonitoringSaves];
}


#pragma mark Observing Saves

- (void)startMonitoringSaves
{
    [self stopMonitoringSaves];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextSaving:) name:NSManagedObjectContextWillSaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextSaving:) name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void)stopMonitoringSaves
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    saveOccurredDuringMerge = NO;
}

- (void)contextSaving:(NSNotification *)notif
{
    NSManagedObjectContext *context = notif.object;
    if (self.managedObjectContext == context) return;
    if (context.parentContext) return; // Only handle saves directly into store
    
    NSArray *stores = context.persistentStoreCoordinator.persistentStores;
    for (NSPersistentStore *store in stores) {
        NSURL *url1 = [self.storeURL URLByStandardizingPath];
        NSURL *url2 = [store.URL URLByStandardizingPath];
        if ([url1 isEqual:url2]) {
            saveOccurredDuringMerge = YES;
            break;
        }
    }
}

#pragma mark Progress

- (NSUInteger)numberOfProgressUnits
{
    return self.managedObjectModel.entities.count * 2;
}

#pragma mark Merging Store Modification Events

- (void)mergeEventsWithCompletion:(CDECompletionBlock)completion
{
    NSAssert([NSThread isMainThread], @"mergeEvents... called off main thread");
    
    newEventUniqueId = nil;
    
    // Setup a context for accessing the main store
    __block NSError *error;
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    __block NSPersistentStore *persistentStore;
    if ([coordinator respondsToSelector:@selector(performBlockAndWait:)]) {
        [coordinator performBlockAndWait:^{
            NSError *localError = nil;
            persistentStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:self.persistentStoreOptions error:&localError];
            if (!persistentStore) error = localError;
        }];
    }
    else {
        [(id)coordinator lock];
        persistentStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:self.persistentStoreOptions error:&error];
        [(id)coordinator unlock];
    }
    
    if (!persistentStore) {
        [self failWithCompletion:completion error:error];
        return;
    }
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.managedObjectContext performBlockAndWait:^{
        self.managedObjectContext.persistentStoreCoordinator = coordinator;
        self.managedObjectContext.undoManager = nil;
    }];
    
    NSManagedObjectContext *eventStoreContext = self.eventStore.managedObjectContext;
    
    // Integrate on background queue
    [queue addOperationWithBlock:^{
        @try {
            __block NSError *error;
            
            // What store modification events should be included?
            NSArray *storeModEventIDs = [self storeModificationEventIDsForIntegration:&error];
            if (!storeModEventIDs) {
                [self failWithCompletion:completion error:error];
                return;
            }
            
            // Remove any events for which prerequisites are not met
            NSSet *infoErrorCodes = nil;
            storeModEventIDs = [self integrableEventIDsFromEventIDs:storeModEventIDs informativeErrorCodes:&infoErrorCodes];
            if (infoErrorCodes) {
                self.ensemble.nonCriticalErrorCodes = infoErrorCodes;
            }
            
            // Do we actually need to integrate the events?
            BOOL integrationNeeded = [self integrationIsNeededForEventIDs:storeModEventIDs];
            if (!integrationNeeded) {
                if (self.progressUnitsCompletionBlock) self.progressUnitsCompletionBlock(self.numberOfProgressUnits);
                [self completeSuccessfullyWithCompletion:completion];
                return;
            }
            
            // Create id for new merge event. Register event in case of crashes
            newEventUniqueId = [[NSProcessInfo processInfo] globallyUniqueString];
            
            // Create a merge event
            eventBuilder = [[CDEEventBuilder alloc] initWithEventStore:self.eventStore];
            eventBuilder.ensemble = self.ensemble;
            CDERevision *revision = [eventBuilder makeNewEventOfType:CDEStoreModificationEventTypeMerge uniqueIdentifier:newEventUniqueId];
            [eventBuilder updateEventRevisionsAccountingForMergeOfEventIDs:storeModEventIDs];
            
            // Integrate
            BOOL success = [self integrateEventIDs:storeModEventIDs error:&error];
            if (!success) {
                [self failWithCompletion:completion error:error];
                return;
            }
            
            // Save changes event context
            __block BOOL eventSaveSucceeded = NO;
            [eventStoreContext performBlockAndWait:^{
                // Check uniqueness
                BOOL isUnique = [self checkUniquenessOfEventWithRevision:revision];
                if (isUnique && !saveOccurredDuringMerge) {
                    [eventBuilder finalizeNewEvent];
                    NSError *saveError = nil;
                    eventSaveSucceeded = [eventStoreContext save:&saveError];
                    error = saveError;
                    [eventStoreContext reset];
                }
                else {
                    error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeSaveOccurredDuringMerge userInfo:nil];
                }
            }];
            if (!eventSaveSucceeded) {
                [self failWithCompletion:completion error:error];
                return;
            }
            
            // Complete
            [self completeSuccessfullyWithCompletion:completion];
        }
        @catch (NSException *exception) {
            NSDictionary *info = @{NSLocalizedFailureReasonErrorKey:exception.reason};
            NSError *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeUnknown userInfo:info];
            [self failWithCompletion:completion error:error];
        }
    }];
}

- (BOOL)checkUniquenessOfEventWithRevision:(CDERevision *)revision
{
    __block NSUInteger count = 0;
    [self.eventStore.managedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"CDEStoreModificationEvent"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"eventRevision.persistentStoreIdentifier = %@ && eventRevision.revisionNumber = %lld && type != %d", self.eventStore.persistentStoreIdentifier, revision.revisionNumber, CDEStoreModificationEventTypeBaseline];
        NSError *error = nil;
        count = [self.eventStore.managedObjectContext countForFetchRequest:fetch error:&error];
        if (count == NSNotFound) CDELog(CDELoggingLevelError, @"Could not get count of revisions: %@", error);
    }];
    return count == 1;
}


#pragma mark Completing Merge

- (void)failWithCompletion:(CDECompletionBlock)completion error:(NSError *)error
{
    NSManagedObjectContext *eventContext = self.eventStore.managedObjectContext;
    if (newEventUniqueId) {
        [eventContext performBlockAndWait:^{
            CDEStoreModificationEvent *event = [CDEStoreModificationEvent fetchStoreModificationEventWithUniqueIdentifier:newEventUniqueId inManagedObjectContext:eventContext];
            if (event) {
                NSError *error = nil;
                [eventContext deleteObject:event];
                if (![eventContext save:&error]) {
                    CDELog(CDELoggingLevelError, @"Could not save after deleting partially merged event from a failed merge. Will reset context: %@", error);
                }
                [eventContext reset];
            }
        }];
    }
    newEventUniqueId = nil;
    eventBuilder = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) completion(error);
    });
}

- (void)completeSuccessfullyWithCompletion:(CDECompletionBlock)completion
{
    newEventUniqueId = nil;
    eventBuilder = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) completion(nil);
    });
}


#pragma mark Preparing For Integration

- (BOOL)needsFullIntegration
{
    // Determine if we need to do a full integration of all data.
    // First case is if the baseline identity has changed.
    NSString *storeBaselineId = self.eventStore.identifierOfBaselineUsedToConstructStore;
    NSString *currentBaselineId = self.eventStore.currentBaselineIdentifier;
    if (!storeBaselineId || ![storeBaselineId isEqualToString:currentBaselineId]) return YES;
    
    // Determine if a full integration is needed due to abandonment during rebasing
    // This is the case if no merge event exists that comes fully after the baseline.
    CDERevisionManager *revisionManager = [[CDERevisionManager alloc] initWithEventStore:self.eventStore];
    NSError *error = nil;
    BOOL passed = [revisionManager checkThatLocalPersistentStoreHasNotBeenAbandoned:&error];
    if (error) CDELog(CDELoggingLevelError, @"Error determining if store is abandoned: %@", error);
    if (!passed) return YES;
    
    return NO;
}

- (NSArray *)storeModificationEventIDsForIntegration:(NSError * __autoreleasing *)error
{
    CDELog(CDELoggingLevelTrace, @"Determining events to include in integration");

    CDERevisionManager *revisionManager = [[CDERevisionManager alloc] initWithEventStore:self.eventStore];
    revisionManager.managedObjectModelURL = self.ensemble.managedObjectModelURL;
    
    NSManagedObjectContext *eventStoreContext = self.eventStore.managedObjectContext;
    BOOL fullIntegration = [self needsFullIntegration];
    __block NSArray *storeModEventIDs = nil;
    __block NSError *localError = nil;
    [eventStoreContext performBlockAndWait:^{
        NSArray *storeModEvents = nil;
        NSError *blockError = nil;
        
        // Get events
        if (fullIntegration) {
            // All events, including baseline
            NSMutableArray *events = [[CDEStoreModificationEvent fetchNonBaselineEventsInManagedObjectContext:eventStoreContext] mutableCopy];
            CDEStoreModificationEvent *baseline = [CDEStoreModificationEvent fetchBaselineEventInManagedObjectContext:eventStoreContext];
            if (baseline) [events insertObject:baseline atIndex:0];
            storeModEvents = events;
            CDELog(CDELoggingLevelTrace, @"Baseline has changed. Will carry out full integration of the persistent store.");
        }
        else {
            // Get all modification events added since the last merge
            storeModEvents = [revisionManager fetchUncommittedStoreModificationEvents:&blockError];
            localError = blockError;
            if (storeModEvents.count == 0) return;
            
            // Add any modification events concurrent with the new events. Results are ordered.
            // We repeat this until there is no change in the set. This will be when there are
            // no events existing outside the set that are concurrent with the events in the set.
            storeModEvents = [revisionManager recursivelyFetchStoreModificationEventsConcurrentWithEvents:storeModEvents error:&blockError];
            localError = blockError;
            
            // If all events are local, no integration is needed.
            // This is a fast path, to avoid the expensive analysis of events later.
            NSArray *storeIdentifiers = [storeModEvents valueForKeyPath:@"@distinctUnionOfObjects.eventRevision.persistentStoreIdentifier"];
            if (storeIdentifiers.count == 1 && [storeIdentifiers.lastObject isEqualToString:eventStore.persistentStoreIdentifier]) {
                CDELog(CDELoggingLevelVerbose, @"All events are local. Won't integrate.");
                storeModEvents = @[];
            }
        }
        
        storeModEventIDs = [storeModEvents valueForKeyPath:@"objectID"];
        CDELog(CDELoggingLevelVerbose, @"Including these events in the integration: %@", storeModEvents);
    }];
    
    if (error) *error = localError;
    
    return storeModEventIDs;
}

- (NSArray *)integrableEventIDsFromEventIDs:(NSArray *)storeModEventIDs informativeErrorCodes:(NSSet * __autoreleasing *)errorCodes
{
    CDELog(CDELoggingLevelTrace, @"Checking which events can be integrated");
    
    CDERevisionManager *revisionManager = [[CDERevisionManager alloc] initWithEventStore:self.eventStore];
    revisionManager.managedObjectModelURL = self.ensemble.managedObjectModelURL;
    
    __block NSArray *integrableIDs = nil;
    __block NSSet *localErrorCodes = nil;
    if (errorCodes) *errorCodes = nil;

    NSManagedObjectContext *eventStoreContext = self.eventStore.managedObjectContext;
    [eventStoreContext performBlockAndWait:^{
        NSArray *storeModEvents = [storeModEventIDs cde_arrayByTransformingObjectsWithBlock:^(NSManagedObjectID *objectID) {
            return [eventStoreContext objectWithID:objectID];
        }];
        
        NSSet *blockErrorCodes = nil;
        NSArray *integrableEvents = [revisionManager integrableEventsFromEvents:storeModEvents informativeErrorCodes:&blockErrorCodes];
        localErrorCodes = blockErrorCodes;
        
        integrableIDs = [integrableEvents cde_arrayByTransformingObjectsWithBlock:^(CDEStoreModificationEvent *event) {
            return event.objectID;
        }];
    }];

    if (errorCodes) *errorCodes = localErrorCodes;
    
    return integrableIDs;
}

- (BOOL)integrationIsNeededForEventIDs:(NSArray *)storeModEventIDs
{
    CDELog(CDELoggingLevelTrace, @"Checking if ready for integration");
    
    BOOL fullIntegration = [self needsFullIntegration];
    if (fullIntegration) return YES;
    
    __block BOOL integrationNeeded = YES;
    NSManagedObjectContext *eventStoreContext = self.eventStore.managedObjectContext;
    [eventStoreContext performBlockAndWait:^{
        NSArray *storeModEvents = [storeModEventIDs cde_arrayByTransformingObjectsWithBlock:^id(NSManagedObjectID *objectID) {
            return [eventStoreContext objectWithID:objectID];
        }];
        
        // If all events are from this device, don't merge
        NSArray *storeIds = [storeModEvents valueForKeyPath:@"@distinctUnionOfObjects.eventRevision.persistentStoreIdentifier"];
        if (storeIds.count == 1 && [storeIds.lastObject isEqualToString:self.eventStore.persistentStoreIdentifier]) {
            integrationNeeded = NO;
            return;
        }
        
        // If there are no object changes, don't merge
        NSUInteger numberOfChanges = [CDEObjectChange countOfObjectChangesInStoreModificationEvents:storeModEvents];
        if (numberOfChanges == 0) {
            integrationNeeded = NO;
            return;
        }
    }];
    
    return integrationNeeded;
}


#pragma mark Integrating

- (BOOL)integrateEventIDs:(NSArray *)storeModEventIDs error:(NSError * __autoreleasing *)error
{
    BOOL fullIntegration = [self needsFullIntegration];
    CDELog(CDELoggingLevelTrace, @"Beginning integration");
    if (fullIntegration) CDELog(CDELoggingLevelTrace, @"Will perform full integration");

    // Iterate entities in order
    NSArray *entities = [managedObjectModel cde_entitiesOrderedByMigrationPriority];
    NSArray *migratedEntities = @[];
    __block NSError *localError = nil;
    for (NSEntityDescription *entity in entities) {
        CDELog(CDELoggingLevelVerbose, @"Integrating entity: %@", entity.name);
        
        if (willBeginMergingEntityBlock) willBeginMergingEntityBlock(entity);
        
        NSUInteger batchSize = entity.cde_migrationBatchSize;
        NSMutableSet *allInsertedObjectIDs = fullIntegration ? [NSMutableSet set] : nil;
        NSArray *currentAndMigratedEntities = [migratedEntities arrayByAddingObject:entity];
        NSArray *relationshipsToMigratedEntities = [entity cde_nonRedundantRelationshipsDestinedForEntities:migratedEntities];

        // Fetch objectIDs for all global identifiers in the events
        NSArray *globalIdentifierIDs = [self fetchGlobalIdentifierIDsForEventIDs:storeModEventIDs entity:entity error:&localError];
        if (!globalIdentifierIDs) {
            if (error) *error = localError;
            return NO;
        }
            
        // Iterate over global ids in batches
        NSUInteger b = batchSize ? : MAX(1, globalIdentifierIDs.count);
        __block BOOL success = YES;
        [globalIdentifierIDs cde_enumerateObjectsInBatchesWithBatchSize:b usingBlock:^(NSArray *batchGlobalIdentifierIDs, NSUInteger batchesRemaining, BOOL *stop) {
            CDELog(CDELoggingLevelVerbose, @"Number of objects remaining to integrate for this entity: %lu", (unsigned long)batchesRemaining * batchSize);
            
            // Fetch the object change ids grouped by event id
            NSError *blockError = nil;
            NSMutableDictionary *changeDescsByTypeByEventID = [self fetchObjectChangeDescriptorsForGlobalIdentifierIDs:batchGlobalIdentifierIDs entity:entity groupedByTypeAndEventIDs:storeModEventIDs error:&blockError];
            if (!changeDescsByTypeByEventID) {
                localError = blockError;
                success = NO;
                *stop = YES;
                return;
            }
            
            // Remove redundant object changes
            [self removeRedundantChangesFromChangeDescriptorsByTypeByEventID:changeDescsByTypeByEventID forOrderedEventIDs:storeModEventIDs];
            
            // Insert and update objects in all events
            for (NSManagedObjectID *eventID in storeModEventIDs) {
                
                // Insert and update objects
                // Use batch size 0 here, because we are batching over global identifiers, not change ids
                NSArray *insertChangeDescs = changeDescsByTypeByEventID[eventID][@(CDEObjectChangeTypeInsert)];
                NSSet *insertedObjectIDs = nil;
                if (insertChangeDescs.count > 0) {
                    NSArray *insertChangeIDs = [insertChangeDescs valueForKeyPath:@"changeID"];
                    success = [self insertAndUpdateObjectsForInsertChangeIDs:insertChangeIDs relationships:relationshipsToMigratedEntities batchSize:0 migratedEntities:migratedEntities objectIDsForInserts:&insertedObjectIDs error:&blockError];
                }
                if (!success) {
                    localError = blockError;
                    *stop = YES;
                    return;
                }
                if (insertedObjectIDs) [allInsertedObjectIDs unionSet:insertedObjectIDs];
                
                // Updates
                NSArray *updateChangeDescs = changeDescsByTypeByEventID[eventID][@(CDEObjectChangeTypeUpdate)];
                if (updateChangeDescs.count > 0) {
                    NSArray *updateChangeIDs = [updateChangeDescs valueForKeyPath:@"changeID"];
                    success = [self updateObjectsForUpdateChangeIDs:updateChangeIDs relationships:relationshipsToMigratedEntities batchSize:0 error:&blockError];
                }
                if (!success) {
                    localError = blockError;
                    *stop = YES;
                    return;
                }
                
                // Deletes
                NSArray *deleteChangeDescs = changeDescsByTypeByEventID[eventID][@(CDEObjectChangeTypeDelete)];
                if (deleteChangeDescs.count > 0) {
                    NSArray *deleteChangeIDs = [deleteChangeDescs valueForKeyPath:@"changeID"];
                    success = [self deleteObjectsForChangeIDs:deleteChangeIDs batchSize:0 error:&blockError];
                }
                if (!success) {
                    localError = blockError;
                    *stop = YES;
                    return;
                }
            }
            
            if (![self saveAndResetBatchForEntity:entity error:&blockError]) {
                localError = blockError;
                success = NO;
                *stop = YES;
                return;
            }
        }];
        if (!success) {
            if (error) *error = localError;
            return NO;
        }
        
        if (self.progressUnitsCompletionBlock) self.progressUnitsCompletionBlock(1);
        
        // Connect any relationships from the migrated entities to the new entity.
        // Include self-referential relationships, and relationships that go to an ancestor of the
        // new entity.
        for (NSEntityDescription *migratedEntity in currentAndMigratedEntities) {
            NSUInteger migratedEntityBatchSize = migratedEntity.cde_migrationBatchSize;

            NSArray *entityAndAncestors = [@[entity] arrayByAddingObjectsFromArray:entity.cde_ancestorEntities];
            NSArray *relationshipsFromMigratedEntity = [migratedEntity cde_nonRedundantRelationshipsDestinedForEntities:entityAndAncestors];
            if (relationshipsFromMigratedEntity.count == 0) continue;

            for (NSManagedObjectID *eventID in storeModEventIDs) {
                NSArray *migratedInsertIDs = [self fetchObjectChangeIDsOfType:CDEObjectChangeTypeInsert fromStoreModificationEventID:eventID forEntity:migratedEntity error:&localError];
                if (!migratedInsertIDs) {
                    if (error) *error = localError;
                    return NO;
                }

                NSArray *migratedUpdateIDs = [self fetchObjectChangeIDsOfType:CDEObjectChangeTypeUpdate fromStoreModificationEventID:eventID forEntity:migratedEntity error:&localError];
                if (!migratedUpdateIDs) {
                    if (error) *error = localError;
                    return NO;
                }

                NSArray *allUpdatedIDs = [migratedInsertIDs arrayByAddingObjectsFromArray:migratedUpdateIDs];
                
                BOOL success = [self updateRelationships:relationshipsFromMigratedEntity changeIDs:allUpdatedIDs batchSize:migratedEntityBatchSize error:&localError];
                if (!success) {
                    if (error) *error = localError;
                    return NO;
                }
            }
            
            if (![self saveAndResetBatchForEntity:migratedEntity error:&localError]) {
                if (error) *error = localError;
                return NO;
            }
        }
    
        // For a full integration, remove any unreferenced objects
        if (fullIntegration) {
            success = [self deleteUnreferencedObjectsOfEntity:entity insertedObjectIDs:allInsertedObjectIDs error:&localError];
            if (!success) {
                if (error) *error = localError;
                return NO;
            }
        }
        
        migratedEntities = currentAndMigratedEntities;
        
        if (didFinishMergingEntityBlock) didFinishMergingEntityBlock(entity);
    
        if (self.progressUnitsCompletionBlock) self.progressUnitsCompletionBlock(1);
    }
    
    BOOL success = [self saveAndResetManagedObjectContext:&localError];
    if (!success) {
        if (error) *error = localError;
        return NO;
    }
    
    success = [eventBuilder saveAndReset:&localError];
    if (!success) {
        if (error) *error = localError;
        return NO;
    }
    
    success = [eventBuilder checkUniquenessOfGlobalIdentifiers:&localError];
    if (!success) {
        if (error) *error = localError;
        return NO;
    }
    
    return YES;
}

- (void)removeRedundantChangesFromChangeDescriptorsByTypeByEventID:(NSMutableDictionary *)descsByTypeByEventID forOrderedEventIDs:(NSArray *)eventIDs
{
    // Just remove inserts and updates that preceed a deletion on the same object
    NSMutableSet *deletedObjectGlobalIDs = [[NSMutableSet alloc] init];
    for (NSManagedObjectID *eventID in eventIDs.reverseObjectEnumerator) {
        NSDictionary *descsByType = descsByTypeByEventID[eventID];
        NSMutableDictionary *newDescsByType = [descsByType mutableCopy];
        
        NSArray *deleted = descsByType[@(CDEObjectChangeTypeDelete)];
        NSArray *deletedGlobalIDs = [deleted valueForKeyPath:@"globalIdentifierID"];
        [deletedObjectGlobalIDs addObjectsFromArray:deletedGlobalIDs];
        
        NSArray *inserted = descsByType[@(CDEObjectChangeTypeInsert)];
        NSMutableSet *insertedGlobalIDsSet = [[NSMutableSet alloc] initWithArray:[inserted valueForKeyPath:@"globalIdentifierID"]];
        [insertedGlobalIDsSet minusSet:deletedObjectGlobalIDs];
        if (inserted.count != insertedGlobalIDsSet.count) {
            NSArray *newInserted = [inserted filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CDEObjectChangeDescriptor *desc, NSDictionary *bindings) {
                return [insertedGlobalIDsSet containsObject:desc.globalIdentifierID];
            }]];
            newDescsByType[@(CDEObjectChangeTypeInsert)] = newInserted;
        }
        
        NSArray *updated = descsByType[@(CDEObjectChangeTypeUpdate)];
        NSMutableSet *updatedGlobalIDsSet = [[NSMutableSet alloc] initWithArray:[updated valueForKeyPath:@"globalIdentifierID"]];
        [updatedGlobalIDsSet minusSet:deletedObjectGlobalIDs];
        if (updated.count != updatedGlobalIDsSet.count) {
            NSArray *newUpdated = [updated filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CDEObjectChangeDescriptor *desc, NSDictionary *bindings) {
                return [updatedGlobalIDsSet containsObject:desc.globalIdentifierID];
            }]];
            newDescsByType[@(CDEObjectChangeTypeUpdate)] = newUpdated;
        }
        
        if (newDescsByType) descsByTypeByEventID[eventID] = newDescsByType;
    }
}


#pragma mark Saving the Context

- (BOOL)saveAndResetBatchForEntity:(NSEntityDescription *)entity error:(NSError * __autoreleasing *)error
{
    BOOL success = YES;
    
    if (entity.cde_migrationBatchSize > 0) {
        success = [self saveAndResetManagedObjectContext:error];
        if (!success) return NO;
    }
    
    success = [eventBuilder saveAndReset:error];
    if (!success) return NO;
    
    return YES;
}

- (BOOL)saveAndResetManagedObjectContext:(NSError * __autoreleasing *)error
{
    // Don't save if there are no changes
    __block BOOL contextHasChanges;
    [managedObjectContext performBlockAndWait:^{
        contextHasChanges = managedObjectContext.hasChanges;
    }];
    if (!contextHasChanges) return YES;
    
    // Repair inconsistencies caused by integration
    NSError *localError = nil;
    BOOL repairSucceeded = [self repair:&localError];
    if (error) *error = localError;
    if (!repairSucceeded) return NO;

    // Commit (save) the changes
    BOOL commitSucceeded = [self commit:&localError];
    if (error) *error = localError;
    if (!commitSucceeded) return NO;
    
    // Notify of save
    [managedObjectContext performBlockAndWait:^{
        if (didSaveBlock) didSaveBlock(managedObjectContext, saveInfoDictionary);
        saveInfoDictionary = nil;
        [managedObjectContext reset];
    }];
    
    return YES;
}

- (void)processPendingChangesInManagedObjectContext {
    [managedObjectContext performBlockAndWait:^{
        [managedObjectContext processPendingChanges];
    }];
}

// Called on background queue
- (BOOL)commit:(NSError * __autoreleasing *)error
{
    CDELog(CDELoggingLevelTrace, @"Committing merge changes to store");
    
    __block NSError *localError = nil;
    __block BOOL saved = [self saveContext:&localError];
    if (!saved && !saveOccurredDuringMerge) {
        if (localError.code != NSManagedObjectMergeError && failedSaveBlock) {
            // Setup a child reparation context
            NSManagedObjectContext *reparationContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            reparationContext.parentContext = managedObjectContext;
            
            // Inform of failure, and give chance to repair
            BOOL retry = failedSaveBlock(managedObjectContext, localError, reparationContext);
            
            // If repairs were carried out, add changes to the merge event, and save
            // reparation context
            __block BOOL needExtraSave = NO;
            [reparationContext performBlockAndWait:^{
                if (retry && reparationContext.hasChanges) {
                    NSError *blockError = nil;
                    BOOL success = [eventBuilder addChangesForUnsavedManagedObjectContext:reparationContext error:&blockError];
                    success = success && [reparationContext save:&blockError];
                    localError = blockError;
                    if (success) needExtraSave = YES;
                }
            }];
            
            // Retry save if necessary
            if (needExtraSave) saved = [self saveContext:&localError];
        }
    }
    
    if (error) *error = localError;
    return saved;
}

// Called on background queue
- (BOOL)repair:(NSError * __autoreleasing *)error
{
    CDELog(CDELoggingLevelTrace, @"Repairing context after integrating changes");
    
    // Give opportunity to merge/repair changes in a child context.
    // We can then retrieve the changes and generate a new store mod event to represent the merge.
    __block BOOL merged = YES;
    __block BOOL contextHasChanges = NO;
    __block NSError *localError = nil;
    
    [managedObjectContext performBlockAndWait:^{
        contextHasChanges = managedObjectContext.hasChanges;
    }];
    
    if (contextHasChanges && shouldSaveBlock) {
        // Setup a context to store repairs
        NSManagedObjectContext *reparationContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [reparationContext performBlockAndWait:^{
            reparationContext.parentContext = managedObjectContext;
        }];
        
        // Call block
        BOOL shouldSave = shouldSaveBlock(managedObjectContext, reparationContext);
        if (!shouldSave) {
            if (error) *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeCancelled userInfo:nil];
            return NO;
        }
        
        // Capture changes in the reparation context in the merge event.
        // Save any changes made in the reparation context.
        [reparationContext performBlockAndWait:^{
            if (reparationContext.hasChanges) {
                NSError *blockError = nil;
                BOOL success = [eventBuilder addChangesForUnsavedManagedObjectContext:reparationContext error:&blockError];
                if (!success) {
                    localError = blockError;
                    merged = NO;
                    return;
                }
                
                merged = [reparationContext save:&blockError];
                if (!merged) {
                    localError = blockError;
                    CDELog(CDELoggingLevelError, @"Saving merge context after willSave changes failed: %@", blockError);
                    return;
                }
            }
        }];
    }
    
    if (error) *error = localError;
    
    return merged;
}

// Call from any queue
- (BOOL)saveContext:(NSError * __autoreleasing *)error
{
    __block BOOL saved = NO;
    __block NSError *localError;
    [managedObjectContext performBlockAndWait:^{
        NSError *blockError;
        if (saveOccurredDuringMerge) {
            blockError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeSaveOccurredDuringMerge userInfo:nil];
            localError = blockError;
            return;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChangesFromContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
        saved = [managedObjectContext save:&blockError];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
        
        if (!saved) {
            localError = blockError;
        }
    }];
    
    if (!saved && error) {
        *error = localError;
    }
    
    return saved;
}

- (void)storeChangesFromContextDidSaveNotification:(NSNotification *)notif
{
    saveInfoDictionary = notif.userInfo;
}


#pragma mark Integration Stages

- (BOOL)applyBatchesInStages:(NSArray *)stages batchSize:(NSUInteger)batchSize error:(NSError * __autoreleasing *)error
{
    NSError *localError = nil;
    BOOL hasMore = YES;
    BOOL success = YES;
    
    do {
        @autoreleasepool {
            NSError *poolError = nil;
            
            for (CDEIntegrationStage *stage in stages) {
                success = [stage applyNextBatchOfChanges:&poolError];
            }
            
            if (batchSize > 0) {
                if (success && ![eventBuilder saveAndReset:&poolError]) {
                    success = NO;
                }
                    
                if (success && ![self saveAndResetManagedObjectContext:&poolError]) {
                    success = NO;
                }
            }
            
            hasMore = [stages.lastObject numberOfBatchesRemaining] > 0;
            localError = poolError;
        }
    } while (hasMore && success);
    if (error) *error = localError;

    return success;
}

- (BOOL)insertAndUpdateObjectsForInsertChangeIDs:(NSArray *)insertChangeIDs relationships:(NSArray *)relationships batchSize:(NSUInteger)batchSize migratedEntities:(NSArray *)migratedEntities objectIDsForInserts:(NSSet * __autoreleasing *)insertedIDs error:(NSError * __autoreleasing *)error
{
    NSSet *localInsertedIDs = nil;
    NSError *localError = nil;
    BOOL success = YES;
    
    @autoreleasepool {
        CDEInsertStage *inserter = [[CDEInsertStage alloc] initWithEventBuilder:eventBuilder objectChangeIDs:insertChangeIDs managedObjectContext:managedObjectContext batchSize:batchSize];
        
        CDEUpdateStage *insertedObjectUpdater = [[CDEUpdateStage alloc] initWithEventBuilder:eventBuilder objectChangeIDs:insertChangeIDs managedObjectContext:managedObjectContext batchSize:batchSize];
        insertedObjectUpdater.relationshipsToUpdate = relationships;
        insertedObjectUpdater.updatesAttributes = YES;
        
        NSError *blockError = nil;
        success = [self applyBatchesInStages:@[inserter, insertedObjectUpdater] batchSize:batchSize error:&blockError];
        localError = blockError;
        
        if (success) {
            localInsertedIDs = [inserter.insertedObjectIDs copy];
            if (!localInsertedIDs) localInsertedIDs = [[NSSet alloc] init];
        }
    }
    
    *insertedIDs = localInsertedIDs;
    if (!success && error) *error = localError;
    return success;
}

- (BOOL)updateObjectsForUpdateChangeIDs:(NSArray *)updateChangeIDs relationships:(NSArray *)relationships batchSize:(NSUInteger)batchSize error:(NSError * __autoreleasing *)error
{
    NSError *localError = nil;
    BOOL success;
    
    @autoreleasepool {
        NSError *blockError = nil;
        CDEUpdateStage *updater = [[CDEUpdateStage alloc] initWithEventBuilder:eventBuilder objectChangeIDs:updateChangeIDs managedObjectContext:managedObjectContext batchSize:batchSize];
        updater.relationshipsToUpdate = relationships;
        updater.updatesAttributes = YES;
        success = [self applyBatchesInStages:@[updater] batchSize:batchSize error:&blockError];
        localError = blockError;
    }
    
    if (!success && error) *error = localError;
    return success;
}

- (BOOL)updateRelationships:(NSArray *)relationships changeIDs:(NSArray *)changeIDs batchSize:(NSUInteger)batchSize error:(NSError * __autoreleasing *)error
{
    NSError *localError = nil;
    BOOL success;
    
    @autoreleasepool {
        NSError *blockError = nil;
        CDEUpdateStage *relationshipUpdater = [[CDEUpdateStage alloc]  initWithEventBuilder:eventBuilder objectChangeIDs:changeIDs managedObjectContext:managedObjectContext batchSize:batchSize];
        relationshipUpdater.updatesAttributes = NO;
        relationshipUpdater.relationshipsToUpdate = relationships;
        success = [self applyBatchesInStages:@[relationshipUpdater] batchSize:batchSize error:&blockError];
        localError = blockError;
    }
    
    if (!success && error) *error = localError;
    return success;
}

- (BOOL)deleteObjectsForChangeIDs:(NSArray *)deleteChangeIDs batchSize:(NSUInteger)batchSize error:(NSError * __autoreleasing *)error
{
    NSError *localError = nil;
    BOOL success = YES;
    
    @autoreleasepool {
        NSError *blockError = nil;
        CDEDeleteStage *deleter = [[CDEDeleteStage alloc] initWithEventBuilder:eventBuilder objectChangeIDs:deleteChangeIDs managedObjectContext:managedObjectContext batchSize:batchSize];
        success = [self applyBatchesInStages:@[deleter] batchSize:batchSize error:&blockError];
        localError = blockError;
    }
    
    if (!success && error) *error = localError;
    return success;
}

- (BOOL)deleteUnreferencedObjectsOfEntity:(NSEntityDescription *)entity insertedObjectIDs:(NSSet *)insertedObjectIDs error:(NSError * __autoreleasing *)error
{
    __block BOOL success = YES;
    __block NSError *localError = nil;
    [managedObjectContext performBlockAndWait:^{
        NSError *blockError = nil;

        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:entity.name];
        fetch.includesSubentities = NO;
        fetch.predicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", insertedObjectIDs];
        NSArray *unreferencedObjects = [managedObjectContext executeFetchRequest:fetch error:&blockError];
        success = (unreferencedObjects != nil);
        localError = blockError;
        if (!success) return;
        
        for (NSManagedObject *object in unreferencedObjects) {
            @try {
                [CDEDeleteStage nullifyRelationshipsAndDeleteObject:object];
            }
            @catch ( NSException *exception ) {
                CDELog(CDELoggingLevelError, @"Exception thrown while nullifying relationships: %@", exception);
            }
        }
    }];
    
    if (!success && error) *error = localError;
    return success;
}


#pragma mark Fetching 

- (NSDictionary *)fetchObjectChangeIDsOfType:(CDEObjectChangeType)type forGlobalIdentifierIDs:(NSArray *)globalIdentifierIDs entity:(NSEntityDescription *)entity groupedByEventIDs:(NSArray *)eventIDs error:(NSError * __autoreleasing *)error
{
    __block NSArray *fetchResult = nil;
    __block NSError *localError = nil;
    [self.eventStore.managedObjectContext performBlockAndWait:^{
        NSError *blockError = nil;
        
        NSExpressionDescription *objectIDDesc = [[NSExpressionDescription alloc] init];
        objectIDDesc.name = @"objectID";
        objectIDDesc.expression = [NSExpression expressionForEvaluatedObject];
        objectIDDesc.expressionResultType = NSObjectIDAttributeType;
        
        NSExpressionDescription *storeEventIDDesc = [[NSExpressionDescription alloc] init];
        storeEventIDDesc.name = @"storeEventID";
        storeEventIDDesc.expression = [NSExpression expressionForKeyPath:@"storeModificationEvent"];
        storeEventIDDesc.expressionResultType = NSObjectIDAttributeType;
        
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"nameOfEntity = %@ && type = %d && storeModificationEvent IN %@ && globalIdentifier IN %@", entity.name, type, eventIDs, globalIdentifierIDs];
        fetch.sortDescriptors = [CDEObjectChange sortDescriptorsForEventOrder];
        fetch.propertiesToFetch = @[objectIDDesc, storeEventIDDesc];
        fetch.resultType = NSDictionaryResultType;
        fetchResult = [self.eventStore.managedObjectContext executeFetchRequest:fetch error:&blockError];
        
        localError = blockError;
    }];
    
    if (!fetchResult) {
        if (error) *error = localError;
        return nil;
    }
    
    // Group results with store event id as the key
    NSMutableDictionary *objectIDsByEventID = [NSMutableDictionary dictionary];
    for (NSDictionary *d in fetchResult) {
        NSManagedObjectID *eventID = d[@"storeEventID"];
        NSMutableArray *changes = objectIDsByEventID[eventID];
        if (!changes) {
            changes = [NSMutableArray array];
            objectIDsByEventID[eventID] = changes;
        }
        [changes addObject:d[@"objectID"]];
    }
    
    return objectIDsByEventID;
}

- (NSMutableDictionary *)fetchObjectChangeDescriptorsForGlobalIdentifierIDs:(NSArray *)globalIdentifierIDs entity:(NSEntityDescription *)entity groupedByTypeAndEventIDs:(NSArray *)eventIDs error:(NSError * __autoreleasing *)error
{
    __block NSArray *fetchResult = nil;
    __block NSError *localError = nil;
    [self.eventStore.managedObjectContext performBlockAndWait:^{
        NSError *blockError = nil;
        
        NSExpressionDescription *objectIDDesc = [[NSExpressionDescription alloc] init];
        objectIDDesc.name = @"objectID";
        objectIDDesc.expression = [NSExpression expressionForEvaluatedObject];
        objectIDDesc.expressionResultType = NSObjectIDAttributeType;
        
        NSExpressionDescription *storeEventIDDesc = [[NSExpressionDescription alloc] init];
        storeEventIDDesc.name = @"storeEventID";
        storeEventIDDesc.expression = [NSExpression expressionForKeyPath:@"storeModificationEvent"];
        storeEventIDDesc.expressionResultType = NSObjectIDAttributeType;
        
        NSExpressionDescription *typeDesc = [[NSExpressionDescription alloc] init];
        typeDesc.name = @"type";
        typeDesc.expression = [NSExpression expressionForKeyPath:@"type"];
        typeDesc.expressionResultType = NSInteger16AttributeType;
        
        NSExpressionDescription *globalIDDesc = [[NSExpressionDescription alloc] init];
        globalIDDesc.name = @"globalIdentifier";
        globalIDDesc.expression = [NSExpression expressionForKeyPath:@"globalIdentifier"];
        globalIDDesc.expressionResultType = NSObjectIDAttributeType;
        
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"nameOfEntity = %@ && storeModificationEvent IN %@ && globalIdentifier IN %@", entity.name, eventIDs, globalIdentifierIDs];
        fetch.sortDescriptors = [CDEObjectChange sortDescriptorsForEventOrder];
        fetch.propertiesToFetch = @[objectIDDesc, storeEventIDDesc, typeDesc, globalIDDesc];
        fetch.resultType = NSDictionaryResultType;
        fetchResult = [self.eventStore.managedObjectContext executeFetchRequest:fetch error:&blockError];
        
        localError = blockError;
    }];
    
    if (!fetchResult) {
        if (error) *error = localError;
        return nil;
    }
    
    // Group results with store event id as the key
    NSMutableDictionary *objectIDsByTypeByEventID = [NSMutableDictionary dictionary];
    for (NSDictionary *d in fetchResult) {
        NSManagedObjectID *eventID = d[@"storeEventID"];
        NSDictionary *changesByType = objectIDsByTypeByEventID[eventID];
        if (!changesByType) {
            changesByType = @{@(CDEObjectChangeTypeDelete):[NSMutableArray array], @(CDEObjectChangeTypeInsert):[NSMutableArray array], @(CDEObjectChangeTypeUpdate):[NSMutableArray array]};
            objectIDsByTypeByEventID[eventID] = changesByType;
        }
        NSMutableArray *changes = changesByType[d[@"type"]];
        
        CDEObjectChangeDescriptor *desc = [[CDEObjectChangeDescriptor alloc] init];
        desc.globalIdentifierID = d[@"globalIdentifier"];
        desc.changeID = d[@"objectID"];
        [changes addObject:desc];
    }
    
    return objectIDsByTypeByEventID;
}

- (NSArray *)fetchObjectChangeIDsOfType:(CDEObjectChangeType)type forGlobalIdentifierIDs:(NSArray *)globalIdentifierIDs entity:(NSEntityDescription *)entity inEventsWithIDs:(NSArray *)eventIDs error:(NSError * __autoreleasing *)error
{
    __block NSArray *result = nil;
    __block NSError *localError = nil;
    [self.eventStore.managedObjectContext performBlockAndWait:^{
        NSError *blockError = nil;
        
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"nameOfEntity = %@ && type = %d && storeModificationEvent IN %@ && globalIdentifier IN %@", entity.name, type, eventIDs, globalIdentifierIDs];
        fetch.sortDescriptors = [CDEObjectChange sortDescriptorsForEventOrder];
        fetch.resultType = NSManagedObjectIDResultType;
        result = [self.eventStore.managedObjectContext executeFetchRequest:fetch error:&blockError];
        
        localError = blockError;
    }];
    
    if (!result && error) *error = localError;
    return result;
}

- (NSArray *)fetchGlobalIdentifierIDsForEventIDs:(NSArray *)storeModEventIDs entity:(NSEntityDescription *)entity error:(NSError * __autoreleasing *)error
{
    if (storeModEventIDs.count == 0) return @[];
    
    __block NSArray *result = nil;
    __block NSError *localError = nil;
    [self.eventStore.managedObjectContext performBlockAndWait:^{
        NSError *blockError = nil;
        NSArray *objectIDs = [self fetchObjectChangeIDsFromStoreModificationEventIDs:storeModEventIDs forEntity:entity error:&blockError];
        
        // Fetch
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEGlobalIdentifier"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"ANY objectChanges IN %@", objectIDs];
        fetch.resultType = NSManagedObjectIDResultType;
        result = [self.eventStore.managedObjectContext executeFetchRequest:fetch error:&blockError];
        
        localError = blockError;
    }];
    
    if (!result && error) *error = localError;
    return result;
}

- (NSArray *)fetchObjectChangeIDsOfType:(CDEObjectChangeType)type fromStoreModificationEventID:(NSManagedObjectID *)eventID forEntity:(NSEntityDescription *)entity error:(NSError * __autoreleasing *)error
{
    __block NSArray *result = nil;
    __block NSError *localError = nil;
    [self.eventStore.managedObjectContext performBlockAndWait:^{
        NSError *blockError = nil;
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"nameOfEntity = %@ && type = %d && storeModificationEvent = %@", entity.name, type, eventID];
        fetch.resultType = NSManagedObjectIDResultType;
        result = [self.eventStore.managedObjectContext executeFetchRequest:fetch error:&blockError];
        localError = blockError;
    }];
    
    if (!result && error) *error = localError;
    return result;
}

- (NSArray *)fetchObjectChangeIDsFromStoreModificationEventIDs:(NSArray *)eventIDs forEntity:(NSEntityDescription *)entity error:(NSError * __autoreleasing *)error
{
    __block NSArray *result = nil;
    __block NSError *localError = nil;
    [self.eventStore.managedObjectContext performBlockAndWait:^{
        NSError *blockError = nil;
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"nameOfEntity = %@ && storeModificationEvent IN %@", entity.name, eventIDs];
        fetch.resultType = NSManagedObjectIDResultType;
        result = [self.eventStore.managedObjectContext executeFetchRequest:fetch error:&blockError];
        localError = blockError;
    }];
    
    if (error) *error = localError;
    
    return result;
}

@end
