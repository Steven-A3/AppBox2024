//
//  CDECloudKitFileSystem.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 9/22/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import "CDECloudKitFileSystem.h"

NSString * const CDECloudKitRecordZoneName = @"com.mentalfaculty.ensembles.zone";

@interface CDECloudKitFileSystem ()

@property (nonatomic, readwrite) CKContainer *container;
@property (nonatomic, readwrite) CKDatabase *database;
@property (nonatomic, readwrite) CKSubscription *subscription;

@end

@implementation CDECloudKitFileSystem {
    NSOperation *setupOperation;
    NSOperationQueue *operationQueue;
    NSFileManager *fileManager;
}

@synthesize database;
@synthesize container;
@synthesize usePublicDatabase;
@synthesize ubiquityContainerIdentifier;
@synthesize rootDirectory;

- (instancetype)initWithUbiquityContainerIdentifier:(NSString *)ubiquity rootDirectory:(NSString *)rootPath usePublicDatabase:(BOOL)usePublic
{
    NSParameterAssert(ubiquity != nil);
    self = [super init];
    if (self) {
        fileManager = [[NSFileManager alloc] init];
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
        
        ubiquityContainerIdentifier = [ubiquity copy];
        rootDirectory = rootPath ? : @"/";
        usePublicDatabase = usePublic;
        
        [self setupDatabase];
        [self setupCloud:^(NSError *error) {
            if (error) CDELog(CDELoggingLevelError, @"Setting up cloud directories in CloudKit failed: %@", error);
        }];
    }
    return self;
}

#pragma mark - Database

- (void)setupDatabase
{
    self.container = [CKContainer containerWithIdentifier:ubiquityContainerIdentifier];
    self.database = usePublicDatabase ? self.container.publicCloudDatabase : self.container.privateCloudDatabase;
}

#pragma mark - Subscription

- (NSPredicate *)subscriptionPredicate
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileSize > 0"];
    return predicate;
}

- (void)subscribeForPushNotificationsWithCompletion:(CDECompletionBlock)completion
{
    NSPredicate *predicate = self.subscriptionPredicate;
    CKSubscription *subscription = [[CKSubscription alloc] initWithRecordType:@"CDEItem" predicate:predicate subscriptionID:@"CDEFileAddedSubscription" options:CKSubscriptionOptionsFiresOnRecordCreation];
    
    CKNotificationInfo *notificationInfo = [[CKNotificationInfo alloc] init];
    notificationInfo.shouldSendContentAvailable = YES;
    subscription.notificationInfo = notificationInfo;
    
    [self.database saveSubscription:subscription completionHandler:^(CKSubscription *subscription, NSError *error) {
        if (error) CDELog(CDELoggingLevelWarning, @"Error while saving CloudKit subscription: %@", error);
        [self dispatchCompletion:completion withError:error];
    }];
}

#pragma mark - Setup Cloud

- (void)setupCloud:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Setting up cloud directories in CloudKit");
    
    if (!self.database) {
        [self dispatchCompletion:completion withError:[self noConnectionError]];
        return;
    }
    
    CDEAsynchronousTaskBlock task = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self createRootDirectoryIfNecessaryWithCompletion:^(NSError *error) {
            next(error, NO);
        }];
    };
    
    setupOperation = [[CDEAsynchronousTaskQueue alloc] initWithTask:task completion:^(NSError *error) {
        if (error) CDELog(CDELoggingLevelError, @"Failed to create root directory: %@", error);
        if (completion) completion(error);
    }];
    [operationQueue addOperation:setupOperation];
}

- (NSError *)noConnectionError
{
    NSError *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeConnectionError userInfo:@{NSLocalizedDescriptionKey : @"No iCloud connection"}];
    return error;
}

#pragma mark - Connection Status

- (BOOL)isConnected
{
    return self.container != nil;
}

- (void)connect:(CDECompletionBlock)completion
{
    [self setupDatabase];
    [self setupCloud:^(NSError *error) {
        [self dispatchCompletion:completion withError:error];
    }];
}

- (void)fetchUserIdentityWithCompletion:(CDEFetchUserIdentityCallback)completion
{
    [self.container fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error.code == CKErrorNotAuthenticated) {
                if (completion) completion(nil, nil);
            }
            else {
                if (completion) completion(recordID, error);
            }
        });
    }];
}

#pragma mark - File Handling

- (NSString *)fullPathForPath:(NSString *)path
{
    if ([path hasPrefix:@"/"]) path = [path substringFromIndex:1];
    return [self.rootDirectory stringByAppendingString:path];
}

- (void)fileExistsAtPath:(NSString *)path completion:(CDEFileExistenceCallback)completion
{
    CDELog(CDELoggingLevelTrace, @"Checking existence of file: %@", path);

    if (!self.database) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(NO, NO, [self noConnectionError]);
        });
        return;
    }
    
    NSString *fullPath = [self fullPathForPath:path];
    CKRecordID *fileRecordID = [[CKRecordID alloc] initWithRecordName:fullPath];
    CKFetchRecordsOperation *operation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[fileRecordID]];
    operation.fetchRecordsCompletionBlock = ^(NSDictionary *recordsByRecordID, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CKRecord *record = recordsByRecordID[fileRecordID];
            if (error && error.code != CKErrorUnknownItem && error.code != CKErrorPartialFailure) {
                CDELog(CDELoggingLevelError, @"Failed fetch: %@", error);
                if (completion) completion(NO, NO, error);
            }
            else if (record) {
                CDELog(CDELoggingLevelVerbose, @"File exists. Is dir? %@", [record valueForKey:@"isDirectory"]);
                if (completion) completion(YES, [[record valueForKey:@"isDirectory"] boolValue], nil);
            }
            else {
                CDELog(CDELoggingLevelVerbose, @"File doesn't exist");
                if (completion) completion(NO, NO, nil);
            }
        });
    };
    [self.database addOperation:operation];
}

- (id)itemForRecord:(CKRecord *)record
{
    NSString *fullPath = record.recordID.recordName;
    NSUInteger rootLength = self.rootDirectory.length;
    id item;
    NSString *name = fullPath.lastPathComponent;
    NSString *path = [fullPath substringFromIndex:rootLength];
    if ([[record valueForKey:@"isDirectory"] boolValue]) {
        CDECloudDirectory *dir = [[CDECloudDirectory alloc] init];
        dir.name = name;
        dir.path = path;
        item = dir;
    }
    else {
        CDECloudFile *file = [[CDECloudFile alloc] init];
        file.name = name;
        file.path = path;
        file.size = [[record valueForKey:@"fileSize"] unsignedLongLongValue];
        item = file;
    }
    return item;
}

- (CKQueryOperation *)queryOperationForQuery:(CKQuery *)query queryCursor:(CKQueryCursor *)cursor directoryContents:(NSMutableArray *)contents completion:(CDEDirectoryContentsCallback)completion
{
    __weak typeof (self) weakSelf = self;
    CKQueryOperation *queryOperation = nil;
    if (query) {
        queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    }
    else {
        queryOperation = [[CKQueryOperation alloc] initWithCursor:cursor];
    }
    
    queryOperation.recordFetchedBlock = ^(CKRecord *childRecord) {
        typeof (self) strongSelf = weakSelf;
        if (!strongSelf) return;
        id item = [strongSelf itemForRecord:childRecord];
        [contents addObject:item];
    };
    
    queryOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
        typeof (self) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (cursor) {
            CKQueryOperation *extraOperation = [strongSelf queryOperationForQuery:nil queryCursor:cursor directoryContents:contents completion:completion];
            [strongSelf.database addOperation:extraOperation];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) CDELog(CDELoggingLevelVerbose, @"Contents of directory: %@", [contents valueForKeyPath:@"name"]);
                if (completion) completion(error ? nil : contents, error);
            });
        }
    };
    
    return queryOperation;
}

- (void)contentsOfDirectoryAtPath:(NSString *)path completion:(CDEDirectoryContentsCallback)completion
{
    CDELog(CDELoggingLevelTrace, @"Getting contents of directory at path: %@", path);

    if (!self.database) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(nil, [self noConnectionError]);
        });
        return;
    }
    
    NSString *fullPath = [self fullPathForPath:path];
    CKRecordID *dirRecordID = [[CKRecordID alloc] initWithRecordName:fullPath];
    
    NSMutableArray *contents = [NSMutableArray array];
    CKQuery *childQuery = [[CKQuery alloc] initWithRecordType:@"CDEItem" predicate:[NSPredicate predicateWithFormat:@"directory = %@", dirRecordID]];
    childQuery.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"path" ascending:YES]];
    CKQueryOperation *queryOperation = [self queryOperationForQuery:childQuery queryCursor:nil directoryContents:contents completion:completion];
    [self.database addOperation:queryOperation];
}

- (void)createRootDirectoryIfNecessaryWithCompletion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Creating root directory if necessary");

    if (!self.database) {
        [self dispatchCompletion:completion withError:[self noConnectionError]];
        return;
    }
    
    CKRecordID *dirRecordID = [[CKRecordID alloc] initWithRecordName:self.rootDirectory];
    CKFetchRecordsOperation *operation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[dirRecordID]];
    operation.queuePriority = NSOperationQueuePriorityHigh;
    operation.fetchRecordsCompletionBlock = ^(NSDictionary *recordsByRecordID, NSError *error) {
        CKRecord *rootRecord = recordsByRecordID[dirRecordID];
        if ((error && error.code != CKErrorPartialFailure) || rootRecord) {
            [self dispatchCompletion:completion withError:(rootRecord ? nil : error)];
            return;
        }
        
        // Create new record
        CKRecord *record = [[CKRecord alloc] initWithRecordType:@"CDEItem" recordID:dirRecordID];
        [record setValue:@YES forKey:@"isDirectory"];
        [record setValue:self.rootDirectory forKey:@"path"];

        CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[record] recordIDsToDelete:nil];
        operation.queuePriority = NSOperationQueuePriorityHigh;
        operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecords, NSError *error) {
            [self dispatchCompletion:completion withError:error];
        };
        [self.database addOperation:operation];

    };
    [self.database addOperation:operation];
}

- (void)createDirectoryAtPath:(NSString *)path completion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Creating directory at path: %@", path);

    if (!self.database) {
        [self dispatchCompletion:completion withError:[self noConnectionError]];
        return;
    }
    
    NSString *fullPath = [self fullPathForPath:path];
    NSString *parentDirPath = [fullPath stringByDeletingLastPathComponent];
    CKRecordID *parentDirRecordID = [[CKRecordID alloc] initWithRecordName:parentDirPath];
    CKReference *parentRef = [[CKReference alloc] initWithRecordID:parentDirRecordID action:CKReferenceActionDeleteSelf];
    
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:fullPath];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"CDEItem" recordID:recordID];
    [record setValue:@YES forKey:@"isDirectory"];
    [record setValue:parentRef forKey:@"directory"];
    [record setValue:fullPath forKey:@"path"];
    
    CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[record] recordIDsToDelete:nil];
    [operation addDependency:setupOperation];
    operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecords, NSError *error) {
        [self dispatchCompletion:completion withError:error];
    };
    [self.database addOperation:operation];
}

- (NSUInteger)fileUploadMaximumBatchSize
{
    return 30;
}

- (void)uploadLocalFile:(NSString *)fromPath toPath:(NSString *)toPath completion:(CDECompletionBlock)completion
{
    [self uploadLocalFiles:@[fromPath] toPaths:@[toPath] completion:completion];
}

- (void)uploadLocalFiles:(NSArray *)fromPaths toPaths:(NSArray *)toPaths completion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Uploading from paths %@ to paths %@", fromPaths, toPaths);
    
    if (!self.database) {
        [self dispatchCompletion:completion withError:[self noConnectionError]];
        return;
    }
    
    NSMutableArray *records = [[NSMutableArray alloc] init];
    [fromPaths enumerateObjectsUsingBlock:^(NSString *fromPath, NSUInteger idx, BOOL *stop) {
        NSString *toPath = toPaths[idx];
        
        NSString *filePath = [self fullPathForPath:toPath];
        NSString *dirPath = [filePath stringByDeletingLastPathComponent];
        CKRecordID *dirRecordID = [[CKRecordID alloc] initWithRecordName:dirPath];
        CKReference *dirReference = [[CKReference alloc] initWithRecordID:dirRecordID action:CKReferenceActionDeleteSelf];
        
        NSError *error = nil;
        NSURL *fromURL = [NSURL fileURLWithPath:fromPath];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fromPath error:&error];
        if (!fileAttributes) {
            [self dispatchCompletion:completion withError:error];
            *stop = YES;
            return;
        }
        
        CKRecordID *fileRecordID = [[CKRecordID alloc] initWithRecordName:filePath];
        CKRecord *fileRecord = [[CKRecord alloc] initWithRecordType:@"CDEItem" recordID:fileRecordID];
        [fileRecord setValue:@NO forKey:@"isDirectory"];
        [fileRecord setValue:dirReference forKey:@"directory"];
        [fileRecord setValue:filePath forKey:@"path"];
        [fileRecord setValue:@(fileAttributes.fileSize) forKey:@"fileSize"];
        
        NSString *dataFileIDString = [NSString stringWithFormat:@"DataFile_%@", filePath];
        CKRecordID *datafileID = [[CKRecordID alloc] initWithRecordName:dataFileIDString];
        CKRecord *mediaRecord = [[CKRecord alloc] initWithRecordType:@"CDEDataFile" recordID:datafileID];
        CKReference *fileRef = [[CKReference alloc] initWithRecord:fileRecord action:CKReferenceActionDeleteSelf];
        CKAsset *asset = [[CKAsset alloc] initWithFileURL:fromURL];
        [mediaRecord setValue:fileRef forKey:@"file"];
        [mediaRecord setValue:asset forKey:@"data"];
        
        [records addObject:fileRecord];
        [records addObject:mediaRecord];
    }];
    
    CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:records recordIDsToDelete:nil];
    operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecords, NSError *error) {
        // Ignore errors for already existing data. This can arise if the CloudKit queries are not
        // fully up-to-date due to caching and other server-side details
        if (error.code == CKErrorPartialFailure) {
            BOOL allErrorsAreDueToExistingObjects = [self.class partialErrorOnlyIncludesServerRecordChangedErrors:error];
            if (allErrorsAreDueToExistingObjects) {
                CDELog(CDELoggingLevelWarning, @"Some records failed to upload due to existing items. Usually due to out-of-date query caching on CloudKit. Will self correct. Ignoring: %@", error);
                error = nil;
            }
        }
        
        [self dispatchCompletion:completion withError:error];
    };
    [self.database addOperation:operation];
}

- (NSUInteger)fileDownloadMaximumBatchSize
{
    return 30;
}

- (void)downloadFromPath:(NSString *)fromPath toLocalFile:(NSString *)toPath completion:(CDECompletionBlock)completion
{
    [self downloadFromPaths:@[fromPath] toLocalFiles:@[toPath] completion:completion];
}

- (void)downloadFromPaths:(NSArray *)fromPaths toLocalFiles:(NSArray *)toPaths completion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Downloading from paths %@ to path %@", fromPaths, toPaths);

    if (!self.database) {
        [self dispatchCompletion:completion withError:[self noConnectionError]];
        return;
    }
    
    NSMutableArray *recordIDs = [[NSMutableArray alloc] init];
    NSMutableDictionary *toPathsByRecordID = [[NSMutableDictionary alloc] init];
    [fromPaths enumerateObjectsUsingBlock:^(NSString *fromPath, NSUInteger idx, BOOL *stop) {
        NSString *filePath = [self fullPathForPath:fromPath];
        NSString *toPath = toPaths[idx];
        NSString *dataFileIDString = [NSString stringWithFormat:@"DataFile_%@", filePath];
        CKRecordID *dataFileID = [[CKRecordID alloc] initWithRecordName:dataFileIDString];
        [recordIDs addObject:dataFileID];
        toPathsByRecordID[dataFileID] = toPath;
    }];
    
    CKFetchRecordsOperation *operation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:recordIDs];
    operation.fetchRecordsCompletionBlock = ^(NSDictionary *recordsByRecordID, NSError *error) {
        if (error) {
            [self performRepairsIfNecessaryForError:error];
            [self dispatchCompletion:completion withError:error];
            return;
        }
        
        BOOL success = YES;
        NSError *copyError = nil;
        NSFileManager *fm = [[NSFileManager alloc] init];
        for (CKRecordID *dataFileID in recordsByRecordID) {
            CKRecord *dataFileRecord = recordsByRecordID[dataFileID];
            CKAsset *asset = [dataFileRecord valueForKey:@"data"];
            
            success = [fm copyItemAtURL:asset.fileURL toURL:[NSURL fileURLWithPath:toPathsByRecordID[dataFileID]] error:&copyError];
            if (!success) break;
        }
        
        [self dispatchCompletion:completion withError:(success ? nil : copyError)];
    };
    [self.database addOperation:operation];
}

- (void)removeItemAtPath:(NSString *)path completion:(CDECompletionBlock)completion
{
    [self removeItemsAtPaths:@[path] completion:completion];
}

- (void)removeItemsAtPaths:(NSArray *)paths completion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Removing items at paths: %@", paths);
    
    if (!self.database) {
        [self dispatchCompletion:completion withError:[self noConnectionError]];
        return;
    }
    
    NSMutableArray *recordIDs = [[NSMutableArray alloc] init];
    for (NSString *path in paths) {
        NSString *fullPath = [self fullPathForPath:path];
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:fullPath];
        [recordIDs addObject:recordID];
    }

    CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:recordIDs];
    operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecords, NSError *error) {
        // Ignore errors for already removed data. This can arise if the CloudKit queries are not
        // fully up-to-date due to caching and other server-side details
        if (error.code == CKErrorPartialFailure) {
            BOOL errorsAreDueToAlreadyRemovedItems = [self.class partialErrorOnlyIncludesServerRecordChangedErrors:error];
            if (errorsAreDueToAlreadyRemovedItems) {
                CDELog(CDELoggingLevelWarning, @"Some records failed to be removed. Usually due to out-of-date query caching or other devices removing items. Will self correct. Ignoring: %@", error);
            }
        }
        
        [self dispatchCompletion:completion withError:error];
    };
    [self.database addOperation:operation];
}

#pragma mark - Error Handling

- (void)performRepairsIfNecessaryForError:(NSError *)error
{
    if (error.code != CKErrorPartialFailure) return;
    
    NSDictionary *errorsByRecordID = error.userInfo[CKPartialErrorsByItemIDKey];
    NSMutableArray *recordIDsForRemoval = [[NSMutableArray alloc] init];
    [errorsByRecordID enumerateKeysAndObjectsUsingBlock:^(CKRecordID *recordID, NSError *recordError, BOOL *stop) {
        static NSString * const dataFilePrefix = @"DataFile_";
        if ([recordID.recordName hasPrefix:dataFilePrefix] && (recordError.code == CKErrorUnknownItem)) {
            NSString *itemIDString = [recordID.recordName substringFromIndex:dataFilePrefix.length];
            CKRecordID *itemRecordID = [[CKRecordID alloc] initWithRecordName:itemIDString];
            [recordIDsForRemoval addObject:itemRecordID];
        }
    }];
    
    if (recordIDsForRemoval.count == 0) return;
    
    CDELog(CDELoggingLevelWarning, @"Located some items in CloudKit without data. Removing: %@", recordIDsForRemoval);
    
    CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:recordIDsForRemoval];
    operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecords, NSError *error) {
        if (error) {
            CDELog(CDELoggingLevelWarning, @"Error occurred while removing items without data in CloudKit: %@", error);
        }
        else {
            CDELog(CDELoggingLevelWarning, @"Deleted records with no data attached: %@", deletedRecords);
        }
    };
    [self.database addOperation:operation];
}

+ (BOOL)partialErrorOnlyIncludesServerRecordChangedErrors:(NSError *)error
{
    BOOL allErrorsAreDueToExistingObjects = YES;
    NSDictionary *errorsByItemID = error.userInfo[CKPartialErrorsByItemIDKey];
    for (NSError *error in errorsByItemID.objectEnumerator) {
        if (error.code != CKErrorServerRecordChanged) allErrorsAreDueToExistingObjects = NO;
    }
    return allErrorsAreDueToExistingObjects;
}

#pragma mark - Completion

- (void)dispatchCompletion:(CDECompletionBlock)completion withError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) completion(error);
    });
}

@end
