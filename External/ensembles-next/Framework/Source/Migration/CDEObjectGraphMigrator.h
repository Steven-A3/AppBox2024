//
//  CDEObjectGraphMigrator.h
//  Ensembles Mac
//
//  Created by Drew McCormack on 16/04/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDEStoreModificationEvent;

@interface CDEObjectGraphMigrator : NSObject

- (NSManagedObject *)migrateObject:(NSManagedObject *)fromStoreObject andRelatedObjectsToManagedObjectContext:(NSManagedObjectContext *)toContext;

- (void)registerMigratedObject:(NSManagedObject *)migratedObject forOriginalObject:(NSManagedObject *)originalObject;
- (void)registerMigratedObjectsByOriginalObjects:(NSMapTable *)registeredByOriginal;
- (void)clearRegisteredObjects;

+ (CDEStoreModificationEvent *)migrateEventAndRevisions:(CDEStoreModificationEvent *)theEvent toContext:(NSManagedObjectContext *)context;
+ (NSMapTable *)migrateEntity:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)fromContext toContext:(NSManagedObjectContext *)toContext enforceUniquenessForAttributes:(NSArray *)uniqueAttributes error:(NSError * __autoreleasing *)error;
+ (void)copyAttributesFromManagedObject:(NSManagedObject *)fromObject toManagedObject:(NSManagedObject *)toObject;

+ (NSMapTable *)migrateGlobalIdentifiersInManagedObjectContext:(NSManagedObjectContext *)fromContext toContext:(NSManagedObjectContext *)toContext error:(NSError * __autoreleasing *)error;

@end
