//
//  CDEDropboxSyncCloudFileSystem.h
//  Ensembles
//
//  Uses the Dropbox Sync API (https://www.dropbox.com/developers/sync)
//
//  Created by Drew McCormack on 10/11/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ensembles/Ensembles.h>
#import <Dropbox/Dropbox.h>

@class CDEDropboxSyncCloudFileSystem;

extern NSString * const CDEDropboxSyncCloudFileSystemDidDownloadFilesNotification;
extern NSString * const CDEDropboxSyncCloudFileSystemDidMakeTransferProgressNotification;
extern NSString * const CDEDropboxSyncCloudFileSystemDidUploadFilesNotification;

@protocol CDEDropboxSyncCloudFileSystemDelegate <NSObject>

- (void)linkAccountManagerForDropboxSyncCloudFileSystem:(CDEDropboxSyncCloudFileSystem *)fileSystem completion:(CDECompletionBlock)completion;

@end


@interface CDEDropboxSyncCloudFileSystem : NSObject <CDECloudFileSystem>

@property (readonly) DBAccountManager *accountManager;
@property (readwrite, weak) id <CDEDropboxSyncCloudFileSystemDelegate> delegate;
@property (atomic, readonly) unsigned long long bytesRemainingToDownload;
@property (atomic, readonly) unsigned long long bytesRemainingToUpload;

- (instancetype)initWithAccountManager:(DBAccountManager *)newManager;

@end
