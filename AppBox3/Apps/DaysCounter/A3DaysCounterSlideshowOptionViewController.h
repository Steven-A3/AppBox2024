//
//  A3DaysCounterSlideshowOptionViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3DaysCounterSlideshowOptionViewController : UITableViewController

@property (strong,nonatomic) UIActivity *activity;
@property (strong, nonatomic) void (^completionBlock)(NSDictionary *userInfo);

@end
