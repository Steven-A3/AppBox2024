//
//  CDEIntegrationStage.m
//  Ensembles iOS
//
//  Created by Drew McCormack on 05/05/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import "CDEIntegrationStage.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "NSMapTable+CDEAdditions.h"
#import "CDEDefines.h"
#import "CDEEventStore.h"
#import "CDEEventBuilder.h"
#import "CDEGlobalIdentifier.h"
#import "CDEPropertyChangeValue.h"
#import "CDEObjectChange.h"

@implementation CDEIntegrationStage {
    NSUInteger totalNumberOfBatches;
    NSUInteger maximumBatchSize;
}

@synthesize managedObjectContext = managedObjectContext;
@synthesize batchSize = batchSize;
@synthesize numberOfBatchesRemaining = numberOfBatchesRemaining;
@synthesize numberOfChangesInNextBatch = numberOfChangesInNextBatch;
@synthesize firstIndexOfNextBatch = firstIndexOfNextBatch;
@synthesize objectChangeIDs = objectChangeIDs;
@synthesize eventBuilder = eventBuilder;
@synthesize eventStore = eventStore;

#pragma mark Initialization

- (instancetype)initWithEventBuilder:(CDEEventBuilder *)newBuilder objectChangeIDs:(NSArray *)newChangeIDs managedObjectContext:(NSManagedObjectContext *)newContext batchSize:(NSUInteger)newBatchSize
{
    self = [super init];
    if (self) {
        eventBuilder = newBuilder;
        eventStore = newBuilder.eventStore;
        objectChangeIDs = newChangeIDs;
        managedObjectContext = newContext;
        batchSize = newBatchSize;
        
        NSUInteger count = newChangeIDs.count;
        maximumBatchSize = batchSize ? : count;
        totalNumberOfBatches = count / MAX(1, maximumBatchSize) + ((count > 0 && count%maximumBatchSize != 0) ? 1 : 0);
        numberOfBatchesRemaining = totalNumberOfBatches;
        [self updateBatchProperties];
    }
    return self;
}

#pragma mark Batching

- (BOOL)applyNextBatchOfChanges:(NSError * __autoreleasing *)error
{
    NSArray *batchChangeIDs = [self nextBatchChangeIDs];
    if (batchChangeIDs.count == 0) return YES;
    
    __block BOOL success = YES;
    NSManagedObjectContext *eventContext = self.eventStore.managedObjectContext;
    [eventContext performBlockAndWait:^{
        success = [self applyChangeIDs:batchChangeIDs error:error];
    }];
    
    if (success) [self incrementBatch];
    return success;
}

- (void)incrementBatch
{
    if (numberOfBatchesRemaining > 0) numberOfBatchesRemaining--;
    [self updateBatchProperties];
}

- (void)updateBatchProperties
{
    if (numberOfBatchesRemaining == 0) {
        numberOfChangesInNextBatch = 0;
        firstIndexOfNextBatch = NSNotFound;
        return;
    }
    
    NSUInteger count = self.objectChangeIDs.count;
    numberOfChangesInNextBatch = maximumBatchSize;
    firstIndexOfNextBatch = (totalNumberOfBatches - numberOfBatchesRemaining) * maximumBatchSize;
    if (numberOfBatchesRemaining == 1 && count%maximumBatchSize != 0) {
        numberOfChangesInNextBatch = count%maximumBatchSize;
    }
}

- (NSArray *)nextBatchChangeIDs
{
    if (firstIndexOfNextBatch == NSNotFound) return nil;
    return [self.objectChangeIDs subarrayWithRange:NSMakeRange(firstIndexOfNextBatch, numberOfChangesInNextBatch)];
}

#pragma mark Accessing Values

+ (id)valueForKey:(NSString *)key inObject:(id)object
{
    [object willAccessValueForKey:key];
    id related = [object primitiveValueForKey:key];
    [object didAccessValueForKey:key];
    return related;
}

+ (void)setValue:(id)value forKey:(NSString *)key inObject:(id)object
{
    id currentValue = [self valueForKey:key inObject:object];
    if (value != currentValue && ![value isEqual:currentValue]) {
        @try {
            [object willChangeValueForKey:key];
            [object setPrimitiveValue:value forKey:key];
            [object didChangeValueForKey:key];
        }
        @catch ( NSException *exception ) {
            CDELog(CDELoggingLevelError, @"Exception thrown setting value during integration. Possibly DB corruption. Ignoring: %@", exception);
        }
    }
}

#pragma mark Batch Iterating Object Change Managed Object IDs

- (void)enumerateObjectChangeIDs:(NSArray *)changeIDs withBlock:(void(^)(NSArray *ids))block
{
    if (changeIDs.count == 0) return;
    
    NSManagedObjectContext *eventContext = self.eventStore.managedObjectContext;
    NSUInteger sizeOfBatch = batchSize == 0 ? changeIDs.count : batchSize;
    
    NSUInteger count = changeIDs.count;
    NSUInteger numberOfBatches = count / MAX(1, sizeOfBatch) + ((count && count%sizeOfBatch) ? 1 : 0);
    
    for (NSUInteger b = 0; b < numberOfBatches; b++) {
        @autoreleasepool {
            NSUInteger offset = b * sizeOfBatch;
            NSUInteger limit = MIN(sizeOfBatch, count-offset);
            NSArray *batchChangeIDs = [changeIDs subarrayWithRange:NSMakeRange(offset, limit)];
            
            [CDEObjectChange prefetchObjectChangesForObjectIDs:batchChangeIDs inManagedObjectContext:eventContext];
            
            if (block) block(batchChangeIDs);
            
            [eventBuilder saveAndReset:NULL];
        }
    }
}

#pragma mark Fetching from Synced Store

- (NSMapTable *)fetchObjectsByGlobalIdentifierForEntityName:(NSString *)entityName globalIdentifiers:(id)globalIdentifiers error:(NSError * __autoreleasing *)error
{
    // Setup mappings between types of identifiers
    NSPersistentStoreCoordinator *coordinator = managedObjectContext.persistentStoreCoordinator;
    NSMutableSet *objectIDs = [[NSMutableSet alloc] initWithCapacity:[globalIdentifiers count]];
    NSMapTable *objectIDByGlobalId = [NSMapTable cde_strongToStrongObjectsMapTable];
    for (CDEGlobalIdentifier *globalId in globalIdentifiers) {
        NSString *storeIdString = globalId.storeURI;
        if (!storeIdString) continue; // Doesn't exist in store
        
        NSURL *uri = [NSURL URLWithString:storeIdString];
        NSManagedObjectID *objectID = [coordinator managedObjectIDForURIRepresentation:uri];
        [objectIDs addObject:objectID];
        
        [objectIDByGlobalId setObject:objectID forKey:globalId];
    }
    
    // Fetch objects
    __block NSArray *objects = nil;
    __block NSArray *objectIDsOfFetched = nil;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:entityName];
        fetch.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", objectIDs];
        fetch.includesSubentities = NO;
        objects = [managedObjectContext executeFetchRequest:fetch error:error];
        objectIDsOfFetched = [objects valueForKeyPath:@"objectID"];
    }];
    if (!objects) return nil;
    
    // ObjectID to object mapping
    NSDictionary *objectByObjectID = [[NSDictionary alloc] initWithObjects:objects forKeys:objectIDsOfFetched];
    
    // Prepare results
    NSMapTable *result = [NSMapTable cde_strongToStrongObjectsMapTable];
    for (CDEGlobalIdentifier *globalId in globalIdentifiers) {
        NSManagedObjectID *objectID = [objectIDByGlobalId objectForKey:globalId];
        [result setObject:objectByObjectID[objectID] forKey:globalId];
    }
    
    return result;
}

// Must be called on event store context thread
- (NSDictionary *)fetchObjectsByGlobalIdStringByEntityNameForChanges:(id)objectChanges relationshipsToInclude:(NSArray *)relationships error:(NSError * __autoreleasing *)error
{
    // Get ids for objects directly involved in the change
    NSDictionary *globalIdStringsByEntity = [self globalIdentifierStringsByEntityNameInObjectChanges:objectChanges relationshipsToInclude:relationships];
    
    // Convert to global ids
    NSMutableDictionary *changeObjectsByIdStringByEntity = [NSMutableDictionary dictionary];
    for (NSString *entityName in globalIdStringsByEntity) {
        NSSet *globalIdStrings = globalIdStringsByEntity[entityName];
        NSArray *globalIds = [self fetchGlobalIdentifiersForIdentifierStrings:globalIdStrings entityName:entityName];
        changeObjectsByIdStringByEntity[entityName] = [self fetchObjectsByIdStringForGlobalIdentifiers:globalIds];
    }
    
    // We need to get ids for existing related objects in ordered relationships.
    // The existing objects are needed, because we always need
    // to sort an ordered relationship, and this involves all objects, whether they are new or not.
    NSDictionary *relatedOrderedObjectsByIdStringByEntity = [self fetchObjectsByGlobalIdStringByEntityForRelatedObjectsInOrderedRelationshipsOfObjectChanges:objectChanges];

    // Combine results
    NSMutableDictionary *objectsByGlobalIdByEntityName = [NSMutableDictionary dictionaryWithCapacity:100];
    for (NSString *entityName in changeObjectsByIdStringByEntity) {
        NSMapTable *objectsByGlobalId = objectsByGlobalIdByEntityName[entityName];
        if (!objectsByGlobalId) {
            objectsByGlobalId = [NSMapTable cde_strongToStrongObjectsMapTable];
            objectsByGlobalIdByEntityName[entityName] = objectsByGlobalId;
        }
        [objectsByGlobalId cde_addEntriesFromMapTable:changeObjectsByIdStringByEntity[entityName]];
        [objectsByGlobalId cde_addEntriesFromMapTable:relatedOrderedObjectsByIdStringByEntity[entityName]];
    }
    
    return objectsByGlobalIdByEntityName;
}

- (NSDictionary *)fetchObjectsByGlobalIdStringByEntityForRelatedObjectsInOrderedRelationshipsOfObjectChanges:(id)objectChanges
{
    NSMutableDictionary *changedOrderedPropertiesByGlobalIdByEntity = [NSMutableDictionary dictionaryWithCapacity:10];
    
    // Map changed ordered properties to global ids
    for (CDEObjectChange *change in objectChanges) {
        NSArray *propertyChangeValues = change.propertyChangeValues;
        for (CDEPropertyChangeValue *value in propertyChangeValues) {
            if (value.movedIdentifiersByIndex.count > 0) {
                // Get the map for this entity
                NSString *entityName = change.nameOfEntity;
                NSMapTable *changedOrderedPropertiesByGlobalId = changedOrderedPropertiesByGlobalIdByEntity[entityName];
                if (!changedOrderedPropertiesByGlobalId) {
                    changedOrderedPropertiesByGlobalId = [NSMapTable cde_strongToStrongObjectsMapTable];
                    changedOrderedPropertiesByGlobalIdByEntity[entityName] = changedOrderedPropertiesByGlobalId;
                }
                
                // Store the property name, so we can add existing related objects below
                CDEGlobalIdentifier *globalId = change.globalIdentifier;
                NSMutableSet *propertyNames = [changedOrderedPropertiesByGlobalId objectForKey:globalId];
                if (!propertyNames) propertyNames = [[NSMutableSet alloc] initWithCapacity:3];
                [propertyNames addObject:value.propertyName];
                [changedOrderedPropertiesByGlobalId setObject:propertyNames forKey:globalId];
            }
        }
    }
    
    // Gather all related objects, grouped by entity
    NSMutableDictionary *relatedObjectsByEntity = [[NSMutableDictionary alloc] init];
    for (NSString *entityName in changedOrderedPropertiesByGlobalIdByEntity) {
        NSError *error = nil;
        NSMapTable *changedOrderedPropertiesByGlobalId = changedOrderedPropertiesByGlobalIdByEntity[entityName];
        NSArray *globalIds = changedOrderedPropertiesByGlobalId.cde_allKeys;
        NSMapTable *objectsByGlobalId = [self fetchObjectsByGlobalIdentifierForEntityName:entityName globalIdentifiers:globalIds error:&error];
        
        for (CDEGlobalIdentifier *globalId in globalIds) {
            NSSet *changedOrderedProperties = [changedOrderedPropertiesByGlobalId objectForKey:globalId];
            NSManagedObject *object = [objectsByGlobalId objectForKey:globalId];
            for (NSString *propertyName in changedOrderedProperties) {
                NSOrderedSet *relatedSet = [object valueForKey:propertyName];
                
                NSRelationshipDescription *relationship = object.entity.relationshipsByName[propertyName];
                NSString *relatedEntityName = relationship.destinationEntity.name;
                NSMutableSet *relatedEntityObjects = relatedObjectsByEntity[relatedEntityName];
                if (!relatedEntityObjects) {
                    relatedEntityObjects = [[NSMutableSet alloc] init];
                    relatedObjectsByEntity[relatedEntityName] = relatedEntityObjects;
                }
                
                [relatedEntityObjects addObjectsFromArray:relatedSet.array];
            }
        }
    }
    
    // Map related objects to their global ids
    NSMutableDictionary *relatedObjectsByGlobalIdByEntity = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *entityName in relatedObjectsByEntity) {
        NSMapTable *relatedObjectsByGlobalId = relatedObjectsByGlobalIdByEntity[entityName];
        if (!relatedObjectsByGlobalId) {
            relatedObjectsByGlobalId = [NSMapTable cde_strongToStrongObjectsMapTable];
            relatedObjectsByGlobalIdByEntity[entityName] = relatedObjectsByGlobalId;
        }
        
        NSArray *relatedObjects = [relatedObjectsByEntity[entityName] allObjects];
        NSArray *objectIDs = [relatedObjects valueForKeyPath:@"objectID"];
        NSArray *globalIds = [CDEGlobalIdentifier fetchGlobalIdentifiersForObjectIDs:objectIDs inManagedObjectContext:self.eventStore.managedObjectContext];
        
        [relatedObjects enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
            CDEGlobalIdentifier *globalId = globalIds[index];
            if (globalId == (id)[NSNull null]) {
                CDELog(CDELoggingLevelError, @"A global identifier was not found for an ordered-relationship object");
                return;
            }
            [relatedObjectsByGlobalId setObject:object forKey:globalId.globalIdentifier];
        }];
    }
    
    return relatedObjectsByGlobalIdByEntity;
}

- (NSMapTable *)fetchObjectsByIdStringForGlobalIdentifiers:(NSArray *)globalIds
{
    NSDictionary *globalIdsByEntityName = [self entityGroupedGlobalIdentifiersForIdentifiers:globalIds];
    NSMapTable *results = [NSMapTable cde_strongToStrongObjectsMapTable];
    for (NSString *entityName in globalIdsByEntityName) {
        NSSet *entityGlobalIds = globalIdsByEntityName[entityName];
        NSError *error;
        NSMapTable *resultsForEntity = [self fetchObjectsByGlobalIdentifierForEntityName:entityName globalIdentifiers:entityGlobalIds error:&error];
        if (!resultsForEntity) return nil;
        
        for (CDEGlobalIdentifier *globalId in resultsForEntity) {
            [results setObject:[resultsForEntity objectForKey:globalId] forKey:globalId.globalIdentifier];
        }
    }
    return results;
}

- (NSArray *)fetchGlobalIdentifiersForIdentifierStrings:(id)idStrings entityName:(NSString *)entityName
{
    NSError *error;
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEGlobalIdentifier"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"nameOfEntity = %@ AND globalIdentifier IN %@", entityName, idStrings];
    NSArray *globalIds = [self.eventStore.managedObjectContext executeFetchRequest:fetch error:&error];
    if (!globalIds) CDELog(CDELoggingLevelError, @"Error fetching ids: %@", error);
    return globalIds;
}

- (NSDictionary *)globalIdentifierStringsByEntityNameInObjectChanges:(id)objectChanges relationshipsToInclude:(NSArray *)relationships
{
    NSSet *relationshipNames = [NSSet setWithArray:[relationships valueForKeyPath:@"name"]];
    NSMutableDictionary *globalIdStringsByEntity = [NSMutableDictionary dictionary];
    NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    
    NSMutableDictionary *destinationEntitiesByEntityName = [NSMutableDictionary dictionary];
    for (CDEObjectChange *change in objectChanges) {
        NSString *entityName = change.nameOfEntity;
        NSEntityDescription *entity = model.entitiesByName[entityName];
        if (!entity) {
            CDELog(CDELoggingLevelWarning, @"Did not find entity in model: %@", entityName);
            continue;
        }
        
        NSMutableSet *globalIdStrings = globalIdStringsByEntity[entityName];
        if (!globalIdStrings) {
            globalIdStrings = [[NSMutableSet alloc] initWithCapacity:100];
            globalIdStringsByEntity[entityName] = globalIdStrings;
        }
        [globalIdStrings addObject:change.globalIdentifier.globalIdentifier];
        
        NSArray *propertyChangeValues = change.propertyChangeValues;
        for (CDEPropertyChangeValue *value in propertyChangeValues) {
            if (relationships && ![relationshipNames containsObject:value.propertyName]) continue;
            
            NSRelationshipDescription *relationship = entity.relationshipsByName[value.propertyName];
            if (!relationship)  {
                CDELog(CDELoggingLevelWarning, @"Did not find relationship property in model: %@", value.propertyName);
                continue;
            }
            
            // A relationship may reference a parent entity, rather than the entity of the
            // related object. For that reason, we need to include all descendant entities.
            NSString *destinationName = relationship.destinationEntity.name;
            NSArray *destinationEntities = destinationEntitiesByEntityName[destinationName];
            if (!destinationEntities) {
                destinationEntities = [relationship.destinationEntity cde_descendantEntities];
                destinationEntities = [destinationEntities arrayByAddingObject:relationship.destinationEntity];
                destinationEntitiesByEntityName[destinationName] = destinationEntities;
            }
            
            for (NSEntityDescription *relatedEntity in destinationEntities) {
                NSString *relatedEntityName = relatedEntity.name;
                NSMutableSet *globalIdStrings = globalIdStringsByEntity[relatedEntityName];
                if (!globalIdStrings) {
                    globalIdStrings = [[NSMutableSet alloc] initWithCapacity:100];
                    globalIdStringsByEntity[relatedEntityName] = globalIdStrings;
                }
                
                if (value.relatedIdentifier) [globalIdStrings addObject:value.relatedIdentifier];
                if (value.addedIdentifiers) [globalIdStrings unionSet:value.addedIdentifiers];
                if (value.removedIdentifiers) [globalIdStrings unionSet:value.removedIdentifiers];
                if (value.movedIdentifiersByIndex) [globalIdStrings addObjectsFromArray:value.movedIdentifiersByIndex.allValues];
            }
        }
    }
    
    return globalIdStringsByEntity;
}

- (NSDictionary *)entityGroupedGlobalIdentifiersForIdentifiers:(NSArray *)globalIds
{
    NSMutableDictionary *globalIdsByEntityName = [NSMutableDictionary dictionaryWithCapacity:globalIds.count];
    for (CDEGlobalIdentifier *globalId in globalIds) {
        NSMutableSet *idsForEntity = globalIdsByEntityName[globalId.nameOfEntity];
        if (!idsForEntity) {
            idsForEntity = [NSMutableSet set];
            globalIdsByEntityName[globalId.nameOfEntity] = idsForEntity;
        }
        [idsForEntity addObject:globalId];
    }
    return globalIdsByEntityName;
}

@end
