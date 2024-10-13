//
//  A3DaysCounterEventChangeCalendarViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//


@class A3DaysCounterModelManager;
@class DaysCounterCalendar_;


@interface A3DaysCounterEventChangeCalendarViewController : UITableViewController

@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) NSArray *eventArray;
@property (strong, nonatomic) DaysCounterCalendar_ *currentCalendar;
@property (strong, nonatomic) void (^doneActionCompletionBlock)(void);

@end
