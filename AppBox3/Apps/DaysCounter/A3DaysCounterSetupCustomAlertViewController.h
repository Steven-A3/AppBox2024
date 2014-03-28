//
//  A3DaysCounterSetupCustomAlertViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2014. 2. 4..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3KeyboardDelegate.h"

@interface A3DaysCounterSetupCustomAlertViewController : UITableViewController<UITextFieldDelegate,A3KeyboardDelegate>

@property (strong, nonatomic) NSMutableDictionary *eventModel;

@end
