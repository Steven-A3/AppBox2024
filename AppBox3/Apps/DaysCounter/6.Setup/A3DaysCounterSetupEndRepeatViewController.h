//
//  A3DaysCounterSetupEndRepeatViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3DateKeyboardViewController.h"
@class DaysCounterEvent_;
@class A3DaysCounterModelManager;
@interface A3DaysCounterSetupEndRepeatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,A3DateKeyboardDelegate>
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterEvent_ *eventModel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) void (^dismissCompletionBlock)(void);
@end
