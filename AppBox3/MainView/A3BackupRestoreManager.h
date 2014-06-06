//
//  A3BackupRestoreManager.h
//  AppBox3
//
//  Created by A3 on 6/4/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

@class DBRestClient;

extern NSString *const kDropboxDir;

@interface A3BackupRestoreManager : NSObject

@property (nonatomic, weak) UIView *hostingView;

- (void)backupData;
@end
