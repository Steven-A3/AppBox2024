//
//  A3DaysCounterSetupDurationViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3DaysCounterSetupDurationViewController : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *eventModel;
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UILabel *examLabel;
@property (strong, nonatomic) void (^dismissCompletionBlock)();
@end
