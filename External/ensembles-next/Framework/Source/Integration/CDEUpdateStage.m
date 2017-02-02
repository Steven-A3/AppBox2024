//
//  CDEIntegrationUpdater.m
//  Ensembles iOS
//
//  Created by Drew McCormack on 02/05/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import "CDEUpdateStage.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "CDEFoundationAdditions.h"
#import "NSMapTable+CDEAdditions.h"
#import "CDEDefines.h"
#import "CDEEventStore.h"
#import "CDEGlobalIdentifier.h"
#import "CDEPropertyChangeValue.h"
#import "CDEObjectChange.h"

@implementation CDEUpdateStage

- (BOOL)applyChangeIDs:(NSArray *)changeIDs error:(NSError * __autoreleasing *)error
{
    NSManagedObjectContext *eventContext = self.eventStore.managedObjectContext;
    NSArray *changes = [changeIDs cde_arrayByTransformingObjectsWithBlock:^(NSManagedObjectID *changeID) {
        return [eventContext objectWithID:changeID];
    }];
    
    BOOL success = [self applyObjectChanges:changes error:error];
    return success;
}

// Called on event context queue
- (BOOL)applyObjectChanges:(NSArray *)changes error:(NSError * __autoreleasing *)error
{
    if (changes.count == 0) return YES;
    
    NSDictionary *objectsByGlobalIdStringByEntity = [self fetchObjectsByGlobalIdStringByEntityNameForChanges:changes relationshipsToInclude:self.relationshipsToUpdate error:error];
    NSMutableDictionary *globalIdStringsByObjectByEntity = [[NSMutableDictionary alloc] initWithCapacity:10];
    for (NSString *entityName in objectsByGlobalIdStringByEntity) {
        NSMapTable *objectsByGlobalIdString = objectsByGlobalIdStringByEntity[entityName];
        if (!objectsByGlobalIdString) return NO;
        
        NSMapTable *globalIdStringsByObject = [NSMapTable cde_strongToStrongObjectsMapTable];
        for (NSString *globalIdString in objectsByGlobalIdString) {
            id object = [objectsByGlobalIdString objectForKey:globalIdString];
            [globalIdStringsByObject setObject:globalIdString forKey:object];
        }
        globalIdStringsByObjectByEntity[entityName] = globalIdStringsByObject;
    }
    
    NSSet *relationshipNames = [NSSet setWithArray:[self.relationshipsToUpdate valueForKeyPath:@"name"]];
    NSPredicate *attributePredicate = [NSPredicate predicateWithFormat:@"type = %d", CDEPropertyChangeTypeAttribute];
    NSPredicate *toOneRelationshipPredicate = [NSPredicate predicateWithFormat:@"type = %d AND propertyName IN %@", CDEPropertyChangeTypeToOneRelationship, relationshipNames];
    NSPredicate *toManyRelationshipPredicate = [NSPredicate predicateWithFormat:@"type = %d AND propertyName IN %@", CDEPropertyChangeTypeToManyRelationship, relationshipNames];
    NSPredicate *orderedToManyRelationshipPredicate = [NSPredicate predicateWithFormat:@"type = %d AND propertyName IN %@", CDEPropertyChangeTypeOrderedToManyRelationship, relationshipNames];
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    NSMutableArray *propertyChangeValuesForObjects = [[NSMutableArray alloc] init];
    for (CDEObjectChange *change in changes) {
        NSString *entityName = change.nameOfEntity;
        NSMapTable *objectsByGlobalId = objectsByGlobalIdStringByEntity[entityName];
        NSManagedObject *object = [objectsByGlobalId objectForKey:change.globalIdentifier.globalIdentifier];
        NSArray *propertyChangeValues = change.propertyChangeValues;
        if (!object || propertyChangeValues.count == 0) continue;
        
        [objects addObject:object];
        [propertyChangeValuesForObjects addObject:propertyChangeValues];
    }
        
    __block BOOL success = YES;
    __block NSError *localError = nil;
    [self.managedObjectContext performBlockAndWait:^{
        @try {
            [objects cde_enumerateObjectsDrainingEveryIterations:100 usingBlock:^(NSManagedObject *object, NSUInteger index, BOOL *stop) {
                NSArray *propertyChangeValues = propertyChangeValuesForObjects[index];
                
                // Attribute changes
                if (self.updatesAttributes) {
                    NSArray *attributeChanges = [propertyChangeValues filteredArrayUsingPredicate:attributePredicate];
                    [self applyAttributeChanges:attributeChanges toObject:object];
                }
                
                // To-one relationship changes
                NSArray *toOneChanges = [propertyChangeValues filteredArrayUsingPredicate:toOneRelationshipPredicate];
                [self applyToOneRelationshipChanges:toOneChanges toObject:object withObjectsByGlobalIdByEntityName:objectsByGlobalIdStringByEntity];
                
                // To-many relationship changes
                NSArray *toManyChanges = [propertyChangeValues filteredArrayUsingPredicate:toManyRelationshipPredicate];
                [self applyToManyRelationshipChanges:toManyChanges toObject:object withObjectsByGlobalIdByEntityName:objectsByGlobalIdStringByEntity];
                
                // Ordered to-many relationship changes
                NSArray *orderedToManyChanges = [propertyChangeValues filteredArrayUsingPredicate:orderedToManyRelationshipPredicate];
                [self applyOrderedToManyRelationshipChanges:orderedToManyChanges toObject:object withObjectsByGlobalIdByEntityName:objectsByGlobalIdStringByEntity andGlobalIdsByObjectByEntityName:globalIdStringsByObjectByEntity];
            }];
        }
        @catch (NSException *exception) {
            localError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeUnknown userInfo:@{NSLocalizedFailureReasonErrorKey:exception.reason}];
            success = NO;
        }
    }];
    
    if (error) *error = localError;

    return success;
}

// Called on main context queue
- (void)applyAttributeChanges:(NSArray *)properyChangeValues toObject:(NSManagedObject *)object
{
    NSEntityDescription *entity = object.entity;
    for (CDEPropertyChangeValue *changeValue in properyChangeValues) {
        NSAttributeDescription *attribute = entity.attributesByName[changeValue.propertyName];
        if (!attribute) {
            // Likely attribute removed from model since change
            CDELog(CDELoggingLevelWarning, @"Attribute from change value not in model: %@", changeValue.propertyName);
            continue;
        }
        
        changeValue.eventStore = self.eventStore; // Needed to retrieve data files
        id newValue = [changeValue attributeValueForAttributeDescription:attribute];
        [self.class setValue:newValue forKey:changeValue.propertyName inObject:object];
    }
}

// Called on main context queue
- (void)applyToOneRelationshipChanges:(NSArray *)changes toObject:(NSManagedObject *)object withObjectsByGlobalIdByEntityName:(NSDictionary *)objectsByGlobalIdByEntityName
{
    NSMutableDictionary *destinationEntitiesByEntityName = [[NSMutableDictionary alloc] init];
    NSEntityDescription *entity = object.entity;
    for (CDEPropertyChangeValue *relationshipChange in changes) {
        NSRelationshipDescription *relationship = entity.relationshipsByName[relationshipChange.propertyName];
        if (!relationship || relationship.isToMany) {
            CDELog(CDELoggingLevelWarning, @"Could not find relationship in entity, or found a to-many relationship for a to-one property change. Skipping: %@ %@", relationshipChange.propertyName, relationshipChange.relatedIdentifier);
            continue;
        }
        
        id newRelatedObject = nil;
        if (relationshipChange.relatedIdentifier && (id)relationshipChange.relatedIdentifier != [NSNull null]) {
            // A relationship may reference descendent entities
            NSString *destinationName = relationship.destinationEntity.name;
            NSArray *destinationEntities = destinationEntitiesByEntityName[destinationName];
            if (!destinationEntities) {
                destinationEntities = [relationship.destinationEntity cde_descendantEntities];
                destinationEntities = [destinationEntities arrayByAddingObject:relationship.destinationEntity];
                destinationEntitiesByEntityName[destinationName] = destinationEntities;
            }
            
            for (NSEntityDescription *relatedEntity in destinationEntities) {
                NSMapTable *objectsByGlobalId = objectsByGlobalIdByEntityName[relatedEntity.name];
                newRelatedObject = [objectsByGlobalId objectForKey:relationshipChange.relatedIdentifier];
                if (newRelatedObject) break;
            }
            
            if (!newRelatedObject) {
                CDELog(CDELoggingLevelVerbose, @"Could not find object for identifier while setting to-one relationship. Skipping: %@ in %@ for %@", relationshipChange.propertyName, entity.name, relationshipChange.relatedIdentifier);
                continue;
            }
        }
        
        [self.class setValue:newRelatedObject forKey:relationshipChange.propertyName inObject:object];
    }
}

// Called on main context queue
- (void)applyToManyRelationshipChanges:(NSArray *)changes toObject:(NSManagedObject *)object withObjectsByGlobalIdByEntityName:(NSDictionary *)objectsByGlobalIdByEntityName
{
    NSMutableDictionary *destinationEntitiesByEntityName = [[NSMutableDictionary alloc] init];
    NSEntityDescription *entity = object.entity;
    for (CDEPropertyChangeValue *relationshipChange in changes) {
        NSRelationshipDescription *relationship = entity.relationshipsByName[relationshipChange.propertyName];
        if (!relationship || !relationship.isToMany) {
            CDELog(CDELoggingLevelWarning, @"Could not find relationship in entity, or found a to-one relationship for a to-many property change. Skipping: %@ %@", relationshipChange.propertyName, relationshipChange.relatedIdentifier);
            continue;
        }
        
        // A relationship may reference descendent entities
        NSString *destinationName = relationship.destinationEntity.name;
        NSArray *destinationEntities = destinationEntitiesByEntityName[destinationName];
        if (!destinationEntities) {
            destinationEntities = [relationship.destinationEntity cde_descendantEntities];
            destinationEntities = [destinationEntities arrayByAddingObject:relationship.destinationEntity];
            destinationEntitiesByEntityName[destinationName] = destinationEntities;
        }
        
        NSMutableSet *relatedObjects = [object mutableSetValueForKey:relationshipChange.propertyName];
        for (NSString *identifier in relationshipChange.addedIdentifiers) {
            id newRelatedObject = nil;
        
            for (NSEntityDescription *relatedEntity in destinationEntities) {
                NSMapTable *objectsByGlobalId = objectsByGlobalIdByEntityName[relatedEntity.name];
                newRelatedObject = [objectsByGlobalId objectForKey:identifier];
                if (newRelatedObject) break;
            }
            
            if (newRelatedObject) [relatedObjects addObject:newRelatedObject];
        }
        
        for (NSString *identifier in relationshipChange.removedIdentifiers) {            
            for (NSEntityDescription *relatedEntity in destinationEntities) {
                NSMapTable *objectsByGlobalId = objectsByGlobalIdByEntityName[relatedEntity.name];
                id removedObject = [objectsByGlobalId objectForKey:identifier];
                if (removedObject) {
                    [relatedObjects removeObject:removedObject];
                    break;
                }
            }
        }
    }
}

// Called on main context queue
- (void)applyOrderedToManyRelationshipChanges:(NSArray *)changes toObject:(NSManagedObject *)object withObjectsByGlobalIdByEntityName:(NSDictionary *)objectsByGlobalIdByEntityName andGlobalIdsByObjectByEntityName:(NSDictionary *)globalIdsByObjectByEntityName
{
    NSMutableDictionary *destinationEntitiesByEntityName = [[NSMutableDictionary alloc] init];
    NSEntityDescription *entity = object.entity;
    for (CDEPropertyChangeValue *relationshipChange in changes) {
        NSRelationshipDescription *relationship = entity.relationshipsByName[relationshipChange.propertyName];
        if (!relationship || !relationship.isToMany || !relationship.isOrdered) {
            CDELog(CDELoggingLevelWarning, @"Could not find relationship in entity, or found the wrong type of relationship. Skipping: %@ %@", relationshipChange.propertyName, relationshipChange.relatedIdentifier);
            continue;
        }
        
        // A relationship may reference descendent entities
        NSString *destinationName = relationship.destinationEntity.name;
        NSArray *destinationEntities = destinationEntitiesByEntityName[destinationName];
        if (!destinationEntities) {
            destinationEntities = [relationship.destinationEntity cde_descendantEntities];
            destinationEntities = [destinationEntities arrayByAddingObject:relationship.destinationEntity];
            destinationEntitiesByEntityName[destinationName] = destinationEntities;
        }
        
        // Merge indexes for global ids
        NSMutableOrderedSet *relatedObjects = [[object valueForKey:relationshipChange.propertyName] mutableCopy];
        NSMapTable *finalIndexesByObject = [NSMapTable cde_strongToStrongObjectsMapTable];
        for (NSUInteger index = 0; index < relatedObjects.count; index++) {
            [finalIndexesByObject setObject:@(index) forKey:relatedObjects[index]];
        }
        
        // Gather related objects
        for (NSEntityDescription *relatedEntity in destinationEntities) {
            // Added objects
            NSMapTable *objectsByGlobalId = objectsByGlobalIdByEntityName[relatedEntity.name];
            for (NSString *identifier in relationshipChange.addedIdentifiers) {
                id newRelatedObject = [objectsByGlobalId objectForKey:identifier];
                if (newRelatedObject) [relatedObjects addObject:newRelatedObject];
            }
            
            // Delete removed objects
            for (NSString *identifier in relationshipChange.removedIdentifiers) {
                id removedObject = [objectsByGlobalId objectForKey:identifier];
                if (removedObject) [relatedObjects removeObject:removedObject];
            }
        }
        
        // Determine indexes for objects in the moved identifiers
        NSDictionary *movedIdentifiersByIndex = relationshipChange.movedIdentifiersByIndex;
        for (NSNumber *index in movedIdentifiersByIndex.allKeys) {
            NSString *globalId = movedIdentifiersByIndex[index];
            for (NSEntityDescription *relatedEntity in destinationEntities) {
                NSMapTable *objectsByGlobalId = objectsByGlobalIdByEntityName[relatedEntity.name];
                id relatedObject = [objectsByGlobalId objectForKey:globalId];
                if (relatedObject) {
                    [finalIndexesByObject setObject:(index) forKey:relatedObject];
                    break;
                }
            }
        }
        
        // Apply new ordering. Sort first on index, and use global id to resolve conflicts.
        [relatedObjects sortUsingComparator:^NSComparisonResult(id object1, id object2) {
            NSNumber *index1 = [finalIndexesByObject objectForKey:object1];
            NSNumber *index2 = [finalIndexesByObject objectForKey:object2];
            NSComparisonResult indexResult = [index1 compare:index2];
            
            if (indexResult != NSOrderedSame) return indexResult;
            
            NSComparisonResult globalIdResult = NSOrderedSame;
            NSString *globalId1 = nil, *globalId2 = nil;
            for (NSEntityDescription *relatedEntity in destinationEntities) {
                NSMapTable *globalIdsByObject = globalIdsByObjectByEntityName[relatedEntity.name];
                if (!globalId1) globalId1 = [globalIdsByObject objectForKey:object1];
                if (!globalId2) globalId2 = [globalIdsByObject objectForKey:object2];
                
                if (globalId1 && globalId2) {
                    globalIdResult = [globalId1 compare:globalId2];
                    break;
                }
            }
            
            NSAssert(globalId1 && globalId2, @"Did not find both global ids when sorting ordered relationship");
            
            return globalIdResult;
        }];
        
        [object setValue:relatedObjects forKey:relationshipChange.propertyName];
    }
}


@end
