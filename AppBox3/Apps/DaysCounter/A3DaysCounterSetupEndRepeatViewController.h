//
//  A3DaysCounterSetupEndRepeatViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3DateKeyboardViewController.h"

@interface A3DaysCounterSetupEndRepeatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,A3DateKeyboardDelegate>

@property (strong, nonatomic) NSMutableDictionary *eventModel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) void (^dismissCompletionBlock)();
@end
