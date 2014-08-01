//
//  CDEEventMigrator.h
//  Test App iOS
//
//  Migrates events in and out of the event store.
//
//  Created by Drew McCormack on 5/10/13.
//  Copyright (c) 2013 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDEDefines.h"

@class CDEEventStore;
@class CDEPersistentStoreEnsemble;

@interface CDEEventMigrator : NSObject

@property (nonatomic, strong, readonly) CDEEventStore *eventStore;
@property (nonatomic, strong, readwrite) NSString *storeTypeForNewFiles;
@property (nonatomic, weak, readonly) NSManagedObjectModel *managedObjectModel;

- (instancetype)initWithEventStore:(CDEEventStore *)newStore managedObjectModel:(NSManagedObjectModel *)newModel;

- (void)migrateLocalEventToTemporaryFilesForRevision:(CDERevisionNumber)revision allowedTypes:(NSArray *)types completion:(void(^)(NSError *error, NSArray *fileURLs))completion;
- (void)migrateLocalBaselineToTemporaryFilesForUniqueIdentifier:(NSString *)uniqueId globalCount:(CDEGlobalCount)count persistentStorePrefix:(NSString *)storePrefix completion:(void(^)(NSError *error, NSArray *fileURLs))completion;
- (void)migrateStoreModificationEventWithObjectID:(NSManagedObjectID *)eventID toTemporaryFilesWithCompletion:(void(^)(NSError *error, NSArray *fileURLs))completion;

- (void)migrateEventInFromFileURLs:(NSArray *)urls completion:(void(^)(NSError *, NSManagedObjectID *eventID))completion;

@end
