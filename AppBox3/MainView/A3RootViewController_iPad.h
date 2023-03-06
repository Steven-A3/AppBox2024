//
//  A3RootViewController_iPad.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3MainMenuTableViewController;

@interface A3RootViewController_iPad : UIViewController

@property (nonatomic, strong)	A3MainMenuTableViewController *mainMenuViewController;
@property (nonatomic, strong)	UINavigationController *leftNavigationController;
@property (nonatomic, strong)	UINavigationController *centerNavigationController;
@property (nonatomic, strong)	UINavigationController *rightNavigationController;
@property (nonatomic, weak)		UIViewController *modalPresentedInRightNavigationViewController;
@property (nonatomic, strong)   NSMutableArray *presentViewControllers;

@property(nonatomic) BOOL showLeftView;
@property(nonatomic) BOOL showRightView;

- (void)animateHideLeftViewForFullScreenCenterView:(BOOL)fullScreenCenterView;

- (void)toggleLeftMenuViewOnOff;

- (void)presentCenterViewController:(UIViewController *)viewController fromViewController:(UIViewController *)sourceViewController;
- (void)presentCenterViewController:(UIViewController *)viewController fromViewController:(UIViewController *)sourceViewController withCompletion:(void (^)(void))completion;
- (void)dismissCenterViewController;
- (void)presentRightSideViewController:(UIViewController *)viewController toViewController:(UIViewController *)targetVC;
- (void)dismissRightSideViewController;
- (void)presentDownSideViewController:(UIViewController *)viewController;

@end
