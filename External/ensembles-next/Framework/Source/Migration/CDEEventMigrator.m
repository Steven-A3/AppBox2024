//
//  CDEEventMigrator.m
//  Test App iOS
//
//  Created by Drew McCormack on 5/10/13.
//  Copyright (c) 2013 The Mental Faculty B.V. All rights reserved.
//

#import "CDEEventMigrator.h"
#import "CDEDefines.h"
#import "NSMapTable+CDEAdditions.h"
#import "NSManagedObjectContext+CDEAdditions.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "CDEFoundationAdditions.h"
#import "CDEPersistentStoreEnsemble.h"
#import "CDEEventStore.h"
#import "CDEGlobalIdentifier.h"
#import "CDEEventRevision.h"
#import "CDERevision.h"
#import "CDEStoreModificationEvent.h"
#import "CDEObjectChange.h"
#import "CDEObjectGraphMigrator.h"
#import "CDEEventExport.h"
#import "CDEJSONEventExport.h"
#import "CDEEventImport.h"
#import "CDEPersistentStoreEventImport.h"
#import "CDEJSONEventImport.h"
#import "CDEAsynchronousTaskQueue.h"


static NSString *kCDEDefaultStoreType;


@implementation CDEEventMigrator {
    NSOperationQueue *queue;
}

@synthesize eventStore = eventStore;
@synthesize storeTypeForNewFiles = storeTypeForNewFiles;
@synthesize managedObjectModel = managedObjectModel;

+ (void)initialize
{
    if (self == [CDEEventMigrator class]) {
        kCDEDefaultStoreType = NSBinaryStoreType;
    }
}

- (instancetype)initWithEventStore:(CDEEventStore *)newStore managedObjectModel:(NSManagedObjectModel *)newModel
{
    self = [super init];
    if (self) {
        eventStore = newStore;
        managedObjectModel = newModel;
        storeTypeForNewFiles = kCDEDefaultStoreType;
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        if ([queue respondsToSelector:@selector(setQualityOfService:)]) {
            [queue setQualityOfService:NSQualityOfServiceUserInitiated];
        }
    }
    return self;
}

- (void)migrateLocalEventToTemporaryFilesForRevision:(CDERevisionNumber)revisionNumber allowedTypes:(NSArray *)types completion:(void (^)(NSError *error, NSArray *fileURLs))completion
{
    [eventStore.managedObjectContext performBlock:^{
        NSError *error = nil;
        CDEStoreModificationEvent *event = nil;
        event = [CDEStoreModificationEvent fetchStoreModificationEventWithAllowedTypes:types persistentStoreIdentifier:eventStore.persistentStoreIdentifier revisionNumber:revisionNumber inManagedObjectContext:eventStore.managedObjectContext];
        if (event) {
            [self migrateStoreModificationEventWithObjectID:event.objectID toTemporaryFilesWithCompletion:completion];
        }
        else {
            NSDictionary *info = @{NSLocalizedDescriptionKey : @"Failed to fetch local event in migrateLocalEventToTemporaryFilesForRevision..."};
            error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeCoreDataError userInfo:info];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(error, nil);
            });
        }
    }];
}

- (void)migrateLocalBaselineToTemporaryFilesForUniqueIdentifier:(NSString *)uniqueId globalCount:(CDEGlobalCount)count persistentStorePrefix:(NSString *)storePrefix completion:(void (^)(NSError *, NSArray *))completion
{
    [eventStore.managedObjectContext performBlock:^{
        NSError *error = nil;
        CDEStoreModificationEvent *baseline = nil;
        baseline = [CDEStoreModificationEvent fetchStoreModificationEventWithUniqueIdentifier:uniqueId globalCount:count persistentStorePrefix:storePrefix inManagedObjectContext:eventStore.managedObjectContext];
        if (baseline) {
            NSAssert(baseline.type == CDEStoreModificationEventTypeBaseline, @"Wrong event type for baseline");
            [self migrateStoreModificationEventWithObjectID:baseline.objectID toTemporaryFilesWithCompletion:completion];
        }
        else {
            NSDictionary *info = @{NSLocalizedDescriptionKey : @"Failed to fetch local event in migrateLocalBaselineToTemporaryFilesForUniqueIdentifier..."};
            error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeCoreDataError userInfo:info];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(error, nil);
            });
        }
    }];
}

#pragma mark Batched Migration

- (void)migrateEventInFromFileURLs:(NSArray *)urls completion:(void(^)(NSError *, NSManagedObjectID *eventID))completion
{
    CDELog(CDELoggingLevelTrace, @"Migrating events in from files");
    
    CDEJSONEventImport *jsonImport = [[CDEJSONEventImport alloc] initWithEventStore:self.eventStore importURLs:urls];
    __weak CDEJSONEventImport *weakJSONImport = jsonImport;
    __weak NSOperationQueue *weakQueue = queue;
    jsonImport.completionBlock = ^{
        CDEJSONEventImport *strongOp = weakJSONImport;
        
        if (strongOp.error) {
            CDELog(CDELoggingLevelVerbose, @"Failed to import JSON. Trying Binary store.");
            CDEPersistentStoreEventImport *storeImport = [[CDEPersistentStoreEventImport alloc] initWithEventStore:self.eventStore importURLs:urls];
            __weak CDEPersistentStoreEventImport *weakStoreImport = storeImport;
            storeImport.completionBlock = ^{
                CDEPersistentStoreEventImport *strongStoreImport = weakStoreImport;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(strongStoreImport.error, strongStoreImport.eventID);
                });
            };
            [weakQueue addOperation:storeImport];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil, strongOp.eventID);
            });
        }
    };
    
    [queue addOperation:jsonImport];
}

- (void)migrateStoreModificationEventWithObjectID:(NSManagedObjectID *)eventID toTemporaryFilesWithCompletion:(void(^)(NSError *error, NSArray *fileURLs))completion
{
    CDELog(CDELoggingLevelTrace, @"Migrating events out to files");
    
    CDEJSONEventExport *exportOperation = [[CDEJSONEventExport alloc] initWithEventStore:self.eventStore eventID:eventID managedObjectModel:self.managedObjectModel];
    __weak CDEEventExport *weakOp = exportOperation;
    exportOperation.completionBlock = ^{
        CDEEventExport *strongOp = weakOp;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(strongOp.error, strongOp.error ? nil : strongOp.fileURLs);
        });
    };
    
    [queue addOperation:exportOperation];
}

@end

