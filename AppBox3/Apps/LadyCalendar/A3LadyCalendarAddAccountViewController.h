//
//  A3LadyCalendarAddAccountViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

@class A3LadyCalendarModelManager;

@interface A3LadyCalendarAddAccountViewController : UITableViewController<UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) LadyCalendarAccount_ *accountItem;
@property (assign, nonatomic) BOOL isEditMode;
@property (weak, nonatomic) A3LadyCalendarModelManager *dataManager;

@end
