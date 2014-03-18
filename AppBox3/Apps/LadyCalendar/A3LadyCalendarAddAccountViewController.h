//
//  A3LadyCalendarAddAccountViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LadyCalendarAccount;
@interface A3LadyCalendarAddAccountViewController : UITableViewController<UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) LadyCalendarAccount *accountItem;
@property (assign,nonatomic) BOOL isEditMode;
@end
