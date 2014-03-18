//
//  A3DaysCounterEventListEditViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DaysCounterCalendar;
@interface A3DaysCounterEventListEditViewController : UITableViewController<UIPopoverControllerDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) DaysCounterCalendar *calendarItem;
@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;

- (IBAction)removeAction:(id)sender;
- (IBAction)changeCalendarAction:(id)sender;
- (IBAction)shareAction:(id)sender;
@end
