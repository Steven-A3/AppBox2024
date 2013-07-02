//
//  UIViewController+navigation.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 6/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+navigation.h"
#import "UIViewController+MMDrawerController.h"
#import "A3AppDelegate.h"

@implementation UIViewController (navigation)

- (void)popToRootAndPushViewController:(UIViewController *)viewController {
	UINavigationController *navigationController = (UINavigationController *) self.mm_drawerController.centerViewController;
	[navigationController popToRootViewControllerAnimated:NO];
	[navigationController pushViewController:viewController animated:YES];

    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
}

- (void)showRightDrawerViewController:(UIViewController *)viewController {
	MMDrawerController *mm_drawerController = [[A3AppDelegate instance] mm_drawerController];
	[mm_drawerController setRightDrawerViewController:viewController];
	[mm_drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

@end
