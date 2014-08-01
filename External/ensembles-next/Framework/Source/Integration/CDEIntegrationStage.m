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
        [object willChangeValueForKey:key];
        [object setPrimitiveValue:value forKey:key];
        [object didChangeValueForKey:key];
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
- (NSMapTable *)fetchObjectsByGlobalIdentifierForChanges:(id)objectChanges relationshipsToInclude:(NSArray *)relationships error:(NSError * __autoreleasing *)error
{
    // Get ids for objects directly involved in the change
    NSSet *globalIdStrings = [self globalIdentifierStringsInObjectChanges:objectChanges relationshipsToInclude:relationships];
    NSArray *globalIds = [self fetchGlobalIdentifiersForIdentifierStrings:globalIdStrings];
    NSMapTable *changeObjectsByIdString = [self fetchObjectsByIdStringForGlobalIdentifiers:globalIds];
    
    // We need to get ids for existing related objects in ordered relationships.
    // The existing objects are needed, because we always need
    // to sort an ordered relationship, and this involves all objects, whether they are new or not.
    NSMapTable *relatedOrderedObjectsByIdString = [self fetchObjectsByIdStringForRelatedObjectsInOrderedRelationshipsOfObjectChanges:objectChanges];
    
    NSMapTable *result = [NSMapTable cde_strongToStrongObjectsMapTable];
    [result cde_addEntriesFromMapTable:changeObjectsByIdString];
    [result cde_addEntriesFromMapTable:relatedOrderedObjectsByIdString];
    
    return result;
}

- (NSMapTable *)fetchObjectsByIdStringForRelatedObjectsInOrderedRelationshipsOfObjectChanges:(id)objectChanges
{
    NSMapTable *changedOrderedPropertiesByGlobalId = [NSMapTable cde_strongToStrongObjectsMapTable];
    for (CDEObjectChange *change in objectChanges) {
        NSArray *propertyChangeValues = change.propertyChangeValues;
        for (CDEPropertyChangeValue *value in propertyChangeValues) {
            if (value.movedIdentifiersByIndex.count > 0) {
                // Store the property name, so we can add existing related objects below
                CDEGlobalIdentifier *globalId = change.globalIdentifier;
                NSMutableSet *propertyNames = [changedOrderedPropertiesByGlobalId objectForKey:globalId];
                if (!propertyNames) propertyNames = [[NSMutableSet alloc] initWithCapacity:3];
                [propertyNames addObject:value.propertyName];
                [changedOrderedPropertiesByGlobalId setObject:propertyNames forKey:globalId];
            }
        }
    }
    
    NSArray *allGlobalIds = changedOrderedPropertiesByGlobalId.cde_allKeys;
    NSDictionary *globalIdsByEntity = [self entityGroupedGlobalIdentifiersForIdentifiers:allGlobalIds];
    NSMutableArray *relatedObjects = [[NSMutableArray alloc] init];
    for (NSString *entityName in globalIdsByEntity) {
        NSError *error;
        NSArray *globalIds = globalIdsByEntity[entityName];
        NSMapTable *objectsByGlobalId = [self fetchObjectsByGlobalIdentifierForEntityName:entityName globalIdentifiers:globalIds error:&error];
        for (CDEGlobalIdentifier *globalId in globalIds) {
            NSSet *changedOrderedProperties = [changedOrderedPropertiesByGlobalId objectForKey:globalId];
            NSManagedObject *object = [objectsByGlobalId objectForKey:globalId];
            for (NSString *propertyName in changedOrderedProperties) {
                NSOrderedSet *relatedSet = [object valueForKey:propertyName];
                [relatedObjects addObjectsFromArray:relatedSet.array];
            }
        }
    }
    
    NSArray *objectIDs = [relatedObjects valueForKeyPath:@"objectID"];
    NSArray *globalIds = [CDEGlobalIdentifier fetchGlobalIdentifiersForObjectIDs:objectIDs inManagedObjectContext:self.eventStore.managedObjectContext];
    
    NSMapTable *relatedObjectsByGlobalId = [NSMapTable cde_strongToStrongObjectsMapTable];
    [relatedObjects enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        CDEGlobalIdentifier *globalId = globalIds[index];
        if (globalId == (id)[NSNull null]) {
            CDELog(CDELoggingLevelError, @"A global identifier was not found for an ordered-relationship object");
            return;
        }
        [relatedObjectsByGlobalId setObject:object forKey:globalId.globalIdentifier];
    }];
    
    return relatedObjectsByGlobalId;
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

- (NSArray *)fetchGlobalIdentifiersForIdentifierStrings:(id)idStrings
{
    NSError *error;
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEGlobalIdentifier"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"globalIdentifier IN %@", idStrings];
    NSArray *globalIds = [self.eventStore.managedObjectContext executeFetchRequest:fetch error:&error];
    if (!globalIds) CDELog(CDELoggingLevelError, @"Error fetching ids: %@", error);
    return globalIds;
}

- (NSSet *)globalIdentifierStringsInObjectChanges:(id)objectChanges relationshipsToInclude:(NSArray *)relationships
{
    NSSet *relationshipNames = [NSSet setWithArray:[relationships valueForKeyPath:@"name"]];
    NSMutableSet *globalIdStrings = [NSMutableSet setWithCapacity:[objectChanges count]*3];
    for (CDEObjectChange *change in objectChanges) {
        [globalIdStrings addObject:change.globalIdentifier.globalIdentifier];
        
        NSArray *propertyChangeValues = change.propertyChangeValues;
        for (CDEPropertyChangeValue *value in propertyChangeValues) {
            if (relationships && ![relationshipNames containsObject:value.propertyName]) continue;
            if (value.relatedIdentifier) [globalIdStrings addObject:value.relatedIdentifier];
            if (value.addedIdentifiers) [globalIdStrings unionSet:value.addedIdentifiers];
            if (value.removedIdentifiers) [globalIdStrings unionSet:value.removedIdentifiers];
            if (value.movedIdentifiersByIndex) [globalIdStrings addObjectsFromArray:value.movedIdentifiersByIndex.allValues];
        }
    }
    return globalIdStrings;
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
