//
//  UIViewController+navigation.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 6/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (navigation)

- (void)popToRootAndPushViewController:(UIViewController *)viewController;

- (void)showRightDrawerViewController:(UIViewController *)viewController;
@end
