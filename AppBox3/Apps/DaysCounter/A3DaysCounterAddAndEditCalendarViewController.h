//
//  A3DaysCounterAddAndEditCalendarViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 1..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3DaysCounterAddAndEditCalendarViewController : UITableViewController<UITextFieldDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableDictionary *calendarItem;
@property (assign, nonatomic) BOOL isEditMode;

- (IBAction)deleteCalendarAction:(id)sender;
@end
