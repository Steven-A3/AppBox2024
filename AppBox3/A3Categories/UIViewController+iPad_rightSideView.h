//
//  UIViewController+iPad_rightSideView.h
//  AppBox3
//
//  Created by A3 on 4/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const A3NotificationRightSideViewWillDismiss;
extern NSString *const A3NotificationRightSideViewDidDismiss;
extern NSString *const A3NotificationRightSideViewDidAppear;
extern NSString *const A3NotificationChildViewControllerDidDismiss;

#define RIGHT_SIDE_VIEW_TAG    43895
#define CENTER_VIEW_TAG        54232

@interface UIViewController (iPad_rightSideView)

- (void)presentRightSideView:(UIView *)presentingView;
- (void)addCoverToView:(UIView *)targetView;
- (void)removeCoverView;
- (void)dismissRightSideView;

@end
