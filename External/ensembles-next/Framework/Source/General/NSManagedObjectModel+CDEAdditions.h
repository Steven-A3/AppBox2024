//
//  NSManagedObjectModel+CDEAdditions.h
//  Ensembles
//
//  Created by Drew McCormack on 08/11/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectModel (CDEAdditions)

- (NSString *)cde_modelHash;
- (NSString *)cde_compressedModelHash;

- (NSString *)cde_entityHashesPropertyList; // XML Dictionary
+ (NSDictionary *)cde_entityHashesByNameFromPropertyList:(NSString *)propertyList;

- (NSArray *)cde_entitiesOrderedByMigrationPriority;

@end


@interface NSEntityDescription (CDEAdditions)

@property (nonatomic, readonly) NSUInteger cde_migrationBatchSize;
@property (nonatomic, readonly) NSArray *cde_nonRedundantProperties;
@property (nonatomic, readonly) NSArray *cde_descendantEntities;

- (NSArray *)cde_nonRedundantRelationshipsDestinedForEntities:(NSArray *)targetEntities;

@end


@interface NSRelationshipDescription (CDEAdditions)

@property (nonatomic, readonly) BOOL cde_isRedundant;

@end