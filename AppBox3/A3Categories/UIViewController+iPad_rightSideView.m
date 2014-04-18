//
//  UIViewController+iPad_rightSideView.m
//  AppBox3
//
//  Created by A3 on 4/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+iPad_rightSideView.h"
#import "UIViewController+A3Addition.h"

#define RIGHT_SIDE_VIEW_TAG	43895
#define CENTER_VIEW_TAG		54232

NSString *const A3NotificationRightSideViewWillDismiss = @"A3NotificationRightSideViewWillDismiss";
NSString *const A3NotificationRightSideViewDidDismissed = @"A3NotificationRightSideViewDidDismissed";

@implementation UIViewController (iPad_rightSideView)

- (void)presentRightSideView:(UIView *)presentingView {
	self.navigationItem.leftBarButtonItem.enabled = NO;

	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	UIView *coverView = [UIView new];
	coverView.frame = screenBounds;
	coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	coverView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
	coverView.tag = CENTER_VIEW_TAG;
	[self.navigationController.view insertSubview:coverView belowSubview:presentingView];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissRightSideView)];
	[coverView addGestureRecognizer:tapGestureRecognizer];

	CGRect frame = screenBounds;
	CGFloat sideViewWidth = 320.0;
	frame.origin.x = screenBounds.size.width;
	frame.size.width = sideViewWidth;
	presentingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
	presentingView.frame = frame;
	presentingView.tag = RIGHT_SIDE_VIEW_TAG;
	[self.navigationController.view addSubview:presentingView];

	[UIView animateWithDuration:0.3 animations:^{
		CGRect sideViewFrame = presentingView.frame;
		sideViewFrame.origin.x -= sideViewWidth;
		presentingView.frame = sideViewFrame;
	} completion:^(BOOL finished) {
	}];
}

- (void)dismissRightSideView {
	FNLOG();
	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationRightSideViewWillDismiss object:nil];

	UIView *centerView = [self.navigationController.view viewWithTag:CENTER_VIEW_TAG];
	[centerView removeFromSuperview];

	UIView *rightSideView = [self.navigationController.view viewWithTag:RIGHT_SIDE_VIEW_TAG];
	[UIView animateWithDuration:0.3 animations:^{
		CGRect bounds = [self screenBoundsAdjustedWithOrientation];
		CGRect frame = rightSideView.frame;
		frame.origin.x = bounds.size.width;
		rightSideView.frame = frame;
	} completion:^(BOOL finished) {
		[rightSideView removeFromSuperview];
	}];

	self.navigationItem.leftBarButtonItem.enabled = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationRightSideViewDidDismissed object:nil];
}

@end
