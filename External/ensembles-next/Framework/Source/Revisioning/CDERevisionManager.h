//
//  CDERevisionManager.h
//  Ensembles
//
//  Created by Drew McCormack on 25/08/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CDEDefines.h"  

@class CDEEventStore;
@class CDERevisionSet;
@class CDEStoreModificationEvent;

extern BOOL CDEPerformIntegrabilityChecks; // Used for tests to disable checks

@interface CDERevisionManager : NSObject

@property (nonatomic, strong, readonly) CDEEventStore *eventStore;
@property (nonatomic, strong, readonly) NSManagedObjectContext *eventManagedObjectContext;
@property (nonatomic, strong, readwrite) NSURL *managedObjectModelURL; 

- (instancetype)initWithEventStore:(CDEEventStore *)eventStore eventManagedObjectContext:(NSManagedObjectContext *)context;
- (instancetype)initWithEventStore:(CDEEventStore *)eventStore;

- (NSArray *)fetchUncommittedStoreModificationEvents:(NSError * __autoreleasing *)error;
- (NSArray *)fetchStoreModificationEventsConcurrentWithEvents:(NSArray *)events error:(NSError * __autoreleasing *)error;
- (NSArray *)recursivelyFetchStoreModificationEventsConcurrentWithEvents:(NSArray *)events error:(NSError *__autoreleasing *)error;

- (NSArray *)integrableEventsFromEvents:(NSArray *)events;

- (BOOL)checkModelVersionsOfStoreModificationEvents:(NSArray *)events;
- (BOOL)checkAllDataFilesExistForStoreModificationEvents:(NSArray *)events;

- (BOOL)checkDependenciesOfBaseline:(CDEStoreModificationEvent *)baseline;
- (BOOL)checkThatLocalPersistentStoreHasNotBeenAbandoned:(NSError * __autoreleasing *)error;

- (CDEGlobalCount)maximumGlobalCount;
- (CDERevisionSet *)revisionSetOfMostRecentIntegrableEvents;
- (NSSet *)persistentStoreIdentifiersIncludedInIntegrableEvents;

- (CDERevisionSet *)revisionSetForLastMergeOrBaseline;

+ (NSArray *)sortStoreModificationEvents:(NSArray *)events;


@end
