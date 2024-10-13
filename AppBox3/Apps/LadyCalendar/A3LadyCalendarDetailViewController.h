//
//  A3LadyCalendarDetailViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3LadyCalendarModelManager;

@interface A3LadyCalendarDetailViewController : UITableViewController

@property (strong, nonatomic) NSString *periodID;
@property (strong, nonatomic) NSMutableArray *periodItems;
@property (strong, nonatomic) NSDate *month;
@property (assign, nonatomic) BOOL isFromNotification;

@end
