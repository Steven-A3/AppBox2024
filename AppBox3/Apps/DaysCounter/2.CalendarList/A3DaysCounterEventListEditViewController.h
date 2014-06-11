//
//  A3DaysCounterEventListEditViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DaysCounterCalendar;
@class A3DaysCounterModelManager;
@interface A3DaysCounterEventListEditViewController : UITableViewController
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterCalendar *calendarItem;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *calendarBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareBarButton;

- (IBAction)removeAction:(id)sender;
- (IBAction)changeCalendarAction:(id)sender;
- (IBAction)shareAction:(id)sender;
@end
