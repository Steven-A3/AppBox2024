//
//  CDEEventMigratorMultipleFileTests.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 15/04/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDEEventStoreTestCase.h"
#import "CDEEventMigrator.h"
#import "CDEGlobalIdentifier.h"
#import "CDEObjectChange.h"
#import "CDEStoreModificationEvent.h"
#import "CDEEventRevision.h"

@interface CDEEventMigratorMultipleFileTests : CDEEventStoreTestCase

@end

@implementation CDEEventMigratorMultipleFileTests {
    CDEMockPersistentStoreEnsemble *ensemble;
    CDEEventMigrator *migrator;
    NSManagedObjectID *eventID;
}

+ (void)setUp
{
    [super setUp];
    [self setUseDiskStore:YES];
}

- (void)setUp
{
    [super setUp];
    
    self.eventStore.pathToTemporaryDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"EventMigratorTest"];
    [[NSFileManager defaultManager] removeItemAtPath:self.eventStore.pathToTemporaryDirectory error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.eventStore.pathToTemporaryDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    
    ensemble = [[CDEMockPersistentStoreEnsemble alloc] init];
    ensemble.managedObjectModel = self.testModel;
    
    migrator = [[CDEEventMigrator alloc] initWithEventStore:(id)self.eventStore managedObjectModel:self.testModel];
    
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        CDEStoreModificationEvent *modEvent = [NSEntityDescription insertNewObjectForEntityForName:@"CDEStoreModificationEvent" inManagedObjectContext:moc];
        modEvent.timestamp = 123;
        modEvent.type = CDEStoreModificationEventTypeMerge;
        
        CDEEventRevision *revision = [NSEntityDescription insertNewObjectForEntityForName:@"CDEEventRevision" inManagedObjectContext:moc];
        revision.persistentStoreIdentifier = [self.eventStore persistentStoreIdentifier];
        revision.revisionNumber = 0;
        modEvent.eventRevision = revision;
        
        for (NSUInteger i = 0; i < 100; i++) {
            CDEGlobalIdentifier *globalId = [NSEntityDescription insertNewObjectForEntityForName:@"CDEGlobalIdentifier" inManagedObjectContext:moc];
            globalId.globalIdentifier = [[NSProcessInfo processInfo] globallyUniqueString];
            globalId.nameOfEntity = @"Parent";
            
            CDEObjectChange *objectChange = [NSEntityDescription insertNewObjectForEntityForName:@"CDEObjectChange" inManagedObjectContext:moc];
            objectChange.nameOfEntity = @"Parent";
            objectChange.type = CDEObjectChangeTypeInsert;
            objectChange.storeModificationEvent = modEvent;
            objectChange.globalIdentifier = globalId;
            objectChange.propertyChangeValues = @[];
        }
        
        [moc save:NULL];
        
        eventID = modEvent.objectID;
    }];
}

- (void)tearDown
{
    [super tearDown];
    [[NSFileManager defaultManager] removeItemAtPath:self.eventStore.pathToTemporaryDirectory error:NULL];
}

- (void)testExportingSingleFile
{
    NSEntityDescription *parentEntity = self.testModel.entitiesByName[@"Parent"];
    NSMutableDictionary *mutableInfo = [parentEntity.userInfo mutableCopy];
    mutableInfo[CDEMigrationBatchSizeKey] = @"100";
    parentEntity.userInfo = mutableInfo;
    
    [migrator migrateStoreModificationEventWithObjectID:eventID toTemporaryFilesWithCompletion:^(NSError *error, NSArray *fileURLs) {
        XCTAssertNil(error, @"Error occurred");
        XCTAssertEqual(fileURLs.count, (NSUInteger)1, @"Wrong number of files");
        [self stopAsyncOp];
    }];
    [self waitForAsyncOpToFinish];
}

- (void)testExportingTwoEqualBatches
{
    NSEntityDescription *parentEntity = self.testModel.entitiesByName[@"Parent"];
    NSMutableDictionary *mutableInfo = [parentEntity.userInfo mutableCopy];
    mutableInfo[CDEMigrationBatchSizeKey] = @"50";
    parentEntity.userInfo = mutableInfo;
    
    [migrator migrateStoreModificationEventWithObjectID:eventID toTemporaryFilesWithCompletion:^(NSError *error, NSArray *fileURLs) {
        XCTAssertEqual(fileURLs.count, (NSUInteger)2, @"Should be 2 files");
        
        NSDictionary *json1 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:fileURLs[0]] options:0 error:NULL];
        NSDictionary *json2 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:fileURLs[1]] options:0 error:NULL];
        XCTAssertTrue(json1 && json2, @"No json in one of the files");

        [self stopAsyncOp];
    }];
    [self waitForAsyncOpToFinish];
}

- (void)testExportingSmallThirdBatch
{
    NSEntityDescription *parentEntity = self.testModel.entitiesByName[@"Parent"];
    NSMutableDictionary *mutableInfo = [parentEntity.userInfo mutableCopy];
    mutableInfo[CDEMigrationBatchSizeKey] = @"49";
    parentEntity.userInfo = mutableInfo;
    
    [migrator migrateStoreModificationEventWithObjectID:eventID toTemporaryFilesWithCompletion:^(NSError *error, NSArray *fileURLs) {
        XCTAssertEqual(fileURLs.count, (NSUInteger)3, @"Should be 3 files");
        
        NSDictionary *json0 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:fileURLs[0]] options:0 error:NULL];
        NSDictionary *json1 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:fileURLs[1]] options:0 error:NULL];
        NSDictionary *json2 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:fileURLs[2]] options:0 error:NULL];

        NSArray *changes = json0[@"changesByEntity"][@"Parent"];
        XCTAssertEqual(changes.count, (NSUInteger)49, @"Wrong number of changes in file");

        changes = json1[@"changesByEntity"][@"Parent"];
        XCTAssertEqual(changes.count, (NSUInteger)49, @"Wrong number of changes in file");
        
        changes = json2[@"changesByEntity"][@"Parent"];
        XCTAssertEqual(changes.count, (NSUInteger)2, @"Wrong number of changes in file");
    
        [self stopAsyncOp];
    }];
    [self waitForAsyncOpToFinish];
}

- (void)testFilesContainDistinctObjectChanges
{
    NSEntityDescription *parentEntity = self.testModel.entitiesByName[@"Parent"];
    NSMutableDictionary *mutableInfo = [parentEntity.userInfo mutableCopy];
    mutableInfo[CDEMigrationBatchSizeKey] = @"51";
    parentEntity.userInfo = mutableInfo;
    
    [migrator migrateStoreModificationEventWithObjectID:eventID toTemporaryFilesWithCompletion:^(NSError *error, NSArray *fileURLs) {
        NSMutableSet *globalIds = [NSMutableSet set];
    
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:fileURLs[0]] options:0 error:NULL];
        NSArray *changes = json[@"changesByEntity"][@"Parent"];
        [globalIds addObjectsFromArray:[changes valueForKeyPath:@"globalIdentifier"]];
        
        json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:fileURLs[1]] options:0 error:NULL];
        changes = json[@"changesByEntity"][@"Parent"];
        [globalIds addObjectsFromArray:[changes valueForKeyPath:@"globalIdentifier"]];
        
        XCTAssertEqual(globalIds.count, (NSUInteger)100, @"Wrong number of global ids");
        
        [self stopAsyncOp];
    }];
    [self waitForAsyncOpToFinish];
}

- (void)testExportAndReimport
{
    NSEntityDescription *parentEntity = self.testModel.entitiesByName[@"Parent"];
    NSMutableDictionary *mutableInfo = [parentEntity.userInfo mutableCopy];
    mutableInfo[CDEMigrationBatchSizeKey] = @"50";
    parentEntity.userInfo = mutableInfo;
    
    [migrator migrateStoreModificationEventWithObjectID:eventID toTemporaryFilesWithCompletion:^(NSError *error, NSArray *fileURLs) {
        // Delete event from main event store
        NSManagedObjectContext *context = self.eventStore.managedObjectContext;
        [context performBlockAndWait:^{
            CDEStoreModificationEvent *event = (id)[context objectWithID:eventID];
            [context deleteObject:event];
            [context save:NULL];
            
            NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
            NSArray *events = [context executeFetchRequest:fetch error:NULL];
            XCTAssertEqual(events.count, (NSUInteger)0, @"Should be no event left");
        }];
        
        // Migrate event back in
        [migrator migrateEventInFromFileURLs:fileURLs completion:^(NSError *error, NSManagedObjectID *anEventID) {
            XCTAssertNotNil(anEventID, @"Should be event id passed");
            
            NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
            NSArray *events = [context executeFetchRequest:fetch error:NULL];
            XCTAssertEqual(events.count, (NSUInteger)1, @"Should be an event after import");
            
            CDEStoreModificationEvent *event = events.lastObject;
            XCTAssertEqualObjects(event.objectID, anEventID, @"Wrong event id passed back");
            
            XCTAssertEqual(event.objectChanges.count, (NSUInteger)100, @"Wrong number changes");
            
            NSSet *globalIds = [event.objectChanges valueForKeyPath:@"globalIdentifier.globalIdentifier"];
            XCTAssertEqual(globalIds.count, (NSUInteger)100, @"Wrong number of global ids");
            
            [self stopAsyncOp];
        }];
    }];
    [self waitForAsyncOpToFinish];
}

- (NSManagedObjectContext *)contextForFileURL:(NSURL *)url
{
    NSManagedObjectModel *model = self.eventStore.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSManagedObjectContext *fileContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    fileContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [fileContext.persistentStoreCoordinator addPersistentStoreWithType:NSBinaryStoreType configuration:nil URL:url options:nil error:NULL];
    return fileContext;
}

- (void)waitForAsyncOpToFinish
{
    CFRunLoopRun();
}

- (void)stopAsyncOp
{
    CFRunLoopStop(CFRunLoopGetCurrent());
}

@end
