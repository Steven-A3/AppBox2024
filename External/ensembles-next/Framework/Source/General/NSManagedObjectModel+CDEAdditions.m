//
//  NSManagedObjectModel+CDEAdditions.m
//  Ensembles
//
//  Created by Drew McCormack on 08/11/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import "NSManagedObjectModel+CDEAdditions.h"
#import "CDEFoundationAdditions.h"
#import "CDEDefines.h"
#import "NSData+CDEAdditions.h"

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

- (NSString *)cde_compressedModelHash
{
    NSData *uncompressedHash = [[self cde_modelHash] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *checksum = [NSString stringWithFormat:@"md5%@", [uncompressedHash cde_md5Checksum]];
    return checksum;
}

- (NSString *)cde_entityHashesPropertyList
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSString *error = nil;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:self.entityVersionHashesByName format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    if (!data) CDELog(CDELoggingLevelError, @"Error generating property list: %@", error);
#pragma clang diagnostic pop

    NSString *string = nil;
    if (data) string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return string;
}

+ (NSDictionary *)cde_entityHashesByNameFromPropertyList:(NSString *)propertyList
{
    NSData *data = [propertyList dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) return nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSString *error;
    NSPropertyListFormat format;
    NSDictionary *entitiesByName = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
    if (!entitiesByName) CDELog(CDELoggingLevelError, @"Error reading property list: %@", error);
#pragma clang diagnostic pop
    
    return entitiesByName;
}

- (NSArray *)cde_entitiesOrderedByMigrationPriority
{
    NSArray *filteredEntities = [self.entities filteredArrayUsingPredicate:
        [NSPredicate predicateWithBlock:^BOOL(NSEntityDescription *entity, NSDictionary *bindings) {
        return ![entity.userInfo[CDEIgnoredKey] boolValue];
    }]];
    return [filteredEntities sortedArrayUsingComparator:^NSComparisonResult(NSEntityDescription *entity1, NSEntityDescription *entity2) {
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
        if ([property.userInfo[CDEIgnoredKey] boolValue]) continue;
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

- (NSArray *)cde_descendantEntities
{
    NSMutableArray *descendants = [[NSMutableArray alloc] init];
    for (NSEntityDescription *subentity in self.subentities) {
        [descendants addObject:subentity];
        [descendants addObjectsFromArray:[subentity cde_descendantEntities]];
    }
    return descendants;
}

- (NSArray *)cde_ancestorEntities
{
    NSMutableArray *ancestors = [[NSMutableArray alloc] init];
    NSEntityDescription *ancestor = self;
    while ((ancestor = ancestor.superentity)) {
        [ancestors addObject:ancestor];
    }
    return ancestors;
}

@end


@implementation NSRelationshipDescription (CDEAdditions)

- (BOOL)cde_isRedundant
{
    NSDictionary *info = self.userInfo;
    if ([info[CDEIgnoredKey] boolValue]) return YES;
    if ([self.entity.userInfo[CDEIgnoredKey] boolValue]) return YES;
    if ([self.destinationEntity.userInfo[CDEIgnoredKey] boolValue]) return YES;

    NSDictionary *inverseInfo = self.inverseRelationship.userInfo;
    if (!self.inverseRelationship || self.inverseRelationship.isTransient || [inverseInfo[CDEIgnoredKey] boolValue]) return NO;
    
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
