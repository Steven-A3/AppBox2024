//
//  A3RootViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3MMDrawerController;

@interface A3RootViewController : UIViewController

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) A3MMDrawerController *drawerController;

- (void)presentRightSideViewController:(UIViewController *)viewController;

- (void)dismissRightSideViewController;
@end
