//
//  A3RootViewController_iPad.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3NavigationController.h"

@interface A3RootViewController_iPad : UIViewController

@property (nonatomic, strong)	A3NavigationController *leftNavigationController;
@property (nonatomic, strong)	A3NavigationController *centerNavigationController;
@property (nonatomic, strong)	A3NavigationController *rightNavigationController;
@property (nonatomic, strong)   NSMutableArray *presentViewControllers;

@property(nonatomic) BOOL showLeftView;
@property(nonatomic) BOOL showRightView;

- (void)animateHideLeftViewForFullScreenCenterView:(BOOL)fullScreenCenterView;

- (void)toggleLeftMenuViewOnOff;

- (void)presentCenterViewController:(UIViewController *)viewController fromViewController:(UIViewController *)sourceViewController;
- (void)presentCenterViewController:(UIViewController *)viewController fromViewController:(UIViewController *)sourceViewController withCompletion:(void (^)(void))completion;
- (void)dismissCenterViewController;
- (void)presentRightSideViewController:(UIViewController *)viewController;
- (void)dismissRightSideViewController;
- (void)presentDownSideViewController:(UIViewController *)viewController;

@end
