//
//  CDERevisionManagerTests.m
//  Ensembles
//
//  Created by Drew McCormack on 25/08/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDEEventStoreTestCase.h"
#import "CDERevisionManager.h"
#import "CDEStoreModificationEvent.h"
#import "CDERevisionSet.h"
#import "CDEEventRevision.h"
#import "CDERevision.h"

@interface CDERevisionManagerTests : CDEEventStoreTestCase

@end

@implementation CDERevisionManagerTests {
    CDERevisionManager *revisionManager;
    CDEStoreModificationEvent *modEvent;
}

- (void)setUp
{
    [super setUp];
    
    revisionManager = [[CDERevisionManager alloc] initWithEventStore:(id)self.eventStore];
    revisionManager.managedObjectModelURL = self.testModelURL;
    
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        modEvent = [self addModEventForStore:@"store1" revision:0 globalCount:99 timestamp:124];
        modEvent.type = CDEStoreModificationEventTypeBaseline;
    }];
}

- (void)testMaximumGlobalCount
{
    XCTAssertEqual(revisionManager.maximumGlobalCount, (CDEGlobalCount)99, @"Wrong count");
}

- (void)testMaximumGlobalCountForMultipleEvents
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        modEvent = [self addModEventForStore:@"store2" revision:0 globalCount:150 timestamp:124];
    }];
    XCTAssertEqual(revisionManager.maximumGlobalCount, (CDEGlobalCount)150, @"Wrong count");
}

- (void)testMaximumGlobalCountForEmptyStore
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        [moc deleteObject:modEvent];
    }];
    
    XCTAssertEqual(revisionManager.maximumGlobalCount, (CDEGlobalCount)-1, @"Wrong count");
}

- (void)testMaximumGlobalCountForStoreWithBaseline
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        [moc deleteObject:modEvent];
        modEvent = [self addModEventForStore:@"store1" revision:5 globalCount:78 timestamp:124];
        modEvent.type = CDEStoreModificationEventTypeBaseline;
    }];
    
    XCTAssertEqual(revisionManager.maximumGlobalCount, (CDEGlobalCount)78, @"Wrong count");
}

- (void)testRecentRevisions
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        CDEStoreModificationEvent *event = [self addModEventForStore:@"store1" revision:0 globalCount:99 timestamp:124];
        event.type = CDEStoreModificationEventTypeBaseline;
        
        CDEEventRevision *eventRevision = [CDEEventRevision makeEventRevisionForPersistentStoreIdentifier:@"store1" revisionNumber:0 inManagedObjectContext:moc];
        event.eventRevision = eventRevision;
        
        modEvent.type = CDEStoreModificationEventTypeSave;
        
        [moc processPendingChanges];
    }];
        
    CDERevisionSet *set = [revisionManager revisionSetOfMostRecentIntegrableEvents];
    XCTAssertEqual(set.numberOfRevisions, (NSUInteger)1, @"Wrong number of revisions");
    
    CDERevision *revision = [set revisionForPersistentStoreIdentifier:@"1234"];
    XCTAssertEqual(revision.revisionNumber, (CDERevisionNumber)0, @"Wrong revision number");
}

- (void)testRecentRevisionsForDiscontinousRevision
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        CDEEventRevision *eventRevision = [CDEEventRevision makeEventRevisionForPersistentStoreIdentifier:@"1234" revisionNumber:0 inManagedObjectContext:moc];
        modEvent.eventRevision = eventRevision;
        [moc processPendingChanges];
    }];
    
    CDERevisionSet *set = [revisionManager revisionSetOfMostRecentIntegrableEvents];
    XCTAssertEqual(set.numberOfRevisions, (NSUInteger)1, @"Wrong number of revisions");
    
    CDERevision *revision = [set revisionForPersistentStoreIdentifier:@"1234"];
    XCTAssertEqual(revision.revisionNumber, (CDERevisionNumber)0, @"Wrong revision number");
}

- (void)testFetchingUncommittedEventsWithOnlyCurrentStoreEvent
{
    NSArray *events = [revisionManager fetchUncommittedStoreModificationEvents:NULL];
    XCTAssertNotNil(events, @"Failed to fetch uncommitted events");
    XCTAssertEqual(events.count, (NSUInteger)0, @"Wrong event count");
}

- (void)testFetchingUncommittedEventsWithOtherStoreBaseline
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        CDEStoreModificationEvent *event = [self addModEventForStore:@"otherstore" revision:0 timestamp:1234];
        event.type = CDEStoreModificationEventTypeBaseline;
        modEvent.type = CDEStoreModificationEventTypeSave;
    }];
    
    NSArray *events = [revisionManager fetchUncommittedStoreModificationEvents:NULL];
    XCTAssertEqual(events.count, (NSUInteger)1, @"Wrong event count");
}

- (void)testFetchingUncommittedEventsWithOtherStoreEvents
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        CDEStoreModificationEvent *event = [self addModEventForStore:@"otherstore" revision:0 timestamp:1234];
        event.type = CDEStoreModificationEventTypeBaseline;
        [self addModEventForStore:@"otherstore" revision:1 timestamp:1234];
        [self addModEventForStore:@"otherstore" revision:2 timestamp:1234];
        modEvent.type = CDEStoreModificationEventTypeSave;
    }];

    NSArray *events = [revisionManager fetchUncommittedStoreModificationEvents:NULL];
    XCTAssertEqual(events.count, (NSUInteger)3, @"Wrong event count");
}

- (void)testFetchingUncommittedEventsWithOtherStoreEventsAndDiscontinuity
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        CDEStoreModificationEvent *event = [self addModEventForStore:@"otherstore" revision:0 timestamp:1234];
        event.type = CDEStoreModificationEventTypeBaseline;
        [self addModEventForStore:@"otherstore" revision:1 timestamp:1234];
        [self addModEventForStore:@"otherstore" revision:2 timestamp:1234];
        [self addModEventForStore:@"otherstore" revision:4 timestamp:1234];
        modEvent.type = CDEStoreModificationEventTypeSave;
    }];
    
    NSArray *events = [revisionManager fetchUncommittedStoreModificationEvents:NULL];
    XCTAssertEqual(events.count, (NSUInteger)4, @"Wrong event count");
}

- (void)testFetchingUncommittedEventsWithPreviousMerge
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        [self addModEventForStore:@"otherstore" revision:0 timestamp:1234];
        [self addModEventForStore:@"otherstore" revision:1 timestamp:1234];
    }];
    
    self.eventStore.lastMergeRevisionSaved = 0;
    NSArray *events = [revisionManager fetchUncommittedStoreModificationEvents:NULL];
    XCTAssertEqual(events.count, (NSUInteger)2, @"Wrong event count for merge revision 0");
}

- (void)testFetchingNoUncommittedEventsWithBaseline
{
    self.eventStore.lastMergeRevisionSaved = -1;
    NSArray *events = [revisionManager fetchUncommittedStoreModificationEvents:NULL];
    XCTAssertEqual(events.count, (NSUInteger)0, @"Should be no events since baseline");
}

- (void)testFetchingUncommittedEventsWithExtraStore
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        modEvent.eventRevisionsOfOtherStores = [NSSet setWithObject:[self addEventRevisionForStore:@"abc" revision:4]];
        [self addModEventForStore:@"abc" revision:5 timestamp:1234];
        [self addModEventForStore:@"abc" revision:2 timestamp:1234]; // Preceeds baseline, so ignored
        [self addModEventForStore:@"abc" revision:4 timestamp:1234]; // Equal to baseline, so ignored
    }];
    
    self.eventStore.lastMergeRevisionSaved = -1;
    NSArray *events = [revisionManager fetchUncommittedStoreModificationEvents:NULL];
    XCTAssertEqual(events.count, (NSUInteger)1, @"Should be an event");
}

- (void)testFetchingUncommittedEventsWithBaselineAndLastMerge
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    
    __block CDEStoreModificationEvent *merge;
    [moc performBlockAndWait:^{
        modEvent.eventRevision.revisionNumber = 4;
        modEvent.eventRevisionsOfOtherStores = [NSSet setWithObject:[self addEventRevisionForStore:@"otherstore" revision:2]];

        merge = [self addModEventForStore:@"store1" revision:5 timestamp:1234];
        merge.type = CDEStoreModificationEventTypeMerge;
    }];
    
    self.eventStore.lastMergeRevisionSaved = 5;
    NSArray *events = [revisionManager fetchUncommittedStoreModificationEvents:NULL];
    XCTAssertEqual(events.count, (NSUInteger)0, @"Should be no event");
    
    [moc performBlockAndWait:^{
        [self addModEventForStore:@"store1" revision:6 timestamp:1234];
    }];
    events = [revisionManager fetchUncommittedStoreModificationEvents:NULL];
    XCTAssertEqual(events.count, (NSUInteger)1, @"Should be an event");
}

- (void)testFetchingConcurrentEventsForMultipleEvents
{
    __block CDEStoreModificationEvent *event;
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        modEvent.eventRevisionsOfOtherStores = [NSSet setWithObject:[self addEventRevisionForStore:@"abc" revision:4]];
        event = [self addModEventForStore:@"store1" revision:1 timestamp:1234];
        [self addModEventForStore:@"abc" revision:5 timestamp:1234];
        [self addModEventForStore:@"abc" revision:5 timestamp:1234];
    }];

    NSArray *events = [revisionManager fetchStoreModificationEventsConcurrentWithEvents:@[event] error:NULL];
    XCTAssertEqual(events.count, (NSUInteger)3, @"Should be concurrent with all other events");
}

- (void)testSortingOfEvents
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    [moc performBlockAndWait:^{
        [self addModEventForStore:@"otherstore" revision:1 globalCount:110 timestamp:1200.0];
        [self addModEventForStore:@"thirdstore" revision:0 globalCount:100 timestamp:1234.0];
    }];
    
    self.eventStore.lastMergeRevisionSaved = 0;
    NSArray *events = [revisionManager fetchUncommittedStoreModificationEvents:NULL];
    
    XCTAssertEqual([events[0] globalCount], (CDEGlobalCount)100, @"Global count of first wrong in uncommitted");
    XCTAssertEqual([events[1] globalCount], (CDEGlobalCount)110, @"Global count of second wrong in uncommitted");
    
    events = [CDERevisionManager sortStoreModificationEvents:events];
    
    XCTAssertEqual([events[0] globalCount], (CDEGlobalCount)100, @"Global count of first wrong");
    XCTAssertEqual([events[1] globalCount], (CDEGlobalCount)110, @"Global count of second wrong");
}

@end
