//
//  A3DaysCounterSetupCalendarViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DaysCounterEvent;
@interface A3DaysCounterSetupCalendarViewController : UITableViewController

@property (strong, nonatomic) DaysCounterEvent *eventModel;
@property (strong, nonatomic) void (^completionBlock)();
@property (strong, nonatomic) void (^dismissCompletionBlock)();
@end
