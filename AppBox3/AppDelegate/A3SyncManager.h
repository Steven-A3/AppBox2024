//
//  A3SyncManager.h
//  AppBox3
//
//  Created by A3 on 7/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Ensembles/Ensembles.h>

extern NSString * const A3SyncManagerCloudEnabled;
extern NSString * const A3SyncDeviceSyncStartInfo;

@interface A3SyncManager : NSObject

@property (nonatomic, readonly, strong) CDEPersistentStoreEnsemble *ensemble;
@property (nonatomic, strong) CDEICloudFileSystem *cloudFileSystem;
@property (nonatomic, copy) NSString *storePath;
@property (nonatomic, strong) NSFileManager *fileManager;

+ (instancetype)sharedSyncManager;

- (BOOL)canSyncStart;

- (BOOL)isCloudAvailable;
- (void)setupEnsemble;
- (void)enableCloudSync;
- (void)disableCloudSync;
- (BOOL)isCloudEnabled;
- (void)synchronizeWithCompletion:(CDECompletionBlock)completion;

- (void)uploadMediaFilesToCloud;
- (void)downloadMediaFilesFromCloud;

@end
