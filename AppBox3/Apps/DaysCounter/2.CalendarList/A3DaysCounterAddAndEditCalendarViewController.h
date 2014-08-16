//
//  A3DaysCounterAddAndEditCalendarViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 1..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//


@class A3DaysCounterModelManager;
@class DaysCounterCalendar;

@interface A3DaysCounterAddAndEditCalendarViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterCalendar *calendar;
@property (assign, nonatomic) BOOL isEditMode;
@property (strong, nonatomic) NSManagedObjectContext *savingContext;

- (IBAction)deleteCalendarAction:(id)sender;

@end
