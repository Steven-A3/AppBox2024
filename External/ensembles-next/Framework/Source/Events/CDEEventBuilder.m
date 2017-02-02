//
//  CDEEventFactory.m
//  Ensembles
//
//  Created by Drew McCormack on 22/09/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import "CDEEventBuilder.h"
#import "CDEPersistentStoreEnsemble+Private.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "CDEPersistentStoreEnsemble.h"
#import "CDEEventStore.h"
#import "CDEStoreModificationEvent.h"
#import "CDEDefines.h"
#import "CDEFoundationAdditions.h"
#import "CDEPropertyChangeValue.h"
#import "CDEGlobalIdentifier.h"
#import "CDEObjectChange.h"
#import "CDEEventRevision.h"
#import "CDERevisionSet.h"
#import "CDERevision.h"
#import "CDERevisionManager.h"

@implementation CDEEventBuilder {
    NSManagedObjectID *eventID;
}

@synthesize event = event;
@synthesize eventStore = eventStore;
@synthesize eventManagedObjectContext = eventManagedObjectContext;
@synthesize eventType = eventType;

#pragma mark - Initialization

- (id)initWithEventStore:(CDEEventStore *)newStore eventManagedObjectContext:(NSManagedObjectContext *)newContext
{
    self = [super init];
    if (self) {
        eventStore = newStore;
        eventManagedObjectContext = newContext;
        eventType = CDEStoreModificationEventTypeIncomplete;
        eventID = nil;
    }
    return self;
}

- (id)initWithEventStore:(CDEEventStore *)newStore
{
    return [self initWithEventStore:newStore eventManagedObjectContext:newStore.managedObjectContext];
}

#pragma mark - Making New Events

- (CDERevision *)makeNewEventOfType:(CDEStoreModificationEventType)type uniqueIdentifier:(NSString *)uniqueIdOrNil
{
    __block CDERevision *returnRevision = nil;
    [eventManagedObjectContext performBlockAndWait:^{
        eventType = type;
        
        CDERevisionNumber lastRevision = eventStore.lastRevisionSaved;
        NSString *persistentStoreId = self.eventStore.persistentStoreIdentifier;

        CDERevisionManager *revisionManager = [[CDERevisionManager alloc] initWithEventStore:eventStore];
        revisionManager.managedObjectModelURL = self.ensemble.managedObjectModelURL;

        NSError *error = nil;
        event = [NSEntityDescription insertNewObjectForEntityForName:@"CDEStoreModificationEvent" inManagedObjectContext:eventManagedObjectContext];
        if ([eventManagedObjectContext obtainPermanentIDsForObjects:@[event] error:&error]) {
            eventID = [event.objectID copy];
        }
        else {
            CDELog(CDELoggingLevelError, @"Could not obtain permanent id for event: %@", error);
        }
        
        event.type = CDEStoreModificationEventTypeIncomplete;
        event.timestamp = [NSDate timeIntervalSinceReferenceDate];
        event.globalCount = 0;
        event.modelVersion = self.ensemble.modelVersionHash;
        if (uniqueIdOrNil) event.uniqueIdentifier = uniqueIdOrNil;
        
        CDEEventRevision *revision = [NSEntityDescription insertNewObjectForEntityForName:@"CDEEventRevision" inManagedObjectContext:eventManagedObjectContext];
        revision.persistentStoreIdentifier = persistentStoreId;
        revision.revisionNumber = lastRevision+1;
        revision.storeModificationEvent = event;
        
        // Set the state of other stores
        CDERevisionSet *newRevisionSet = [revisionManager revisionSetForLastMergeOrBaseline];
        [newRevisionSet removeRevisionForPersistentStoreIdentifier:persistentStoreId];
        event.revisionSetOfOtherStoresAtCreation = newRevisionSet;
        
        [eventManagedObjectContext processPendingChanges];
        if (persistentStoreId) returnRevision = [event.revisionSet revisionForPersistentStoreIdentifier:persistentStoreId];
    }];
    
    return returnRevision;
}

- (void)finalizeNewEvent
{
    [eventManagedObjectContext performBlockAndWait:^{
        [self refetchEvent];

        CDERevisionManager *revisionManager = [[CDERevisionManager alloc] initWithEventStore:eventStore];
        revisionManager.managedObjectModelURL = self.ensemble.managedObjectModelURL;
        
        CDEGlobalCount globalCountBeforeMakingEvent = [revisionManager maximumGlobalCount];
        event.globalCount = globalCountBeforeMakingEvent+1;
        event.type = eventType;
    }];
}

#pragma mark - Revisions

- (void)updateEventRevisionsAccountingForMergeOfEventIDs:(NSArray *)eventIDs
{
    // The event has the revisions from the last merge (or baseline).
    // Replace where appropriate with the newer revisions from the events.
    // Don't update the local persistent store revision, because that is set right.
    [eventManagedObjectContext performBlockAndWait:^{
        NSArray *revisionSets = [eventIDs cde_arrayByTransformingObjectsWithBlock:^(NSManagedObjectID *anEventID) {
            CDEStoreModificationEvent *anEvent = (id)[eventManagedObjectContext objectWithID:anEventID];
            return anEvent.revisionSet;
        }];
        
        NSString *localStoreIdentifier = self.event.eventRevision.persistentStoreIdentifier;
        CDERevisionSet *maximumSet = [CDERevisionSet revisionSetByTakingStoreWiseMaximumOfRevisionSets:revisionSets];
        
        CDERevisionSet *newSet = [self.event.revisionSet copy];
        for (NSString *storeIdentifier in maximumSet.persistentStoreIdentifiers) {
            if ([storeIdentifier isEqualToString:localStoreIdentifier]) continue;
            [newSet removeRevisionForPersistentStoreIdentifier:storeIdentifier];
            [newSet addRevision:[maximumSet revisionForPersistentStoreIdentifier:storeIdentifier]];
        }
        [self.event setRevisionSet:newSet forPersistentStoreIdentifier:localStoreIdentifier];
    }];
}

#pragma mark - Accessors

- (CDEStoreModificationEvent *)event
{
    [self refetchEvent];
    return event;
}

- (void)refetchEvent
{
    if (!eventID) {
        event = nil;
    }
    else {
        event = (id)[eventManagedObjectContext existingObjectWithID:eventID error:NULL];
    }
}

#pragma mark - Modifying Events

- (void)performBlockAndWait:(CDECodeBlock)block
{
    [eventManagedObjectContext performBlockAndWait:^{
        [self refetchEvent];
        if (block) block();
    }];
}

#pragma mark - Saving

- (BOOL)saveAndReset:(NSError * __autoreleasing *)error
{
    __block BOOL result = YES;
    [eventManagedObjectContext performBlockAndWait:^{
        [self refetchEvent];

        if (eventManagedObjectContext.hasChanges) result = [eventManagedObjectContext save:error];
        if (!result) return;
        
        [eventManagedObjectContext reset];
        
        [self refetchEvent];
        result = (event != nil);
    }];
    return result;
}

#pragma mark - Global Identifiers

- (void)performInContext:(NSManagedObjectContext *)context block:(CDECodeBlock)block
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (context.concurrencyType != NSConfinementConcurrencyType)
        [context performBlockAndWait:block];
    else
        block();
#pragma clang diagnostic pop
}

- (NSArray *)retrieveGlobalIdentifierStringsForManagedObjects:(NSArray *)objects storedInEventStore:(BOOL)inEventStore
{
    if (objects.count == 0) return @[];
    NSManagedObjectContext *context = [objects.lastObject managedObjectContext];
    
    __block NSArray *globalIDStrings = nil;
    
    if (inEventStore) {
        // Get object ids
        __block NSArray *objectIDs = nil;
        [self performInContext:context block:^{
            objectIDs = [objects valueForKeyPath:@"objectID"];
        }];
        
        // Fetch global ids from event store
        NSManagedObjectContext *eventContext = self.eventStore.managedObjectContext;
        [eventContext performBlockAndWait:^{
            NSArray *globalIds = [CDEGlobalIdentifier fetchGlobalIdentifiersForObjectIDs:objectIDs inManagedObjectContext:eventContext];
            globalIDStrings = [globalIds valueForKeyPath:@"globalIdentifier"];
        }];
    }
    else {
        [self performInContext:context block:^{
            globalIDStrings = [[self.ensemble globalIdentifiersForManagedObjects:objects] copy];
        }];
    }
    
    return globalIDStrings;
}

- (NSArray *)addGlobalIdentifiersForManagedObjectIDs:(NSArray *)objectIDs identifierStrings:(NSArray *)globalIDStrings
{
    NSParameterAssert((globalIDStrings == nil) || (objectIDs.count == globalIDStrings.count));
    
    NSArray *entityNames = [objectIDs valueForKeyPath:@"entity.name"];
    NSMutableArray *globalIDs = [[NSMutableArray alloc] init];
    __block NSArray *globalIDObjectIDs = nil;
    [eventManagedObjectContext performBlockAndWait:^{
        [self refetchEvent];

        NSArray *existingGlobalIdentifiers = nil;
        if (globalIDStrings) existingGlobalIdentifiers = [CDEGlobalIdentifier fetchGlobalIdentifiersForIdentifierStrings:globalIDStrings withEntityNames:entityNames inManagedObjectContext:eventManagedObjectContext];
        
        for (NSUInteger i = 0; i < objectIDs.count; i++) {
            NSManagedObjectID *objectID = objectIDs[i];
            NSString *globalIDString = CDENSNullToNil(globalIDStrings[i]);
            NSString *entityName = entityNames[i];
            CDEGlobalIdentifier *existingGlobalIdentifier = CDENSNullToNil(existingGlobalIdentifiers[i]);
            
            CDEGlobalIdentifier *newGlobalID = existingGlobalIdentifier;
            if (!newGlobalID) {
                newGlobalID = [NSEntityDescription insertNewObjectForEntityForName:@"CDEGlobalIdentifier" inManagedObjectContext:eventManagedObjectContext];
                newGlobalID.nameOfEntity = entityName;
                if (globalIDString) newGlobalID.globalIdentifier = globalIDString;
            }
            
            newGlobalID.storeURI = objectID.URIRepresentation.absoluteString;
            
            [globalIDs addObject:newGlobalID];
        }
        
        NSError *error;
        if (![eventManagedObjectContext save:&error]) CDELog(CDELoggingLevelError, @"Error saving event store: %@", error);
        
        globalIDObjectIDs = [globalIDs valueForKey:@"objectID"];
    }];
    
    return globalIDObjectIDs;
}

#pragma mark - Insertion Object Changes

- (void)addChangesForInsertedObjects:(NSSet *)insertedObjects objectsAreSaved:(BOOL)saved useGlobalIdentifiersInEventStore:(BOOL)useGlobalIdsFromEventStore inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (insertedObjects.count == 0) return;
    
    // This method must be called on context thread
    NSArray *orderedObjects = insertedObjects.allObjects;
    
    NSArray *globalIdStrings = [self retrieveGlobalIdentifierStringsForManagedObjects:orderedObjects storedInEventStore:useGlobalIdsFromEventStore];
    NSArray *globalIdObjectIDs = [self addGlobalIdentifiersForManagedObjectIDs:[orderedObjects valueForKeyPath:@"objectID"] identifierStrings:globalIdStrings];
    NSArray *changeValueArrays = [self propertyChangeValueArraysForInsertedObjects:orderedObjects objectsAreSaved:saved inManagedObjectContext:context];
    
    // Add changes
    [self addInsertChangesForPropertyChangeValueArrays:changeValueArrays globalIdentifierObjectIDs:globalIdObjectIDs];
}

- (NSArray *)propertyChangeValueArraysForInsertedObjects:(NSArray *)insertedObjects objectsAreSaved:(BOOL)saved inManagedObjectContext:(NSManagedObjectContext *)context
{
    // Created property value change objects from the inserted objects
    __block NSMutableArray *changeArrays = nil;
    __block NSMutableArray *entityNames = nil;
    NSMutableDictionary *propertiesToStoreByEntity = [[NSMutableDictionary alloc] init];

    // Create block to make property change values from the objects
    CDECodeBlock block = ^{
        @autoreleasepool {
            changeArrays = [NSMutableArray arrayWithCapacity:insertedObjects.count];
            entityNames = [NSMutableArray array];
            
            [insertedObjects cde_enumerateObjectsDrainingEveryIterations:50 usingBlock:^(NSManagedObject *object, NSUInteger index, BOOL *stop) {
                NSArray *propertiesToStore = propertiesToStoreByEntity[object.entity.name];
                if (!propertiesToStore) {
                    propertiesToStore = [[object.entity cde_nonRedundantProperties] valueForKeyPath:@"name"];
                    propertiesToStoreByEntity[object.entity.name] = propertiesToStore;
                }
                
                NSArray *propertyChanges = [CDEPropertyChangeValue propertyChangesForObject:object eventStore:self.eventStore propertyNames:propertiesToStore isPreSave:!saved storeValues:YES];
                if (!propertyChanges) return;
                
                [changeArrays addObject:propertyChanges];
                [entityNames addObject:object.entity.name];
            }];
        }
    };
    
    // Execute the block on the context's thread
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (context.concurrencyType != NSConfinementConcurrencyType)
        [context performBlockAndWait:block];
    else
        block();
#pragma clang diagnostic pop
    
    return changeArrays;
}

- (void)addInsertChangesForPropertyChangeValueArrays:(NSArray *)changeArrays globalIdentifierObjectIDs:(NSArray *)globalIdObjectIDs
{
    // Build the event from the property changes on the event store thread
    [eventManagedObjectContext performBlockAndWait:^{
        @autoreleasepool {
            __block NSUInteger i = 0;
            [self refetchEvent];
            NSArray *allPropertyChanges = [changeArrays valueForKeyPath:@"@unionOfArrays.self"];
            NSDictionary *globalIdsByObjectID = [self globalIdentifiersByObjectIDForPropertyChangeValues:allPropertyChanges];
            [changeArrays cde_enumerateObjectsDrainingEveryIterations:50 usingBlock:^(NSArray *propertyChanges, NSUInteger index, BOOL *stop) {
                NSManagedObjectID *globalIDObjectID = globalIdObjectIDs[i];
                CDEGlobalIdentifier *newGlobalId = (id)[eventManagedObjectContext objectWithID:globalIDObjectID];
                NSString *entityName = newGlobalId.nameOfEntity;
                [self addObjectChangeOfType:CDEObjectChangeTypeInsert forGlobalIdentifier:newGlobalId entityName:entityName propertyChanges:propertyChanges globalIdentifiersByObjectID:globalIdsByObjectID];
                i++;
            }];
        }
    }];
}

#pragma mark - Deletion Object Changes

- (void)addChangesForDeletedObjects:(NSSet *)deletedObjects inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (deletedObjects.count == 0) return;
    
    NSArray *orderedObjects = deletedObjects.allObjects;
    NSArray *objectIDs = [orderedObjects valueForKeyPath:@"objectID"];
    [self addDeleteChangesForObjectIDs:objectIDs];
}

- (void)addDeleteChangesForObjectIDs:(NSArray *)objectIDs
{
    [eventManagedObjectContext performBlockAndWait:^{
        @autoreleasepool {
            [self refetchEvent];
            NSArray *globalIds = [CDEGlobalIdentifier fetchGlobalIdentifiersForObjectIDs:objectIDs inManagedObjectContext:eventManagedObjectContext];
            [globalIds enumerateObjectsUsingBlock:^(CDEGlobalIdentifier *globalId, NSUInteger i, BOOL *stop) {
                NSManagedObjectID *objectID = objectIDs[i];
                
                if (globalId == (id)[NSNull null]) {
                    CDELog(CDELoggingLevelWarning, @"Deleted object with no global identifier. This can be due to creating and deleting two separate objects with the same global id in a single save operation. ObjectID: %@", objectID);
                    return;
                }
                
                CDEObjectChange *change = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:eventManagedObjectContext];
                change.storeModificationEvent = self.event;
                change.type = CDEObjectChangeTypeDelete;
                change.nameOfEntity = objectID.entity.name;
                change.globalIdentifier = globalId;
            }];
        }
    }];
}

#pragma mark - Update Object Changes

- (void)addChangesForUpdatedObjects:(NSSet *)updatedObjects inManagedObjectContext:(NSManagedObjectContext *)context options:(CDEUpdateStoreOption)options propertyChangeValuesByObjectID:(NSDictionary *)propertyChangeValuesByObjectID
{
    if (updatedObjects.count == 0) return;
    
    NSArray *orderedObjects = updatedObjects.allObjects;
    NSArray *objectIDs = [orderedObjects valueForKeyPath:@"objectID"];
    [self updatePropertyChangeValuesForUpdatedObjects:orderedObjects inManagedObjectContext:context options:options propertyChangeValuesByObjectID:propertyChangeValuesByObjectID];
    [self addUpdateChangesForObjectIDs:objectIDs propertyChangeValuesByObjectID:propertyChangeValuesByObjectID];
}

- (void)updatePropertyChangeValuesForUpdatedObjects:(NSArray *)updatedObjects inManagedObjectContext:(NSManagedObjectContext *)context options:(CDEUpdateStoreOption)options propertyChangeValuesByObjectID:(NSDictionary *)propertyChangeValuesByObjectID
{
    // Determine what needs to be stored
    BOOL storePreSaveInfo = (CDEUpdateStoreOptionPreSaveInfo & options);
    BOOL storeUnsavedValues = (CDEUpdateStoreOptionUnsavedValue & options);
    BOOL storeSavedValues = (CDEUpdateStoreOptionSavedValue & options);
    NSAssert(!(storePreSaveInfo && storeSavedValues), @"Cannot store pre-save info and saved values");
    NSAssert(!(storeUnsavedValues && storeSavedValues), @"Cannot store unsaved values and saved values");
    
    // Can't access objects in background, so just pass ids
    CDECodeBlock block = ^{
        // Update property changes with saved values
        BOOL isPreSave = storePreSaveInfo || storeUnsavedValues;
        BOOL storeValues = storeUnsavedValues || storeSavedValues;
        for (NSManagedObject *object in updatedObjects) {
            NSManagedObjectID *objectID = object.objectID;
            NSArray *propertyChanges = propertyChangeValuesByObjectID[objectID];
            for (CDEPropertyChangeValue *propertyChangeValue in propertyChanges) {
                [propertyChangeValue updateWithObject:object isPreSave:isPreSave storeValues:storeValues];
            }
        }
    };
    
    if (context.concurrencyType != NSConfinementConcurrencyType)
        [context performBlockAndWait:block];
    else
        block();
}

- (void)addUpdateChangesForObjectIDs:(NSArray *)objectIDs propertyChangeValuesByObjectID:(NSDictionary *)propertyChangeValuesByObjectID
{
    [eventManagedObjectContext performBlockAndWait:^{
        @autoreleasepool {
            [self refetchEvent];
            NSArray *globalIds = [CDEGlobalIdentifier fetchGlobalIdentifiersForObjectIDs:objectIDs inManagedObjectContext:eventManagedObjectContext];
            [globalIds cde_enumerateObjectsDrainingEveryIterations:50 usingBlock:^(CDEGlobalIdentifier *globalId, NSUInteger index, BOOL *stop) {
                if ((id)globalId == [NSNull null]) {
                    CDELog(CDELoggingLevelWarning, @"Tried to store updates for object with no global identifier. Skipping.");
                    return;
                }
                
                NSManagedObjectID *objectID = objectIDs[index];
                NSArray *propertyChanges = [propertyChangeValuesByObjectID objectForKey:objectID];
                if (!propertyChanges) return;
                
                [self addObjectChangeOfType:CDEObjectChangeTypeUpdate forGlobalIdentifier:globalId entityName:objectID.entity.name propertyChanges:propertyChanges];
            }];
        }
    }];
}

- (void)addChangesForUnsavedUpdatedObjects:(NSSet *)updatedObjects inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (updatedObjects.count == 0) return;
    
    __block NSMutableDictionary *changedValuesByObjectID = nil;
    NSMutableDictionary *propertiesToStoreByEntity = [[NSMutableDictionary alloc] init];
    NSManagedObjectContext *updatedObjectsContext = context;
    [updatedObjectsContext performBlockAndWait:^{
        changedValuesByObjectID = [NSMutableDictionary dictionaryWithCapacity:updatedObjects.count];
        [updatedObjects.allObjects cde_enumerateObjectsDrainingEveryIterations:50 usingBlock:^(NSManagedObject *object, NSUInteger index, BOOL *stop) {
            NSSet *propertiesToStore = propertiesToStoreByEntity[object.entity.name];
            if (!propertiesToStore) {
                propertiesToStore = [NSSet setWithArray:[[object.entity cde_nonRedundantProperties] valueForKeyPath:@"name"]];
                propertiesToStoreByEntity[object.entity.name] = propertiesToStore;
            }
            
            NSArray *changedKeys = object.changedValues.allKeys;
            changedKeys = [changedKeys filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *key, NSDictionary *bindings) {
                return [propertiesToStore containsObject:key];
            }]];
            
            NSArray *propertyChanges = [CDEPropertyChangeValue propertyChangesForObject:object eventStore:self.eventStore propertyNames:changedKeys isPreSave:YES storeValues:YES];
            NSManagedObjectID *objectID = object.objectID;
            changedValuesByObjectID[objectID] = propertyChanges;
        }];
    }];
    
    [self addChangesForUpdatedObjects:updatedObjects inManagedObjectContext:context options:(CDEUpdateStoreOptionPreSaveInfo | CDEUpdateStoreOptionUnsavedValue) propertyChangeValuesByObjectID:changedValuesByObjectID];
}

- (BOOL)addChangesForUnsavedManagedObjectContext:(NSManagedObjectContext *)contextWithChanges error:(NSError * __autoreleasing *)error
{
    __block BOOL success = NO;
    success = [contextWithChanges obtainPermanentIDsForObjects:contextWithChanges.insertedObjects.allObjects error:error];
    if (!success) return NO;

    [self addChangesForInsertedObjects:contextWithChanges.insertedObjects objectsAreSaved:NO useGlobalIdentifiersInEventStore:NO inManagedObjectContext:contextWithChanges];
    [self addChangesForDeletedObjects:contextWithChanges.deletedObjects inManagedObjectContext:contextWithChanges];
    [self addChangesForUnsavedUpdatedObjects:contextWithChanges.updatedObjects inManagedObjectContext:contextWithChanges];
    
    return YES;
}

#pragma mark Converting property changes for storage in event store

- (NSDictionary *)globalIdentifiersByObjectIDForPropertyChangeValues:(NSArray *)propertyChanges
{
    // Fetch the needed global ids
    NSMutableSet *objectIDs = [[NSMutableSet alloc] initWithCapacity:propertyChanges.count];
    for (CDEPropertyChangeValue *propertyChange in propertyChanges) {
        if (propertyChange.relatedIdentifier) [objectIDs addObject:propertyChange.relatedIdentifier];
        if (propertyChange.addedIdentifiers) [objectIDs unionSet:propertyChange.addedIdentifiers];
        if (propertyChange.removedIdentifiers) [objectIDs unionSet:propertyChange.removedIdentifiers];
        if (propertyChange.movedIdentifiersByIndex) [objectIDs addObjectsFromArray:propertyChange.movedIdentifiersByIndex.allValues];
    }
    [objectIDs removeObject:[NSNull null]];
    
    NSArray *orderedObjectIDs = objectIDs.allObjects;
    NSArray *globalIds = [CDEGlobalIdentifier fetchGlobalIdentifiersForObjectIDs:orderedObjectIDs inManagedObjectContext:self.eventManagedObjectContext];
    NSDictionary *globalIdentifiersByObjectID = [NSDictionary dictionaryWithObjects:globalIds forKeys:orderedObjectIDs];

    return globalIdentifiersByObjectID;
}

- (void)addObjectChangeOfType:(CDEObjectChangeType)type forGlobalIdentifier:(CDEGlobalIdentifier *)globalId entityName:(NSString *)entityName propertyChanges:(NSArray *)propertyChanges
{
    NSDictionary *globalIdsByObjectID = [self globalIdentifiersByObjectIDForPropertyChangeValues:propertyChanges];
    [self addObjectChangeOfType:type forGlobalIdentifier:globalId entityName:entityName propertyChanges:propertyChanges globalIdentifiersByObjectID:globalIdsByObjectID];
}

- (void)addObjectChangeOfType:(CDEObjectChangeType)type forGlobalIdentifier:(CDEGlobalIdentifier *)globalId entityName:(NSString *)entityName propertyChanges:(NSArray *)propertyChanges globalIdentifiersByObjectID:(NSDictionary *)globalIdentifiersByObjectID
{
    NSParameterAssert(type == CDEObjectChangeTypeInsert || type == CDEObjectChangeTypeUpdate);
    NSParameterAssert(globalId != nil);
    NSParameterAssert(entityName != nil);
    NSParameterAssert(propertyChanges != nil);
    NSAssert(self.event, @"No event created. Call makeNewEvent first.");
    
    CDEObjectChange *objectChange = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:eventManagedObjectContext];
    objectChange.storeModificationEvent = self.event;
    objectChange.type = type;
    objectChange.nameOfEntity = entityName;
    objectChange.globalIdentifier = globalId;
    
    // Fetch the needed global ids
    for (CDEPropertyChangeValue *propertyChange in propertyChanges) {
        [self convertRelationshipValuesToGlobalIdentifiersInPropertyChangeValue:propertyChange withGlobalIdentifiersByObjectID:globalIdentifiersByObjectID];
    }
    
    objectChange.propertyChangeValues = propertyChanges;
}

- (void)convertRelationshipValuesToGlobalIdentifiersInPropertyChangeValue:(CDEPropertyChangeValue *)propertyChange withGlobalIdentifiersByObjectID:(NSDictionary *)globalIdentifiersByObjectID
{
    switch (propertyChange.type) {
        case CDEPropertyChangeTypeToOneRelationship:
            [self convertToOneRelationshipValuesToGlobalIdentifiersInPropertyChangeValue:propertyChange withGlobalIdentifiersByObjectID:globalIdentifiersByObjectID];
            break;
            
        case CDEPropertyChangeTypeOrderedToManyRelationship:
        case CDEPropertyChangeTypeToManyRelationship:
            [self convertToManyRelationshipValuesToGlobalIdentifiersInPropertyChangeValue:propertyChange withGlobalIdentifiersByObjectID:globalIdentifiersByObjectID];
            break;
            
        case CDEPropertyChangeTypeAttribute:
        default:
            break;
    }
}

- (void)convertToOneRelationshipValuesToGlobalIdentifiersInPropertyChangeValue:(CDEPropertyChangeValue *)propertyChange withGlobalIdentifiersByObjectID:(NSDictionary *)globalIdentifiersByObjectID
{
    CDEGlobalIdentifier *globalId = nil;
    globalId = globalIdentifiersByObjectID[propertyChange.relatedIdentifier];
    globalId = CDENSNullToNil(globalId);
    if (propertyChange.relatedIdentifier && !globalId) {
        CDELog(CDELoggingLevelError, @"No global id found for to-one relationship with target objectID: %@", propertyChange.relatedIdentifier);
    }
    propertyChange.relatedIdentifier = globalId.globalIdentifier;
}

- (void)convertToManyRelationshipValuesToGlobalIdentifiersInPropertyChangeValue:(CDEPropertyChangeValue *)propertyChange withGlobalIdentifiersByObjectID:(NSDictionary *)globalIdentifiersByObjectID
{
    static NSPredicate *notNullPredicate = nil;
    static NSString *globalIdIsNullErrorMessage = @"Missing global ids for added ids in a to-many relationship. This is usually caused by saving multiple objects with the same global id at once.";
    if (!notNullPredicate) notNullPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != [NSNull null];
    }];
    
    NSArray *addedGlobalIdentifiers = [globalIdentifiersByObjectID objectsForKeys:propertyChange.addedIdentifiers.allObjects notFoundMarker:[NSNull null]];
    BOOL containsNull = [addedGlobalIdentifiers containsObject:[NSNull null]];
    if (containsNull) {
        addedGlobalIdentifiers = [addedGlobalIdentifiers filteredArrayUsingPredicate:notNullPredicate];
        CDELog(CDELoggingLevelError, @"%@", globalIdIsNullErrorMessage);
    }
    
    NSArray *removedGlobalIdentifiers = [globalIdentifiersByObjectID objectsForKeys:propertyChange.removedIdentifiers.allObjects notFoundMarker:[NSNull null]];
    containsNull = [removedGlobalIdentifiers containsObject:[NSNull null]];
    if (containsNull) {
        removedGlobalIdentifiers = [removedGlobalIdentifiers filteredArrayUsingPredicate:notNullPredicate];
        CDELog(CDELoggingLevelError, @"%@", globalIdIsNullErrorMessage);
    }
    
    propertyChange.addedIdentifiers = [NSSet setWithArray:[addedGlobalIdentifiers valueForKeyPath:@"globalIdentifier"]];
    propertyChange.removedIdentifiers = [NSSet setWithArray:[removedGlobalIdentifiers valueForKeyPath:@"globalIdentifier"]];
    
    if (propertyChange.type != CDEPropertyChangeTypeOrderedToManyRelationship) return;
    
    NSMutableDictionary *newMovedIdentifiers = [[NSMutableDictionary alloc] initWithCapacity:propertyChange.movedIdentifiersByIndex.count];
    for (NSNumber *index in propertyChange.movedIdentifiersByIndex.allKeys) {
        id objectID = propertyChange.movedIdentifiersByIndex[index];
        CDEGlobalIdentifier *globalIDObject = [globalIdentifiersByObjectID objectForKey:objectID];
        NSString *globalIdentifier = nil;
        if (globalIDObject != (id)[NSNull null]) globalIdentifier = globalIDObject.globalIdentifier;
        if (!globalIdentifier) {
            CDELog(CDELoggingLevelWarning, @"Missing global id for moved object with objectID: %@", objectID);
            continue;
        }
        newMovedIdentifiers[index] = globalIdentifier;
    }
    propertyChange.movedIdentifiersByIndex = newMovedIdentifiers;
}

#pragma mark Checking Global Identifier Uniqueness

// There should not be any global ids that are shared by more than one object change
// in the event.
- (BOOL)checkUniquenessOfGlobalIdentifiers:(NSError * __autoreleasing *)error
{
    __block BOOL success = YES;
    [eventManagedObjectContext performBlockAndWait:^{
        [self refetchEvent];

        NSFetchRequest *changeRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
        changeRequest.resultType = NSManagedObjectIDResultType;
        changeRequest.predicate = [NSPredicate predicateWithFormat:@"storeModificationEvent = %@", event];
        NSArray *changeIDs = [eventManagedObjectContext executeFetchRequest:changeRequest error:error];
        if (!changeIDs) {
            success = NO;
            return;
        }
        
        NSFetchRequest *globalIdRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDEGlobalIdentifier"];
        globalIdRequest.predicate = [NSPredicate predicateWithFormat:@"ANY objectChanges IN %@", changeIDs];
        NSUInteger globalIdCount = [eventManagedObjectContext countForFetchRequest:globalIdRequest error:error];
        if (globalIdCount == NSNotFound) {
            success = NO;
            return;
        }
        
        if (globalIdCount != changeIDs.count) {
            success = NO;
            NSDictionary *info = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Number of object changes: %lu, Number of global ids: %lu", (unsigned long)changeIDs.count, (unsigned long)globalIdCount]};
            *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeMultipleObjectChanges userInfo:info];
        }
    }];
    return success;
}

@end
