//
//  A3DaysCounterLocationPopupViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSVenue;
@class A3DaysCounterModelManager;
@interface A3DaysCounterLocationPopupViewController : UITableViewController
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) FSVenue *locationItem;
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (assign, nonatomic) BOOL showDoneButton;
@property (strong, nonatomic) void (^resizeFrameBlock)(CGSize size);
@property (strong, nonatomic) void (^dismissCompletionBlock)(FSVenue *locationItem);
@property (strong, nonatomic) void (^shrinkPopoverViewBlock)(CGSize size);
@end
