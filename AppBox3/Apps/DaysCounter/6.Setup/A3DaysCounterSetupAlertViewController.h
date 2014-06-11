//
//  A3DaysCounterSetupAlertViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DaysCounterEvent;
@class A3DaysCounterModelManager;
@interface A3DaysCounterSetupAlertViewController : UITableViewController

@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterEvent *eventModel;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (strong, nonatomic) void (^dismissCompletionBlock)();

- (IBAction)dateChangedAction:(id)sender;

@end
