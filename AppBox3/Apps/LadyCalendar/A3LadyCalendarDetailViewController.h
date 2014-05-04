//
//  A3LadyCalendarDetailViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LadyCalendarPeriod;
@class LadyCalendarAccount;
@class A3LadyCalendarModelManager;

@interface A3LadyCalendarDetailViewController : UITableViewController

@property (weak, nonatomic) A3LadyCalendarModelManager *dataManager;
@property (strong, nonatomic) NSMutableArray *periodItems;
@property (strong, nonatomic) NSDate *month;

@end
