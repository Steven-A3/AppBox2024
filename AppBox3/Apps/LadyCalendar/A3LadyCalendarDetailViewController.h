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
@interface A3LadyCalendarDetailViewController : UITableViewController{
    LadyCalendarAccount *currentAccount;
    BOOL isEditNavigationBar;
}

@property (strong, nonatomic) NSMutableArray *periodItems;
@property (strong, nonatomic) NSDate *month;

@end
