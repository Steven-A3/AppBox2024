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

@property(nonatomic) BOOL showLeftView;
@property(nonatomic) BOOL showRightView;

- (void)toggleLeftMenuViewOnOff;

- (void)presentRightSideViewController:(UIViewController *)viewController;
- (void)dismissRightSideViewController;

@end
