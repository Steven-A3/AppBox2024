//
//  A3DaysCounterEventChangeCalendarViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DaysCounterCalendar;
@class A3DaysCounterModelManager;
@interface A3DaysCounterEventChangeCalendarViewController : UITableViewController
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) NSArray *eventArray;
@property (strong, nonatomic) DaysCounterCalendar *currentCalendar;
@property (strong, nonatomic) void (^doneActionCompletionBlock)(void);
@end