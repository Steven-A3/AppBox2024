//
//  CDEJSONEventImport.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 11/06/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import "CDEJSONEventImport.h"
#import "NSData+CDEAdditions.h"
#import "CDEEventStore.h"
#import "CDEStoreModificationEvent.h"
#import "CDEEventRevision.h"
#import "CDERevisionSet.h"
#import "CDEGlobalIdentifier.h"
#import "CDEObjectChange.h"
#import "CDEDataFile.h"
#import "CDEPropertyChangeValue.h"

@implementation CDEJSONEventImport

- (void)prepareToImport
{
}

- (CDEStoreModificationEvent *)importFirstFileAtURL:(NSURL *)url error:(NSError * __autoreleasing *)error
{
    NSManagedObjectContext *eventStoreContext = self.eventStore.managedObjectContext;
    CDEStoreModificationEvent *event = [NSEntityDescription insertNewObjectForEntityForName:@"CDEStoreModificationEvent" inManagedObjectContext:eventStoreContext];
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithURL:url];
    [inputStream open];
    NSDictionary *eventDictionary = [NSJSONSerialization JSONObjectWithStream:inputStream options:0 error:error];
    [inputStream close];
    if (!eventDictionary) return nil;
    
    event.globalCount = [eventDictionary[@"globalCount"] longValue];
    event.type = [eventDictionary[@"type"] unsignedIntegerValue];
    event.modelVersion = eventDictionary[@"modelVersion"];
    event.timestamp = [eventDictionary[@"timestamp"] doubleValue];
    event.uniqueIdentifier = eventDictionary[@"uniqueIdentifier"];
    
    NSString *storeId = eventDictionary[@"storeIdentifier"];
    
    NSDictionary *revisionsByStoreId = eventDictionary[@"revisionsByStoreIdentifier"];
    CDERevisionNumber revisionNumber = [revisionsByStoreId[storeId] longValue];
    event.eventRevision = [CDEEventRevision makeEventRevisionForPersistentStoreIdentifier:storeId revisionNumber:revisionNumber inManagedObjectContext:eventStoreContext];
    
    for (NSString *store in revisionsByStoreId) {
        if ([store isEqualToString:storeId]) continue;
        CDERevisionNumber revisionNumber = [revisionsByStoreId[store] longValue];
        CDEEventRevision *eventRev = [CDEEventRevision makeEventRevisionForPersistentStoreIdentifier:store revisionNumber:revisionNumber inManagedObjectContext:eventStoreContext];
        [[event mutableSetValueForKey:@"eventRevisionsOfOtherStores"] addObject:eventRev];
    }
    
    if (![eventStoreContext obtainPermanentIDsForObjects:@[event] error:error]) return nil;
    self.eventID = event.objectID;
    
    if (![self importObjectChangesFromJSONObject:eventDictionary error:error]) return nil;
    
    return event;
}

- (BOOL)importSubsequentFileAtURL:(NSURL *)url error:(NSError * __autoreleasing *)error
{
    NSInputStream *inputStream = [NSInputStream inputStreamWithURL:url];
    [inputStream open];
    NSDictionary *eventDictionary = [NSJSONSerialization JSONObjectWithStream:inputStream options:0 error:error];
    [inputStream close];
    if (!eventDictionary) return NO;
    if (![self importObjectChangesFromJSONObject:eventDictionary error:error]) return NO;
    return YES;
}

- (BOOL)importObjectChangesFromJSONObject:(NSDictionary *)eventDictionary error:(NSError * __autoreleasing *)error
{
    NSManagedObjectContext *eventStoreContext = self.eventStore.managedObjectContext;
    NSDictionary *entityDicts = eventDictionary[@"changesByEntity"];
    CDEStoreModificationEvent *event = (id)[eventStoreContext existingObjectWithID:self.eventID error:error];
    if (!event) return NO;

    for (NSString *entityName in entityDicts) {
        NSArray *changeDicts = entityDicts[entityName];
        NSArray *globalIdStrings = [changeDicts valueForKeyPath:@"globalIdentifier"];
        NSArray *globalIds = [CDEGlobalIdentifier fetchGlobalIdentifiersForIdentifierStrings:globalIdStrings withEntityName:entityName inManagedObjectContext:eventStoreContext];
        
        [globalIdStrings enumerateObjectsUsingBlock:^(NSString *globalIdString, NSUInteger idx, BOOL *stop) {
            CDEGlobalIdentifier *globalId = globalIds[idx];
            if (globalId == (id)[NSNull null]) {
                globalId = [NSEntityDescription insertNewObjectForEntityForName:@"CDEGlobalIdentifier" inManagedObjectContext:eventStoreContext];
                globalId.globalIdentifier = globalIdString;
                globalId.nameOfEntity = entityName;
            }
            
            NSDictionary *changeDict = changeDicts[idx];
            CDEObjectChange *change = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:eventStoreContext];
            change.globalIdentifier = globalId;
            change.storeModificationEvent = event;
            change.type = [changeDict[@"type"] integerValue];
            change.nameOfEntity = entityName;
            
            NSArray *dataFileNames = changeDict[@"dataFiles"];
            for (NSString *dataFileName in dataFileNames) {
                CDEDataFile *dataFile = [NSEntityDescription insertNewObjectForEntityForName:@"CDEDataFile" inManagedObjectContext:eventStoreContext];
                dataFile.objectChange = change;
                dataFile.filename = dataFileName;
            }
            
            NSMutableArray *propertyValues = [[NSMutableArray alloc] initWithCapacity:10];
            for (NSDictionary *propertyDict in changeDict[@"properties"]) {
                CDEPropertyChangeType type = [propertyDict[@"type"] integerValue];
                NSString *name = propertyDict[@"name"];
                CDEPropertyChangeValue *propertyValue = [[CDEPropertyChangeValue alloc] initWithType:type propertyName:name];
                [propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key isEqualToString:@"name"] || [key isEqualToString:@"type"]) {
                    }
                    else if ([key isEqualToString:@"value"]) {
                        propertyValue.value = [self coreDataValueFromJSONValue:obj];
                    }
                    else if ([@[@"addedIdentifiers", @"removedIdentifiers"] containsObject:key]) {
                        [propertyValue setValue:[NSSet setWithArray:obj] forKey:key];
                    }
                    else if ([key isEqualToString:@"movedIdentifiersByIndex"]) {
                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                        [obj enumerateKeysAndObjectsUsingBlock:^(NSString *indexString, NSString *identifier, BOOL *stop) {
                            dict[@([indexString integerValue])] = identifier;
                        }];
                        propertyValue.movedIdentifiersByIndex = dict;
                    }
                    else {
                        [propertyValue setValue:obj forKey:key];
                    }
                }];
                [propertyValues addObject:propertyValue];
            }
            change.propertyChangeValues = propertyValues;
        }];
    }
    
    return YES;
}

- (id)coreDataValueFromJSONValue:(id)value
{
    NSString *type = nil;
    if ([value isKindOfClass:[NSArray class]]) {
        type = value[0];
        value = value[1];
    }
    
    if (!type) return value;
    
    if ([type isEqualToString:@"decimal"]) {
        value = [NSDecimalNumber decimalNumberWithString:value];
    }
    else if ([type isEqualToString:@"date"]) {
        NSTimeInterval time = [value doubleValue] / 1000.0;
        value = [NSDate dateWithTimeIntervalSince1970:time];
    }
    else if ([type isEqualToString:@"data"]) {
        value = [NSData cde_dataWithBase64EncodedString:value];
    }
    else if ([type isEqualToString:@"number"]) {
        if ([value isEqualToString:@"nan"]) {
            value = (id)kCFNumberNaN;
        }
        else if ([value isEqualToString:@"+inf"]) {
            value = (id)kCFNumberPositiveInfinity;
        }
        else if ([value isEqualToString:@"-inf"]) {
            value = (id)kCFNumberNegativeInfinity;
        }
        else {
            CDELog(CDELoggingLevelError, @"Unknown number string found in JSON: %@", value);
            value = nil;
        }
    }
    
    return value;
}

@end
