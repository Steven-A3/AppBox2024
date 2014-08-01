//
//  CDEObjectGraphMigrator.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 16/04/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import "CDEObjectGraphMigrator.h"
#import "NSMapTable+CDEAdditions.h"
#import "CDEFoundationAdditions.h"
#import "CDEStoreModificationEvent.h"
#import "CDEEventRevision.h"

@implementation CDEObjectGraphMigrator {
    NSMapTable *toStoreObjectsByFromStoreObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        toStoreObjectsByFromStoreObject = [NSMapTable cde_strongToStrongObjectsMapTable];
    }
    return self;
}

- (NSManagedObject *)migrateObject:(NSManagedObject *)fromStoreObject andRelatedObjectsToManagedObjectContext:(NSManagedObjectContext *)toContext
{
    if (fromStoreObject == nil) return nil;
    
    NSManagedObject *migratedObject = [toStoreObjectsByFromStoreObject objectForKey:fromStoreObject];
    if (migratedObject) return migratedObject;
    
    // Migrated object doesn't exist, so create it
    NSString *entityName = fromStoreObject.entity.name;
    migratedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:toContext];
    [self.class copyAttributesFromManagedObject:fromStoreObject toManagedObject:migratedObject];
    
    // Add object to map
    [self registerMigratedObject:migratedObject forOriginalObject:fromStoreObject];
    
    // Migrate related objects recursively
    NSDictionary *relationships = fromStoreObject.entity.relationshipsByName;
    for (NSRelationshipDescription *relationship in relationships.allValues) {
        if (relationship.isTransient) continue;
        
        NSString *exclude = relationship.userInfo[@"excludeFromMigration"];
        if (exclude && [exclude boolValue]) continue;
        
        if (relationship.isToMany) {
            // To-many relationship
            id fromStoreRelatives = [fromStoreObject valueForKey:relationship.name];
            for (NSManagedObject *fromRelative in fromStoreRelatives) {
                NSManagedObject *toStoreRelative = [self migrateObject:fromRelative andRelatedObjectsToManagedObjectContext:toContext];
                if (relationship.isOrdered)
                    [[migratedObject mutableOrderedSetValueForKey:relationship.name] addObject:toStoreRelative];
                else
                    [[migratedObject mutableSetValueForKey:relationship.name] addObject:toStoreRelative];
            }
        }
        else {
            // To-one relationship
            NSManagedObject *fromStoreRelative = [fromStoreObject valueForKey:relationship.name];
            NSManagedObject *toStoreRelative = [self migrateObject:fromStoreRelative andRelatedObjectsToManagedObjectContext:toContext];
            [migratedObject setValue:toStoreRelative forKey:relationship.name];
        }
    }
    
    return migratedObject;
}

- (void)registerMigratedObject:(NSManagedObject *)migratedObject forOriginalObject:(NSManagedObject *)originalObject
{
    [toStoreObjectsByFromStoreObject setObject:migratedObject forKey:originalObject];
}

- (void)registerMigratedObjectsByOriginalObjects:(NSMapTable *)registeredByOriginal
{
    [toStoreObjectsByFromStoreObject cde_addEntriesFromMapTable:registeredByOriginal];
}

- (void)clearRegisteredObjects
{
    [toStoreObjectsByFromStoreObject removeAllObjects];
}

+ (void)copyAttributesFromManagedObject:(NSManagedObject *)fromObject toManagedObject:(NSManagedObject *)toObject
{
    for (NSAttributeDescription *attribute in fromObject.entity.attributesByName.allValues) {
        if (attribute.isTransient) continue;
        
        NSString *exclude = attribute.userInfo[@"excludeFromMigration"];
        if (exclude && [exclude boolValue]) continue;
        
        NSString *key = attribute.name;
        [toObject setValue:[fromObject valueForKey:key] forKey:key];
    }
}

+ (NSMapTable *)migrateEntity:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)fromContext toContext:(NSManagedObjectContext *)toContext enforceUniquenessForAttributes:(NSArray *)uniqueAttributes error:(NSError * __autoreleasing *)error
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray *fromContextObjects = [fromContext executeFetchRequest:fetch error:error];
    if (!fromContextObjects) return nil;
    
    NSFetchRequest *toContextFetch = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSArray *toContextObjects = [toContext executeFetchRequest:toContextFetch error:error];
    if (!toContextObjects) return nil;
    
    NSArray *toStoreKeys = [self uniqueKeysForManagedObjects:toContextObjects uniqueAttributes:uniqueAttributes];
    NSArray *fromStoreKeys = [self uniqueKeysForManagedObjects:fromContextObjects uniqueAttributes:uniqueAttributes];
    
    NSDictionary *toStoreObjectsByUniqueValue = [[NSDictionary alloc] initWithObjects:toContextObjects forKeys:toStoreKeys];
    NSDictionary *fromStoreObjectsByUniqueValue = [[NSDictionary alloc] initWithObjects:fromContextObjects forKeys:fromStoreKeys];
    
    NSMapTable *toObjectByFromObject = [NSMapTable cde_strongToStrongObjectsMapTable];
    [fromStoreObjectsByUniqueValue.allKeys cde_enumerateObjectsDrainingEveryIterations:100 usingBlock:^(id uniqueValue, NSUInteger index, BOOL *stop) {
        NSManagedObject *toContextObject = toStoreObjectsByUniqueValue[uniqueValue];
        NSManagedObject *fromContextObject = fromStoreObjectsByUniqueValue[uniqueValue];
        
        if (toContextObject) {
            [toObjectByFromObject setObject:toContextObject forKey:fromContextObject];
            return;
        }
        
        toContextObject = [NSEntityDescription insertNewObjectForEntityForName:fromContextObject.entity.name inManagedObjectContext:toContext];
        [self copyAttributesFromManagedObject:fromContextObject toManagedObject:toContextObject];
        
        [toObjectByFromObject setObject:toContextObject forKey:fromContextObject];
    }];
    
    return toObjectByFromObject;
}

+ (NSMapTable *)migrateGlobalIdentifiersInManagedObjectContext:(NSManagedObjectContext *)fromContext toContext:(NSManagedObjectContext *)toContext error:(NSError * __autoreleasing *)error
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEGlobalIdentifier"];
    NSArray *fromContextGlobalIds = [fromContext executeFetchRequest:fetch error:error];
    if (!fromContextGlobalIds) return nil;
    
    NSFetchRequest *toContextFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEGlobalIdentifier"];
    toContextFetch.predicate = [NSPredicate predicateWithFormat:@"globalIdentifier IN %@", [fromContextGlobalIds valueForKeyPath:@"globalIdentifier"]];
    NSArray *toContextGlobalIds = [toContext executeFetchRequest:toContextFetch error:error];
    if (!toContextGlobalIds) return nil;
    
    NSArray *uniqueAttributes = @[@"nameOfEntity", @"globalIdentifier"];
    NSArray *toStoreKeys = [self uniqueKeysForManagedObjects:toContextGlobalIds uniqueAttributes:uniqueAttributes];
    NSArray *fromStoreKeys = [self uniqueKeysForManagedObjects:fromContextGlobalIds uniqueAttributes:uniqueAttributes];
    
    NSDictionary *toStoreObjectsByUniqueValue = [[NSDictionary alloc] initWithObjects:toContextGlobalIds forKeys:toStoreKeys];
    NSDictionary *fromStoreObjectsByUniqueValue = [[NSDictionary alloc] initWithObjects:fromContextGlobalIds forKeys:fromStoreKeys];
    
    NSMapTable *toObjectByFromObject = [NSMapTable cde_strongToStrongObjectsMapTable];
    [fromStoreObjectsByUniqueValue.allKeys cde_enumerateObjectsDrainingEveryIterations:100 usingBlock:^(id uniqueValue, NSUInteger index, BOOL *stop) {
        NSManagedObject *toContextObject = toStoreObjectsByUniqueValue[uniqueValue];
        NSManagedObject *fromContextObject = fromStoreObjectsByUniqueValue[uniqueValue];
        
        if (toContextObject) {
            [toObjectByFromObject setObject:toContextObject forKey:fromContextObject];
            return;
        }
        
        toContextObject = [NSEntityDescription insertNewObjectForEntityForName:fromContextObject.entity.name inManagedObjectContext:toContext];
        [self copyAttributesFromManagedObject:fromContextObject toManagedObject:toContextObject];
        
        [toObjectByFromObject setObject:toContextObject forKey:fromContextObject];
    }];
    
    return toObjectByFromObject;
}

+ (NSArray *)uniqueKeysForManagedObjects:(NSArray *)objects uniqueAttributes:(NSArray *)uniqueAttributes
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    [objects cde_enumerateObjectsDrainingEveryIterations:100 usingBlock:^(NSManagedObject *object, NSUInteger index, BOOL *stop) {
        NSMutableString *key = [[NSMutableString alloc] init];
        for (NSString *attribute in uniqueAttributes) {
            [key appendString:[[object valueForKeyPath:attribute] description]];
            [key appendString:@"__"];
        }
        [keys addObject:key];
        if (!object.hasChanges) [object.managedObjectContext refreshObject:object mergeChanges:NO];
    }];
    return keys;
}

+ (CDEStoreModificationEvent *)migrateEventAndRevisions:(CDEStoreModificationEvent *)theEvent toContext:(NSManagedObjectContext *)context
{
    if (!theEvent) return nil;
    
    // Create event
    CDEStoreModificationEvent *newMigratedEvent = [NSEntityDescription insertNewObjectForEntityForName:@"CDEStoreModificationEvent" inManagedObjectContext:context];
    [CDEObjectGraphMigrator copyAttributesFromManagedObject:theEvent toManagedObject:newMigratedEvent];
    
    // Event Revision
    CDEEventRevision *migratedEventRevision = [NSEntityDescription insertNewObjectForEntityForName:@"CDEEventRevision" inManagedObjectContext:context];
    [CDEObjectGraphMigrator copyAttributesFromManagedObject:theEvent.eventRevision toManagedObject:(id)migratedEventRevision];
    migratedEventRevision.storeModificationEvent = newMigratedEvent;
    
    // Other Revisions
    for (CDEEventRevision *otherRevision in theEvent.eventRevisionsOfOtherStores) {
        migratedEventRevision = [NSEntityDescription insertNewObjectForEntityForName:@"CDEEventRevision" inManagedObjectContext:context];
        [CDEObjectGraphMigrator copyAttributesFromManagedObject:otherRevision toManagedObject:migratedEventRevision];
        migratedEventRevision.storeModificationEventForOtherStores = newMigratedEvent;
    }
    
    [context processPendingChanges];
    
    return newMigratedEvent;
}

@end
