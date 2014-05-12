//
//  A3DaysCounterSetupCustomAlertViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2014. 2. 4..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3KeyboardDelegate.h"
@class DaysCounterEvent;
@class A3DaysCounterModelManager;
@interface A3DaysCounterSetupCustomAlertViewController : UITableViewController<UITextFieldDelegate,A3KeyboardDelegate>
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterEvent *eventModel;

@end
