//
//  CDEPersistentStoreEnsembleTests.m
//  Ensembles
//
//  Created by Drew McCormack on 25/09/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDEEventStore.h"
#import "CDEPersistentStoreEnsemble.h"
#import "CDELocalCloudFileSystem.h"
#import "CDEMockLocalFileSystem.h"

@interface CDEPersistentStoreEnsemble (CDETestMethods)

- (CDEEventStore *)eventStore;

@end


@interface CDEPersistentStoreEnsembleTests : XCTestCase <CDEPersistentStoreEnsembleDelegate>

@end

@implementation CDEPersistentStoreEnsembleTests {
    CDEPersistentStoreEnsemble *ensemble;
    CDEMockLocalFileSystem *cloudFileSystem;
    NSManagedObjectContext *managedObjectContext;
    NSString *rootDir;
    NSString *cloudDir;
    NSURL *storeURL;
    BOOL deleechOccurred;
    BOOL finishedAsync;
    BOOL testingSavingDuringLeeching;
}

- (void)setUp
{
    [super setUp];
    
    rootDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"CDEPersistentStoreEnsembleTests"];
    [[NSFileManager defaultManager] removeItemAtPath:rootDir error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:rootDir withIntermediateDirectories:YES attributes:nil error:NULL];
    
    [CDEEventStore setDefaultPathToEventDataRootDirectory:[rootDir stringByAppendingPathComponent:@"eventStore"]];
    
    cloudDir = [rootDir stringByAppendingPathComponent:@"cloud"];
    [[NSFileManager defaultManager] createDirectoryAtPath:cloudDir withIntermediateDirectories:YES attributes:nil error:NULL];

    cloudFileSystem = (id)[[CDEMockLocalFileSystem alloc] initWithRootDirectory:cloudDir];
    cloudFileSystem.identityToken = @"first";
    
    NSString *storePath = [rootDir stringByAppendingPathComponent:@"teststore.sqlite"];
    storeURL = [NSURL fileURLWithPath:storePath];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
    
    NSURL *testModelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"CDEStoreModificationEventTestsModel" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:testModelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:NULL];
    managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    managedObjectContext.persistentStoreCoordinator = coordinator;
    [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:managedObjectContext];
    [managedObjectContext save:NULL];
    
    ensemble = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"testensemble" persistentStoreURL:storeURL managedObjectModelURL:testModelURL cloudFileSystem:(id)cloudFileSystem];
    
    deleechOccurred = NO;
    testingSavingDuringLeeching = NO;
}

- (void)tearDown
{
    [ensemble dismantle];
    [[NSFileManager defaultManager] removeItemAtPath:rootDir error:NULL];
    [super tearDown];
}

- (void)waitForAsync
{
    finishedAsync = NO;
    while (!finishedAsync) CFRunLoopRun();
}

- (void)finishAsync
{
    finishedAsync = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)testCannotCreateAnEnsembleThatTriesToSharePersistentDataWithAnExistingEnsemble
{
    NSURL *testModelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"CDEStoreModificationEventTestsModel" withExtension:@"momd"];
    CDEPersistentStoreEnsemble *e = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"testensemble" persistentStoreURL:storeURL managedObjectModelURL:testModelURL cloudFileSystem:(id)cloudFileSystem];
    XCTAssertNil(e);

    e = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"testensemble1" persistentStoreURL:storeURL managedObjectModelURL:testModelURL cloudFileSystem:(id)cloudFileSystem];
    XCTAssertNil(e);
    
    NSString *storePath = [rootDir stringByAppendingPathComponent:@"teststore1.sqlite"];
    NSURL *otherStoreURL = [NSURL fileURLWithPath:storePath];
    e = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"testensemble1" persistentStoreURL:otherStoreURL managedObjectModelURL:testModelURL cloudFileSystem:(id)cloudFileSystem];
    XCTAssertNotNil(e);
    
    [e dismantle];
}

- (void)testDismantle
{
    NSURL *testModelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"CDEStoreModificationEventTestsModel" withExtension:@"momd"];
    CDEPersistentStoreEnsemble *e = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"testensemble" persistentStoreURL:storeURL managedObjectModelURL:testModelURL cloudFileSystem:(id)cloudFileSystem];
    XCTAssertNil(e);

    [ensemble dismantle];
    
    e = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"testensemble" persistentStoreURL:storeURL managedObjectModelURL:testModelURL cloudFileSystem:(id)cloudFileSystem];
    XCTAssertNotNil(e);
    
    [e dismantle];
}

- (void)testReleasedEnsembleGetsDealloced
{
    [ensemble dismantle];
    
    __weak CDEPersistentStoreEnsemble *weakEnsemble;
    @autoreleasepool {
        NSURL *testModelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"CDEStoreModificationEventTestsModel" withExtension:@"momd"];
        CDEPersistentStoreEnsemble *e = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"testensemble" persistentStoreURL:storeURL managedObjectModelURL:testModelURL cloudFileSystem:(id)cloudFileSystem];
        [e leechPersistentStoreWithCompletion:^(NSError *error) {
            [e mergeWithCompletion:^(NSError *error) {
                [self finishAsync];
            }];
        }];
        weakEnsemble = e;
    }
    [self waitForAsync];

    finishedAsync = NO;
    if (weakEnsemble) {
        [weakEnsemble processPendingChangesWithCompletion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self finishAsync];
            });
        }];
        [self waitForAsync];
    }
    
    XCTAssertNil(weakEnsemble);
}

- (void)testInitialization
{
    XCTAssertNotNil(ensemble, @"Ensemble should not be nil");
}

- (void)testLeech
{
    XCTAssertFalse(ensemble.isLeeched, @"Should not be leeched");
    [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
        XCTAssertNil(error, @"Error occurred while leeching");
        XCTAssertTrue(ensemble.isLeeched, @"Should be leeched");
        [self finishAsync];
    }];
    [self waitForAsync];
}

- (void)testDeleech
{
    [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
        XCTAssertNil(error, @"Error occurred while leeching");
        [ensemble deleechPersistentStoreWithCompletion:^(NSError *error) {
            XCTAssertNil(error, @"Error occurred while deleeching");
            [self finishAsync];
        }];
    }];
    [self waitForAsync];
}

- (void)testDeleechWithoutLeech
{
    [ensemble deleechPersistentStoreWithCompletion:^(NSError *error) {
        XCTAssertNotNil(error, @"Error should occur while deleeching");
        [self finishAsync];
    }];
    [self waitForAsync];
}

- (void)testChangingIdentityTokenCausesDeleech
{
    XCTAssertFalse(deleechOccurred, @"Should be NO");
    ensemble.delegate = self;
    [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
        XCTAssertNil(error, @"Error occurred while leeching");
        cloudFileSystem.identityToken = @"second";
        [ensemble mergeWithCompletion:NULL];
        [self performSelector:@selector(checkForDeleech) withObject:nil afterDelay:0.5];
    }];
    [self waitForAsync];
}

- (void)testRemovingRegistrationInfoCausesDeleech
{
    XCTAssertFalse(deleechOccurred, @"Should be NO");
    ensemble.delegate = self;
    [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
        XCTAssertNil(error, @"Error occurred while leeching");
        
        NSString *path = [cloudDir stringByAppendingPathComponent:@"testensemble/stores"];
        path = [path stringByAppendingPathComponent:ensemble.eventStore.persistentStoreIdentifier];
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        
        [ensemble mergeWithCompletion:^(NSError *error) {
            XCTAssertNotNil(error, @"Merge should fail due to missing store info");
            [self performSelector:@selector(checkForDeleech) withObject:nil afterDelay:0.5];
        }];
    }];
    [self waitForAsync];
}

- (void)testInitWithIncompleteMandatoryEventsCausesDeleech
{
    [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
        XCTAssertNil(error, @"Error occurred while leeching");
        [[ensemble eventStore] registerIncompleteMandatoryEventIdentifier:@"123"];
        [self finishAsync];
    }];
    [self waitForAsync];
    
    [ensemble processPendingChangesWithCompletion:^(NSError *error) {
        [self finishAsync];
    }];
    [self waitForAsync];
    
    [ensemble dismantle];
    
    ensemble = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"testensemble" persistentStoreURL:ensemble.persistentStoreURL managedObjectModelURL:ensemble.managedObjectModelURL cloudFileSystem:(id)cloudFileSystem];
    ensemble.delegate = self;
    
    [self performSelector:@selector(checkForDeleech) withObject:nil afterDelay:0.5];
    [self waitForAsync];
}

- (void)testSavingDuringLeechingCausesError
{
    ensemble.delegate = self;
    testingSavingDuringLeeching = YES;
    [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
        XCTAssertNotNil(error, @"Error should have occurred while leeching");
        [self finishAsync];
    }];
    [self waitForAsync];
}

#pragma mark Flag Checks

- (void)checkForLeech
{
    XCTAssert(!deleechOccurred, @"A deleech occurred when it shouldn't have");
    [self finishAsync];
}

- (void)checkForDeleech
{
    XCTAssert(deleechOccurred, @"No deleech occurred");
    [self finishAsync];
}

#pragma mark Ensemble Delegate Methods

- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didDeleechWithError:(NSError *)error
{
    deleechOccurred = YES;
}

- (void)persistentStoreEnsembleWillImportStore:(CDEPersistentStoreEnsemble *)ensemble
{
    if (!testingSavingDuringLeeching) return;
    
    // Save here to cause leech to fail
    [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:managedObjectContext];
    [managedObjectContext save:NULL];
}

@end
