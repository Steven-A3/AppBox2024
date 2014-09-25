//
//  A3SettingsiTunesSelectBackupViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3SettingsITunesSelectBackupDelegate <NSObject>

- (void)iTunesSelectBackupViewController:(UIViewController *)vc backupFileSelected:(NSString *)filename;

@end


@interface A3SettingsiTunesSelectBackupViewController : UITableViewController

@property (nonatomic, weak) id<A3SettingsITunesSelectBackupDelegate> delegate;

@end
