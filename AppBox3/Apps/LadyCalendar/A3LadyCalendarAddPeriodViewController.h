//
//  A3LadyCalendarAddPeriodViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3KeyboardDelegate.h"

@class LadyCalendarPeriod;
@class LadyCalendarAccount;
@class A3LadyCalendarModelManager;

@interface A3LadyCalendarAddPeriodViewController : UITableViewController<UITextViewDelegate,A3KeyboardDelegate,UITextFieldDelegate,UIAlertViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) LadyCalendarPeriod *periodItem;
@property (assign, nonatomic) BOOL isEditMode;
@property (weak, nonatomic) A3LadyCalendarModelManager *dataManager;

@end
