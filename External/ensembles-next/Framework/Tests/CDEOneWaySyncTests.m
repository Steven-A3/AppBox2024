//
//  CDEOneWaySyncTest.m
//  Ensembles
//
//  Created by Drew McCormack on 9/14/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import "CDESyncTest.h"
#import "CDEPersistentStoreEnsemble.h"
#import "CDELocalCloudFileSystem.h"

@interface CDEOneWaySyncTests : CDESyncTest <CDEPersistentStoreEnsembleDelegate>

@end

@implementation CDEOneWaySyncTests

- (void)testLeeching
{
    [ensemble1 leechPersistentStoreWithCompletion:^(NSError *error) {
        XCTAssertNil(error, @"Error during leech");
        [self completeAsync];
    }];
    [self waitForAsync];
    
    XCTAssert(ensemble1.isLeeched, @"Should be leeched");
}

- (void)testLeechingTwiceGivesError
{
    [ensemble1 leechPersistentStoreWithCompletion:^(NSError *error) {
        XCTAssertNil(error, @"Error during leech");
        [ensemble1 leechPersistentStoreWithCompletion:^(NSError *error) {
            XCTAssertNotNil(error, @"Should get error in during second leech");
            [self completeAsync];
        }];
    }];
    [self waitForAsync];
    
    XCTAssert(ensemble1.isLeeched, @"Should be leeched");
}

- (void)testDeleeching
{
    [ensemble1 leechPersistentStoreWithCompletion:^(NSError *error) {
        [ensemble1 deleechPersistentStoreWithCompletion:^(NSError *error) {
            XCTAssertNil(error, @"Error during deleech");
            [self completeAsync];
        }];
    }];
    [self waitForAsync];
    
    XCTAssertFalse(ensemble1.isLeeched, @"Should not be leeched");
}

- (void)testDeleechingTwiceGivesError
{
    [ensemble1 leechPersistentStoreWithCompletion:^(NSError *error) {
        [ensemble1 deleechPersistentStoreWithCompletion:^(NSError *error) {
            [ensemble1 deleechPersistentStoreWithCompletion:^(NSError *error) {
                XCTAssertNotNil(error, @"Should be error during second deleech");
                [self completeAsync];
            }];
        }];
    }];
    [self waitForAsync];
    
    XCTAssertFalse(ensemble1.isLeeched, @"Should not be leeched");
}

- (void)testSaveAndMerge
{
    [self leechStores];
    
    id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:10.0];
    [parent setValue:@"bob" forKey:@"name"];
    [parent setValue:date forKey:@"date"];
    XCTAssertTrue([context1 save:NULL], @"Could not save");

    XCTAssertNil([self syncChanges], @"Sync failed");
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parents = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents.count, (NSUInteger)1, @"No parent found");
    
    id syncedParent = parents.lastObject;
    XCTAssertEqualObjects([syncedParent valueForKey:@"name"], @"bob", @"Wrong name");
    XCTAssertEqualObjects([syncedParent valueForKey:@"date"], date, @"Wrong date");
}

- (void)testUpdate
{
    [self leechStores];
    
    id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:10.0];
    [parent setValue:@"bob" forKey:@"name"];
    [parent setValue:date forKey:@"date"];
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    XCTAssertNil([self syncChanges], @"First sync failed");

    [parent setValue:@"dave" forKey:@"name"];
    XCTAssertTrue([context1 save:NULL], @"Could not save");

    NSError *syncError = [self syncChanges];
    XCTAssertNil(syncError, @"Second sync failed");
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parents = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents.count, (NSUInteger)1, @"No parent found");
    
    id syncedParent = parents.lastObject;
    XCTAssertEqualObjects([syncedParent valueForKey:@"name"], @"dave", @"Wrong name");
    XCTAssertEqualObjects([syncedParent valueForKey:@"date"], date, @"Wrong date");
}

- (void)testToOneRelationship
{
    [self leechStores];
    
    id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    id child = [NSEntityDescription insertNewObjectForEntityForName:@"Child" inManagedObjectContext:context1];
    [child setValue:parent forKey:@"parent"];
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    XCTAssertNil([self syncChanges], @"Sync failed");
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parents = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents.count, (NSUInteger)1, @"No parent found");
    
    fetch = [NSFetchRequest fetchRequestWithEntityName:@"Child"];
    NSArray *children = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(children.count, (NSUInteger)1, @"No child found");
    
    id syncedParent = parents.lastObject;
    id syncedChild = children.lastObject;
    XCTAssertEqualObjects(syncedChild, [syncedParent valueForKey:@"child"], @"Relationship not set");
}

- (void)testToManyRelationship
{
    [self leechStores];
    
    id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    id child = [NSEntityDescription insertNewObjectForEntityForName:@"Child" inManagedObjectContext:context1];
    [child setValue:parent forKey:@"parentWithSiblings"];
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    XCTAssertNil([self syncChanges], @"Sync failed");
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parents = [context2 executeFetchRequest:fetch error:NULL];
    fetch = [NSFetchRequest fetchRequestWithEntityName:@"Child"];
    NSArray *children = [context2 executeFetchRequest:fetch error:NULL];
    
    id syncedParent = parents.lastObject;
    id syncedChild = children.lastObject;
    XCTAssertEqualObjects([[syncedParent valueForKey:@"children"] anyObject], syncedChild, @"Relationship not set");
}

- (void)testSmallDataAttributeLeadsToNoExternalDataFiles
{
    [self leechStores];

    const uint8_t bytes[10000];
    id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [parent setValue:[[NSData alloc] initWithBytes:bytes length:10000] forKey:@"data"];
    [context1 save:NULL];
    
    NSString *eventStoreDataDir = [eventDataRoot1 stringByAppendingPathComponent:@"com.ensembles.synctest/data"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventStoreDataDir error:NULL];
    XCTAssertEqual(contents.count, (NSUInteger)0, @"Should be no external files in event store. File too small.");
}

- (void)testLargeDataAttributeLeadsToExternalDataFile
{
    [self leechStores];
    
    const uint8_t bytes[10001];
    id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [parent setValue:[[NSData alloc] initWithBytes:bytes length:10001] forKey:@"data"];
    [context1 save:NULL];
    
    NSString *eventStoreDataDir = [eventDataRoot1 stringByAppendingPathComponent:@"com.ensembles.synctest/data"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventStoreDataDir error:NULL];
    XCTAssertEqual(contents.count, (NSUInteger)1, @"Should be an external file.");
}

- (void)testSyncOfLargeDataTransfersFile
{
    [self leechStores];
    
    const uint8_t bytes[10001];
    id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [parent setValue:[[NSData alloc] initWithBytes:bytes length:10001] forKey:@"data"];
    [context1 save:NULL];
    
    NSString *eventStoreDataDir = [eventDataRoot2 stringByAppendingPathComponent:@"com.ensembles.synctest/data"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventStoreDataDir error:NULL];
    XCTAssertEqual(contents.count, (NSUInteger)0, @"Should be no external file.");
    
    [self syncChanges];
    
    contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventStoreDataDir error:NULL];
    XCTAssertEqual(contents.count, (NSUInteger)1, @"Should be an external file.");
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parents = [context2 executeFetchRequest:fetch error:NULL];
    id parentInContext2 = parents.lastObject;
    XCTAssertEqual([[parentInContext2 valueForKey:@"data"] length], (NSUInteger)10001, @"Wrong data length after sync");
}

- (void)testImportOfLargeData
{
    const uint8_t bytes[10001];
    id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [parent setValue:[[NSData alloc] initWithBytes:bytes length:10001] forKey:@"data"];
    [context1 save:NULL];
    
    [self leechStores];
    
    NSString *eventStoreDataDir = [eventDataRoot1 stringByAppendingPathComponent:@"com.ensembles.synctest/data"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventStoreDataDir error:NULL];
    XCTAssertEqual(contents.count, (NSUInteger)1, @"Should be an external file after import.");
}

- (void)testSyncOfSmallData
{
    [self leechStores];

    NSString *testString = @"sadf s sfd fa d afsd fd asfd af fd dfas  f sfadasdf";
    NSData *data = [testString dataUsingEncoding:NSUTF8StringEncoding];
    id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [parent setValue:data forKey:@"data"];
    [context1 save:NULL];
    
    [self syncChanges];
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parents = [context2 executeFetchRequest:fetch error:NULL];
    id parentInContext2 = parents.lastObject;
    NSData *syncData = [parentInContext2 valueForKey:@"data"];
    XCTAssertEqualObjects(data, syncData, @"Wrong data after sync");
}

- (void)testRebasingWithLargeData
{
    [self leechStores];

    const uint8_t bytes[10001];
    NSMutableArray *parents = [NSMutableArray array];
    for (NSUInteger i = 0; i < 100; i++) {
        // 50 saves forces a rebase
        id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
        [parent setValue:[[NSData alloc] initWithBytes:bytes length:10001] forKey:@"data"];
        [parents addObject:parent];
        [context1 save:NULL];
    }
    
    [context1 deleteObject:parents[0]]; // Delete one parent
    [context1 save:NULL];
    
    NSString *eventStoreDataDir = [eventDataRoot1 stringByAppendingPathComponent:@"com.ensembles.synctest/data"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventStoreDataDir error:NULL];
    XCTAssertEqual(contents.count, (NSUInteger)100, @"Should be a 50 data files. Delete has no affect before rebase.");

    [self syncChanges]; // Should rebase due to many saves
    
    contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventStoreDataDir error:NULL];
    XCTAssertEqual(contents.count, (NSUInteger)99, @"Rebase should clean up one of the data files");
}

- (void)testBatchedMigrationAndMultipartFileSets
{
    [self leechStores];
    [self mergeEnsemble:ensemble2]; // Exports baseline
    
    for (NSUInteger i = 0; i < 500; i++) {
        [NSEntityDescription insertNewObjectForEntityForName:@"BatchParent" inManagedObjectContext:context1];
    }
    [context1 save:NULL]; // Generates 10 files
    [self mergeEnsemble:ensemble1]; // Generates 1 file
    
    NSString *eventsDir = [cloudRootDir stringByAppendingPathComponent:@"com.ensembles.synctest/events"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventsDir error:NULL];
    XCTAssertEqual(contents.count, (NSUInteger)11, @"Should be a 11 event files.");
    
    NSString *baselineDir = [cloudRootDir stringByAppendingPathComponent:@"com.ensembles.synctest/baselines"];
    contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:baselineDir error:NULL];
    XCTAssertEqual(contents.count, (NSUInteger)1, @"Should be a single baseline.");
    
    [self mergeEnsemble:ensemble2];
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"BatchParent"];
    NSArray *parentsInContext2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parentsInContext2.count, (NSUInteger)500, @"Wrong parents in second context");
}

- (void)testBatchedMigrationOfRelatedObjects
{
    [self leechStores];
    
    for (NSUInteger i = 0; i < 100; i++) {
        id parent = [NSEntityDescription insertNewObjectForEntityForName:@"BatchParent" inManagedObjectContext:context1];
        for (NSUInteger j = 0; j < 5; j++) {
            id child = [NSEntityDescription insertNewObjectForEntityForName:@"BatchChild" inManagedObjectContext:context1];
            [child setValue:parent forKey:@"batchParent"];
        }
    }
    [context1 save:NULL];
    [self mergeEnsemble:ensemble1];
    
    NSString *eventsDir = [cloudRootDir stringByAppendingPathComponent:@"com.ensembles.synctest/events"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventsDir error:NULL];
    XCTAssertEqual(contents.count, (NSUInteger)2, @"Should be 2 files. Two parts of save.");
    
    [self mergeEnsemble:ensemble2];
    [self mergeEnsemble:ensemble1];

    contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:eventsDir error:NULL];
    XCTAssertEqual(contents.count, (NSUInteger)4, @"Should be 4 files.");
    
    NSFetchRequest *parentFetch = [NSFetchRequest fetchRequestWithEntityName:@"BatchParent"];
    NSArray *parentsInContext2 = [context2 executeFetchRequest:parentFetch error:NULL];
    XCTAssertEqual(parentsInContext2.count, (NSUInteger)100, @"Wrong parents in second context");
    
    NSFetchRequest *childFetch = [NSFetchRequest fetchRequestWithEntityName:@"BatchChild"];
    NSArray *childrenInContext2 = [context2 executeFetchRequest:childFetch error:NULL];
    XCTAssertEqual(childrenInContext2.count, (NSUInteger)500, @"Wrong children in second context");
}

@end


