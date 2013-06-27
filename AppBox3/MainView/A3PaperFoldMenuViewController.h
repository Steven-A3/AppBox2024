//
//  A3PaperFoldMenuViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/9/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperFoldView.h"
#import "A3AppViewController.h"

@class A3MainMenuTableViewController;

@interface A3PaperFoldMenuViewController : A3AppViewController <PaperFoldViewDelegate,MultiFoldViewDelegate>

@property (nonatomic, strong) PaperFoldView *paperFoldView, *paperFoldView2;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) A3MainMenuTableViewController *sideMenuTableViewController;

- (void)pushViewControllerToNavigationController:(UIViewController *)viewController withOption:(BOOL)keepWidth;
- (void)pushViewControllerToNavigationController:(UIViewController *)viewController;
- (void)presentRightWingWithViewController:(UIViewController *)viewController onClose:(void (^)())onCloseBlock;
- (void)removeRightWingViewController;

@end
