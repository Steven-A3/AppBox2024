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

typedef NS_ENUM(NSUInteger, A3DictionaryDBTransactionTypeValue) {
	A3DictionaryDBTransactionTypeSetBaseline = 1,
	A3DictionaryDBTransactionTypeInsertTop,
	A3DictionaryDBTransactionTypeInsertBottom,
	A3DictionaryDBTransactionTypeDelete,
	A3DictionaryDBTransactionTypeUpdate,
	A3DictionaryDBTransactionTypeReplace,	// object has array, [0]OLD / [1]new
	A3DictionaryDBTransactionTypeReorder
};

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

- (void)addTransaction:(NSString *)dataFilename type:(A3DictionaryDBTransactionTypeValue)typeValue object:(id)object;
@end
