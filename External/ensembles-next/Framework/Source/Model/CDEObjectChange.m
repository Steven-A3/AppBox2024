//
//  CDEObjectChange.m
//  Test App iOS
//
//  Created by Drew McCormack on 4/14/13.
//  Copyright (c) 2013 The Mental Faculty B.V. All rights reserved.
//

#import "CDEObjectChange.h"
#import "CDEDefines.h"
#import "CDEDataFile.h"
#import "CDEStoreModificationEvent.h"
#import "CDEPropertyChangeValue.h"

@implementation CDEObjectChange

@dynamic type;
@dynamic globalIdentifier;
@dynamic storeModificationEvent;
@dynamic nameOfEntity;
@dynamic propertyChangeValues;
@dynamic dataFiles;

- (BOOL)validatePropertyChangeValues:(id *)value error:(NSError * __autoreleasing *)error
{
    if (self.type != CDEObjectChangeTypeDelete && *value == nil) {
        if (error) *error = [NSError errorWithDomain:CDEErrorDomain code:-1 userInfo:nil];
        return NO;
    }
    return YES;
}

- (CDEPropertyChangeValue *)propertyChangeValueForPropertyName:(NSString *)name
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"propertyName = %@", name];
    NSArray *values = [self.propertyChangeValues filteredArrayUsingPredicate:predicate];
    CDEPropertyChangeValue *value = values.lastObject;
    return value;
}

- (void)setPropertyChangeValues:(NSArray *)newValues
{
    [self willChangeValueForKey:@"propertyChangeValues"];
    [self setPrimitiveValue:newValues forKey:@"propertyChangeValues"];
    [self didChangeValueForKey:@"propertyChangeValues"];
    [self updateDataFiles];
}


#pragma mark Data Files

- (void)updateDataFiles
{
    NSMutableSet *newFilenames = nil;
    for (CDEPropertyChangeValue *value in self.propertyChangeValues) {
        if (value.filename) {
            if (!newFilenames) newFilenames = [[NSMutableSet alloc] init];
            [newFilenames addObject:value.filename];
        }
    }
    
    if (self.dataFiles.count == 0 && newFilenames.count == 0) return;
    
    NSArray *orderedFiles = self.dataFiles.allObjects;
    NSDictionary *oldFilesByName = [[NSDictionary alloc] initWithObjects:orderedFiles forKeys:[orderedFiles valueForKeyPath:@"filename"]];
    NSSet *oldFilenames = [[NSSet alloc] initWithArray:oldFilesByName.allKeys];
    NSMutableSet *addedFilenames = [newFilenames mutableCopy];
    [addedFilenames minusSet:oldFilenames];
    for (NSString *filename in addedFilenames) {
        CDEDataFile *file = [NSEntityDescription insertNewObjectForEntityForName:@"CDEDataFile" inManagedObjectContext:self.managedObjectContext];
        file.filename = filename;
        file.objectChange = self;
    }
    
    NSMutableSet *removeFilenames = [oldFilenames mutableCopy];
    [removeFilenames minusSet:newFilenames];
    for (NSString *filename in removeFilenames) {
        CDEDataFile *file = oldFilesByName[filename];
        [self.managedObjectContext deleteObject:file];
    }
}


#pragma mark Merging

- (void)mergeValuesFromObjectChange:(CDEObjectChange *)change treatChangeAsSubordinate:(BOOL)subordinate
{
    NSDictionary *existingPropertiesByName = [[NSDictionary alloc] initWithObjects:self.propertyChangeValues forKeys:[self.propertyChangeValues valueForKeyPath:@"propertyName"]];
    NSMutableArray *newPropertyChangeValues = [[NSMutableArray alloc] init];
    
    for (CDEPropertyChangeValue *propertyValue in change.propertyChangeValues) {
        NSString *propertyName = propertyValue.propertyName;
        CDEPropertyChangeValue *existingValue = existingPropertiesByName[propertyName];
        
        // If this property name is not already present, just copy it in
        if (nil == existingValue) {
            [newPropertyChangeValues addObject:propertyValue];
            continue;
        }
        
        // If it is a to-many relationship, take the union
        BOOL isToMany = propertyValue.type == CDEPropertyChangeTypeToManyRelationship;
        isToMany = isToMany || propertyValue.type == CDEPropertyChangeTypeOrderedToManyRelationship;
        if (isToMany) {
            [existingValue mergeToManyRelationshipFromPropertyChangeValue:propertyValue treatValueAsSubordinate:subordinate];
            [newPropertyChangeValues addObject:existingValue];
            continue;
        }
        
        // Both values exist. Choose dominant.
        [newPropertyChangeValues addObject:(subordinate ? existingValue : propertyValue)];
    }

    self.propertyChangeValues = newPropertyChangeValues;
}

#pragma mark Prefetching

+ (void)prefetchRelatedObjectsForObjectChanges:(NSArray *)objectChanges
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", objectChanges];
    fetch.relationshipKeyPathsForPrefetching = @[@"globalIdentifier", @"dataFiles"];
    NSManagedObjectContext *context = [objectChanges.lastObject managedObjectContext];
    [context executeFetchRequest:fetch error:NULL];
}

+ (void)prefetchObjectChangesForObjectIDs:(NSArray *)objectChangeIDs inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", objectChangeIDs];
    fetch.relationshipKeyPathsForPrefetching = @[@"globalIdentifier", @"dataFiles"];
    [context executeFetchRequest:fetch error:NULL];
}

#pragma mark Count

+ (NSUInteger)countOfObjectChangesInStoreModificationEvents:(NSArray *)events
{
    NSManagedObjectContext *context = [events.lastObject managedObjectContext];
    if (!context) return 0;
    
    NSError *error;
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"storeModificationEvent IN %@", events];
    NSUInteger count = [context countForFetchRequest:fetch error:&error];
    if (count == NSNotFound) {
        CDELog(CDELoggingLevelError, @"Could not fetch count of object changes: %@", error);
        count = 0;
    }
    
    return count;
}

#pragma mark Sorting

+ (NSArray *)sortDescriptorsForEventOrder
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"storeModificationEvent.globalCount" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"storeModificationEvent.timestamp" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"storeModificationEvent.eventRevision.persistentStoreIdentifier" ascending:YES]];
}

@end
