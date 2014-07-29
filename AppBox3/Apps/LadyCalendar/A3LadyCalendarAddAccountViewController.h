//
//  A3LadyCalendarAddAccountViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3LadyCalendarModelManager;

@interface A3LadyCalendarAddAccountViewController : UITableViewController<UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableDictionary *accountItem;
@property (assign,nonatomic) BOOL isEditMode;
@property(nonatomic, weak) A3LadyCalendarModelManager *dataManager;

@end
