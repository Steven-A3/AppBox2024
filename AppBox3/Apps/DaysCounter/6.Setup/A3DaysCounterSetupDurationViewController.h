//
//  A3DaysCounterSetupDurationViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DaysCounterEvent_;
@class A3DaysCounterModelManager;
@interface A3DaysCounterSetupDurationViewController : UITableViewController
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterEvent_ *eventModel;
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UILabel *examLabel;
@property (strong, nonatomic) void (^dismissCompletionBlock)(void);
@end
