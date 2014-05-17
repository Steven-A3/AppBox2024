//
//  UIViewController+navigation.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 6/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3ActionMenuViewControllerDelegate.h"

extern NSString *const A3NotificationChildViewControllerDidDismiss;

@interface UIViewController (navigation)

@property (nonatomic, strong) UIViewController *actionMenuViewController;

- (void)presentActionMenuWithDelegate:(id <A3ActionMenuViewControllerDelegate>)delegate;
- (void)presentEmptyActionMenu;
- (void)closeActionMenuViewWithAnimation:(BOOL)animate;
- (void)addToolsButtonWithAction:(SEL)action;
- (void)alertCheck;
- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title action:(SEL)selector;
- (UIBarButtonItem *)blackBarButtonItemWithTitle:(NSString *)title action:(SEL)selector;
- (void)addActionIcon:(NSString *)iconName title:(NSString *)title selector:(SEL)selector atIndex:(NSInteger)index1;
- (CGRect)boundsForRightSideView;

@end
