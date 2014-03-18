//
//  A3LadyCalendarSetupCustomAlertViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3KeyboardProtocol.h"

@interface A3LadyCalendarSetupCustomAlertViewController : UITableViewController<UITextFieldDelegate,A3KeyboardDelegate>

@property (strong, nonatomic) NSMutableDictionary *settingDict;
@end
