//
//  A3PaperFoldMenuViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/9/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperFoldView.h"

@class A3iPhoneMenuTableViewController;

@interface A3PaperFoldMenuViewController : UIViewController <PaperFoldViewDelegate>

@property (nonatomic, strong) PaperFoldView *paperFoldView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) A3iPhoneMenuTableViewController *sideMenuTableViewController;

- (void)pushViewControllerToNavigationController:(UIViewController *)viewController;


@end
