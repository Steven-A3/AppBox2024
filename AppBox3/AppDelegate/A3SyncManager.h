//
//  A3SyncManager.h
//  AppBox3
//
//  Created by A3 on 7/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Ensembles/Ensembles.h>

extern NSString * const A3SyncManagerCloudStoreID;

@interface A3SyncManager : NSObject

@property (nonatomic, readonly, strong) CDEPersistentStoreEnsemble *ensemble;
@property (nonatomic, copy) NSString *storePath;

+ (instancetype)sharedSyncManager;

- (BOOL)isCloudAvailable;

- (void)setupEnsemble;

- (void)removeCloudStore;

- (void)enableCloudSync;

- (void)disableCloudSync;

- (BOOL)isCloudEnabled;

- (void)synchronizeWithCompletion:(CDECompletionBlock)completion;
@end
