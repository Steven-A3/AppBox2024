//
//  A3DaysCounterSetupRepeatViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3KeyboardDelegate.h"

@class DaysCounterEvent;
@class A3DaysCounterModelManager;
@interface A3DaysCounterSetupRepeatViewController : UITableViewController<A3KeyboardDelegate, UITextFieldDelegate>{

}
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterEvent *eventModel;
@property (strong, nonatomic) void (^dismissCompletionBlock)(void);
@end
