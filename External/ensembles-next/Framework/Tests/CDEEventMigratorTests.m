//
//  CDEEventMigratorTests.m
//  Ensembles
//
//  Created by Drew McCormack on 10/08/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDEEventStoreTestCase.h"
#import "CDEStoreModificationEvent.h"
#import "CDEObjectChange.h"
#import "CDEGlobalIdentifier.h"
#import "CDEEventRevision.h"
#import "CDEEventMigrator.h"

@interface CDEEventMigratorTests : CDEEventStoreTestCase

@end

@implementation CDEEventMigratorTests  {
    CDEStoreModificationEvent *modEvent;
    CDEGlobalIdentifier *globalId1, *globalId2, *globalId3;
    CDEObjectChange *objectChange1, *objectChange2, *objectChange3;
    NSManagedObjectContext *moc;
    CDEEventMigrator *migrator;
    NSString *exportedEventsFile;
    NSManagedObjectContext *fileContext;
    BOOL finishedAsyncOp;
}

- (void)setUp
{
    [super setUp];
    fileContext = nil;
    moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        modEvent = [NSEntityDescription insertNewObjectForEntityForName:@"CDEStoreModificationEvent" inManagedObjectContext:moc];
        modEvent.timestamp = 123;
        modEvent.type = CDEStoreModificationEventTypeMerge;
        
        CDEEventRevision *revision = [NSEntityDescription insertNewObjectForEntityForName:@"CDEEventRevision" inManagedObjectContext:moc];
        revision.persistentStoreIdentifier = [self.eventStore persistentStoreIdentifier];
        revision.revisionNumber = 0;
        modEvent.eventRevision = revision;
        
        globalId1 = [NSEntityDescription insertNewObjectForEntityForName:@"CDEGlobalIdentifier" inManagedObjectContext:moc];
        globalId1.globalIdentifier = @"123";
        globalId1.nameOfEntity = @"Parent";
        
        globalId2 = [NSEntityDescription insertNewObjectForEntityForName:@"CDEGlobalIdentifier" inManagedObjectContext:moc];
        globalId2.globalIdentifier = @"1234";
        globalId2.nameOfEntity = @"Child";
        
        globalId3 = [NSEntityDescription insertNewObjectForEntityForName:@"CDEGlobalIdentifier" inManagedObjectContext:moc];
        globalId3.globalIdentifier = @"1234";
        globalId3.nameOfEntity = @"Child";
        
        objectChange1 = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:moc];
        objectChange1.nameOfEntity = @"Parent";
        objectChange1.type = CDEObjectChangeTypeInsert;
        objectChange1.storeModificationEvent = modEvent;
        objectChange1.globalIdentifier = globalId1;
        objectChange1.propertyChangeValues = @[];
        
        objectChange2 = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:moc];
        objectChange2.nameOfEntity = @"Child";
        objectChange2.type = CDEObjectChangeTypeUpdate;
        objectChange2.storeModificationEvent = modEvent;
        objectChange2.globalIdentifier = globalId2;
        objectChange2.propertyChangeValues = @[];
        
        objectChange3 = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:moc];
        objectChange3.nameOfEntity = @"Child";
        objectChange3.type = CDEObjectChangeTypeDelete;
        objectChange3.storeModificationEvent = modEvent;
        objectChange3.globalIdentifier = globalId3;
        
        [moc save:NULL];
    }];
    
    migrator = [[CDEEventMigrator alloc] initWithEventStore:(id)self.eventStore managedObjectModel:self.testModel];
    
    exportedEventsFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"CDEEventMigratorTestFile"];
    [[NSFileManager defaultManager] removeItemAtPath:exportedEventsFile error:NULL];
    
    finishedAsyncOp = NO;
}

- (void)tearDown
{
    [fileContext reset];
    fileContext = nil;
    [[NSFileManager defaultManager] removeItemAtPath:exportedEventsFile error:NULL];
    [super tearDown];
}

- (void)waitForAsyncOpToFinish
{
    while (!finishedAsyncOp) [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
}

- (NSManagedObjectID *)objectIDForEventWithRevisionNumber:(CDERevisionNumber)revisionNumber storeIdentifier:(NSString *)storeId
{
    __block NSManagedObjectID *objectID;
    [self.eventStore.managedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"eventRevision.revisionNumber == %lld AND eventRevision.persistentStoreIdentifier = %@ && type != %d && type != %d", revisionNumber, storeId, CDEStoreModificationEventTypeBaseline, CDEStoreModificationEventTypeIncomplete];
        NSArray *storeModEvents = [self.eventStore.managedObjectContext executeFetchRequest:fetch error:NULL];
        objectID = [[storeModEvents valueForKeyPath:@"objectID"] lastObject];
    }];
    return objectID;
}

- (void)migrateToFileEventWithRevision:(CDERevisionNumber)rev
{
    [self migrateToFileEventWithRevision:rev persistentStoreIdentifier:self.eventStore.persistentStoreIdentifier];
}

- (void)migrateToFileEventWithRevision:(CDERevisionNumber)rev persistentStoreIdentifier:(NSString *)storeId
{
    NSManagedObjectID *objectID = [self objectIDForEventWithRevisionNumber:rev storeIdentifier:storeId];
    if (!objectID) return;
    finishedAsyncOp = NO;
    [migrator migrateStoreModificationEventWithObjectID:objectID toTemporaryFilesWithCompletion:^(NSError *error, NSArray *fileURLs) {
        NSURL *fileURL = fileURLs.lastObject;
        NSURL *exportedEventsURL = [NSURL fileURLWithPath:exportedEventsFile];
        [[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:exportedEventsURL error:NULL];
        finishedAsyncOp = YES;
        XCTAssertNil(error, @"Error migrating to file");
    }];
    [self waitForAsyncOpToFinish];
}

- (NSMutableDictionary *)exportedJSON
{
    NSURL *url = [NSURL fileURLWithPath:exportedEventsFile];
    return [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:NSJSONReadingMutableContainers error:NULL];
}

- (NSDictionary *)changesInFileByEntity
{
    NSDictionary *json = [self exportedJSON];
    return json[@"changesByEntity"];
}

- (void)testMigrationToFileGeneratesFile
{
    [self migrateToFileEventWithRevision:0];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:exportedEventsFile], @"File not generated");
}

- (void)testMigrationToFileMigratesEvents
{
    [self migrateToFileEventWithRevision:0];
    NSDictionary *json = [self exportedJSON];
    XCTAssertTrue(json.count > 0, @"Fetch failed");
}

- (void)testMigrationToFileMigratesEventProperties
{
    [self migrateToFileEventWithRevision:0];
    NSDictionary *json = [self exportedJSON];
    XCTAssertEqual([json[@"timestamp"] doubleValue], (NSTimeInterval)123, @"Wrong save timestamp");
    XCTAssertEqual([[self changesInFileByEntity][@"Child"] count], (NSUInteger)2, @"Wrong number of changes");
    XCTAssertEqual([[self changesInFileByEntity][@"Parent"] count], (NSUInteger)1, @"Wrong number of changes");
}

- (void)testMigrationToFileMigratesObjectChanges
{
    [self migrateToFileEventWithRevision:0];
    NSArray *changes = [self changesInFileByEntity][@"Child"];
    NSDictionary *change = changes.lastObject;
    XCTAssertNotNil(changes, @"Fetch failed");
    XCTAssertEqual(changes.count, (NSUInteger)2, @"Wrong number of changes");
    XCTAssertNotNil(change, @"change should not be nil");
    XCTAssertNotNil(change[@"globalIdentifier"], @"global id should not be nil");
}

- (void)testSingleEventIsMigratedWhenMultipleEventsExist
{
    [moc performBlockAndWait:^{
        // Setup extra event with a shared global identifier.
        // In the past, this caused the migration to pull in extra events. This shouldn't happen.
        CDEStoreModificationEvent *extraEvent = [NSEntityDescription insertNewObjectForEntityForName:@"CDEStoreModificationEvent" inManagedObjectContext:moc];
        extraEvent.timestamp = 124;
        extraEvent.type = CDEStoreModificationEventTypeSave;
        
        CDEEventRevision *revision = [NSEntityDescription insertNewObjectForEntityForName:@"CDEEventRevision" inManagedObjectContext:moc];
        revision.persistentStoreIdentifier = [self.eventStore persistentStoreIdentifier];
        revision.revisionNumber = 1;
        extraEvent.eventRevision = revision;
        
        CDEObjectChange *objectChange = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:moc];
        objectChange.nameOfEntity = @"Hello";
        objectChange.type = CDEObjectChangeTypeUpdate;
        objectChange.storeModificationEvent = extraEvent;
        objectChange.globalIdentifier = globalId1;
        objectChange.propertyChangeValues = @[];
        
        [moc save:NULL];
    }];
    
    finishedAsyncOp = NO;
    NSArray *types = @[@(CDEStoreModificationEventTypeMerge), @(CDEStoreModificationEventTypeSave)];
    [migrator migrateLocalEventToTemporaryFilesForRevision:0 allowedTypes:types completion:^(NSError *error, NSArray *fileURLs) {
        XCTAssertNil(error, @"Error migrating to file");
        XCTAssertEqual(fileURLs.count, (NSUInteger)1, @"Too many files");
        NSURL *fileURL = fileURLs.lastObject;
        NSURL *exportedEventsURL = [NSURL fileURLWithPath:exportedEventsFile];
        [[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:exportedEventsURL error:NULL];
        finishedAsyncOp = YES;
    }];
    [self waitForAsyncOpToFinish];
    
    NSDictionary *json = [self exportedJSON];
    XCTAssertTrue(json.count > 0, @"Should be json.");
    
    XCTAssertEqualObjects(json[@"revisionsByStoreIdentifier"][@"store1"], @(0), @"Wrong revision exported");
}

- (void)testNonLocalEventsAreNotMigratedToFile
{
    [moc performBlockAndWait:^{
        modEvent.eventRevision.persistentStoreIdentifier = @"otherstore";
        XCTAssertTrue([moc save:NULL], @"Failed save");
    }];
    [self migrateToFileEventWithRevision:0 persistentStoreIdentifier:@"otherstore"];

    NSDictionary *json = [self exportedJSON];
    XCTAssertTrue(json.count > 0, @"Should be json.");
}

- (void)testImportFromOtherStore
{
    [self migrateToFileEventWithRevision:0];
    NSMutableDictionary *json = [self exportedJSON];
    XCTAssertTrue(json.count > 0, @"Should be json.");
    
    // Change store id in file and reimport
    json[@"storeIdentifier"] = @"otherstore";

    NSURL *url = [NSURL fileURLWithPath:exportedEventsFile];
    [[NSJSONSerialization dataWithJSONObject:json options:0 error:NULL] writeToURL:url atomically:NO];
    
    finishedAsyncOp = NO;
    [migrator migrateEventInFromFileURLs:@[url] completion:^(NSError *error, NSManagedObjectID *newID) {
        finishedAsyncOp = YES;
        XCTAssertNil(error, @"Error migrating in from file");
    }];
    [self waitForAsyncOpToFinish];
    
    [moc performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
        NSArray *storeEvents = [moc executeFetchRequest:request error:NULL];
        XCTAssertNotNil(storeEvents, @"Fetch failed");
        XCTAssertEqual(storeEvents.count, (NSUInteger)2, @"Wrong store count");
        
        CDEStoreModificationEvent *newEvent = [[storeEvents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"eventRevision.persistentStoreIdentifier = \"otherstore\""]] lastObject];
        XCTAssertNotNil(newEvent, @"Could not retrieve new event");
        XCTAssertEqual(newEvent.objectChanges.count, (NSUInteger)3, @"Wrong number of object changes");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"globalIdentifier.globalIdentifier = \"123\" AND globalIdentifier.nameOfEntity = \"Parent\""];
        CDEObjectChange *change = [[newEvent.objectChanges filteredSetUsingPredicate:predicate] anyObject];
        XCTAssertNotNil(change, @"No change found");
        
        predicate = [NSPredicate predicateWithFormat:@"globalIdentifier.globalIdentifier = \"1234\" AND globalIdentifier.nameOfEntity = \"Child\""];
        change = [[newEvent.objectChanges filteredSetUsingPredicate:predicate] anyObject];
        XCTAssertNotNil(change, @"No change found");
        
        predicate = [NSPredicate predicateWithFormat:@"globalIdentifier.globalIdentifier = \"1234\" AND globalIdentifier.nameOfEntity = \"Child\""];
        change = [[newEvent.objectChanges filteredSetUsingPredicate:predicate] anyObject];
        XCTAssertNotNil(change, @"No change found");
    }];
}

@end
