//
//  CDECloudManager.h
//  Test App iOS
//
//  Created by Drew McCormack on 5/29/13.
//  Copyright (c) 2013 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDEDefines.h"

@protocol CDECloudFileSystem;
@class CDEEventStore;

@interface CDECloudManager : NSObject

@property (nonatomic, strong, readonly) CDEEventStore *eventStore;
@property (nonatomic, strong, readonly) id <CDECloudFileSystem> cloudFileSystem;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSString *remoteEnsembleDirectory;

- (instancetype)initWithEventStore:(CDEEventStore *)newStore cloudFileSystem:(id <CDECloudFileSystem>)cloudFileSystem managedObjectModel:(NSManagedObjectModel *)newModel;

- (void)setup;

- (void)createRemoteDirectoryStructureWithCompletion:(CDECompletionBlock)completion;

- (void)snapshotRemoteFilesWithCompletion:(CDECompletionBlock)completion;
- (void)clearSnapshot;

- (void)importNewRemoteNonBaselineEventsWithProgress:(CDEProgressBlock)progressBlock;
- (void)importNewBaselineEventsWithProgress:(CDEProgressBlock)progressBlock;
- (void)importNewDataFilesWithProgress:(CDEProgressBlock)progressBlock;

- (void)exportNewLocalNonBaselineEventsWithProgress:(CDEProgressBlock)progressBlock;
- (void)exportNewLocalBaselineWithProgress:(CDEProgressBlock)progressBlock;
- (void)exportDataFilesWithProgress:(CDEProgressBlock)progressBlock;

- (void)removeLocallyProducedIncompleteRemoteFileSets:(CDECompletionBlock)completion;
- (void)removeOutdatedRemoteFilesWithCompletion:(CDECompletionBlock)completion;
- (BOOL)removeOutOfDateNewlyImportedFiles:(NSError * __autoreleasing *)error;

- (void)checkExistenceOfRegistrationInfoForStoreWithIdentifier:(NSString *)identifier completion:(void(^)(BOOL exists, NSError *error))completion;
- (void)setRegistrationInfo:(NSDictionary *)info forStoreWithIdentifier:(NSString *)identifier completion:(CDECompletionBlock)completion;

@end
