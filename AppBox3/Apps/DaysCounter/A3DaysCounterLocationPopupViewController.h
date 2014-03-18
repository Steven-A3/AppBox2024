//
//  A3DaysCounterLocationPopupViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSVenue;
@interface A3DaysCounterLocationPopupViewController : UITableViewController

@property (strong, nonatomic) FSVenue *locationItem;
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (assign, nonatomic) BOOL showDoneButton;
@end
