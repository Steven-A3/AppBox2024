//
//  CDEDependencySyncTests.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 14/04/15.
//  Copyright (c) 2015 Drew McCormack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDESyncTest.h"
#import "CDEPersistentStoreEnsemble.h"
#import "CDELocalCloudFileSystem.h"

@interface CDEPersistentStoreEnsemble (CDESyncTestMethods)

- (void)stopMonitoringSaves;

@end

@interface CDEDependencySyncTests : CDESyncTest

@end

@implementation CDEDependencySyncTests {
    NSString *testStoreFile3;
    NSURL *testStoreURL3;
    NSString *eventDataRoot3;
    NSManagedObjectContext *context3;
    CDEPersistentStoreEnsemble *ensemble3;
    id <CDECloudFileSystem> cloudFileSystem3;
}

- (void)setUp
{
    [super setUp];
    
    // First store
    testStoreFile3 = [testRootDirectory stringByAppendingPathComponent:@"store3.sql"];
    testStoreURL3 = [NSURL fileURLWithPath:testStoreFile3];
    
    NSPersistentStoreCoordinator *testPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [testPSC addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:testStoreURL3 options:nil error:NULL];
    
    context3 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    context3.persistentStoreCoordinator = testPSC;
    context3.stalenessInterval = 0.0;
    context3.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    
    cloudFileSystem3 = [[CDELocalCloudFileSystem alloc] initWithRootDirectory:cloudRootDir];
    eventDataRoot3 = [testRootDirectory stringByAppendingPathComponent:@"eventData3"];
    NSURL *eventDataRoot3URL = [NSURL fileURLWithPath:eventDataRoot1];
    ensemble3 = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"com.ensembles.synctest" persistentStoreURL:testStoreURL3 persistentStoreOptions:nil managedObjectModelURL:testModelURL cloudFileSystem:cloudFileSystem3 localDataRootDirectoryURL:eventDataRoot3URL];
    ensemble3.delegate = self;
}

- (void)tearDown
{
    [ensemble3 stopMonitoringSaves];
    [context3 reset];
    [super tearDown];
}

- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didSaveMergeChangesWithNotification:(NSNotification *)notif
{
    if (ensemble == ensemble3) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [context3 mergeChangesFromContextDidSaveNotification:notif];
        });
    }
    else {
        [super persistentStoreEnsemble:ensemble didSaveMergeChangesWithNotification:notif];
    }
}

- (void)testMissingDataFilePreventsEventMerge
{
    [self leechStores];
    
    const uint8_t b[10001];
    NSData *data = [[NSData alloc] initWithBytes:b length:sizeof(b)];
    id parent1 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [parent1 setValue:@"bob" forKey:@"name"];
    [parent1 setValue:data forKey:@"data"];
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    [self mergeEnsemble:ensemble1]; // Exports data file
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parentsInContext2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext2.count, 0);

    // Remove data file to fake it missing
    NSString *dataRoot = [cloudRootDir stringByAppendingPathComponent:@"com.ensembles.synctest/data"];
    [[NSFileManager defaultManager] removeItemAtPath:dataRoot error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:dataRoot withIntermediateDirectories:NO attributes:nil error:NULL];
    
    [self mergeEnsemble:ensemble2];
    
    parentsInContext2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext2.count, 0);
    
    [self mergeEnsemble:ensemble1];
    [self mergeEnsemble:ensemble2];

    parentsInContext2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext2.count, 1);

    id parent1InContext2 = parentsInContext2.lastObject;
    XCTAssertNotNil([parent1InContext2 valueForKey:@"data"]);
}

- (void)testMissingEventInvalidatesFutureEventsFromDevice
{
    [self leechStores];
    
    __unused id parent1 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [context1 save:NULL];
    [self mergeEnsemble:ensemble1];
    
    NSString *eventsRoot = [cloudRootDir stringByAppendingPathComponent:@"com.ensembles.synctest/events"];
    NSArray *eventFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventsRoot error:NULL];
    NSString *firstEventFile = [eventsRoot stringByAppendingPathComponent:eventFiles.lastObject];
    
    __unused id parent2 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [context1 save:NULL];
    [self mergeEnsemble:ensemble1];

    // Remove first cloud event file
    [[NSFileManager defaultManager] removeItemAtPath:firstEventFile error:NULL];
    
    [self mergeEnsemble:ensemble2];
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parentsInContext2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext2.count, 0);
    
    [self syncChanges];
    
    parentsInContext2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext2.count, 2);

}

- (void)testMissingDependenciesFromOneDeviceDoesNotBlockOthersFromSyncing
{
    [self leechStores];
    XCTestExpectation *leechExpect = [self expectationWithDescription:@"leech"];
    [ensemble3 leechPersistentStoreWithCompletion:^(NSError *error) {
        [leechExpect fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:NULL];
    
    __unused id parent1 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [context1 save:NULL];
    [self mergeEnsemble:ensemble1];
    
    NSString *eventsRoot = [cloudRootDir stringByAppendingPathComponent:@"com.ensembles.synctest/events"];
    NSArray *eventFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventsRoot error:NULL];
    NSString *firstEventFile = [eventsRoot stringByAppendingPathComponent:eventFiles.lastObject];
    
    __unused id parent2 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [context1 save:NULL];
    [self mergeEnsemble:ensemble1];
    
    // Remove first cloud event file
    [[NSFileManager defaultManager] removeItemAtPath:firstEventFile error:NULL];
    
    [self mergeEnsemble:ensemble2];
    [self mergeEnsemble:ensemble3];
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parentsInContext2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext2.count, 0);
    
    NSArray *parentsInContext3 = [context3 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext3.count, 0);
    
    // Create object on device 2 and see if it reaches 3
    __unused id parentOn2 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context2];
    [context2 save:NULL];
    [self mergeEnsemble:ensemble2];
    [self mergeEnsemble:ensemble3];

    parentsInContext3 = [context3 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext3.count, 1);
    
    // Now do a full sync, and see if all devices get the objects
    [self syncChanges];
    [self mergeEnsemble:ensemble3];
    
    NSArray *parentsInContext1 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext1.count, 3);
    
    parentsInContext2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext2.count, 3);
    
    parentsInContext3 = [context3 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext3.count, 3);
}

- (void)testThatADependencyFromADifferentDevicePreventsMerge
{
    [self leechStores];
    XCTestExpectation *leechExpect = [self expectationWithDescription:@"leech"];
    [ensemble3 leechPersistentStoreWithCompletion:^(NSError *error) {
        [leechExpect fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:NULL];
    
    __unused id parent1 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [context1 save:NULL];
    [self mergeEnsemble:ensemble1];

    NSString *eventsRoot = [cloudRootDir stringByAppendingPathComponent:@"com.ensembles.synctest/events"];
    NSArray *eventFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventsRoot error:NULL];
    NSString *firstEventFile = [eventsRoot stringByAppendingPathComponent:eventFiles.lastObject];
    
    // Create a save event without dependency on device 2
    [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context2];
    [context2 save:NULL];
    
    // Merge to get device 1 data
    [self mergeEnsemble:ensemble2];
    
    // Another event on device 2, but this one is dependent
    [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context2];
    [context2 save:NULL];
    
    // Upload
    [self mergeEnsemble:ensemble2];
    
    // Remove first cloud event file
    [[NSFileManager defaultManager] removeItemAtPath:firstEventFile error:NULL];
    
    // Device 3 should have a missing dependency. Will only get initial save from device 2
    [self mergeEnsemble:ensemble3];
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parentsInContext3 = [context3 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext3.count, 1);
    
    // Now do a full sync, and see if all devices get the objects
    [self mergeEnsemble:ensemble1];
    [self mergeEnsemble:ensemble3];
    
    parentsInContext3 = [context3 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext3.count, 3);
}

- (void)testBaselineWithMissingDataFilesIsIgnored
{
    const uint8_t b[10001];
    NSData *data = [[NSData alloc] initWithBytes:b length:sizeof(b)];
    id parent1 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [parent1 setValue:@"bob" forKey:@"name"];
    [parent1 setValue:data forKey:@"data"];
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    id child1 = [NSEntityDescription insertNewObjectForEntityForName:@"Child" inManagedObjectContext:context2];
    [child1 setValue:@"peter" forKey:@"name"];
    XCTAssertTrue([context2 save:NULL], @"Could not save");
    
    [self leechStores];
    
    // Add one save event
    id parent2 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [parent2 setValue:@"terry" forKey:@"name"];
    [context1 save:NULL];
    
    // Merge context 1. Exports data file.
    [self mergeEnsemble:ensemble1];
    
    // Remove data file to fake it missing
    NSString *dataRoot = [cloudRootDir stringByAppendingPathComponent:@"com.ensembles.synctest/data"];
    [[NSFileManager defaultManager] removeItemAtPath:dataRoot error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:dataRoot withIntermediateDirectories:NO attributes:nil error:NULL];
    
    // Merge other ensemble. Should ignore baseline and save event due to missing data file.
    [self mergeEnsemble:ensemble2];

    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parentsInContext2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext2.count, 0);
    
    // Reupload the data file
    [self mergeEnsemble:ensemble1];
    
    // See if data from context 1 has made it to context 2
    NSFetchRequest *fetchChild = [NSFetchRequest fetchRequestWithEntityName:@"Child"];
    NSArray *childrenInContext1 = [context1 executeFetchRequest:fetchChild error:NULL];
    XCTAssertEqual(childrenInContext1.count, 1);
    
    // Merge the full data now.
    [self mergeEnsemble:ensemble2];
    
    parentsInContext2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext2.count, 2);
}

@end
