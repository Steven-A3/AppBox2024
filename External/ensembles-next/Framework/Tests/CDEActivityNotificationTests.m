//
//  CDEActivityNotificationTests.m
//  Ensembles Mac
//
//  Created by Jody Hagins on 4/11/15.
//  Copyright (c) 2015 Drew McCormack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDEPersistentStoreEnsemble.h"
#import "CDELocalCloudFileSystem.h"
#import "CDEEventStore.h"

@interface CDEPersistentStoreEnsemble (CDETestMethods)

- (CDEEventStore *)eventStore;

@end

@interface CDEActivityNotificationTests : XCTestCase

@end

@implementation CDEActivityNotificationTests {
    CDEPersistentStoreEnsemble *ensemble;
    NSString *rootTestDir, *cloudDir;
    NSManagedObjectContext *moc;
}

- (void)setUp {
    [super setUp];

    rootTestDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[self className]];
    [[NSFileManager defaultManager] removeItemAtPath:rootTestDir error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:rootTestDir withIntermediateDirectories:YES attributes:nil error:NULL];

    NSURL *testModelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"CDEStoreModificationEventTestsModel" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:testModelURL];

    cloudDir = [rootTestDir stringByAppendingPathComponent:@"cloud"];
    [[NSFileManager defaultManager] createDirectoryAtPath:cloudDir withIntermediateDirectories:YES attributes:nil error:NULL];

    NSString *storePath = [rootTestDir stringByAppendingPathComponent:@"db.sqlite"];
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];

    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:NULL];
    moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    moc.persistentStoreCoordinator = coordinator;

    [CDEEventStore setDefaultPathToEventDataRootDirectory:[rootTestDir stringByAppendingPathComponent:@"eventStore"]];

    id<CDECloudFileSystem> cloudFileSystem = [[CDELocalCloudFileSystem alloc] initWithRootDirectory:cloudDir];
    ensemble = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"testensemble" persistentStoreURL:storeURL managedObjectModelURL:testModelURL cloudFileSystem:(id)cloudFileSystem];
}

- (void)leech {
    XCTestExpectation *complete = [self expectationWithDescription:@"leech"];
    [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
        [complete fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)deleech {
    XCTestExpectation *complete = [self expectationWithDescription:@"deleech"];
    [ensemble deleechPersistentStoreWithCompletion:^(NSError *error) {
        NSLog(@"deleach done with error %@", error);
        [complete fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)merge {
    XCTestExpectation *complete = [self expectationWithDescription:@"merge"];
    [ensemble mergeWithCompletion:^(NSError *error) {
        [complete fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)removeCloudDirectory {
    [[NSFileManager defaultManager] removeItemAtPath:cloudDir error:NULL];
}

- (void)removeEventStore {
    [[ensemble eventStore] removeEventStore];
}

- (void)tearDown {
    [[NSFileManager defaultManager] removeItemAtPath:rootTestDir error:NULL];
    [super tearDown];
}

- (NSArray*)expectationsForActivity:(CDEEnsembleActivity)expectedActivity error:(BOOL)expectError {
    return
  @[
    [self expectationForNotification:CDEPersistentStoreEnsembleDidBeginActivityNotification object:ensemble handler:^BOOL(NSNotification *notification) {
        CDEEnsembleActivity activity = [notification.userInfo[CDEEnsembleActivityKey] unsignedIntegerValue];
        NSError *error = notification.userInfo[CDEActivityErrorKey];
        return activity == expectedActivity && error == nil;
    }],
    [self expectationForNotification:CDEPersistentStoreEnsembleWillEndActivityNotification object:ensemble handler:^BOOL(NSNotification *notification) {
        CDEEnsembleActivity activity = [notification.userInfo[CDEEnsembleActivityKey] unsignedIntegerValue];
        NSError *error = notification.userInfo[CDEActivityErrorKey];
        return activity == expectedActivity && !error == !expectError;
    }]
    ];
}

- (void)testDidBeginWillEndNotificationsForLeeching {
    [self expectationsForActivity:CDEEnsembleActivityLeeching error:NO];
    [self leech];
}

- (void)testDidBeginWillEndNotificationsForLeechingWithError {
    [self removeCloudDirectory];
    [self expectationsForActivity:CDEEnsembleActivityLeeching error:YES];
    [self leech];
}

- (void)testDidBeginWillEndNotificationsForMerging {
    [self leech];
    [self expectationsForActivity:CDEEnsembleActivityMerging error:NO];
    [self merge];
}

- (void)testDidBeginWillEndNotificationsForMergingWithError {
    [self leech];
    [self removeCloudDirectory];
    [self expectationsForActivity:CDEEnsembleActivityMerging error:YES];
    [self merge];
}

- (void)testDidBeginWillEndNotificationsForDeleeching {
    [self leech];
    [self expectationsForActivity:CDEEnsembleActivityDeleeching error:NO];
    [self deleech];
}

- (void)testDidBeginWillEndNotificationsForDeleechingWithError {
    [self leech];
    [self removeEventStore];
    [self expectationsForActivity:CDEEnsembleActivityDeleeching error:YES];
    [self deleech];
}

@end
