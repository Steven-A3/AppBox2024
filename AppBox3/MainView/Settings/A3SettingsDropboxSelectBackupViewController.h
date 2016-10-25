//
//  A3SettingsDropboxSelectBackupViewController.h
//  AppBox3
//
//  Created by A3 on 1/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3SettingsDropboxSelectBackupDelegate <NSObject>

- (void)dropboxSelectBackupViewController:(UIViewController *)vc backupFileSelected:(NSDictionary *)metadata;

@end

@interface A3SettingsDropboxSelectBackupViewController : UITableViewController

@property (nonatomic, copy) NSString *dropboxAccessToken;
@property (nonatomic, strong) NSArray<NSDictionary *> *dropboxFolderList;
@property (nonatomic, weak) id<A3SettingsDropboxSelectBackupDelegate> delegate;

@end
