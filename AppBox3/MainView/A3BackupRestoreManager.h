//
//  A3BackupRestoreManager.h
//  AppBox3
//
//  Created by A3 on 6/4/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

@class A3BackupRestoreManager;
extern NSString *const kDropboxDir;
extern NSString *const A3BackupFileVersionKey;
extern NSString *const A3BackupFileDateKey;
extern NSString *const A3BackupFileOSVersionKey;
extern NSString *const A3BackupFileSystemModelKey;
extern NSString *const A3BackupInfoFilename;

@protocol A3BackupRestoreManagerDelegate <NSObject>
- (void)backupRestoreManager:(A3BackupRestoreManager *)manager restoreCompleteWithSuccess:(BOOL)success;
@end

@interface A3BackupRestoreManager : NSObject

@property (nonatomic, weak) id<A3BackupRestoreManagerDelegate> delegate;
@property (nonatomic, weak) UIView *hostingView;
@property (nonatomic, weak) UIViewController *hostingViewController;

- (void)backupData;

- (void)backupToDocumentDirectory;

- (void)restoreDataAt:(NSString *)backupFilePath toURL:(NSURL *)toURL;
@end
