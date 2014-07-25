//
//  A3SyncManager.h
//  AppBox3
//
//  Created by A3 on 7/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Ensembles/Ensembles.h>

extern NSString * const A3SyncManagerCloudEnabled;

@interface A3SyncManager : NSObject

@property (nonatomic, readonly, strong) CDEPersistentStoreEnsemble *ensemble;
@property (nonatomic, strong) CDEICloudFileSystem *cloudFileSystem;
@property (nonatomic, copy) NSString *storePath;

+ (instancetype)sharedSyncManager;
- (BOOL)isCloudAvailable;
- (void)setupEnsemble;
- (void)enableCloudSync;
- (void)disableCloudSync;
- (BOOL)isCloudEnabled;
- (void)synchronizeWithCompletion:(CDECompletionBlock)completion;

- (void)uploadFilesToCloud;

- (void)downloadFilesFromCloud;

- (void)fileExistsAtPath:(NSString *)path completion:(void (^)(BOOL exists, BOOL isDirectory, NSError *error))block;

- (void)contentsOfDirectoryAtPath:(NSString *)path completion:(void (^)(NSArray *contents, NSError *error))block;

- (void)createDirectoryAtPath:(NSString *)path completion:(CDECompletionBlock)block;

- (void)removeItemAtPath:(NSString *)path completion:(CDECompletionBlock)block;

- (void)uploadLocalFile:(NSString *)fromPath toPath:(NSString *)toPath completion:(CDECompletionBlock)block;

- (void)downloadFromPath:(NSString *)fromPath toLocalFile:(NSString *)toPath completion:(CDECompletionBlock)block;
@end
