//
//  CDEBaseliningSyncTests.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 27/01/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import "CDESyncTest.h"
#import "CDEEventStore.h"
#import "CDEPersistentStoreEnsemble.h"

@interface CDEBaseliningSyncTests : CDESyncTest

@end

@implementation CDEBaseliningSyncTests {
    NSString *cloudBaselinesDir, *cloudEventsDir;
}

- (void)setUp
{
    [super setUp];
    cloudBaselinesDir = [cloudRootDir stringByAppendingPathComponent:@"com.ensembles.synctest/baselines"];
    cloudEventsDir = [cloudRootDir stringByAppendingPathComponent:@"com.ensembles.synctest/events"];
}

- (void)testCloudBaselineUniquenessWithNoInitialData
{
    [self leechStores];
    XCTAssertNil([self syncChanges], @"Sync failed");
    NSArray *baselineFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudBaselinesDir error:NULL];
    XCTAssertEqual(baselineFiles.count, (NSUInteger)1, @"Should only be one baseline");
    
    NSArray *eventFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudEventsDir error:NULL];
    XCTAssert(eventFiles.count <= 2 && eventFiles.count > 0, @"Should be one or two merges. Depends on store ids.");
}

- (void)testCloudBaselineFileContentDuringLeechAndSync
{
    NSManagedObject *parentOnDevice1 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [parentOnDevice1 setValue:@"bob" forKey:@"name"];
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    // Leech and merge first store
    [ensemble1 leechPersistentStoreWithCompletion:^(NSError *error) {
        XCTAssertNil(error, @"Error leeching first store");
        [self completeAsync];
    }];
    [self waitForAsync];
    [self mergeEnsemble:ensemble1];
    
    // Check cloud files and contents
    NSArray *baselineFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudBaselinesDir error:NULL];
    NSString *baseline1 = baselineFiles.lastObject;
    NSString *baseline1Path = [cloudBaselinesDir stringByAppendingPathComponent:baseline1];
    XCTAssertEqual(baselineFiles.count, (NSUInteger)1, @"Should be a baseline");
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:baseline1Path] options:0 error:NULL];
    XCTAssertTrue(json.count > 0, @"JSON dictionary empty");
    
    // Leech second store
    [ensemble2 leechPersistentStoreWithCompletion:^(NSError *error) {
        XCTAssertNil(error, @"Error leeching second store");
        [self completeAsync];
    }];
    [self waitForAsync];
    
    // Check cloud file is unchanged
    json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:baseline1Path] options:0 error:NULL];
    XCTAssertTrue(json.count > 0, @"JSON dictionary empty");
    
    // Merge second store. Should consolidate baselines.
    XCTAssertNil([self mergeEnsemble:ensemble2], @"Error during merge");
    
    // Check new baseline file
    baselineFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudBaselinesDir error:NULL];
    NSString *baseline2 = baselineFiles.lastObject;
    NSString *baseline2Path = [cloudBaselinesDir stringByAppendingPathComponent:baseline2];
    XCTAssertEqual(baselineFiles.count, (NSUInteger)1, @"Should be a baseline");
    
    // Check content
    json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:baseline2Path] options:0 error:NULL];
    XCTAssertTrue(json.count > 0, @"JSON dictionary empty");
    
    // Check things are still OK after several merges
    [self syncChanges];
    baselineFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudBaselinesDir error:NULL];
    XCTAssertEqual(baselineFiles.count, (NSUInteger)1, @"Should be a baseline");
}

- (void)testBaselineConsolidation
{    
    NSManagedObject *parentOnDevice1 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [parentOnDevice1 setValue:@"bob" forKey:@"name"];
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    NSManagedObject *parentOnDevice2 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context2];
    [parentOnDevice2 setValue:@"john" forKey:@"name"];
    XCTAssertTrue([context2 save:NULL], @"Could not save");
    
    [self leechStores];

    NSArray *baselineFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudBaselinesDir error:NULL];
    XCTAssertEqual(baselineFiles.count, (NSUInteger)0, @"Should be no baseline files after leeching, since it doesn't export the events.");

    [self mergeEnsemble:ensemble1];
    
    baselineFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudBaselinesDir error:NULL];
    XCTAssertEqual(baselineFiles.count, (NSUInteger)1, @"Should only be one baseline files after merge");
    
    [self mergeEnsemble:ensemble2];

    baselineFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudBaselinesDir error:NULL];
    XCTAssertEqual(baselineFiles.count, (NSUInteger)1, @"Should only be one baseline files after merge");
    
    [self mergeEnsemble:ensemble1];

    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parents = [context1 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents.count, (NSUInteger)2, @"Should be a parent object in context1");
    
    parents = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents.count, (NSUInteger)2, @"Should be a parent object in context2");
}

- (void)testRebasingIsTriggered
{
    [self leechStores];
    [self mergeEnsemble:ensemble1];

    for (NSUInteger i = 0; i < 100; i++) {
        NSManagedObject *parentOnDevice1 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
        [parentOnDevice1 setValue:@"bob" forKey:@"name"];
    }
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    // Each update is worth 0.1, so we need more than 10 for each object to trigger a rebase.
    NSArray *parents = [context1 executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Parent"] error:NULL];
    for (NSInteger i = 0; i < 11; i++) {
        for (id parent in parents) {
            [parent setValue:@"tom" forKey:@"name"];
        }
        XCTAssertTrue([context1 save:NULL], @"Could not save");
    }
    
    [self mergeEnsemble:ensemble1];
    
    NSArray *baselineFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudBaselinesDir error:NULL];
    NSArray *eventFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudEventsDir error:NULL];
    XCTAssertEqual(baselineFiles.count, (NSUInteger)1, @"Should be one baseline file");
    XCTAssertEqual(eventFiles.count, (NSUInteger)12, @"Should be 12 event files");
    
    [self mergeEnsemble:ensemble2];
    
    NSArray *parentsIn2 = [context2 executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Parent"] error:NULL];
    XCTAssertEqual(parentsIn2.count, (NSUInteger)100, @"Wrong parent count in second context");
}

- (void)testRebasingGoesToMinimumGlobalCountFromAnyDevice
{
    [self leechStores];
    [self mergeEnsemble:ensemble1];
    
    NSArray *baselineFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudBaselinesDir error:NULL];
    NSArray *eventFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudEventsDir error:NULL];
    XCTAssertEqual(baselineFiles.count, (NSUInteger)1, @"Should be one baseline file");
    XCTAssertEqual(eventFiles.count, (NSUInteger)0, @"Should be no event file");

    // Should generate event with global count 1
    for (NSUInteger i = 0; i < 500; i++) {
        NSManagedObject *parentOnDevice2 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context2];
        [parentOnDevice2 setValue:@"jane" forKey:@"name"];
    }
    XCTAssertTrue([context2 save:NULL], @"Could not save");
    
    // Should generate event with global count 2
    [self mergeEnsemble:ensemble2];

    baselineFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudBaselinesDir error:NULL];
    eventFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudEventsDir error:NULL];
    XCTAssertEqual(baselineFiles.count, (NSUInteger)1, @"Should be one baseline file");
    XCTAssertEqual(eventFiles.count, (NSUInteger)2, @"Should be 2 event files");
    
    // Should generate event with global count 1
    for (NSUInteger i = 0; i < 500; i++) {
        NSManagedObject *parentOnDevice1 = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
        [parentOnDevice1 setValue:@"bob" forKey:@"name"];
    }
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    // Should generate events with global counts 2-23
    NSArray *parents = [context1 executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Parent"] error:NULL];
    for (NSInteger i = 0; i < 21; i++) {
        for (id parent in parents) {
            [parent setValue:@"tom" forKey:@"name"];
        }
        XCTAssertTrue([context1 save:NULL], @"Could not save");
    }
    
    // Should generate a merge event with global count 13, and rebase up to global count 2 (lowest from any store)
    [ensemble1 setValue:@YES forKeyPath:@"rebaser.forceRebase"];
    [self mergeEnsemble:ensemble1];
    
    baselineFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudBaselinesDir error:NULL];
    eventFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cloudEventsDir error:NULL];
    XCTAssertEqual(baselineFiles.count, (NSUInteger)1, @"Should be one baseline file");
    XCTAssertEqual(eventFiles.count, (NSUInteger)21, @"Should be 21 events after rebase. Ie global counts 3-23");
    XCTAssertEqual([baselineFiles.lastObject integerValue], (NSInteger)2, @"Wrong global count for baseline");
}

- (void)testRebasingWithLocalStoreLeftBehind
{
    [self leechStores];
    [self syncChanges];
    
    [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context2];
    [context2 save:NULL]; // Save event
    [self mergeEnsemble:ensemble2];
    
    // This leaves behind the context1 store, ie, local store
    // Context1 will need a full integration to recover
    [ensemble1 setValue:@YES forKeyPath:@"rebaser.forceRebase"];
    [self mergeEnsemble:ensemble1];
    [ensemble1 setValue:@NO forKeyPath:@"rebaser.forceRebase"];
    
    // Should be fully synced here
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parents1 = [context1 executeFetchRequest:fetch error:NULL];
    NSArray *parents2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents1.count, parents2.count, @"Unequal number of parents");
}

- (void)testConsolidatingBaselinesAfterRebasingCausesFullIntegrationIfStoreLeftBehind
{
    [self leechStores];
    [self syncChanges];
    
    [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context2];
    [context2 save:NULL]; // Save event
    [self mergeEnsemble:ensemble2];
    
    [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [context1 save:NULL]; // Save event
    
    // This incorporates all events in the baseline.
    // Full integrations are needed for both stores.
    [ensemble1 setValue:@YES forKeyPath:@"rebaser.forceRebase"];
    [self mergeEnsemble:ensemble1];
    [ensemble1 setValue:@NO forKeyPath:@"rebaser.forceRebase"];
    
    [self mergeEnsemble:ensemble2];
    
    // Should be fully synced here
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parents1 = [context1 executeFetchRequest:fetch error:NULL];
    NSArray *parents2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents1.count, parents2.count, @"Unequal number of parents");
}

- (void)testConcurrentRebasing
{
    [self leechStores];
    [self syncChanges];
    
    for (NSUInteger i = 0; i < 50; i++) [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context2];
    [context2 save:NULL]; // Save event

    for (NSUInteger i = 0; i < 20; i++) [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [context1 save:NULL]; // Save event
    for (NSUInteger i = 0; i < 20; i++) [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [context1 save:NULL]; // Save event
    
    [ensemble2 setValue:@YES forKeyPath:@"rebaser.forceRebase"];
    [ensemble1 setValue:@YES forKeyPath:@"rebaser.forceRebase"];
    __block BOOL finished1 = NO, finished2 = NO;
    [ensemble1 mergeWithCompletion:^(NSError *error) {
        finished1 = YES;
        CFRunLoopStop(CFRunLoopGetCurrent());
    }];
    [ensemble2 mergeWithCompletion:^(NSError *error) {
        finished2 = YES;
        CFRunLoopStop(CFRunLoopGetCurrent());
    }];
    while ( !finished1 || !finished2 ) CFRunLoopRun();
    [ensemble2 setValue:@NO forKeyPath:@"rebaser.forceRebase"];
    [ensemble1 setValue:@NO forKeyPath:@"rebaser.forceRebase"];
    
    [self syncChanges];
    
    // Should be fully synced here
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parents1 = [context1 executeFetchRequest:fetch error:NULL];
    NSArray *parents2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents1.count, (NSUInteger)90, @"Wrong numbmer of parents");
    XCTAssertEqual(parents1.count, parents2.count, @"Unequal number of parents");
}

- (void)testRandomRebasing
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];

    [self leechStores];
    [self syncChanges];
    
    srand(55557);
    
    [ensemble2 setValue:@YES forKeyPath:@"rebaser.forceRebase"];
    [ensemble1 setValue:@YES forKeyPath:@"rebaser.forceRebase"];
    
    for (NSUInteger i = 0; i < 20; i++) {
        if (rand()%2 == 0) {
            [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context2];
            [context2 save:NULL];
        }
        if (rand()%2 == 0) {
            [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
            [context1 save:NULL];
        }
        if (rand()%2 == 0) [self mergeEnsemble:ensemble1];
        
        if (rand()%2 == 0) {
            [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context2];
            [context2 save:NULL];
        }
        if (rand()%2 == 0) {
            [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
            [context1 save:NULL];
        }
        
        if (rand()%2 == 0) [self mergeEnsemble:ensemble2];
        
        if (rand()%2 == 0) {
            id parent = [[context1 executeFetchRequest:fetch error:NULL] lastObject];
            if (parent) [context1 deleteObject:parent];
            [context1 save:NULL];
        }
        if (rand()%2 == 0) {
            id parent = [[context2 executeFetchRequest:fetch error:NULL] lastObject];
            if (parent) [context2 deleteObject:parent];
            [context2 save:NULL];
        }
    }

    [self syncChanges];
    
    NSArray *parents1 = [context1 executeFetchRequest:fetch error:NULL];
    NSArray *parents2 = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents1.count, parents2.count, @"Unequal number of parents");
}

- (NSManagedObjectContext *)eventFileContextForURL:(NSURL *)baselineURL
{
    NSManagedObjectContext *baselineContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    NSURL *modelURL = [[NSBundle bundleForClass:[CDEEventStore class]] URLForResource:@"CDEEventStoreModel" withExtension:@"momd"];
    NSManagedObjectModel *eventModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:eventModel];
    baselineContext.persistentStoreCoordinator = coordinator;
    NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSBinaryStoreType configuration:nil URL:baselineURL options:nil error:NULL];
    XCTAssertNotNil(store, @"Store was nil");
    return baselineContext;
}

- (NSArray *)fetchEventsInEventFile:(NSString *)path
{
    NSManagedObjectContext *context = [self eventFileContextForURL:[NSURL fileURLWithPath:path]];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
    NSArray *events = [context executeFetchRequest:fetch error:NULL];
    return events;
}

@end
