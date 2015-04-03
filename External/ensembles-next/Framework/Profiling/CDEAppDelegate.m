//
//  CDEAppDelegate.m
//  Profiling
//
//  Created by Drew McCormack on 10/04/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import "CDEAppDelegate.h"
#import "CDEPersistentStoreEnsemble.h"
#import "CDELocalCloudFileSystem.h"
#import "CDEEventStore.h"


@interface CDEPersistentStoreEnsemble (ProfileMethods)

@property (readonly) CDEEventStore *eventStore;

@end


@interface CDEAppDelegate () <CDEPersistentStoreEnsembleDelegate>

@end


@implementation CDEAppDelegate {
    NSManagedObjectContext *context1, *context2;
    NSManagedObjectModel *model;
    NSString *testStoreFile1, *testStoreFile2;
    NSString *testRootDirectory;
    CDEPersistentStoreEnsemble *ensemble1, *ensemble2;
    id <CDECloudFileSystem> cloudFileSystem1, cloudFileSystem2;
    NSString *cloudRootDir;
    NSURL *testStoreURL1, *testStoreURL2;
    NSString *eventDataRoot1, *eventDataRoot2;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    testRootDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"CDEProfiling"];
    [[NSFileManager defaultManager] removeItemAtPath:testRootDirectory error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:testRootDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    
    // First store
    testStoreFile1 = [testRootDirectory stringByAppendingPathComponent:@"store1.sql"];
    testStoreURL1 = [NSURL fileURLWithPath:testStoreFile1];
    
    NSURL *testModelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"CDEStoreModificationEventTestsModel" withExtension:@"momd"];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:testModelURL];
    NSPersistentStoreCoordinator *testPSC1 = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [testPSC1 addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:testStoreURL1 options:nil error:NULL];
    
    context1 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    context1.persistentStoreCoordinator = testPSC1;
    context1.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    
    cloudRootDir = [testRootDirectory stringByAppendingPathComponent:@"cloudfiles"];
    [[NSFileManager defaultManager] createDirectoryAtPath:cloudRootDir withIntermediateDirectories:YES attributes:nil error:NULL];
    
    cloudFileSystem1 = [[CDELocalCloudFileSystem alloc] initWithRootDirectory:cloudRootDir];
    eventDataRoot1 = [testRootDirectory stringByAppendingPathComponent:@"eventData1"];
    ensemble1 = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"com.ensembles.synctest" persistentStoreURL:testStoreURL1 persistentStoreOptions:nil managedObjectModelURL:testModelURL cloudFileSystem:cloudFileSystem1 localDataRootDirectoryURL:[NSURL URLWithString:eventDataRoot1]];
    ensemble1.delegate = self;
    
    // Second store
    testStoreFile2 = [testRootDirectory stringByAppendingPathComponent:@"store2.sql"];
    testStoreURL2 = [NSURL fileURLWithPath:testStoreFile2];
    
    NSPersistentStoreCoordinator *testPSC2 = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [testPSC2 addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:testStoreURL2 options:nil error:NULL];
    
    context2 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    context2.persistentStoreCoordinator = testPSC2;
    context2.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    
    cloudFileSystem2 = [[CDELocalCloudFileSystem alloc] initWithRootDirectory:cloudRootDir];
    eventDataRoot2 = [testRootDirectory stringByAppendingPathComponent:@"eventData2"];
    ensemble2 = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"com.ensembles.synctest" persistentStoreURL:testStoreURL2 persistentStoreOptions:nil managedObjectModelURL:testModelURL cloudFileSystem:cloudFileSystem2 localDataRootDirectoryURL:[NSURL URLWithString:eventDataRoot2]];
    ensemble2.delegate = self;
    
    // Call test method here
    [self runLargeBinariesTest:self];
}

- (IBAction)runBaselineConsolidationTest:(id)sender
{
    [self addNumberOfObjects:1000 toContext:context1];
    [self addNumberOfObjects:1000 toContext:context2];

    [ensemble1 leechPersistentStoreWithCompletion:^(NSError *error) {
        [ensemble2 leechPersistentStoreWithCompletion:^(NSError *error) {
            [ensemble1 mergeWithCompletion:^(NSError *error) {
            }];
        }];
    }];
}

- (IBAction)runRebaseTest:(id)sender
{
    [self addNumberOfObjects:1000 toContext:context1];

    [ensemble1 leechPersistentStoreWithCompletion:^(NSError *error) {
        [self deleteObjectsInContext:context1];
        [self addNumberOfObjects:500 toContext:context1];
        [ensemble1 mergeWithCompletion:^(NSError *error) {
            if (error) NSLog(@"Error: %@", error);
        }];
    }];
}

- (IBAction)runLargeBinariesTest:(id)sender
{
    [self addNumberOfObjects:100 toContext:context1 includeLargeBinaries:YES];
    [ensemble1 leechPersistentStoreWithCompletion:^(NSError *error) {
        [ensemble2 leechPersistentStoreWithCompletion:^(NSError *error) {
            [ensemble1 mergeWithCompletion:^(NSError *error) {
                [ensemble2 mergeWithCompletion:^(NSError *error) {
                }];
            }];
        }];
    }];
}

- (void)deleteObjectsInContext:(NSManagedObjectContext *)context
{
    @autoreleasepool {
        NSArray *parents = [context executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"BatchParent"] error:NULL];
        for (id parent in parents) [context deleteObject:parent];
        [context save:NULL];
        [context reset];
    }
}

- (void)addNumberOfObjects:(NSUInteger)count toContext:(NSManagedObjectContext *)context
{
    [self addNumberOfObjects:count toContext:context includeLargeBinaries:NO];
}

- (void)addNumberOfObjects:(NSUInteger)count toContext:(NSManagedObjectContext *)context includeLargeBinaries:(BOOL)includeLargeBinaries
{
    @autoreleasepool {
        for (NSUInteger i = 0; i < count; i++) {
            id parent = [NSEntityDescription insertNewObjectForEntityForName:@"BatchParent" inManagedObjectContext:context];
            for (NSUInteger c = 0; c < 5; c++) {
                id child = [NSEntityDescription insertNewObjectForEntityForName:@"BatchChild" inManagedObjectContext:context];
                [child setValue:parent forKey:@"batchParent"];
                if (includeLargeBinaries) {
                    id blob = [NSEntityDescription insertNewObjectForEntityForName:@"LargeDataBlob" inManagedObjectContext:context];
                    NSData *randomData = [self randomDataOfSize:1000000]; // About 1MB
                    [blob setValue:randomData forKey:@"data"];
                    [child setValue:blob forKey:@"largeDataBlob"];
                }
            }
        }
        [context save:NULL];
        [context reset];
    }
}

-(NSData *)randomDataOfSize:(NSUInteger)numberOfBytes
{
    NSMutableData *newData = [NSMutableData dataWithCapacity:numberOfBytes];
    for (NSUInteger i = 0 ; i < numberOfBytes/4 ; ++i ) {
        u_int32_t randomBits = arc4random();
        [newData appendBytes:&randomBits length:4];
    }
    return newData;
}

@end
