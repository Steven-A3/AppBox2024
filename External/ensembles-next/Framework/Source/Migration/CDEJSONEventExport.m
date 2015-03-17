//
//  CDEJSONEventExport.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 27/05/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//
//  This file includes Base64 encoding methods based on code with this license:
//
//  Created by Matt Gallagher on 2009/06/03.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "CDEJSONEventExport.h"
#import "NSManagedObjectContext+CDEAdditions.h"
#import "CDEStoreModificationEvent.h"
#import "CDEEventStore.h"
#import "CDEObjectChange.h"
#import "CDEEventRevision.h"
#import "CDEPropertyChangeValue.h"
#import "CDEGlobalIdentifier.h"
#import "NSData+CDEAdditions.h"


@implementation CDEJSONEventExport {
    NSMutableDictionary *eventDictionary;
    NSMutableDictionary *changesByEntity;
    NSMutableArray *changeDictionaries;
    NSURL *fileURL;
    NSEntityDescription *currentEntity;
}

- (BOOL)prepareForExport
{
    NSError *localError = nil;
    
    NSManagedObjectContext *eventStoreContext = self.eventStore.managedObjectContext;
    event = (id)[eventStoreContext existingObjectWithID:self.eventID error:&localError];
    if (!event) {
        error = localError;
        return NO;
    }

    eventDictionary = [NSMutableDictionary dictionary];
    eventDictionary[@"globalCount"] = @(event.globalCount);
    eventDictionary[@"type"] = @(event.type);
    if (event.modelVersion) eventDictionary[@"modelVersion"] = event.modelVersion;
    eventDictionary[@"timestamp"] = [@(event.timestamp) stringValue];
    eventDictionary[@"uniqueIdentifier"] = event.uniqueIdentifier;
    eventDictionary[@"storeIdentifier"] = event.eventRevision.persistentStoreIdentifier;
    
    NSMutableDictionary *revisionsByStoreIdentifier = [NSMutableDictionary dictionary];
    revisionsByStoreIdentifier[event.eventRevision.persistentStoreIdentifier] = @(event.eventRevision.revisionNumber);
    for (CDEEventRevision *rev in event.eventRevisionsOfOtherStores) {
        revisionsByStoreIdentifier[rev.persistentStoreIdentifier] = @(rev.revisionNumber);
    }
    eventDictionary[@"revisionsByStoreIdentifier"] = revisionsByStoreIdentifier;
    
    changesByEntity = [NSMutableDictionary dictionary];
    
    fileURL = [self createTemporaryFileURL];
    [self addFileURL:fileURL];
    
    return YES;
}

- (BOOL)saveToFile:(NSError * __autoreleasing *)returnError
{
    NSInteger bytesWritten = 0;
    BOOL success = YES;
    
    @try {
        NSError *localError = nil;
        NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:fileURL.path append:NO];
        [stream open];
        eventDictionary[@"changesByEntity"] = changesByEntity;
        bytesWritten = [NSJSONSerialization writeJSONObject:eventDictionary toStream:stream options:0 error:&localError];
        [stream close];
        
        success = bytesWritten != 0;
        if (!success)
            *returnError = localError;
        else if (stream.streamError) {
            success = NO;
            *returnError = stream.streamError;
        }
    }
    @catch ( NSException *exception ) {
        CDELog(CDELoggingLevelError, @"Exception thrown writing JSON file: %@", exception);
        NSString *description = [NSString stringWithFormat:@"Exception raised while exporting JSON: %@", exception];
        *returnError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeExceptionRaised userInfo:@{NSLocalizedDescriptionKey : description}];
        bytesWritten = 0;
        success = NO;
    }

    return success;
}

- (BOOL)prepareNewFile
{
    NSError *localError = nil;
    
    // Save data
    if (![self saveToFile:&localError]) return NO;
    
    // Create new file
    fileURL = [self createTemporaryFileURL];
    [self addFileURL:fileURL];
    
    // Prepare event dictionary
    eventDictionary = [NSMutableDictionary dictionary];
    changesByEntity = [NSMutableDictionary dictionary];
    changeDictionaries = [NSMutableArray array];
    changesByEntity[currentEntity.name] = changeDictionaries;
    
    return YES;
}

- (BOOL)prepareForNewEntity:(NSEntityDescription *)entity
{
    currentEntity = entity;
    changeDictionaries = [NSMutableArray array];
    changesByEntity[entity.name] = changeDictionaries;
    return YES;
}

- (BOOL)migrateObjectChanges:(NSArray *)changes
{
    static NSArray *keys = nil;
    if (!keys) keys = @[@"propertyName", @"type", @"filename", @"relatedIdentifier", @"addedIdentifiers", @"removedIdentifiers"];
    
    for (CDEObjectChange *change in changes) {
        NSMutableDictionary *changeDict = [[NSMutableDictionary alloc] initWithCapacity:10];
        changeDict[@"type"] = @(change.type);
        changeDict[@"globalIdentifier"] = change.globalIdentifier.globalIdentifier;
        
        if (change.dataFiles.count > 0) {
            changeDict[@"dataFiles"] = [[change.dataFiles valueForKeyPath:@"filename"] allObjects];
        }
        
        NSMutableArray *valueDicts = [[NSMutableArray alloc] initWithCapacity:change.propertyChangeValues.count];
        for (CDEPropertyChangeValue *v in change.propertyChangeValues) {
            NSDictionary *values = [v dictionaryWithValuesForKeys:keys];
            
            NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] initWithCapacity:10];
            [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (obj && obj != [NSNull null]) valueDict[key] = obj;
                if ([obj isKindOfClass:[NSSet class]]) valueDict[key] = [(NSSet *)obj allObjects];
            }];
            
            if (v.movedIdentifiersByIndex) {
                NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
                [v.movedIdentifiersByIndex enumerateKeysAndObjectsUsingBlock:^(NSNumber *indexNumber, NSString *identifier, BOOL *stop) {
                    jsonDict[[indexNumber stringValue]] = identifier;
                }];
                valueDict[@"movedIdentifiersByIndex"] = jsonDict;
            }
            
            if (v.value) valueDict[@"value"] = [self JSONValueFromCoreDataValue:v.value];
            
            [valueDicts addObject:valueDict];
        }
        changeDict[@"properties"] = valueDicts;
        
        [changeDictionaries addObject:changeDict];
    }
    
    return YES;
}

- (BOOL)completeMigrationSuccessfully:(BOOL)success
{
    NSError *localError = nil;
    if (success) {
        success = [self saveToFile:&localError];
        if (!success) error = localError;
    }
    return success;
}

- (id)JSONValueFromCoreDataValue:(id)value
{
    if ([value isKindOfClass:[NSDecimalNumber class]]) {
        NSDecimalNumber *decimal = (id)value;
        value = @[@"decimal", [decimal stringValue]];
    }
    else if ([value isKindOfClass:[NSDate class]]) {
        NSDate *date = (id)value;
        value = @[@"date", [NSNumber numberWithDouble:([date timeIntervalSince1970] * 1000)]];
    }
    else if ([value isKindOfClass:[NSData class]]) {
        value = @[@"data", [value cde_base64EncodedString]];
    }
    else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *number = value;
        if ([number isEqualToNumber:(id)kCFNumberNaN]) {
            value = @[@"number", @"nan"];
        }
        else if ([number isEqualToNumber:(id)kCFNumberPositiveInfinity]) {
            value = @[@"number", @"+inf"];
        }
        else if ([number isEqualToNumber:(id)kCFNumberNegativeInfinity]) {
            value = @[@"number", @"-inf"];
        }
    }
    else if ([value isKindOfClass:[NSManagedObjectID class]]) {
        @throw [NSException exceptionWithName:CDEException reason:@"ObjectID type is not supported" userInfo:nil];
    }
    
    return value;
}

@end
