//
//  CDEDropboxSyncCloudFileSystem.m
//  Idiomatic
//
//  Created by Drew McCormack on 10/11/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import "CDEDropboxSyncCloudFileSystem.h"


NSString * const CDEDropboxSyncCloudFileSystemDidDownloadFilesNotification = @"CDEDropboxSyncCloudFileSystemDidDownloadFilesNotification";
NSString * const CDEDropboxSyncCloudFileSystemDidMakeTransferProgressNotification = @"CDEDropboxSyncCloudFileSystemDidMakeTransferProgressNotification";
NSString * const CDEDropboxSyncCloudFileSystemDidUploadFilesNotification = @"CDEDropboxSyncCloudFileSystemDidUploadFilesNotification";


@interface CDEDropboxSyncCloudFileSystem ()

@property (atomic, readwrite) unsigned long long bytesRemainingToDownload;
@property (atomic, readwrite) unsigned long long bytesRemainingToUpload;

@end


@implementation CDEDropboxSyncCloudFileSystem {
    DBFilesystem *filesystem;
    NSOperationQueue *operationQueue;
    NSOperationQueue *transferQueue;
    BOOL updatingBytes;
}

@synthesize accountManager;

- (instancetype)initWithAccountManager:(DBAccountManager *)newManager
{
    self = [super init];
    if (self) {
        accountManager = newManager;
        [DBAccountManager setSharedManager:newManager];
        filesystem = [DBFilesystem sharedFilesystem];
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
        transferQueue = [[NSOperationQueue alloc] init];
        transferQueue.maxConcurrentOperationCount = 4;
        [self updateFilesystem];
    }
    return self;
}

- (void)dealloc
{
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(fireDownloadNotification) object:nil];
    if (filesystem) [filesystem removeObserver:self];
    [operationQueue cancelAllOperations];
}

#pragma mark Connecting

- (BOOL)isConnected
{
    return self.accountManager.linkedAccount != nil;
}

- (void)connect:(CDECompletionBlock)completion
{
    filesystem = nil;
    
    CDECompletionBlock block = ^(NSError *error) {
        [self updateFilesystem];
        [self dispatchCompletion:completion withError:error];
    };
    
    if (self.isConnected) {
        if (block) block(nil);
    }
    else if ([self.delegate respondsToSelector:@selector(linkAccountManagerForDropboxSyncCloudFileSystem:completion:)]) {
        [self.delegate linkAccountManagerForDropboxSyncCloudFileSystem:self completion:block];
    }
    else {
        NSError *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeConnectionError userInfo:nil];
        if (block) block(error);
    }
}

#pragma mark User Identity

- (void)fetchUserIdentityWithCompletion:(CDEFetchUserIdentityCallback)completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        if (!self.accountManager.linkedAccount) {
            NSDictionary *info = @{NSLocalizedDescriptionKey : @"Dropbox account manager does not have a linked account."};
            error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeConnectionError userInfo:info];
        }
        if (completion) completion(self.accountManager.linkedAccount.userId, error);
    });
}

#pragma mark File System

- (void)updateFilesystem
{
    if (accountManager.linkedAccount) {
        if (accountManager.linkedAccount != filesystem.account) {
            __weak typeof(self) weakSelf = self;
            filesystem = [[DBFilesystem alloc] initWithAccount:accountManager.linkedAccount];
            [filesystem addObserver:self forPathAndDescendants:[DBPath root] block:^{
                typeof (self) strongSelf = weakSelf;
                if (!strongSelf) return;
                if (strongSelf->filesystem.status.download.inProgress) [strongSelf scheduleDownloadNotification];
                if (strongSelf->filesystem.status.upload.inProgress) [strongSelf scheduleUploadNotification];
            }];
        }
    }
    else {
        if (filesystem) [filesystem removeObserver:self];
        filesystem = nil;
    }
}

- (void)updateBytesRemainingToTransfer
{
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateBytesRemainingToTransfer) object:nil];

    @synchronized(self) {
        if (updatingBytes) return;
        updatingBytes = YES;
    }
    
    [operationQueue addOperationWithBlock:^{
        @try {
            unsigned long long bytesToUpload = 0;
            unsigned long long count = [self bytesRemainingToDownloadInPath:[DBPath root] upload:&bytesToUpload];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.bytesRemainingToDownload = count;
                self.bytesRemainingToUpload = bytesToUpload;
                [[NSNotificationCenter defaultCenter] postNotificationName:CDEDropboxSyncCloudFileSystemDidMakeTransferProgressNotification object:self];
                if (count > 0 || bytesToUpload > 0) {
                    [self performSelector:@selector(updateBytesRemainingToTransfer) withObject:nil afterDelay:10.0];
                }
                
                @synchronized(self) {
                    updatingBytes = NO;
                }
            }];
        }
        @catch ( NSException *exception ) {}
    }];
}

- (unsigned long long)bytesRemainingToDownloadInPath:(DBPath *)path upload:(unsigned long long *)toUpload
{
    DBError *error = nil;
    DBFileInfo *info = [filesystem fileInfoForPath:path error:&error];
    if (!info) {
        CDELog(CDELoggingLevelError, @"Failed to get file info in Dropbox: %@", error);
        return 0;
    }
    
    if (!info.isFolder) {
        unsigned long long toDownload = 0;
        NSError *error = nil;
        DBFile *file = [filesystem openFile:path error:&error];
        if (!file)
            CDELog(CDELoggingLevelError, @"Couldn't open file: %@", file);
        else {
            toDownload = file.status.cached ? 0 : info.size;
            *toUpload = file.status.state == DBFileStateUploading ? info.size : 0;
            [file close];
        }
        return toDownload;
    }
    
    NSArray *children = [filesystem listFolder:path error:&error];
    if (!children) {
        CDELog(CDELoggingLevelError, @"Failed to list Dropbox folder: %@", error);
        return 0;
    }
    
    unsigned long long bytes = 0;
    *toUpload = 0;
    for (DBFileInfo *child in children) {
        unsigned long long upload = 0;
        bytes += [self bytesRemainingToDownloadInPath:child.path upload:&upload];
        *toUpload += upload;
    }
    
    return bytes;
}

#pragma mark Notifications

- (void)scheduleDownloadNotification
{
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(fireDownloadNotification) object:nil];
    [self performSelector:@selector(fireDownloadNotification) withObject:nil afterDelay:5.0];
    
    [self updateBytesRemainingToTransfer];
}

- (void)scheduleUploadNotification
{
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(fireUploadNotification) object:nil];
    [self performSelector:@selector(fireUploadNotification) withObject:nil afterDelay:5.0];
    
    [self updateBytesRemainingToTransfer];
}

- (void)fireDownloadNotification
{
    if (filesystem.status.download.inProgress) {
        [self scheduleDownloadNotification];
        return;
    }
    
    self.bytesRemainingToDownload = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:CDEDropboxSyncCloudFileSystemDidMakeTransferProgressNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDEDropboxSyncCloudFileSystemDidDownloadFilesNotification object:self];
}

- (void)fireUploadNotification
{
    if (filesystem.status.upload.inProgress) {
        [self scheduleUploadNotification];
        return;
    }
    
    self.bytesRemainingToUpload = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:CDEDropboxSyncCloudFileSystemDidMakeTransferProgressNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDEDropboxSyncCloudFileSystemDidUploadFilesNotification object:self];
}

#pragma mark File Methods

- (void)fileExistsAtPath:(NSString *)path completion:(CDEFileExistenceCallback)completion
{
    DBError *error = nil;
    DBPath *root = [DBPath root];
    DBPath *dropboxPath = [root childPath:path];
    DBFileInfo *info = [filesystem fileInfoForPath:dropboxPath error:&error];
    if (info) {
        // Exists
        if (completion) completion(YES, info.isFolder, nil);
    }
    else if (!info && error.code == DBErrorNotFound) {
        // Doesn't exist
        if (completion) completion(NO, NO, nil);
    }
    else {
        // Error
        if (completion) completion(NO, NO, error);
    }
}

- (void)contentsOfDirectoryAtPath:(NSString *)path completion:(CDEDirectoryContentsCallback)completion
{
    DBError *error = nil;
    DBPath *dropboxPath = [[DBPath root] childPath:path];
    NSArray *children = [filesystem listFolder:dropboxPath error:&error];
    
    if (children) {
        NSMutableArray *contents = [[NSMutableArray alloc] init];
        for (DBFileInfo *child in children) {
            NSString *name = child.path.name;
            if ([name rangeOfString:@")"].location != NSNotFound) continue;
            
            if (child.isFolder) {
                CDECloudDirectory *dir = [CDECloudDirectory new];
                dir.name = child.path.name;
                dir.path = child.path.stringValue;
                [contents addObject:dir];
            }
            else {
                CDECloudFile *file = [CDECloudFile new];
                file.name = child.path.name;
                file.path = child.path.stringValue;
                file.size = child.size;
                [contents addObject:file];
            }
        }
        
        if (completion) completion(contents, nil);
    }
    else {
        if (completion) completion(nil, error);
    }
}

- (void)createDirectoryAtPath:(NSString *)path completion:(CDECompletionBlock)completion
{
    DBError *error = nil;
    DBPath *dropboxPath = [[DBPath root] childPath:path];
    BOOL success = [filesystem createFolder:dropboxPath error:&error];
    if (completion) completion(success ? nil : error);
}

- (void)removeItemAtPath:(NSString *)path completion:(CDECompletionBlock)completion
{
    DBError *error = nil;
    DBPath *dropboxPath = [[DBPath root] childPath:path];
    BOOL success = [filesystem deletePath:dropboxPath error:&error];
    [self dispatchCompletion:completion withError:success ? nil : error];
}

- (NSUInteger)fileUploadMaximumBatchSize
{
    return 10;
}

- (void)uploadLocalFile:(NSString *)fromPath toPath:(NSString *)toPath completion:(CDECompletionBlock)completion
{
    [self uploadLocalFiles:@[fromPath] toPaths:@[toPath] completion:completion];
}

- (void)uploadLocalFiles:(NSArray *)fromPaths toPaths:(NSArray *)toPaths completion:(CDECompletionBlock)completion
{
    [operationQueue addOperationWithBlock:^{
        NSMutableArray *errors = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < fromPaths.count; i++) {
            NSString *fromPath = fromPaths[i];
            NSString *toPath = toPaths[i];

            __weak typeof(transferQueue) weakQueue = transferQueue;
            [transferQueue addOperationWithBlock:^{
                @synchronized(errors) {
                    if (errors.count > 0) return;
                }
                
                DBError *error = nil;
                DBPath *dropboxPath = [[DBPath root] childPath:toPath];
                DBFile *file = [filesystem createFile:dropboxPath error:&error];
                if (!file) {
                    @synchronized(errors) {
                        [errors addObject:error];
                        [weakQueue cancelAllOperations];
                    }
                    return;
                }
                
                BOOL success = [file writeContentsOfFile:fromPath shouldSteal:NO error:&error];
                [file close];
                
                if (!success) {
                    @synchronized(errors) {
                        [errors addObject:error];
                        [weakQueue cancelAllOperations];
                    }
                    return;
                }
            }];
        }
        
        [transferQueue waitUntilAllOperationsAreFinished];
        
        NSError *returnError = [self combineErrors:errors];
        [self dispatchCompletion:completion withError:returnError];
    }];
}

- (NSUInteger)fileDownloadMaximumBatchSize
{
    return 20;
}

- (void)downloadFromPath:(NSString *)fromPath toLocalFile:(NSString *)toPath completion:(CDECompletionBlock)completion
{
    [self downloadFromPaths:@[fromPath] toLocalFiles:@[toPath] completion:completion];
}

- (void)downloadFromPaths:(NSArray *)fromPaths toLocalFiles:(NSArray *)toPaths completion:(CDECompletionBlock)completion
{
    [operationQueue addOperationWithBlock:^{
        NSMutableArray *errors = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < fromPaths.count; i++) {
            NSString *fromPath = fromPaths[i];
            NSString *toPath = toPaths[i];
            
            __weak typeof(transferQueue) weakQueue = transferQueue;
            [transferQueue addOperationWithBlock:^{
                @synchronized(errors) {
                    if (errors.count > 0) return;
                }
                
                DBError *error = nil;
                DBPath *dropboxPath = [[DBPath root] childPath:fromPath];
                DBFile *file = [filesystem openFile:dropboxPath error:&error];
                if (!file) {
                    @synchronized(errors) {
                        [errors addObject:error];
                        [weakQueue cancelAllOperations];
                    }
                    return;
                }
                
                NSData *data = [file readData:&error];
                if (!data) {
                    [file close];
                    @synchronized(errors) {
                        [errors addObject:error];
                        [weakQueue cancelAllOperations];
                    }
                    return;
                }
                
                NSError *writeError = nil;
                BOOL success = [data writeToFile:toPath atomically:YES];
                [file close];
                if (!success) {
                    NSDictionary *info = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Could not write file at path: %@", toPath]};
                    writeError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeFileAccessFailed userInfo:info];
                    
                    @synchronized(errors) {
                        [errors addObject:writeError];
                        [weakQueue cancelAllOperations];
                    }
                    return;
                }
            }];
        }
        
        [transferQueue waitUntilAllOperationsAreFinished];
        
        NSError *returnError = [self combineErrors:errors];
        [self dispatchCompletion:completion withError:returnError];
    }];
}

- (NSError *)combineErrors:(NSArray *)errors
{
    if (errors.count == 0)
        return nil;
    else if (errors.count == 1)
        return errors.lastObject;
    else {
        NSError *multipleErrorsError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeMultipleErrors userInfo:@{@"errors": [errors copy]}];
        return multipleErrorsError;
    }
}

- (void)dispatchCompletion:(CDECompletionBlock)completion withError:(NSError *)error
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (completion) completion(error);
    }];
}

@end
