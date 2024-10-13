//
//  A3DaysCounterAddAndEditCalendarViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 1..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//


@class A3DaysCounterModelManager;
@class DaysCounterCalendar_;

@interface A3DaysCounterAddAndEditCalendarViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterCalendar_ *calendar;
@property (assign, nonatomic) BOOL isEditMode;

- (IBAction)deleteCalendarAction:(id)sender;

@end
