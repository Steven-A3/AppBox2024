//
//  CDEObjectChangeTests.m
//  Ensembles
//
//  Created by Drew McCormack on 01/07/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDEEventStoreTestCase.h"
#import "CDEPropertyChangeValue.h"
#import "CDEStoreModificationEvent.h"
#import "CDEObjectChange.h"
#import "CDEGlobalIdentifier.h"
#import "CDEEventRevision.h"

@interface CDEObjectChangeTests : CDEEventStoreTestCase

@end

@implementation CDEObjectChangeTests {
    CDEStoreModificationEvent *modEvent;
    CDEGlobalIdentifier *globalId;
    CDEObjectChange *objectChange;
}

- (void)setUp
{
    [super setUp];
    [self.eventStore.managedObjectContext performBlockAndWait:^{
        modEvent = [NSEntityDescription insertNewObjectForEntityForName:@"CDEStoreModificationEvent" inManagedObjectContext:self.eventStore.managedObjectContext];
        modEvent.timestamp = 123;
        
        CDEEventRevision *revision = [NSEntityDescription insertNewObjectForEntityForName:@"CDEEventRevision" inManagedObjectContext:self.eventStore.managedObjectContext];
        revision.persistentStoreIdentifier = @"1234";
        revision.revisionNumber = 0;
        modEvent.eventRevision = revision;
        
        globalId = [NSEntityDescription insertNewObjectForEntityForName:@"CDEGlobalIdentifier" inManagedObjectContext:self.eventStore.managedObjectContext];
        globalId.globalIdentifier = @"123";
        globalId.nameOfEntity = @"CDEObjectChange";
        
        objectChange = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:self.eventStore.managedObjectContext];
        objectChange.nameOfEntity = @"Hello";
        objectChange.type = CDEObjectChangeTypeUpdate;
        objectChange.storeModificationEvent = modEvent;
        objectChange.globalIdentifier = globalId;
        objectChange.propertyChangeValues = @[[self propertyChangeValueForProperty:@"a"], [self propertyChangeValueForProperty:@"b"]];
    }];
}

- (void)tearDown
{
    [super tearDown];
}

- (CDEPropertyChangeValue *)propertyChangeValueForProperty:(NSString *)property
{
    return [[CDEPropertyChangeValue alloc] initWithType:CDEPropertyChangeTypeAttribute propertyName:property];
}

- (void)testRequiredProperties
{
    [self.eventStore.managedObjectContext performBlockAndWait:^{
        NSError *error;
        objectChange.nameOfEntity = nil;
        BOOL success = [self.eventStore.managedObjectContext save:NULL];
        XCTAssertFalse(success, @"Should not save with no entity name");
        
        objectChange.nameOfEntity = @"Hello";
        objectChange.storeModificationEvent = nil;
        success = [self.eventStore.managedObjectContext save:NULL];
        XCTAssertFalse(success, @"Should not save with no store mod event");
        
        objectChange.storeModificationEvent = modEvent;
        objectChange.globalIdentifier = nil;
        success = [self.eventStore.managedObjectContext save:NULL];
        XCTAssertFalse(success, @"Should not save with no global id");
        
        objectChange.propertyChangeValues = @[[self propertyChangeValueForProperty:@"c"]];
        objectChange.globalIdentifier = globalId;
        success = [self.eventStore.managedObjectContext save:&error];
        XCTAssertTrue(success, @"Should save with all required set: %@", error);
        
        objectChange.propertyChangeValues = nil;
        success = [self.eventStore.managedObjectContext save:&error];
        XCTAssertFalse(success, @"Should not save for update with nil as propertyChangeValues");

    }];
}

- (void)testPropertyValuesSavedAndRestored
{
    [self.eventStore.managedObjectContext performBlockAndWait:^{
        objectChange.propertyChangeValues = @[[self propertyChangeValueForProperty:@"val"]];
        NSError *error;
        BOOL success = [self.eventStore.managedObjectContext save:&error];
        XCTAssertTrue(success, @"Failed to save: %@", error);
        [self.eventStore.managedObjectContext refreshObject:objectChange mergeChanges:NO];
        NSArray *values = objectChange.propertyChangeValues;
        CDEPropertyChangeValue *value = values[0];
        XCTAssertEqualObjects(value.propertyName, @"val", @"Wrong values");
    }];
}

- (void)testMerging {
    CDEObjectChange *change1 = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:self.eventStore.managedObjectContext];
    CDEPropertyChangeValue *value1 = [[CDEPropertyChangeValue alloc] initWithType:CDEPropertyChangeTypeAttribute propertyName:@"a"];
    value1.value = @"A";
    change1.propertyChangeValues = @[value1];
    
    CDEObjectChange *change2 = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:self.eventStore.managedObjectContext];
    CDEPropertyChangeValue *value2 = [[CDEPropertyChangeValue alloc] initWithType:CDEPropertyChangeTypeAttribute propertyName:@"a"];
    value2.value = @"AA";
    change2.propertyChangeValues = @[value2];
    
    [change1 mergeValuesFromObjectChange:change2 treatChangeAsSubordinate:YES];
    CDEPropertyChangeValue *resultPropertyValue = change1.propertyChangeValues.lastObject;
    id v = resultPropertyValue.value;
    XCTAssertEqualObjects(v, @"A");
    
    [change1 mergeValuesFromObjectChange:change2 treatChangeAsSubordinate:NO];
    resultPropertyValue = change1.propertyChangeValues.lastObject;
    v = resultPropertyValue.value;
    XCTAssertEqualObjects(v, @"AA");
}

- (void)testMergingWithDifferingPropertyNames {
    CDEObjectChange *change1 = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:self.eventStore.managedObjectContext];
    CDEPropertyChangeValue *value1 = [[CDEPropertyChangeValue alloc] initWithType:CDEPropertyChangeTypeAttribute propertyName:@"a"];
    value1.value = @"A";
    change1.propertyChangeValues = @[value1];
    
    CDEObjectChange *change2 = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:self.eventStore.managedObjectContext];
    
    [change1 mergeValuesFromObjectChange:change2 treatChangeAsSubordinate:YES];
    CDEPropertyChangeValue *resultPropertyValue = change1.propertyChangeValues.lastObject;
    id v = resultPropertyValue.value;
    XCTAssertEqualObjects(v, @"A");
    
    [change1 mergeValuesFromObjectChange:change2 treatChangeAsSubordinate:NO];
    resultPropertyValue = change1.propertyChangeValues.lastObject;
    v = resultPropertyValue.value;
    XCTAssertEqualObjects(v, @"A");
    
    change1.propertyChangeValues = @[];
    change2.propertyChangeValues = @[value1];
    
    [change1 mergeValuesFromObjectChange:change2 treatChangeAsSubordinate:YES];
    resultPropertyValue = change1.propertyChangeValues.lastObject;
    v = resultPropertyValue.value;
    XCTAssertEqualObjects(v, @"A");
    
    [change1 mergeValuesFromObjectChange:change2 treatChangeAsSubordinate:NO];
    resultPropertyValue = change1.propertyChangeValues.lastObject;
    v = resultPropertyValue.value;
    XCTAssertEqualObjects(v, @"A");
}

@end
