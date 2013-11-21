//
//  UIViewController(A3Addition)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/7/13 5:59 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "common.h"
#import "A3AppDelegate.h"
#import "UIViewController+MMDrawerController.h"
#import "A3CenterViewProtocol.h"
#import "A3UIDevice.h"
#import "UIViewController+A3Addition.h"


@implementation UIViewController (A3Addition)

- (CGRect)screenBoundsAdjustedWithOrientation {
	CGRect bounds = [[UIScreen mainScreen] bounds];
	if (IS_LANDSCAPE) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	return bounds;
}

- (void)popToRootAndPushViewController:(UIViewController *)viewController {
	UINavigationController *navigationController;

	if (IS_IPHONE) {
		navigationController = (UINavigationController *) self.mm_drawerController.centerViewController;
		[self.mm_drawerController closeDrawerAnimated:YES completion:nil];
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
		navigationController = [rootViewController centerNavigationController];
	}

	[navigationController setToolbarHidden:YES];

	BOOL hidesNavigationBar = NO;
	UIViewController<A3CenterViewProtocol> *targetViewController = (UIViewController <A3CenterViewProtocol> *) viewController;
	if ([viewController respondsToSelector:@selector(hidesNavigationBar)]) {
		hidesNavigationBar = [targetViewController hidesNavigationBar];
	}
    if (hidesNavigationBar) {
        [navigationController setNavigationBarHidden:YES animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

        UIImage *image = [UIImage new];
        [navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        [navigationController.navigationBar setShadowImage:image];
    } else {
        [navigationController setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

        [navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navigationController.navigationBar setShadowImage:nil];
    }

	NSArray *poppedVCs = [navigationController popToRootViewControllerAnimated:NO];
	for (UIViewController<A3CenterViewProtocol> *vc in poppedVCs) {
		if ([vc respondsToSelector:@selector(cleanUp)]) {
			[vc performSelector:@selector(cleanUp)];
		}
	}

	if (IS_IPAD) {
		BOOL usesFullScreenInLandscape = NO;
		if ([viewController respondsToSelector:@selector(usesFullScreenInLandscape)]) {
			usesFullScreenInLandscape = [targetViewController usesFullScreenInLandscape];
		}
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
		[rootViewController animateHideLeftViewForFullScreenCenterView:usesFullScreenInLandscape];
	}

    if (viewController) {
        [navigationController pushViewController:viewController animated:YES];
    }
}

- (void)leftBarButtonAppsButton {
	@autoreleasepool {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction)];
	}
}

- (void)appsButtonAction {
	if (IS_IPHONE) {
		[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
	} else {
		[[[A3AppDelegate instance] rootViewController] toggleLeftMenuViewOnOff];
	}
}

- (void)addTwoButtons:(NSArray *)buttons toView:(UIView *)view {
	NSAssert([buttons count] == 2, @"The number of buttons must 2 but it is %lu", (unsigned long)[buttons count]);
	UIButton *button1 = buttons[0];
	UIButton *button2 = buttons[1];
	for (UIButton *button in buttons) {
		[view addSubview:button];
		[button setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button1
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button2
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button1
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeCenterX multiplier:2.0 * 1.0 / 3.0 constant:0.0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button2
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeCenterX multiplier:2.0 * 2.0 / 3.0 constant:0.0]];
}

- (void)addThreeButtons:(NSArray *)buttons toView:(UIView *)view {
	NSAssert([buttons count] == 3, @"The number of buttons must 3 but it is %lu", (unsigned long)[buttons count]);
	UIButton *button1 = buttons[0];
	UIButton *button2 = buttons[1];
	UIButton *button3 = buttons[2];
	for (UIButton *button in buttons) {
		[view addSubview:button];
		[button setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	NSDictionary *views = NSDictionaryOfVariableBindings(button1, button2, button3);
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button1
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button2
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
	[view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[button1]-[button2]-[button3]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:views]];
}

- (UIView *)moreMenuViewWithButtons:(NSArray *)buttonsArray {
	CGRect frame;
	frame = self.view.frame;
	frame.size.height = 44.0;
	frame.origin.y = -1.0;
	UIView *moreMenuView = [[UIView alloc] initWithFrame:frame];
	moreMenuView.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0];
	frame.origin.y += 44.0;
	frame.size.height = 1.0;
	UIView *bottomLineView = [[UIView alloc] initWithFrame:frame];
	bottomLineView.backgroundColor = [UIColor colorWithRed:178.0 / 255.0 green:178.0 / 255.0 blue:178.0 / 255.0 alpha:1.0];
	[moreMenuView addSubview:bottomLineView];

	if ([buttonsArray count] == 2) {
		[self addTwoButtons:buttonsArray toView:moreMenuView];
	} else {
		[self addThreeButtons:buttonsArray toView:moreMenuView];
	}

	return moreMenuView;
}

- (UIView *)presentMoreMenuWithButtons:(NSArray *)buttons tableView:(UITableView *)tableView {
	UIView *moreMenuView = [self moreMenuViewWithButtons:buttons];
	CGRect clippingViewFrame = moreMenuView.frame;
	clippingViewFrame.origin.y = 20.0 + 44.0 - 1.0;
	UIView *clippingView = [[UIView alloc] initWithFrame:clippingViewFrame];
	clippingView.clipsToBounds = YES;
	CGRect frame = clippingView.bounds;
	frame.origin.y -= frame.size.height;
	moreMenuView.frame = frame;
	[clippingView addSubview:moreMenuView];

	[self.navigationController.view insertSubview:clippingView belowSubview:self.view];

	[UIView animateWithDuration:0.3 animations:^{
		CGRect newFrame = moreMenuView.frame;
		newFrame.origin.y = 0.0;
		moreMenuView.frame = newFrame;

		if (tableView) {
			UIEdgeInsets insets = tableView.contentInset;
			insets.top += clippingViewFrame.size.height;
			tableView.contentInset = insets;

			if (tableView.contentOffset.y == -64.0) {
				CGPoint offset = tableView.contentOffset;
				offset.y = -108.0;
				tableView.contentOffset = offset;
			}
		} else {
			newFrame = CGRectOffset(self.view.frame, 0.0, clippingViewFrame.size.height);
			self.view.frame = newFrame;
		}
	}];

	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreMenuDismissAction:)];
	[self.view addGestureRecognizer:gestureRecognizer];

	return clippingView;
}

- (void)dismissMoreMenuView:(UIView *)moreMenuView tableView:(UITableView *)tableView {
	UIView *menuView = moreMenuView.subviews[0];
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = menuView.frame;
		frame = CGRectOffset(frame, 0.0, -44.0);
		menuView.frame = frame;

		if (tableView) {
			UIEdgeInsets insets = tableView.contentInset;
			insets.top -= moreMenuView.frame.size.height;
			tableView.contentInset = insets;
		} else {
			frame = CGRectOffset(self.view.frame, 0.0, moreMenuView.frame.size.height);
			self.view.frame = frame;
		}
	} completion:^(BOOL finished) {
		[moreMenuView removeFromSuperview];
	}];
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	FNLOG(@"You have to override this method to close moreMenuView properly.");
}

- (UIButton *)shareButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (void)shareButtonAction:(id)sender {

}

- (UIButton *)historyButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"history"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(historyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (void)historyButtonAction:(UIButton *)button {

}

- (UIButton *)settingsButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"general"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (void)settingsButtonAction:(UIButton *)button {

}

- (void)presentSubViewController:(UIViewController *)viewController {
	if (IS_IPHONE) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:navigationController animated:YES completion:nil];
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
		[rootViewController presentRightSideViewController:viewController];
	}
}

- (void)rightBarButtonDoneButton {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {

}

- (void)rightButtonMoreButton {
	UIImage *image = [UIImage imageNamed:@"more_stroke"];
	UIBarButtonItem *moreButtonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(moreButtonAction:)];

	self.navigationItem.rightBarButtonItem = moreButtonItem;
}

- (void)moreButtonAction:(UIBarButtonItem *)button {

}

/*! This will make back bar button title @"" and this will effective for child view controllers
 * \returns void
 */
- (void)makeBackButtonEmptyArrow {
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items fromBarButtonItem:(UIBarButtonItem *)barButtonItem {
	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	} else {
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
		[popoverController presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		return popoverController;
	}
	return nil;
}

@end
