//
//  NSManagedObjectModel+CDEAdditions.m
//  Ensembles
//
//  Created by Drew McCormack on 08/11/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import "NSManagedObjectModel+CDEAdditions.h"
#import "CDEDefines.h"

@implementation NSManagedObjectModel (CDEAdditions)

- (NSString *)cde_modelHash
{
    NSDictionary *entityHashesByName = [self entityVersionHashesByName];
    NSMutableString *result = [[NSMutableString alloc] init];
    NSArray *sortedNames = [entityHashesByName.allKeys sortedArrayUsingSelector:@selector(compare:)];
    [sortedNames enumerateObjectsUsingBlock:^(NSString *entityName, NSUInteger index, BOOL *stop) {
        NSString *separator = index > 0 ? @"__" : @"";
        NSString *entityString = [NSString stringWithFormat:@"%@%@_%@", separator, entityName, entityHashesByName[entityName]];
        [result appendString:entityString];
    }];
    return result;
}

- (NSString *)cde_entityHashesPropertyList
{
    NSString *error = nil;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:self.entityVersionHashesByName format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    if (!data) CDELog(CDELoggingLevelError, @"Error generating property list: %@", error);
    
    NSString *string = nil;
    if (data) string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return string;
}

+ (NSDictionary *)cde_entityHashesByNameFromPropertyList:(NSString *)propertyList
{
    NSData *data = [propertyList dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) return nil;
    
    NSString *error;
    NSPropertyListFormat format;
    NSDictionary *entitiesByName = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
    if (!entitiesByName) CDELog(CDELoggingLevelError, @"Error reading property list: %@", error);
    
    return entitiesByName;
}

- (NSArray *)cde_entitiesOrderedByMigrationPriority
{
    return [self.entities sortedArrayUsingComparator:^NSComparisonResult(NSEntityDescription *entity1, NSEntityDescription *entity2) {
        // Order first on priority stipulated by user in model
        NSNumber *priority1 = @([entity1.userInfo[CDEMigrationPriorityKey] integerValue]);
        NSNumber *priority2 = @([entity2.userInfo[CDEMigrationPriorityKey] integerValue]);
        NSComparisonResult priorityResult = [priority2 compare:priority1];
        if (priorityResult != NSOrderedSame) return priorityResult;
        
        // Order second alphabetically
        NSComparisonResult nameResult = [entity1.name caseInsensitiveCompare:entity2.name];
        return nameResult;
    }];
}

@end


@implementation NSEntityDescription (CDEAdditions)

- (NSUInteger)cde_migrationBatchSize
{
    NSInteger batchSize = [self.userInfo[CDEMigrationBatchSizeKey] integerValue];
    NSUInteger result = batchSize >= 0 ? batchSize : 0;
    return result;
}

- (NSArray *)cde_nonRedundantRelationshipsDestinedForEntities:(NSArray *)targetEntities
{
    NSMutableArray *relationships = [NSMutableArray array];
    for (NSRelationshipDescription *relationship in self.relationshipsByName.allValues) {
        if (relationship.cde_isRedundant) continue;
        if ([targetEntities containsObject:relationship.destinationEntity]) {
            [relationships addObject:relationship];
        }
    }
    return relationships;
}

- (NSArray *)cde_nonRedundantProperties
{
    NSMutableArray *properties = [[NSMutableArray alloc] init];
    for (NSPropertyDescription *property in self.properties) {
        if (property.isTransient) continue;
        if ([property.userInfo[CDEExcludePropertyKey] boolValue]) continue;
        if ([property isKindOfClass:[NSRelationshipDescription class]]) {
            NSRelationshipDescription *relationship = (id)property;
            if (!relationship.cde_isRedundant) [properties addObject:property];
        }
        else {
            [properties addObject:property];
        }
    }
    return properties;
}

@end


@implementation NSRelationshipDescription (CDEAdditions)

- (BOOL)cde_isRedundant
{
    NSDictionary *info = self.userInfo;
    if ([info[CDEExcludePropertyKey] boolValue]) return YES;

    NSDictionary *inverseInfo = self.inverseRelationship.userInfo;
    if (!self.inverseRelationship || self.inverseRelationship.isTransient || [inverseInfo[CDEExcludePropertyKey] boolValue]) return NO;
    
    if (self.isOrdered) return NO;
    if (self.isToMany && self.inverseRelationship.isToMany) return NO;
    if (!self.isToMany && self.inverseRelationship.isToMany) return NO;
    if ([self.entity.name isEqualToString:self.inverseRelationship.entity.name]) return NO;
    
    if (!self.isToMany && !self.inverseRelationship.isToMany) {
        // One-to-one. Keep first entity ordered alphabetically.
        return [self.entity.name caseInsensitiveCompare:self.inverseRelationship.entity.name] == NSOrderedDescending;
    }
    
    return YES;
}

@end
