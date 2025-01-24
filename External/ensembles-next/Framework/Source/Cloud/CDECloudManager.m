//
//  CDECloudManager.m
//  Test App iOS
//
//  Created by Drew McCormack on 5/29/13.
//  Copyright (c) 2013 The Mental Faculty B.V. All rights reserved.
//

#import "CDECloudManager.h"
#import "CDEEventFileSet.h"
#import "CDEFoundationAdditions.h"
#import "CDEEventStore.h"
#import "CDECloudFileSystem.h"
#import "CDEAsynchronousTaskQueue.h"
#import "CDEStoreModificationEvent.h"
#import "CDEEventRevision.h"
#import "CDERevision.h"
#import "CDEEventMigrator.h"

const NSUInteger CDEFileUploadBatchSize = 10;
const NSUInteger CDEFileDownloadBatchSize = 10;

@interface CDECloudManager ()

@property (nonatomic, strong, readwrite) NSSet *snapshotBaselineFilenames;
@property (nonatomic, strong, readwrite) NSSet *snapshotEventFilenames;
@property (nonatomic, strong, readwrite) NSSet *snapshotDataFilenames;

@property (nonatomic, strong, readonly) NSString *localEnsembleDirectory;

@property (nonatomic, strong, readonly) NSString *localDownloadDirectory;
@property (nonatomic, strong, readonly) NSString *localUploadDirectory;

@property (nonatomic, strong, readonly) NSString *remoteStoresDirectory;
@property (nonatomic, strong, readonly) NSString *remoteEventsDirectory;
@property (nonatomic, strong, readonly) NSString *remoteBaselinesDirectory;
@property (nonatomic, strong, readonly) NSString *remoteDataDirectory;

@end

@implementation CDECloudManager {
    NSString *localFileRoot;
    NSFileManager *fileManager;
    NSOperationQueue *operationQueue;
}

@synthesize eventStore = eventStore;
@synthesize cloudFileSystem = cloudFileSystem;
@synthesize snapshotBaselineFilenames = snapshotBaselineFilenames;
@synthesize snapshotEventFilenames = snapshotEventFilenames;
@synthesize snapshotDataFilenames = snapshotDataFilenames;
@synthesize managedObjectModel = managedObjectModel;

#pragma mark Initialization

- (instancetype)initWithEventStore:(CDEEventStore *)newStore cloudFileSystem:(id <CDECloudFileSystem>)newSystem managedObjectModel:(NSManagedObjectModel *)newModel
{
    self = [super init];
    if (self) {
        fileManager = [[NSFileManager alloc] init];
        eventStore = newStore;
        managedObjectModel = newModel;
        cloudFileSystem = newSystem;
        localFileRoot = [eventStore.pathToEventDataRootDirectory stringByAppendingPathComponent:@"transitcache"];
        
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
        if ([operationQueue respondsToSelector:@selector(setQualityOfService:)]) {
            [operationQueue setQualityOfService:NSQualityOfServiceUserInitiated];
        }
        
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self createTransitCacheDirectories];
}


#pragma mark Snapshotting Remote Files

- (void)snapshotRemoteFilesWithCompletion:(CDECompletionBlock)completion
{
    [self clearSnapshot];
    
    CDEAsynchronousTaskBlock baselinesTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudFileSystem contentsOfDirectoryAtPath:self.remoteBaselinesDirectory completion:^(NSArray *baselineContents, NSError *error) {
            if (!error) snapshotBaselineFilenames = [NSSet setWithArray:[baselineContents valueForKeyPath:@"name"]];
            next(error, NO);
        }];
    };
    
    CDEAsynchronousTaskBlock eventsTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudFileSystem contentsOfDirectoryAtPath:self.remoteEventsDirectory completion:^(NSArray *eventContents, NSError *error) {
            if (!error) snapshotEventFilenames = [NSSet setWithArray:[eventContents valueForKeyPath:@"name"]];
            next(error, NO);
        }];
    };
    
    CDEAsynchronousTaskBlock dataTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudFileSystem contentsOfDirectoryAtPath:self.remoteDataDirectory completion:^(NSArray *dataContents, NSError *error) {
            if (!error) snapshotDataFilenames = [NSSet setWithArray:[dataContents valueForKeyPath:@"name"]];
            next(error, NO);
        }];
    };
    
    NSArray *tasks = @[baselinesTask, eventsTask, dataTask];
    CDEAsynchronousTaskQueue *taskQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:tasks terminationPolicy:CDETaskQueueTerminationPolicyStopOnError completion:^(NSError *error) {
        if (error) [self clearSnapshot];
        if (completion) completion(error);
    }];
    [operationQueue addOperation:taskQueue];
}

- (void)clearSnapshot
{
    snapshotEventFilenames = nil;
    snapshotBaselineFilenames = nil;
    snapshotDataFilenames = nil;
}


#pragma mark Importing Remote Files

- (void)importNewRemoteNonBaselineEventsWithProgress:(CDEProgressBlock)progressBlock
{
    NSAssert([NSThread isMainThread], @"importNewRemote... called off the main thread");
    CDELog(CDELoggingLevelTrace, @"Transferring new events from cloud to event store");
    
    [self transferNewRemoteEventFilesToTransitCacheWithProgress:^(NSError *error, float progress, BOOL isFinished) {
        if (error) {
            if (progressBlock) progressBlock(error, progress, NO);
            return;
        }
        
        if (isFinished) {
            [self migrateNewEventsWhichAreBaselines:NO fromTransitCacheWithCompletion:^(NSError *error) {
                progressBlock(error, 1.0, YES);
            }];
        }
        else {
            if (progressBlock) progressBlock(nil, progress, NO);
        }
    }];
}

- (void)importNewBaselineEventsWithProgress:(CDEProgressBlock)progressBlock
{
    NSAssert([NSThread isMainThread], @"importNewBaselineEventsWithCompletion... called off the main thread");
    CDELog(CDELoggingLevelTrace, @"Transferring new baselines from cloud to event store");
    
    [self transferNewRemoteBaselineFilesToTransitCacheWithProgress:^(NSError *error, float progress, BOOL isFinished) {
        if (error) {
            if (progressBlock) progressBlock(error, progress, NO);
            return;
        }
        
        if (isFinished) {
            [self migrateNewEventsWhichAreBaselines:YES fromTransitCacheWithCompletion:^(NSError *error) {
                if (progressBlock) progressBlock(error, 1.0, YES);
            }];
        }
        else {
            if (progressBlock) progressBlock(nil, progress, NO);
        }
    }];
}

- (void)importNewDataFilesWithProgress:(CDEProgressBlock)progressBlock
{
    NSAssert([NSThread isMainThread], @"importNewDataFilesWithCompletion... called off the main thread");
    CDELog(CDELoggingLevelTrace, @"Transferring new data files from cloud to event store");
    
    NSMutableSet *toRetrieve = [self.snapshotDataFilenames mutableCopy];
    NSSet *storeFilenames = self.eventStore.allDataFilenames;
    [toRetrieve minusSet:storeFilenames];
    
    NSArray *filesToDownload = toRetrieve.allObjects;
    [self downloadFiles:filesToDownload fromRemoteDirectory:self.remoteDataDirectory batchCompletionBlock:^(NSArray *remotePaths, NSArray *localPaths) {
        NSError *error = nil;
        [self migrateNewDataFilesFromTransitCache:&error];
        return error;
    }
    progress:progressBlock];
}


#pragma mark Downloading Remote Files

- (void)transferNewRemoteEventFilesToTransitCacheWithProgress:(CDEProgressBlock)progress
{
    NSAssert(snapshotEventFilenames, @"No snapshot files");
    NSArray *types = @[@(CDEStoreModificationEventTypeSave), @(CDEStoreModificationEventTypeMerge)];
    [self transferNewFilesToTransitCacheFromRemoteDirectory:self.remoteEventsDirectory availableFilenames:snapshotEventFilenames.allObjects forEventTypes:types progress:progress];
}

- (void)transferNewRemoteBaselineFilesToTransitCacheWithProgress:(CDEProgressBlock)progressBlock
{
    NSAssert(snapshotBaselineFilenames, @"No snapshot files");
    NSArray *types = @[@(CDEStoreModificationEventTypeBaseline)];
    [self transferNewFilesToTransitCacheFromRemoteDirectory:self.remoteBaselinesDirectory availableFilenames:snapshotBaselineFilenames.allObjects forEventTypes:types progress:progressBlock];
}

- (void)transferNewFilesToTransitCacheFromRemoteDirectory:(NSString *)remoteDirectory availableFilenames:(NSArray *)filenames forEventTypes:(NSArray *)eventTypes progress:(CDEProgressBlock)progressBlock
{
    [self filesRequiringRetrievalFromAvailableRemoteFiles:filenames allowedEventTypes:eventTypes completion:^(NSArray *filenamesToRetrieve) {
        [self transferRemoteFiles:filenamesToRetrieve fromRemoteDirectory:remoteDirectory withProgress:progressBlock];
    }];
}

- (void)transferRemoteFiles:(NSArray *)filenames fromRemoteDirectory:(NSString *)remoteDirectory withProgress:(CDEProgressBlock)progressBlock
{
    // Remove any existing files in the cache first
    NSError *error = nil;
    BOOL success = [self removeFilesInDirectory:self.localDownloadDirectory error:&error];
    if (!success) {
        if (progressBlock) progressBlock(error, 0.0, NO);
        return;
    }
    
    [self downloadFiles:filenames fromRemoteDirectory:remoteDirectory batchCompletionBlock:NULL progress:progressBlock];
}

- (void)filesRequiringRetrievalFromAvailableRemoteFiles:(NSArray *)remoteFiles allowedEventTypes:(NSArray *)eventTypes completion:(void(^)(NSArray *filenames))completion
{
    [operationQueue addOperationWithBlock:^{
        BOOL isBaselines = [eventTypes containsObject:@(CDEStoreModificationEventTypeBaseline)];
        NSSet *localEventFileSets = [self eventFileSetsForEventsWithAllowedTypes:eventTypes createdInStore:nil];
        NSSet *remoteEventFileSets = [CDEEventFileSet eventFileSetsForFilenames:[NSSet setWithArray:remoteFiles] containingBaselines:isBaselines];
        NSMutableSet *toRetrieve = [NSMutableSet setWithArray:remoteFiles];
        
        // Remove any files that are in an incomplete file set, or are already present locally
        for (CDEEventFileSet *remoteFileSet in remoteEventFileSets) {
            BOOL remove = !remoteFileSet.hasAllParts;
            for (CDEEventFileSet *localFileSet in localEventFileSets) {
                if (remove) break;
                remove = [localFileSet representsSameEventAsEventFileSet:remoteFileSet];
            }
            if (remove) [toRetrieve minusSet:remoteFileSet.allAliases];
        }
        
        NSArray *result = [self sortFilenamesByGlobalCount:toRetrieve.allObjects];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completion(result);
        }];
    }];
}

- (void)transferNewRemoteDataFilesToTransitCacheWithProgress:(CDEProgressBlock)progressBlock
{
    NSAssert(snapshotDataFilenames, @"No snapshot files");
    NSMutableSet *toRetrieve = [self.snapshotDataFilenames mutableCopy];
    NSSet *storeFilenames = self.eventStore.allDataFilenames;
    [toRetrieve minusSet:storeFilenames];
    [self transferRemoteFiles:toRetrieve.allObjects fromRemoteDirectory:self.remoteDataDirectory withProgress:progressBlock];
}

- (void)downloadFiles:(NSArray *)filenames fromRemoteDirectory:(NSString *)remoteDirectory batchCompletionBlock:(NSError* (^)(NSArray *remotePaths, NSArray *localPaths))batchCompletion progress:(CDEProgressBlock)progressBlock
{
    NSMutableArray *taskBlocks = [NSMutableArray array];
    
    NSUInteger batchSize = [cloudFileSystem respondsToSelector:@selector(fileDownloadMaximumBatchSize)] ? cloudFileSystem.fileDownloadMaximumBatchSize : CDEFileDownloadBatchSize;
    NSUInteger totalFiles = filenames.count;
    __block NSUInteger numberOfFilesDownloaded = 0;
    [filenames cde_enumerateObjectsInBatchesWithBatchSize:batchSize usingBlock:^(NSArray *filesToDownload, NSUInteger batchesRemaining, BOOL *stop) {
        CDEAsynchronousTaskBlock block = ^(CDEAsynchronousTaskCallbackBlock next) {
            NSMutableArray *remotePaths = [[NSMutableArray alloc] init];
            NSMutableArray *localPaths = [[NSMutableArray alloc] init];
            for (NSString *filename in filesToDownload) {
                NSString *remotePath = [remoteDirectory stringByAppendingPathComponent:filename];
                NSString *localPath = [self.localDownloadDirectory stringByAppendingPathComponent:filename];
                [remotePaths addObject:remotePath];
                [localPaths addObject:localPath];
            }
            
            CDELog(CDELoggingLevelVerbose, @"Downloading files to transit cache: %@", remotePaths);
            
            if ([cloudFileSystem respondsToSelector:@selector(downloadFromPaths:toLocalFiles:completion:)]) {
                [self.cloudFileSystem downloadFromPaths:remotePaths toLocalFiles:localPaths completion:^(NSError *error) {
                    if (error) {
                        next(error, NO);
                        return;
                    }
                    
                    if (batchCompletion) error = batchCompletion(remotePaths, localPaths);
                    
                    if (progressBlock && !error) {
                        numberOfFilesDownloaded += filesToDownload.count;
                        float progress = (float)numberOfFilesDownloaded / totalFiles;
                        progressBlock(nil, progress, NO);
                    }
                    
                    next(error, NO);
                }];
            }
            else {
                NSMutableArray *downloadTasks = [NSMutableArray array];
                [localPaths enumerateObjectsUsingBlock:^(NSString *localPath, NSUInteger idx, BOOL *stop) {
                    NSString *remotePath = remotePaths[idx];
                    CDEAsynchronousTaskBlock task = ^(CDEAsynchronousTaskCallbackBlock nextFileDownload) {
                        [self.cloudFileSystem downloadFromPath:remotePath toLocalFile:localPath completion:^(NSError *error) {
                            if (error) {
                                CDELog(CDELoggingLevelError, @"Failed file download with error: %@", error);
                                nextFileDownload(error, NO);
                                return;
                            }
                            
                            if (batchCompletion) error = batchCompletion(@[remotePath], @[localPath]);
                            
                            if (progressBlock && !error) {
                                numberOfFilesDownloaded++;
                                float progress = (float)numberOfFilesDownloaded / totalFiles;
                                progressBlock(nil, progress, NO);
                            }
                            
                            nextFileDownload(error, NO);
                        }];
                    };
                    [downloadTasks addObject:task];
                }];
                CDEAsynchronousTaskQueue *batchQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:downloadTasks terminationPolicy:CDETaskQueueTerminationPolicyStopOnError completion:^(NSError *error) {
                    next(error, NO);
                }];
                [batchQueue start];
            }
            
        };
        [taskBlocks addObject:block];
    }];
    
    CDEAsynchronousTaskQueue *taskQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:taskBlocks terminationPolicy:CDETaskQueueTerminationPolicyStopOnError completion:^(NSError *error) {
        if (progressBlock) progressBlock(error, 1.0, YES);
    }];
    [operationQueue addOperation:taskQueue];
}


#pragma mark Migrating Data In

- (void)migrateNewEventsWhichAreBaselines:(BOOL)areBaselines fromTransitCacheWithCompletion:(CDECompletionBlock)completion
{
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:self.localDownloadDirectory error:&error];
    NSSet *eventFileSets = [CDEEventFileSet eventFileSetsForFilenames:[NSSet setWithArray:files] containingBaselines:areBaselines];
    
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    CDEEventMigrator *migrator = [[CDEEventMigrator alloc] initWithEventStore:self.eventStore managedObjectModel:managedObjectModel];
    
    NSMutableArray *tasks = [[NSMutableArray alloc] initWithCapacity:files.count];
    for (CDEEventFileSet *eventFileSet in eventFileSets) {
        // Create a task block to run asynchronously
        CDEAsynchronousTaskBlock block = ^(CDEAsynchronousTaskCallbackBlock next) {
            // Check for a pre-existing event first. Skip if we find one.
            __block BOOL eventsExist = NO;
            [moc performBlockAndWait:^{
                NSError *error;
                NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"CDEStoreModificationEvent"];
                fetch.predicate = eventFileSet.eventFetchPredicate;
                NSArray *events = [moc executeFetchRequest:fetch error:&error];
                if (!events) CDELog(CDELoggingLevelError, @"Could not fetch events: %@", error);
                eventsExist = events.count > 0;
            }];
            
            // Determine all filenames and file URLs
            NSMutableArray *filenames = [[NSMutableArray alloc] init];
            NSMutableArray *fileURLs = [[NSMutableArray alloc] init];
            for (NSString *filename in eventFileSet.preferredFilenamesForExistingParts) {
                NSString *path = [self.localDownloadDirectory stringByAppendingPathComponent:filename];
                [filenames addObject:filename];
                [fileURLs addObject:[NSURL fileURLWithPath:path]];
            }
            
            // Do some checks
            if (areBaselines && !eventFileSet.hasAllParts) {
                NSDictionary *info = @{NSLocalizedDescriptionKey : @"Some parts of a multipart baseline are missing. Probably still downloading."};
                NSError *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeIncompleteMultipartFile userInfo:info];
                [self removeFilesAtURLs:fileURLs];
                next(error, NO);
                return;
            }
            else if (!eventFileSet.hasAllParts || (eventsExist && eventFileSet.eventShouldBeUnique)) {
                // If event already exists or is incomplete, skip.
                CDELog(CDELoggingLevelVerbose, @"Skipping import of files due to incompleteness or event already existing: %@", filenames);
                [self removeFilesAtURLs:fileURLs];
                next(nil, NO);
                return;
            }
            
            // Migrate data into event store
            dispatch_async(dispatch_get_main_queue(), ^{
                CDELog(CDELoggingLevelVerbose, @"Migrating event in to event store from files: %@", filenames);
                [migrator migrateEventInFromFileURLs:fileURLs completion:^(NSError *error, NSManagedObjectID *eventID) {
                    [self removeFilesAtURLs:fileURLs];
                    next(error, NO);
                }];
            });
        };
        
        [tasks addObject:block];
    }
    
    CDEAsynchronousTaskQueue *taskQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:tasks terminationPolicy:CDETaskQueueTerminationPolicyCompleteAll completion:completion];
    [operationQueue addOperation:taskQueue];
}

- (void)removeFilesAtURLs:(id <NSFastEnumeration>)urls
{
    for (NSURL *url in urls) [fileManager removeItemAtURL:url error:NULL];
}

- (BOOL)migrateNewDataFilesFromTransitCache:(NSError * __autoreleasing *)error
{
    NSArray *files = [fileManager contentsOfDirectoryAtPath:self.localDownloadDirectory error:error];
    if (!files) return NO;
    
    for (NSString *file in files) {
        NSString *path = [self.localDownloadDirectory stringByAppendingPathComponent:file];
        CDELog(CDELoggingLevelVerbose, @"Importing data file into event store: %@", file);
        
        BOOL success = [self.eventStore importDataFile:path];
        if (!success) {
            if (error) *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeFileAccessFailed userInfo:nil];
            return NO;
        }
    }
    
    return YES;
}


#pragma mark Uploading Local Events

- (void)exportNewLocalNonBaselineEventsWithProgress:(CDEProgressBlock)progressBlock
{
    NSAssert(snapshotEventFilenames, @"No snapshot");
    CDELog(CDELoggingLevelTrace, @"Transferring events from event store to cloud");

    NSArray *types = @[@(CDEStoreModificationEventTypeMerge), @(CDEStoreModificationEventTypeSave)];
    [self migrateNewLocalEventsToTransitCacheWithRemoteDirectory:self.remoteEventsDirectory existingRemoteFilenames:snapshotEventFilenames.allObjects allowedTypes:types completion:^(NSError *error) {
        if (error) CDELog(CDELoggingLevelWarning, @"Error migrating out events: %@", error);
        [self transferFilesInTransitCacheToRemoteDirectory:self.remoteEventsDirectory progress:progressBlock];
    }];
}

- (void)exportNewLocalBaselineWithProgress:(CDEProgressBlock)progressBlock
{
    NSAssert(snapshotBaselineFilenames, @"No snapshot");
    CDELog(CDELoggingLevelTrace, @"Transferring baseline from event store to cloud");
    
    NSArray *types = @[@(CDEStoreModificationEventTypeBaseline)];
    [self migrateNewLocalEventsToTransitCacheWithRemoteDirectory:self.remoteBaselinesDirectory existingRemoteFilenames:snapshotBaselineFilenames.allObjects allowedTypes:types completion:^(NSError *error) {
        if (error) CDELog(CDELoggingLevelWarning, @"Error migrating out baseline: %@", error);
        [self transferFilesInTransitCacheToRemoteDirectory:self.remoteBaselinesDirectory progress:progressBlock];
    }];
}

- (void)exportDataFilesWithProgress:(CDEProgressBlock)progressBlock
{
    NSAssert(snapshotDataFilenames, @"No snapshot");
    CDELog(CDELoggingLevelTrace, @"Transferring data files from event store to cloud");

    NSError *error;
    BOOL success = [self migrateNewLocalDataFilesToTransitCache:&error];
    if (!success) {
        if (progressBlock) progressBlock(error, 0.0, NO);
        return;
    }
    
    [self transferFilesInTransitCacheToRemoteDirectory:self.remoteDataDirectory progress:progressBlock];
}

- (void)migrateNewLocalEventsToTransitCacheWithRemoteDirectory:(NSString *)remoteDirectory existingRemoteFilenames:(NSArray *)filenames allowedTypes:(NSArray *)types completion:(CDECompletionBlock)completion
{
    NSArray *fileSetsToUpload = [self localEventFileSetsMissingFromRemoteCloudFiles:filenames allowedTypes:types];
    [self migrateLocalEventsToTransitCacheForEventFileSets:fileSetsToUpload allowedTypes:types completion:completion];
}

- (void)migrateLocalEventsToTransitCacheForEventFileSets:(NSArray *)fileSetsToUpload allowedTypes:(NSArray *)types completion:(CDECompletionBlock)completion
{
    // Remove any existing files in the cache first
    NSError *error = nil;
    BOOL success = [self removeFilesInDirectory:self.localUploadDirectory error:&error];
    if (!success) {
        if (completion) completion(error);
        return;
    }
    
    // Migrate events to file
    CDEEventMigrator *migrator = [[CDEEventMigrator alloc] initWithEventStore:self.eventStore managedObjectModel:managedObjectModel];
    NSMutableArray *tasks = [[NSMutableArray alloc] initWithCapacity:fileSetsToUpload.count];
    for (CDEEventFileSet *fileSet in fileSetsToUpload) {
        CDEAsynchronousTaskBlock block = ^(CDEAsynchronousTaskCallbackBlock next) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (fileSet.isBaseline) {
                    [migrator migrateLocalBaselineToTemporaryFilesForUniqueIdentifier:fileSet.uniqueIdentifier globalCount:fileSet.globalCount persistentStorePrefix:fileSet.persistentStorePrefix completion:^(NSError *error, NSArray *fileURLs) {
                        BOOL success = [self moveFileURLs:fileURLs toUploadDirectoryForEventFileSet:fileSet error:&error];
                        next(success ? nil : error, NO);
                    }];
                }
                else {
                    [migrator migrateLocalEventToTemporaryFilesForRevision:fileSet.revisionNumber allowedTypes:types completion:^(NSError *error, NSArray *fileURLs) {
                        BOOL success = [self moveFileURLs:fileURLs toUploadDirectoryForEventFileSet:fileSet error:&error];
                        next(success ? nil : error, NO);
                    }];
                }
            });
        };
        
        [tasks addObject:block];
    }
    
    CDEAsynchronousTaskQueue *taskQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:tasks terminationPolicy:CDETaskQueueTerminationPolicyCompleteAll completion:completion];
    [operationQueue addOperation:taskQueue];
}

- (BOOL)moveFileURLs:(NSArray *)fileURLs toUploadDirectoryForEventFileSet:(CDEEventFileSet *)fileSet error:(NSError * __autoreleasing *)error
{
    if (error) *error = nil;
    fileSet.totalNumberOfParts = fileURLs.count;
    
    NSArray *filenames = fileSet.allPreferredFilenames;
    NSArray *toPaths = [filenames cde_arrayByTransformingObjectsWithBlock:^id(NSString *filename) {
        return [self.localUploadDirectory stringByAppendingPathComponent:filename];
    }];
    
    NSArray *tempFilePaths = [fileURLs valueForKeyPath:@"path"];
 
    NSEnumerator *fromEnum = [tempFilePaths objectEnumerator];
    NSEnumerator *toEnum = [toPaths objectEnumerator];
    NSString *toPath, *fromPath;
    while ((toPath = [toEnum nextObject]) && (fromPath = [fromEnum nextObject])) {
        if (![fileManager moveItemAtPath:fromPath toPath:toPath error:error]) return NO;
    }
    
    return YES;
}

- (BOOL)migrateNewLocalDataFilesToTransitCache:(NSError * __autoreleasing *)error
{
    // Remove any existing files in the cache first
    BOOL success = [self removeFilesInDirectory:self.localUploadDirectory error:error];
    if (!success) return NO;
    
    NSMutableSet *toTransfer = [self.eventStore.previouslyReferencedDataFilenames mutableCopy];
    [toTransfer minusSet:snapshotDataFilenames];
    
    for (NSString *file in toTransfer) {
        BOOL success = [self.eventStore exportDataFile:file toDirectory:self.localUploadDirectory];
        if (!success) {
            if (error) *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeFileAccessFailed userInfo:nil];
            return NO;
        }
    }
    
    return YES;
}

- (void)transferFilesInTransitCacheToRemoteDirectory:(NSString *)remoteDirectory progress:(CDEProgressBlock)progressBlock
{
    NSError *error = nil;
    NSArray *filesToUpload = [fileManager contentsOfDirectoryAtPath:self.localUploadDirectory error:&error];
    filesToUpload = [self sortFilenamesByGlobalCount:filesToUpload];
    
    NSMutableArray *taskBlocks = [NSMutableArray array];
    
    NSUInteger totalNumberOfFiles = filesToUpload.count;
    __block NSUInteger numberOfFilesUploaded = 0;
    NSUInteger batchSize = [cloudFileSystem respondsToSelector:@selector(fileUploadMaximumBatchSize)] ? cloudFileSystem.fileUploadMaximumBatchSize : CDEFileUploadBatchSize;
    [filesToUpload cde_enumerateObjectsInBatchesWithBatchSize:batchSize usingBlock:^(NSArray *filenames, NSUInteger batchesRemaining, BOOL *stop) {
        CDEAsynchronousTaskBlock block = ^(CDEAsynchronousTaskCallbackBlock next) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *remotePaths = [NSMutableArray array];
                NSMutableArray *localPaths = [NSMutableArray array];
                for (NSString *filename in filenames) {
                    NSString *remotePath = [remoteDirectory stringByAppendingPathComponent:filename];
                    [remotePaths addObject:remotePath];
                    NSString *localPath = [self.localUploadDirectory stringByAppendingPathComponent:filename];
                    [localPaths addObject:localPath];
                }

                CDELog(CDELoggingLevelVerbose, @"Uploading files to remote path: %@", remotePaths);
                
                if ([self.cloudFileSystem respondsToSelector:@selector(uploadLocalFiles:toPaths:completion:)]) {
                    [self.cloudFileSystem uploadLocalFiles:localPaths toPaths:remotePaths completion:^(NSError *error) {
                        for (NSString *localPath in localPaths) [fileManager removeItemAtPath:localPath error:NULL];
                        if (error) CDELog(CDELoggingLevelError, @"Failed file uploads with error: %@", error);
                        
                        if (progressBlock && !error) {
                            numberOfFilesUploaded += filenames.count;
                            float progress = (float)numberOfFilesUploaded / totalNumberOfFiles;
                            progressBlock(nil, progress, NO);
                        }
                    
                        next(error, NO);
                    }];
                }
                else {
                    NSMutableArray *uploadTasks = [NSMutableArray array];
                    [localPaths enumerateObjectsUsingBlock:^(NSString *localPath, NSUInteger idx, BOOL *stop) {
                        NSString *remotePath = remotePaths[idx];
                        CDEAsynchronousTaskBlock task = ^(CDEAsynchronousTaskCallbackBlock nextFileUpload) {
                            [self.cloudFileSystem uploadLocalFile:localPath toPath:remotePath completion:^(NSError *error) {
                                [fileManager removeItemAtPath:localPath error:NULL];
                                if (error) CDELog(CDELoggingLevelError, @"Failed file upload with error: %@", error);
                                
                                if (progressBlock && !error) {
                                    numberOfFilesUploaded++;
                                    float progress = (float)numberOfFilesUploaded / totalNumberOfFiles;
                                    progressBlock(nil, progress, NO);
                                }
                                
                                nextFileUpload(error, NO);
                            }];
                        };
                        [uploadTasks addObject:task];
                    }];
                    CDEAsynchronousTaskQueue *batchQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:uploadTasks terminationPolicy:CDETaskQueueTerminationPolicyStopOnError completion:^(NSError *error) {
                        next(error, NO);
                    }];
                    [batchQueue start];
                }
            });
        };
        [taskBlocks addObject:block];
    }];
    
    CDEAsynchronousTaskQueue *taskQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:taskBlocks terminationPolicy:CDETaskQueueTerminationPolicyStopOnError completion:^(NSError *error) {
        if (progressBlock) progressBlock(error, 1.0, YES);
    }];
    [operationQueue addOperation:taskQueue];
}


#pragma mark Event Files

- (NSArray *)localEventFileSetsMissingFromRemoteCloudFiles:(NSArray *)remoteFiles allowedTypes:(NSArray *)types
{
    BOOL areBaselines = [types containsObject:@(CDEStoreModificationEventTypeBaseline)];
    NSString *persistentStoreId = self.eventStore.persistentStoreIdentifier;
    NSSet *storeFileSets = [self eventFileSetsForEventsWithAllowedTypes:types createdInStore:persistentStoreId];
    NSSet *existingRemoteFileSets = [CDEEventFileSet eventFileSetsForFilenames:[NSSet setWithArray:remoteFiles] containingBaselines:areBaselines];
    NSMutableArray *missingSets = [NSMutableArray arrayWithArray:storeFileSets.allObjects];
    
    for (CDEEventFileSet *localSet in storeFileSets) {
        for (CDEEventFileSet *remoteSet in existingRemoteFileSets) {
            if (!remoteSet.hasAllParts) continue; // Upload any incomplete set
            if ([localSet representsSameEventAsEventFileSet:remoteSet]) {
                [missingSets removeObject:localSet];
                break;
            }
        }
    }
    
    NSArray *sortedSets = [missingSets sortedArrayUsingComparator:^NSComparisonResult(CDEEventFileSet *eventFileSet1, CDEEventFileSet *eventFileSet2) {
        return [@(eventFileSet1.globalCount) compare:@(eventFileSet2.globalCount)];
    }];
    
    return sortedSets;
}

- (NSSet *)completeRemoteEventFileSetsMissingInEventStoreFromCloudFiles:(NSSet *)remoteFiles allowedTypes:(NSArray *)types
{
    BOOL areBaselines = [types containsObject:@(CDEStoreModificationEventTypeBaseline)];
    NSSet *storeFileSets = [self eventFileSetsForEventsWithAllowedTypes:types createdInStore:nil];
    NSSet *existingRemoteFileSets = [CDEEventFileSet eventFileSetsForFilenames:remoteFiles containingBaselines:areBaselines];
    NSMutableSet *missingSets = [NSMutableSet set];
    
    for (CDEEventFileSet *remoteSet in existingRemoteFileSets) {
        BOOL remoteSetIsInEventStore = NO;
        for (CDEEventFileSet *localSet in storeFileSets) {
            if ([localSet representsSameEventAsEventFileSet:remoteSet]) {
                remoteSetIsInEventStore = YES;
                break;
            }
        }
        if (!remoteSetIsInEventStore && remoteSet.hasAllParts) [missingSets addObject:remoteSet];
    }
    
    return missingSets;
}

- (NSArray *)sortFilenamesByGlobalCount:(NSArray *)filenames
{
    NSArray *sortedResult = [filenames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CDEGlobalCount g1 = [obj1 longLongValue];
        CDEGlobalCount g2 = [obj2 longLongValue];
        return [@(g1) compare:@(g2)];
    }];
    return sortedResult;
}

- (NSSet *)eventFileSetsForEventsWithAllowedTypes:(NSArray *)types createdInStore:(NSString *)persistentStoreIdentifier
{
    NSManagedObjectContext *moc = self.eventStore.managedObjectContext;
    __block NSMutableSet *eventFiles = [NSMutableSet set];
    [moc performBlockAndWait:^{
        NSArray *events = [CDEStoreModificationEvent fetchStoreModificationEventsWithTypes:types persistentStoreIdentifier:persistentStoreIdentifier inManagedObjectContext:moc];
        if (!events) {
            CDELog(CDELoggingLevelError, @"Could not retrieve local events");
        }

        for (CDEStoreModificationEvent *event in events) {
            CDEEventFileSet *eventFile = [[CDEEventFileSet alloc] initWithStoreModificationEvent:event];
            [eventFiles addObject:eventFile];
        }
    }];
    return eventFiles;
}


#pragma mark Local Directories

- (NSString *)localEnsembleDirectory
{
    return [localFileRoot stringByAppendingPathComponent:self.eventStore.ensembleIdentifier];
}

- (NSString *)localUploadDirectory
{
    return [self.localEnsembleDirectory stringByAppendingPathComponent:@"upload"];
}

- (NSString *)localDownloadDirectory
{
    return [self.localEnsembleDirectory stringByAppendingPathComponent:@"download"];
}


#pragma mark Local Directory Structure

- (void)createTransitCacheDirectories
{
    NSArray *dirs = @[self.localDownloadDirectory, self.localUploadDirectory];
    for (NSString *dir in dirs) {
        NSError *error = nil;
        [fileManager removeItemAtPath:dir error:NULL];
        BOOL success = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success) {
            CDELog(CDELoggingLevelError, @"Could not create transit directory %@: %@", dir, error);
        }
    }
}

- (BOOL)removeFilesInDirectory:(NSString *)dir error:(NSError * __autoreleasing *)error
{
    NSArray *files = [fileManager contentsOfDirectoryAtPath:dir error:error];
    if (!files) return NO;
    
    for (NSString *file in files) {
        if ([file hasPrefix:@"."]) continue; // Ignore system files
        NSString *path = [dir stringByAppendingPathComponent:file];
        
        NSError *localError = nil;
        BOOL success = [fileManager removeItemAtPath:path error:&localError];
        if (!success) {
            BOOL noSuchFileError = [localError.domain isEqualToString:NSCocoaErrorDomain] && localError.code == NSFileReadNoSuchFileError;
            if (!noSuchFileError) {
                if (error) *error = localError;
                return NO;
            }
        }
    }
    
    return YES;
}


#pragma mark Removing Files

- (BOOL)removeOutOfDateNewlyImportedFiles:(NSError * __autoreleasing *)error
{
    // Remove files that are found locally but no longer found remotely.
    NSMutableSet *filesToRemove = [self.eventStore.newlyImportedDataFilenames mutableCopy];
    [filesToRemove minusSet:snapshotDataFilenames];
    for (NSString *file in filesToRemove) {
        BOOL success = [self.eventStore removeNewlyImportedDataFile:file];
        if (!success) {
            NSDictionary *info = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Could not remove data file: %@", file]};
            if (error) *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeFileAccessFailed userInfo:info];
            return NO;
        }
    }
    return YES;
}

// Requires a snapshot already exist
- (void)removeOutdatedRemoteFilesWithCompletion:(CDECompletionBlock)completion
{
    NSAssert([NSThread isMainThread], @"removeOutdatedRemoteFilesWithCompletion... called off the main thread");
    
    CDELog(CDELoggingLevelTrace, @"Removing outdated files");
    
    if (!snapshotBaselineFilenames || !snapshotEventFilenames) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeMissingCloudSnapshot userInfo:nil];
            if (completion) completion(error);
        });
        return;
    }
    
    // Determine corresponding files for data still in event store
    NSArray *nonBaselineTypes = @[@(CDEStoreModificationEventTypeSave), @(CDEStoreModificationEventTypeMerge)];
    NSArray *baselineTypes = @[@(CDEStoreModificationEventTypeBaseline)];
    
    // Determine baselines to remove
    NSSet *baselineFileSetsToRemove = [self completeRemoteEventFileSetsMissingInEventStoreFromCloudFiles:snapshotBaselineFilenames allowedTypes:baselineTypes];
    NSSet *aliases = [baselineFileSetsToRemove valueForKeyPath:@"@distinctUnionOfSets.allAliases"];
    NSMutableSet *baselinesToRemove = [snapshotBaselineFilenames mutableCopy];
    [baselinesToRemove intersectSet:aliases];
    
    // Determine non-baselines to remove
    NSSet *eventFileSetsToRemove = [self completeRemoteEventFileSetsMissingInEventStoreFromCloudFiles:snapshotEventFilenames allowedTypes:nonBaselineTypes];
    aliases = [eventFileSetsToRemove valueForKeyPath:@"@distinctUnionOfSets.allAliases"];
    NSMutableSet *nonBaselinesToRemove = [snapshotEventFilenames mutableCopy];
    [nonBaselinesToRemove intersectSet:aliases];
    
    // Determine data files to remove
    NSSet *dataFilesForEventStore = self.eventStore.allDataFilenames;
    NSMutableSet *dataFilesToRemove = [snapshotDataFilenames mutableCopy];
    [dataFilesToRemove minusSet:dataFilesForEventStore];
    
    // Queue up removals
    NSMutableArray *pathsToRemove = [NSMutableArray array];
    [baselinesToRemove enumerateObjectsUsingBlock:^(NSString *file, BOOL *stop) {
        [pathsToRemove addObject:[self.remoteBaselinesDirectory stringByAppendingPathComponent:file]];
    }];
    [nonBaselinesToRemove enumerateObjectsUsingBlock:^(NSString *file, BOOL *stop) {
        [pathsToRemove addObject:[self.remoteEventsDirectory stringByAppendingPathComponent:file]];
    }];
    [dataFilesToRemove enumerateObjectsUsingBlock:^(NSString *file, BOOL *stop) {
        [pathsToRemove addObject:[self.remoteDataDirectory stringByAppendingPathComponent:file]];
    }];
    CDELog(CDELoggingLevelVerbose, @"Removing cloud files: %@", [pathsToRemove componentsJoinedByString:@"\n"]);
    
    // Queue up tasks
    NSMutableArray *tasks = [[NSMutableArray alloc] initWithCapacity:pathsToRemove.count];
    if ([self.cloudFileSystem respondsToSelector:@selector(removeItemsAtPaths:completion:)]) {
        CDEAsynchronousTaskBlock block = ^(CDEAsynchronousTaskCallbackBlock next) {
            [self.cloudFileSystem removeItemsAtPaths:pathsToRemove completion:^(NSError *error) {
                next(error, NO);
            }];
        };
        [tasks addObject:block];
    }
    else {
        for (NSString *path in pathsToRemove) {
            CDEAsynchronousTaskBlock block = ^(CDEAsynchronousTaskCallbackBlock next) {
                [self.cloudFileSystem removeItemAtPath:path completion:^(NSError *error) {
                    next(error, NO);
                }];
            };
            [tasks addObject:block];
        }
    }

    CDEAsynchronousTaskQueue *taskQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:tasks terminationPolicy:CDETaskQueueTerminationPolicyCompleteAll completion:completion];
    [operationQueue addOperation:taskQueue];
}

- (void)removeLocallyProducedIncompleteRemoteFileSets:(CDECompletionBlock)completion
{
    NSAssert(snapshotEventFilenames, @"No event snapshot");
    NSAssert(snapshotBaselineFilenames, @"No baseline snapshot");
    CDELog(CDELoggingLevelTrace, @"Removing incomplete remote file sets");
    
    NSSet *baselineEventFileSets = [CDEEventFileSet eventFileSetsForFilenames:[NSSet setWithSet:snapshotBaselineFilenames] containingBaselines:YES];
    NSSet *standardEventFileSets = [CDEEventFileSet eventFileSetsForFilenames:[NSSet setWithSet:snapshotEventFilenames] containingBaselines:NO];
    NSSet *eventFileSets = [baselineEventFileSets setByAddingObjectsFromSet:standardEventFileSets];
    NSSet *filenames = [snapshotBaselineFilenames setByAddingObjectsFromSet:snapshotEventFilenames];
    
    // Determine which event file sets should be removed
    NSMutableSet *fileSetsToRemove = [NSMutableSet set];
    NSString *localStoreId = self.eventStore.persistentStoreIdentifier;
    for (CDEEventFileSet *fileSet in eventFileSets) {
        BOOL storeIdsMatch = [localStoreId isEqualToString:fileSet.persistentStoreIdentifier];
        BOOL storePrefixesMatch = [localStoreId hasPrefix:fileSet.persistentStorePrefix];
        if (!fileSet.hasAllParts && (storeIdsMatch || storePrefixesMatch)) {
            [fileSetsToRemove addObject:fileSet];
        }
    }
    
    // Determine file names that should be removed
    NSMutableSet *pathsToRemove = [NSMutableSet set];
    for (CDEEventFileSet *fileSet in fileSetsToRemove) {
        NSMutableSet *aliases = [fileSet.allAliases mutableCopy];
        [aliases intersectSet:filenames];
        
        NSArray *paths = [aliases.allObjects cde_arrayByTransformingObjectsWithBlock:^id(NSString *filename) {
            NSString *base = fileSet.isBaseline ? self.remoteBaselinesDirectory : self.remoteEventsDirectory;
            return [base stringByAppendingPathComponent:filename];
        }];
        
        [pathsToRemove addObjectsFromArray:paths];
    }
    
    // Queue up tasks
    NSMutableArray *tasks = [[NSMutableArray alloc] initWithCapacity:pathsToRemove.count];
    for (NSString *path in pathsToRemove) {
        CDEAsynchronousTaskBlock block = ^(CDEAsynchronousTaskCallbackBlock next) {
            [self.cloudFileSystem removeItemAtPath:path completion:^(NSError *error) {
                next(error, NO);
            }];
        };
        [tasks addObject:block];
    }
    
    CDEAsynchronousTaskQueue *taskQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:tasks terminationPolicy:CDETaskQueueTerminationPolicyCompleteAll completion:completion];
    [operationQueue addOperation:taskQueue];
}


#pragma mark Remote Directory Structure

- (NSString *)remoteEnsembleDirectory
{
    return [NSString stringWithFormat:@"/%@", self.eventStore.ensembleIdentifier];
}

- (NSString *)remoteStoresDirectory
{
    return [self.remoteEnsembleDirectory stringByAppendingPathComponent:@"stores"];
}

- (NSString *)remoteEventsDirectory
{
    return [self.remoteEnsembleDirectory stringByAppendingPathComponent:@"events"];
}

- (NSString *)remoteBaselinesDirectory
{
    return [self.remoteEnsembleDirectory stringByAppendingPathComponent:@"baselines"];
}

- (NSString *)remoteDataDirectory
{
    return [self.remoteEnsembleDirectory stringByAppendingPathComponent:@"data"];
}

- (void)createRemoteDirectoryStructureWithCompletion:(CDECompletionBlock)completion
{
    NSArray *dirs = @[self.remoteEnsembleDirectory, self.remoteStoresDirectory, self.remoteEventsDirectory, self.remoteBaselinesDirectory, self.remoteDataDirectory];
    [self createRemoteDirectories:dirs withCompletion:completion];
}

- (void)createRemoteDirectories:(NSArray *)paths withCompletion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Creating remote directories");

    NSMutableArray *taskBlocks = [NSMutableArray array];
    for (NSString *path in paths) {
        CDEAsynchronousTaskBlock block = ^(CDEAsynchronousTaskCallbackBlock next) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                void (^postExistenceCheckBlock)(BOOL, NSError*) = ^(BOOL exists, NSError *error) {
                    if (error) {
                        next(error, NO);
                    }
                    else if (!exists) {
                        [self.cloudFileSystem createDirectoryAtPath:path completion:^(NSError *error) {
                            if (error)
                                next(error, NO);
                            else
                                next(nil, NO);
                        }];
                    }
                    else {
                        next(nil, NO);
                    }
                };
                
                if ([self.cloudFileSystem respondsToSelector:@selector(directoryExistsAtPath:completion:)]) {
                    [self.cloudFileSystem directoryExistsAtPath:path completion:^(BOOL exists, NSError *error) {
                        postExistenceCheckBlock(exists, error);
                    }];
                }
                else {
                    [self.cloudFileSystem fileExistsAtPath:path completion:^(BOOL exists, BOOL isDirectory, NSError *error) {
                        postExistenceCheckBlock(exists, error);
                    }];
                }
            });
        };
        [taskBlocks addObject:block];
    }
    
    CDEAsynchronousTaskQueue *taskQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:taskBlocks terminationPolicy:CDETaskQueueTerminationPolicyStopOnError completion:completion];
    [operationQueue addOperation:taskQueue];
}


#pragma mark Store Registration Info

- (void)checkExistenceOfRegistrationInfoForStoreWithIdentifier:(NSString *)identifier completion:(void(^)(BOOL exists, NSError *error))completion
{
    CDELog(CDELoggingLevelTrace, @"Checking existence of registration info");
    
    NSString *remotePath = [self.remoteStoresDirectory stringByAppendingPathComponent:identifier];
    [self.cloudFileSystem fileExistsAtPath:remotePath completion:^(BOOL exists, BOOL isDirectory, NSError *error) {
        if (completion) completion(exists, error);
    }];
}

- (void)setRegistrationInfo:(NSDictionary *)info forStoreWithIdentifier:(NSString *)identifier completion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Setting registration info for store in cloud");

    // Remove any existing files in the cache first
    NSError *error = nil;
    BOOL success = [self removeFilesInDirectory:self.localUploadDirectory error:&error];
    if (!success) {
        if (completion) completion(error);
        return;
    }
    
    NSString *localPath = [self.localUploadDirectory stringByAppendingPathComponent:identifier];
    success = [info writeToFile:localPath atomically:YES];
    if (!success) {
        error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeFailedToWriteFile userInfo:nil];
        if (completion) completion(error);
        return;
    }

    NSString *remotePath = [self.remoteStoresDirectory stringByAppendingPathComponent:identifier];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cloudFileSystem uploadLocalFile:localPath toPath:remotePath completion:^(NSError *error) {
            [fileManager removeItemAtPath:localPath error:NULL];
            if (completion) completion(error);
        }];
    });
}

@end
