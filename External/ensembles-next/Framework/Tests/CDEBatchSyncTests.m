//
//  CDEBatchSyncTests.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 09/05/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDESyncTest.h"
#import "CDEPersistentStoreEnsemble.h" 

@interface CDEBatchSyncTests : CDESyncTest <CDEPersistentStoreEnsembleDelegate>

@end

@implementation CDEBatchSyncTests

- (void)testSingleEntity
{
    [self leechStores];
    
    for (NSUInteger i = 0; i < 101; i++) {
        [NSEntityDescription insertNewObjectForEntityForName:@"BatchParent" inManagedObjectContext:context1];
    }
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    XCTAssertNil([self syncChanges], @"First sync failed");
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"BatchParent"];
    NSArray *parents = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents.count, (NSUInteger)101, @"Wrong number of parents on device 2");
}

- (void)testRelatedEntities
{
    [self leechStores];
    
    for (NSUInteger i = 0; i < 2; i++) {
        id parent = [NSEntityDescription insertNewObjectForEntityForName:@"BatchParent" inManagedObjectContext:context1];
        for (NSUInteger j = 0; j < 600; j++) {
            id child = [NSEntityDescription insertNewObjectForEntityForName:@"BatchChild" inManagedObjectContext:context1];
            [child setValue:parent forKeyPath:@"batchParent"];
        }
    }
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    XCTAssertNil([self syncChanges], @"First sync failed");
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"BatchParent"];
    NSArray *parents = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(parents.count, (NSUInteger)2, @"Wrong number of parents on device 2");
    XCTAssertEqual([[parents.lastObject valueForKeyPath:@"batchChildren"] count], (NSUInteger)600, @"Wrong number of children");
}

- (void)testSelfReferentialRelationship
{
    [self leechStores];
    
    for (NSUInteger i = 0; i < 30; i++) {
        id child1 = [NSEntityDescription insertNewObjectForEntityForName:@"BatchChild" inManagedObjectContext:context1];
        id child2 = [NSEntityDescription insertNewObjectForEntityForName:@"BatchChild" inManagedObjectContext:context1];
        [child1 setValue:child2 forKey:@"friend"];
        [child2 setValue:[NSSet setWithObjects:child1, child2, nil] forKeyPath:@"siblings"];
    }
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    XCTAssertNil([self syncChanges], @"First sync failed");
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"BatchChild"];
    NSArray *children = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(children.count, (NSUInteger)60, @"Wrong number of children on device 2");
    
    id child = children.lastObject;
    XCTAssertTrue([child valueForKey:@"friend"] || [[child valueForKey:@"siblings"] count], @"Should have friend or siblings set");
    
    NSMutableArray *friends = [[children valueForKeyPath:@"friend"] mutableCopy];
    [friends removeObject:[NSNull null]];
    XCTAssertEqual(friends.count, (NSUInteger)30, @"Wrong number of friends");
}

- (void)testThreeEntities
{
    [self leechStores];

    id parent = [NSEntityDescription insertNewObjectForEntityForName:@"BatchParent" inManagedObjectContext:context1];
    id child1 = [NSEntityDescription insertNewObjectForEntityForName:@"BatchChild" inManagedObjectContext:context1];
    id child2 = [NSEntityDescription insertNewObjectForEntityForName:@"BatchChild" inManagedObjectContext:context1];
    [child1 setValue:@"thing1" forKeyPath:@"name"];
    [child2 setValue:@"thing2" forKeyPath:@"name"];
    id grandparent = [NSEntityDescription insertNewObjectForEntityForName:@"BatchGrandParent" inManagedObjectContext:context1];

    [parent setValue:[NSSet setWithObjects:child1, child2, nil] forKeyPath:@"batchChildren"];
    [parent setValue:grandparent forKeyPath:@"batchGrandParent"];
    
    [grandparent setValue:[NSSet setWithObject:child1] forKeyPath:@"batchChildren"];
    
    XCTAssertTrue([context1 save:NULL], @"Could not save");
    
    XCTAssertNil([self syncChanges], @"First sync failed");

    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"BatchChild"];
    NSArray *children = [context2 executeFetchRequest:fetch error:NULL];
    XCTAssertEqual(children.count, (NSUInteger)2, @"Wrong number of children on device 2");

    id thing1 = [[children filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = 'thing1'"]] lastObject];
    XCTAssertNotNil([thing1 valueForKey:@"batchParent"], @"Should be a parent");
    XCTAssertEqual([[thing1 valueForKey:@"batchGrandParents"] count], (NSUInteger)1, @"Should be a grand parent");
    
    parent = [thing1 valueForKey:@"batchParent"];
    XCTAssertNotNil([parent valueForKey:@"batchGrandParent"], @"Should be a parent");
    XCTAssertEqual([[parent valueForKey:@"batchChildren"] count], (NSUInteger)2, @"Wrong number of children");
}

@end
