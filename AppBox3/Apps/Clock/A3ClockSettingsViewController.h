//
//  A3ClockSettingsViewController.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const A3NotificationClockSettingsChanged;

@class A3ClockDataManager;

@interface A3ClockSettingsViewController : UIViewController

@property (nonatomic, weak) A3ClockDataManager *clockDataManager;

@end
