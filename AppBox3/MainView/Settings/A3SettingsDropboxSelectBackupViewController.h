//
//  A3SettingsDropboxSelectBackupViewController.h
//  AppBox3
//
//  Created by A3 on 1/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMetadata;
@class DBRestClient;

@protocol A3SettingsDropboxSelectBackupDelegate <NSObject>

- (void)dropboxSelectBackupViewController:(UIViewController *)vc backupFileSelected:(DBMetadata *)metadata;

@end

@interface A3SettingsDropboxSelectBackupViewController : UITableViewController

@property (nonatomic, strong) DBMetadata *dropboxMetadata;
@property (nonatomic, weak) id<A3SettingsDropboxSelectBackupDelegate> delegate;

@end
