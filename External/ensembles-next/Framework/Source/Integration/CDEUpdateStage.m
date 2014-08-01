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
    
    NSMapTable *objectsByGlobalId = [self fetchObjectsByGlobalIdentifierForChanges:changes relationshipsToInclude:self.relationshipsToUpdate error:error];
    if (!objectsByGlobalId) return NO;
    
    NSMapTable *globalIdsByObject = [NSMapTable cde_strongToStrongObjectsMapTable];
    for (CDEGlobalIdentifier *globalId in objectsByGlobalId) {
        id object = [objectsByGlobalId objectForKey:globalId];
        [globalIdsByObject setObject:globalId forKey:object];
    }
    
    @try {
        NSSet *relationshipNames = [NSSet setWithArray:[self.relationshipsToUpdate valueForKeyPath:@"name"]];
        NSPredicate *attributePredicate = [NSPredicate predicateWithFormat:@"type = %d", CDEPropertyChangeTypeAttribute];
        NSPredicate *toOneRelationshipPredicate = [NSPredicate predicateWithFormat:@"type = %d AND propertyName IN %@", CDEPropertyChangeTypeToOneRelationship, relationshipNames];
        NSPredicate *toManyRelationshipPredicate = [NSPredicate predicateWithFormat:@"type = %d AND propertyName IN %@", CDEPropertyChangeTypeToManyRelationship, relationshipNames];
        NSPredicate *orderedToManyRelationshipPredicate = [NSPredicate predicateWithFormat:@"type = %d AND propertyName IN %@", CDEPropertyChangeTypeOrderedToManyRelationship, relationshipNames];
        
        for (CDEObjectChange *change in changes) {
            @autoreleasepool {
                NSManagedObject *object = [objectsByGlobalId objectForKey:change.globalIdentifier.globalIdentifier];
                NSArray *propertyChangeValues = change.propertyChangeValues;
                if (!object || propertyChangeValues.count == 0) continue;
                
                [self.managedObjectContext performBlockAndWait:^{
                    // Attribute changes
                    if (self.updatesAttributes) {
                        NSArray *attributeChanges = [propertyChangeValues filteredArrayUsingPredicate:attributePredicate];
                        [self applyAttributeChanges:attributeChanges toObject:object];
                    }

                    // To-one relationship changes
                    NSArray *toOneChanges = [propertyChangeValues filteredArrayUsingPredicate:toOneRelationshipPredicate];
                    [self applyToOneRelationshipChanges:toOneChanges toObject:object withObjectsByGlobalId:objectsByGlobalId];
                    
                    // To-many relationship changes
                    NSArray *toManyChanges = [propertyChangeValues filteredArrayUsingPredicate:toManyRelationshipPredicate];
                    [self applyToManyRelationshipChanges:toManyChanges toObject:object withObjectsByGlobalId:objectsByGlobalId];
                    
                    // Ordered to-many relationship changes
                    NSArray *orderedToManyChanges = [propertyChangeValues filteredArrayUsingPredicate:orderedToManyRelationshipPredicate];
                    [self applyOrderedToManyRelationshipChanges:orderedToManyChanges toObject:object withObjectsByGlobalId:objectsByGlobalId andGlobalIdsByObject:globalIdsByObject];
                }];
            }
        }
    }
    @catch (NSException *exception) {
        *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeUnknown userInfo:@{NSLocalizedFailureReasonErrorKey:exception.reason}];
        return NO;
    }
    
    return YES;
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
- (void)applyToOneRelationshipChanges:(NSArray *)changes toObject:(NSManagedObject *)object withObjectsByGlobalId:(NSMapTable *)objectsByGlobalId
{
    NSEntityDescription *entity = object.entity;
    for (CDEPropertyChangeValue *relationshipChange in changes) {
        NSRelationshipDescription *relationship = entity.relationshipsByName[relationshipChange.propertyName];
        if (!relationship || relationship.isToMany) {
            CDELog(CDELoggingLevelWarning, @"Could not find relationship in entity, or found a to-many relationship for a to-one property change. Skipping: %@ %@", relationshipChange.propertyName, relationshipChange.relatedIdentifier);
            continue;
        }
        
        id newRelatedObject = nil;
        if (relationshipChange.relatedIdentifier && (id)relationshipChange.relatedIdentifier != [NSNull null]) {
            newRelatedObject = [objectsByGlobalId objectForKey:relationshipChange.relatedIdentifier];
            if (!newRelatedObject) {
                CDELog(CDELoggingLevelVerbose, @"Could not find object for identifier while setting to-one relationship. Skipping: %@ in %@ for %@", relationshipChange.propertyName, entity.name, relationshipChange.relatedIdentifier);
                continue;
            }
        }
        
        [self.class setValue:newRelatedObject forKey:relationshipChange.propertyName inObject:object];
    }
}

// Called on main context queue
- (void)applyToManyRelationshipChanges:(NSArray *)changes toObject:(NSManagedObject *)object withObjectsByGlobalId:(NSMapTable *)objectsByGlobalId
{
    NSEntityDescription *entity = object.entity;
    for (CDEPropertyChangeValue *relationshipChange in changes) {
        NSRelationshipDescription *relationship = entity.relationshipsByName[relationshipChange.propertyName];
        if (!relationship || !relationship.isToMany) {
            CDELog(CDELoggingLevelWarning, @"Could not find relationship in entity, or found a to-one relationship for a to-many property change. Skipping: %@ %@", relationshipChange.propertyName, relationshipChange.relatedIdentifier);
            continue;
        }
        
        NSMutableSet *relatedObjects = [object mutableSetValueForKey:relationshipChange.propertyName];
        for (NSString *identifier in relationshipChange.addedIdentifiers) {
            id newRelatedObject = [objectsByGlobalId objectForKey:identifier];
            if (newRelatedObject)
                [relatedObjects addObject:newRelatedObject];
            else
                CDELog(CDELoggingLevelVerbose, @"Could not find object with identifier while adding to relationship. Skipping: %@ in %@ for %@", relationshipChange.propertyName, entity.name, identifier);
        }
        
        for (NSString *identifier in relationshipChange.removedIdentifiers) {
            id removedObject = [objectsByGlobalId objectForKey:identifier];
            if (removedObject) [relatedObjects removeObject:removedObject];
        }
    }
}

// Called on main context queue
- (void)applyOrderedToManyRelationshipChanges:(NSArray *)changes toObject:(NSManagedObject *)object withObjectsByGlobalId:(NSMapTable *)objectsByGlobalId andGlobalIdsByObject:(NSMapTable *)globalIdsByObject
{
    NSEntityDescription *entity = object.entity;
    for (CDEPropertyChangeValue *relationshipChange in changes) {
        NSRelationshipDescription *relationship = entity.relationshipsByName[relationshipChange.propertyName];
        if (!relationship || !relationship.isToMany || !relationship.isOrdered) {
            CDELog(CDELoggingLevelWarning, @"Could not find relationship in entity, or found the wrong type of relationship. Skipping: %@ %@", relationshipChange.propertyName, relationshipChange.relatedIdentifier);
            continue;
        }
        
        // Merge indexes for global ids
        NSMutableOrderedSet *relatedObjects = [object mutableOrderedSetValueForKey:relationshipChange.propertyName];
        NSMapTable *finalIndexesByObject = [NSMapTable cde_strongToStrongObjectsMapTable];
        for (NSUInteger index = 0; index < relatedObjects.count; index++) {
            [finalIndexesByObject setObject:@(index) forKey:relatedObjects[index]];
        }
        
        // Added objects
        for (NSString *identifier in relationshipChange.addedIdentifiers) {
            id newRelatedObject = [objectsByGlobalId objectForKey:identifier];
            if (newRelatedObject)
                [relatedObjects addObject:newRelatedObject];
            else
                CDELog(CDELoggingLevelWarning, @"Could not find object with identifier while adding to relationship. Skipping: %@", identifier);
        }
        
        // Delete removed objects
        for (NSString *identifier in relationshipChange.removedIdentifiers) {
            id removedObject = [objectsByGlobalId objectForKey:identifier];
            if (removedObject) [relatedObjects removeObject:removedObject];
        }
        
        // Determine indexes for objects in the moved identifiers
        NSDictionary *movedIdentifiersByIndex = relationshipChange.movedIdentifiersByIndex;
        for (NSNumber *index in movedIdentifiersByIndex.allKeys) {
            NSString *globalId = movedIdentifiersByIndex[index];
            id relatedObject = [objectsByGlobalId objectForKey:globalId];
            [finalIndexesByObject setObject:(index) forKey:relatedObject];
        }
        
        // Apply new ordering. Sort first on index, and use global id to resolve conflicts.
        [relatedObjects sortUsingComparator:^NSComparisonResult(id object1, id object2) {
            NSNumber *index1 = [finalIndexesByObject objectForKey:object1];
            NSNumber *index2 = [finalIndexesByObject objectForKey:object2];
            NSComparisonResult indexResult = [index1 compare:index2];
            
            if (indexResult != NSOrderedSame) return indexResult;
            
            NSString *globalId1 = [globalIdsByObject objectForKey:object1];
            NSString *globalId2 = [globalIdsByObject objectForKey:object2];
            NSComparisonResult globalIdResult = [globalId1 compare:globalId2];
            
            return globalIdResult;
        }];
    }
}


@end
