//
//  CDERepairSyncTests.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 22/01/15.
//  Copyright (c) 2015 Drew McCormack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDESyncTest.h"
#import "CDEPersistentStoreEnsemble.h"

@interface CDERepairSyncTests : CDESyncTest <CDEPersistentStoreEnsembleDelegate>

@end

@implementation CDERepairSyncTests {
    void (^shouldSaveBlock)(CDEPersistentStoreEnsemble *ensemble, NSManagedObjectContext *savingContext, NSManagedObjectContext *repairContext);
    CDERepairSyncTests * __weak weakSelf;
}

- (void)setUp
{
    [super setUp];
    shouldSaveBlock = NULL;
    weakSelf = self;
}

- (void)testDeletionRepair
{
    [self leechStores];
    
    id parent = [NSEntityDescription insertNewObjectForEntityForName:@"Parent" inManagedObjectContext:context1];
    [parent setValue:@"bob" forKey:@"name"];
    [parent setValue:@(10.0) forKey:@"doubleProperty"];
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    XCTAssertNil([self mergeEnsemble:ensemble1]);

    shouldSaveBlock = ^(CDEPersistentStoreEnsemble *ensemble, NSManagedObjectContext *savingContext, NSManagedObjectContext *repairContext) {
        __block NSManagedObjectID *parentID = nil;
        [savingContext performBlockAndWait:^{
            parentID = [savingContext.insertedObjects.anyObject valueForKey:@"objectID"];
        }];
        [repairContext performBlockAndWait:^{
            id parent = [repairContext existingObjectWithID:parentID error:NULL];
            [repairContext deleteObject:parent];
        }];
    };
    
    XCTAssertNil([self mergeEnsemble:ensemble2]);
    
    shouldSaveBlock = NULL;

    XCTAssertNil([self mergeEnsemble:ensemble1]);
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Parent"];
    NSArray *parents = [context1 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents.count, (NSUInteger)0, @"Should be no parent");
}

- (BOOL)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble shouldSaveMergedChangesInManagedObjectContext:(NSManagedObjectContext *)savingContext reparationManagedObjectContext:(NSManagedObjectContext *)reparationContext
{
    if (shouldSaveBlock) shouldSaveBlock(ensemble, savingContext, reparationContext);
    return YES;
}

@end
