//
//  UIViewController(A3Addition)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/7/13 5:59 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3MirrorViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "A3WalletItemEditViewController.h"
#import "A3AppDelegate.h"
#import "UIViewController+MMDrawerController.h"
#import "A3CenterViewDelegate.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"
#import "A3UserDefaultsKeys.h"
#import "A3UserDefaults.h"
#import "A3HomeStyleMenuViewController.h"
#import "A3BasicWebViewController.h"
#import <objc/runtime.h>

static char const *const key_firstActionSheet = "key_firstActionSheet";
static char const *const key_adBannerView = "key_adBannerView";

NSString *const AdMobAdUnitIDBattery = @"ca-app-pub-0532362805885914/2432956543";
NSString *const AdMobAdUnitIDCalculator = @"ca-app-pub-0532362805885914/2712158144";
NSString *const AdMobAdUnitIDClock = @"ca-app-pub-0532362805885914/2851758945";
NSString *const AdMobAdUnitIDCurrencyList = @"ca-app-pub-0532362805885914/7281958549";
NSString *const AdMobAdUnitIDCurrencyPicker = @"ca-app-pub-0532362805885914/1644430548";
NSString *const AdMobAdUnitIDDateCalc = @"ca-app-pub-0532362805885914/4188891345";
NSString *const AdMobAdUnitIDDaysCounter = @"ca-app-pub-0532362805885914/7002756948";
NSString *const AdMobAdUnitIDExpenseList = @"ca-app-pub-0532362805885914/8479490142";
NSString *const AdMobAdUnitIDFlashlight = @"ca-app-pub-0532362805885914/3909689745";
NSString *const AdMobAdUnitIDHolidays = @"ca-app-pub-0532362805885914/9956223343";
NSString *const AdMobAdUnitIDLadiesCalendar = @"ca-app-pub-0532362805885914/5805225347";
NSString *const AdMobAdUnitIDLunarConverter = @"ca-app-pub-0532362805885914/5526023743";
NSString *const AdMobAdUnitIDMagnifier = @"ca-app-pub-0532362805885914/5386422940";
NSString *const AdMobAdUnitIDMirror = @"ca-app-pub-0532362805885914/6863156141";
NSString *const AdMobAdUnitIDPercentCalc = @"ca-app-pub-0532362805885914/7142357749";
NSString *const AdMobAdUnitIDRandom = @"ca-app-pub-0532362805885914/8339889346";
NSString *const AdMobAdUnitIDRuler = @"ca-app-pub-0532362805885914/9816622546";
NSString *const AdMobAdUnitIDSalesCalc = @"ca-app-pub-0532362805885914/8619090941";
NSString *const AdMobAdUnitIDTipCalc = @"ca-app-pub-0532362805885914/1095824149";
NSString *const AdMobAdUnitIDTranslator = @"ca-app-pub-0532362805885914/1235424945";
NSString *const AdMobAdUnitIDUnitConverter = @"ca-app-pub-0532362805885914/4049290542";
NSString *const AdMobAdUnitIDUnitPrice = @"ca-app-pub-0532362805885914/2572557342";
NSString *const AdMobAdUnitIDWallet = @"ca-app-pub-0532362805885914/4328492143";
NSString *const AdMobAdUnitIDLevel = @"ca-app-pub-0532362805885914/6920738140";
NSString *const AdMobAdUnitIDQRCode = @"ca-app-pub-0532362805885914/7248371747";

@implementation UIViewController (A3Addition)

/*! MainMenuViewController에서 app switch 할 때 popToRootViewController를 한 뒤에, 각 ViewController에 cleanUp을 호출합니다.
 *  이때 removeObserver와 nil을 할당하면 메모리를 효율적으로 제거할 수 있습니다.
 *  개별 viewController 에서 cleanUp을 구현하지 않은 경우, removeObserver 는 기본적으로 실행이 됩니다.
 *  만약 별도 구현한 경우에는 필요한 조치를 개별 구현하던가, [super cleanUp]을 호출해 주면 되겠습니다.
 */

- (void)cleanUp {
	[self removeObserver];
}

- (void)prepareClose {
	[self dismissInstructionViewController:nil];
}

- (void)dismissInstructionViewController:(id)sender {

}

- (CGRect)screenBoundsAdjustedWithOrientation {
	CGRect bounds = [[[A3AppDelegate instance] window] bounds];
	#ifdef __IPHONE_8_0
	if (IS_IOS7 && IS_LANDSCAPE) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	#else
	if (IS_LANDSCAPE) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	#endif
	return bounds;
}

- (void)callPrepareCloseOnActiveMainAppViewController {
	UINavigationController *navigationController = [[A3AppDelegate instance] navigationController];
	if ([navigationController.viewControllers count] > 1) {
		UIViewController<A3CenterViewDelegate> *activeMainAppViewController = navigationController.viewControllers[1];
		if ([activeMainAppViewController respondsToSelector:@selector(prepareClose)]) {
			[activeMainAppViewController prepareClose];
		}
	}
}

- (void)dismissModalViewControllerOnMainViewController {
	UINavigationController *navigationController;

	if (IS_IPHONE) {
		navigationController = [A3AppDelegate instance].currentMainNavigationController;
		[[A3AppDelegate instance].drawerController closeDrawerAnimated:YES completion:nil];
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
		[rootViewController dismissRightSideViewController];

		navigationController = [rootViewController centerNavigationController];
		// KJH
		if (rootViewController.presentViewControllers && [rootViewController.presentViewControllers count] > 0) {
			[rootViewController dismissCenterViewController];
		}
	}

	if (navigationController.presentedViewController) {
		UIViewController *presentedViewController = navigationController.presentedViewController;
		if ([presentedViewController isKindOfClass:[UINavigationController class]]) {
			UINavigationController *presentedNavigationController = (UINavigationController *) presentedViewController;
			UIViewController *targetViewController = presentedNavigationController.viewControllers[0];
			if (![targetViewController isKindOfClass:[A3PasscodeCommonViewController class]]) {
				[targetViewController dismissViewControllerAnimated:NO completion:NULL];
			}
		} else {
			if (![presentedViewController isKindOfClass:[A3PasscodeCommonViewController class]]) {
				[presentedViewController dismissViewControllerAnimated:NO completion:NULL];
			}
		}
	}
}

- (void)popToRootAndPushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	UINavigationController *navigationController;
	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	[appDelegate popStartingAppInfo];
	navigationController = appDelegate.currentMainNavigationController;

	if (IS_IPHONE) {// TODO: mainmenu가 리스트가 아닌경우 처리
		if ([appDelegate isMainMenuStyleList]) {
			[appDelegate.drawerController closeDrawerAnimated:YES completion:nil];
		}
	} else {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
		[rootViewController dismissRightSideViewController];

        // KJH
        if (rootViewController.presentViewControllers && [rootViewController.presentViewControllers count] > 0) {
            [rootViewController dismissCenterViewController];
        }
	}

	// Modal 이 있는 경우, 제거한다.
	if (navigationController.presentedViewController) {
		UIViewController *presentedViewController = navigationController.presentedViewController;
		if ([presentedViewController isKindOfClass:[UINavigationController class]]) {
			UINavigationController *presentedNavigationController = (UINavigationController *) presentedViewController;
			UIViewController *contentViewController = presentedNavigationController.viewControllers[0];
			if (![contentViewController isKindOfClass:[A3PasscodeCommonViewController class]]) {
				[presentedNavigationController dismissViewControllerAnimated:NO completion:nil];
			}
		} else {
			if (![presentedViewController isKindOfClass:[A3PasscodeCommonViewController class]]) {
				[presentedViewController dismissViewControllerAnimated:NO completion:NULL];
			}
		}
	}

    NSMutableArray *currentViewControllers = [[navigationController viewControllers] mutableCopy];
    // Xcode 5로 빌드하고 iOS 8에서 실행했을때, poppedVCs가 nil이 돌아옵니다. 다른 경우는 더 테스트가 필요합니다.
    // 이 경우에는 pop하기 전과 후의 뷰컨트롤러를 비교해서 없어진 뷰 컨트롤러들의 cleanUp을 호출해 주어야 합니다.
    NSArray *poppedVCs = [navigationController popToRootViewControllerAnimated:NO];
    if (![poppedVCs count]) {
        [currentViewControllers removeObjectsInArray:navigationController.viewControllers];
        for (UIViewController<A3CenterViewDelegate> *vc in currentViewControllers) {
            if ([vc respondsToSelector:@selector(cleanUp)]) {
                [vc performSelector:@selector(cleanUp)];
            }
        }
    } else {
        for (UIViewController<A3CenterViewDelegate> *vc in poppedVCs) {
            if ([vc respondsToSelector:@selector(cleanUp)]) {
                [vc performSelector:@selector(cleanUp)];
            }
        }
    }
    
	[navigationController setToolbarHidden:YES];
	[navigationController setNavigationBarHidden:NO animated:NO];

	BOOL hidesNavigationBar = NO;
	UIViewController<A3CenterViewDelegate> *targetViewController = (UIViewController <A3CenterViewDelegate> *) viewController;
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
		UINavigationController *target = [[A3AppDelegate instance] currentMainNavigationController];
		[self showNavigationBarOn:target];
	}
    navigationController.navigationBar.tintColor = [A3AppDelegate instance].themeColor;

	if (IS_IPAD) {
		A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController_iPad];
		[rootViewController animateHideLeftViewForFullScreenCenterView:YES];
	}

    if (viewController) {
        [navigationController pushViewController:viewController animated:animated];
    }
	[[A3AppDelegate instance] didFinishPushViewController];
}

- (void)showNavigationBarOn:(UINavigationController *)targetController {
	FNLOG();
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

	[targetController setNavigationBarHidden:NO animated:YES];
	[targetController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	[targetController.navigationBar setShadowImage:nil];

	[targetController setToolbarHidden:NO];
	[targetController setNavigationBarHidden:YES animated:NO];

	[targetController setToolbarHidden:YES];
	[targetController setNavigationBarHidden:NO animated:NO];
}

- (void)leftBarButtonAppsButton {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apps", @"Apps") style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction:)];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[self.firstResponder resignFirstResponder];
	if (IS_IPHONE) {
		if ([[A3AppDelegate instance] isMainMenuStyleList]) {
			[[A3AppDelegate instance].drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
		} else {
			UINavigationController *navigationController = [A3AppDelegate instance].currentMainNavigationController;
			id<A3ViewControllerProtocol> viewController = (id)[navigationController topViewController];
			[viewController prepareClose];
			[navigationController setNavigationBarHidden:YES];
			[navigationController popViewControllerAnimated:YES];
			[navigationController setToolbarHidden:YES];
			[A3AppDelegate instance].homeStyleMainMenuViewController.activeAppName = nil;
		}
	} else {
		[[[A3AppDelegate instance] rootViewController_iPad] toggleLeftMenuViewOnOff];
	}
}

- (void)leftBarButtonCancelButton {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction:)];
}

- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem {

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

- (void)addFourButtons:(NSArray *)buttons toView:(UIView *)view {
	NSAssert([buttons count] == 4, @"The number of buttons must 4 but it is %lu", (unsigned long)[buttons count]);
	NSInteger numberOfButtons = [buttons count];
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGFloat width = (screenBounds.size.width + 40) / (numberOfButtons + 1);
	NSInteger buttonIndex = 1;
	for (UIButton *button in buttons) {
		[view addSubview:button];

		[button makeConstraints:^(MASConstraintMaker *make) {
			make.bottom.equalTo(view.bottom).with.offset(-10);
			make.width.equalTo(@44.0);
			make.centerX.equalTo(view.left).with.offset(width * buttonIndex - 20);
		}];
		buttonIndex++;
	}
}

- (UIView *)moreMenuViewWithButtons:(NSArray *)buttonsArray {
	CGRect frame;
	frame = self.view.frame;
	frame.size.height = 44.0;
	frame.origin.y = -1.0;
	UIView *moreMenuView = [[UIView alloc] initWithFrame:frame];
	moreMenuView.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0];
    //frame.origin.y += 44.0;
	frame.origin.y += 45.0; // kjh
	frame.size.height = 0.5;    // kjh
	UIView *bottomLineView = [[UIView alloc] initWithFrame:frame];
	bottomLineView.backgroundColor = [UIColor colorWithRed:178.0 / 255.0 green:178.0 / 255.0 blue:178.0 / 255.0 alpha:1.0];
	[moreMenuView addSubview:bottomLineView];

	switch ([buttonsArray count]) {
		case 2:
			[self addTwoButtons:buttonsArray toView:moreMenuView];
			break;
		case 3:
			[self addThreeButtons:buttonsArray toView:moreMenuView];
			break;
		case 4:
			[self addFourButtons:buttonsArray toView:moreMenuView];
			break;
	}

	return moreMenuView;
}

- (UIView *)presentMoreMenuWithButtons:(NSArray *)buttons pullDownView:(UIView *)pullDownView {
	UIView *moreMenuView = [self moreMenuViewWithButtons:buttons];
	CGRect clippingViewFrame = moreMenuView.frame;
	clippingViewFrame.origin.y = 20.0 + 44.0 - 1.0;
    clippingViewFrame.size.height = clippingViewFrame.size.height + 0.5;//kjh
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

		if ([pullDownView isKindOfClass:[UIScrollView class]]) {
			UIScrollView *scrollView = (UIScrollView *) pullDownView;
			UIEdgeInsets insets = scrollView.contentInset;
			insets.top += clippingViewFrame.size.height;
			scrollView.contentInset = insets;

			if (scrollView.contentOffset.y == -64.0) {
				CGPoint offset = scrollView.contentOffset;
				offset.y = -108.0;
				scrollView.contentOffset = offset;
			}
		} else if (pullDownView) {
			CGRect frame = pullDownView.frame;
			frame.origin.y += moreMenuView.bounds.size.height;
			pullDownView.frame = frame;
		}
	}];

	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreMenuDismissAction:)];
	[self.view addGestureRecognizer:gestureRecognizer];
	[self.navigationItem.leftBarButtonItem setEnabled:NO];

	return clippingView;
}

- (void)dismissMoreMenuView:(UIView *)moreMenuView pullDownView:(UIView *)pullDownView completion:(void (^)())completion {
	UIView *menuView = moreMenuView.subviews[0];
    
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = menuView.frame;
		frame = CGRectOffset(frame, 0.0, -44.0);
		menuView.frame = frame;

		if ([pullDownView isKindOfClass:[UIScrollView class]]) {
			UIScrollView *scrollView = (UIScrollView *) pullDownView;
			UIEdgeInsets insets = scrollView.contentInset;
			insets.top -= moreMenuView.frame.size.height;
			scrollView.contentInset = insets;
		} else if (pullDownView) {
			CGRect frame = pullDownView.frame;
			frame.origin.y -= menuView.bounds.size.height;
			pullDownView.frame = frame;
		}
	} completion:^(BOOL finished) {
		[moreMenuView removeFromSuperview];
		[self.navigationItem.leftBarButtonItem setEnabled:YES];
		if (completion) {
			completion();
		}
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

- (UIButton *)historyButton:(Class)managedObjectClass {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"history"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(historyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	if (managedObjectClass) {
		[button setEnabled:[managedObjectClass MR_countOfEntitiesWithContext:[NSManagedObjectContext MR_defaultContext] ] > 0 ];
	}
	return button;
}

- (UIBarButtonItem *)historyBarButton:(Class)managedObjectClass {
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
	[barButtonItem setEnabled:[managedObjectClass MR_countOfEntitiesWithContext:[NSManagedObjectContext MR_defaultContext] ] > 0 ];
	return barButtonItem;
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

- (UIButton *)instructionHelpButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(instructionHelpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (UIBarButtonItem *)instructionHelpBarButton {
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"help"] style:UIBarButtonItemStylePlain target:self action:@selector(instructionHelpButtonAction:)];
	return barButtonItem;
}

- (void)instructionHelpButtonAction:(id)sender {
    [self showInstructionView];
}

- (UIButton *)composeButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"add07"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(composeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
	return button;
}

- (void)composeButtonAction:(UIButton *)button {

}

- (void)rightBarButtonDoneButton {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {

}

- (void)rightButtonMoreButton {
	UIImage *image = [UIImage imageNamed:@"more"];
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

- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items fromBarButtonItem:(UIBarButtonItem *)barButtonItem completionHandler:(UIActivityViewControllerCompletionHandler)completionHandler {
	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
	activityController.completionHandler = completionHandler;
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	} else {
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
		[popoverController presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		return popoverController;
	}
	return nil;
}

- (UIPopoverController *)presentActivityViewControllerWithActivityItems:(id)items fromSubView:(UIView *)subView completionHandler:(UIActivityViewControllerCompletionHandler)completionHandler {
	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    if (!completionHandler) {
        [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
            FNLOG(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
        }];
    }
    else {
        activityController.completionHandler = completionHandler;
    }
    
    
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	} else {
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
        CGRect viewRect = [subView convertRect:subView.bounds toView:self.view];
        [popoverController presentPopoverFromRect:viewRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		return popoverController;
	}
	return nil;
}

+ (UIViewController<A3PasscodeViewControllerProtocol> *)passcodeViewControllerWithDelegate:(id<A3PasscodeViewControllerDelegate>)delegate {
	UIViewController<A3PasscodeViewControllerProtocol> *passcodeViewController;

	if ([[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForUseSimplePasscode]) {
		passcodeViewController = [[A3PasscodeViewController alloc] initWithDelegate:delegate];
	} else {
		passcodeViewController = [[A3PasswordViewController alloc] initWithDelegate:delegate];
	}
	return passcodeViewController;
}

- (void)alertInternetConnectionIsNotAvailable {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
														message:NSLocalizedString(@"Internet connection is not available.", nil)
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

- (void)willDismissFromRightSide
{

}
- (void)alertCloudNotEnabled {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"iCloud", @"iCloud")
														message:NSLocalizedString(@"iCloud_goto_settings", @"Please goto Settings of your device. Enable iCloud and Documents and Data storages in your Settings to gain access to this feature.")
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

- (UIActionSheet *)actionSheetAskingImagePickupWithDelete:(BOOL)deleteEnable delegate:(id <UIActionSheetDelegate>)delegate {
    UIActionSheet *actionSheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:delegate
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:deleteEnable ? NSLocalizedString(@"Delete Photo", nil) : nil
                                         otherButtonTitles:NSLocalizedString(@"Take Photo", nil),
                       NSLocalizedString(@"Choose Existing", nil),
                       NSLocalizedString(@"Choose and Resize", nil), nil];
        
    }
    else {
        if (deleteEnable) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:delegate
                                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                        destructiveButtonTitle:NSLocalizedString(@"Delete Photo", nil)
                                             otherButtonTitles:
                           NSLocalizedString(@"Choose Existing", nil),
                           NSLocalizedString(@"Choose and Resize", nil), nil];
        }
        else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:delegate
                                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:NSLocalizedString(@"Choose Existing", nil),
                           NSLocalizedString(@"Choose and Resize", nil), nil];
        }
    }

	return actionSheet;
}

#pragma mark - Custom Date String Related

- (NSString *)fullStyleDateStringFromDate:(NSDate *)date withShortTime:(BOOL)shortTime
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterFullStyle;
    if (shortTime) {
        formatter.timeStyle = NSDateFormatterShortStyle;
    }
    
    return [formatter stringFromDate:date];
}

- (NSString *)customFullStyleDateStringFromDate:(NSDate *)date withShortTime:(BOOL)shortTime
{
    NSDateFormatter *formatter = [NSDateFormatter new];

    if ([NSDate isFullStyleLocale]) {
        formatter.dateStyle = NSDateFormatterFullStyle;
        if (shortTime) {
            formatter.timeStyle = NSDateFormatterShortStyle;
        }
    }
    else {
        if (shortTime) {
            formatter.dateFormat = [formatter customFullWithTimeStyleFormat];
        }
        else {
            formatter.dateFormat = [formatter customFullStyleFormat];
        }
    }

    return [formatter stringFromDate:date];
}

#pragma mark - Instruction

- (void)showInstructionView {
    
}

#pragma mark - Share Format

- (NSString *)shareMailMessageWithHeader:(NSString *)header contents:(NSString *)contents tail:(NSString *)tail {
	NSMutableString *txt = [NSMutableString new];
	[txt appendFormat:@"<html><body>%@<br/><br/>", header];
	[txt appendString:contents];

	[txt appendFormat:[self shareMessageFormat], tail];
	return txt;
}

/*! [NSString stringWithFormat:] 에서 사용할 수 있는 문자열을 돌려주며, 하나의 파라메터를 허용하는 포맷으로, 파라메터로는 공유할 내용을 전달함
 * \param 없음
 * \returns
 */
- (NSString *)shareMessageFormat {
	return [NSString stringWithFormat:@"<br/>%%@<br/>%@", [self commonShareFooter]];
}

- (NSString *)commonShareFooter {
	return [NSString stringWithFormat:@"<img style='border:0;' src='http://apns.allaboutapps.net/allaboutapps/appboxIcon60.png' alt='AppBox Pro'><br/><a href='https://itunes.apple.com/app/id318404385'>%@</a></body></html>",
									  NSLocalizedString(@"Download from AppStore", nil)];
}

- (NSString *)appITunesURL {
	return @"https://itunes.apple.com/app/id318404385";
}

- (void)alertLocationDisabled {
	NSString *message = ![CLLocationManager locationServicesEnabled] ? NSLocalizedString(@"Location Services not enabled. Go to Settings > Privacy > Location Services. Location services must enabled and AppBox Pro authorized to show weather.", nil) :
			NSLocalizedString(@"Location services enabled, but AppBox Pro is not authorized to access location services. Go to Settings > Privacy > Location Services and authorize it to show weather.", nil);
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
	[alertView show];
}

- (UIActionSheet *)firstActionSheet {
	return objc_getAssociatedObject(self, key_firstActionSheet);
}

- (void)setFirstActionSheet:(UIActionSheet *)actionSheet {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if (actionSheet) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateFirstActionSheet) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
	objc_setAssociatedObject(self, key_firstActionSheet, actionSheet, OBJC_ASSOCIATION_ASSIGN);
}

- (void)rotateFirstActionSheet {
    [[self firstActionSheet] dismissWithClickedButtonIndex:[self.firstActionSheet cancelButtonIndex] animated:NO];
}

- (BOOL)resignFirstResponder {
	[self.firstResponder resignFirstResponder];
	return [super resignFirstResponder];
}

- (void)requestAuthorizationForCamera:(NSString *)appName {
	if (IS_IOS7) return;
	AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	if (authorizationStatus == AVAuthorizationStatusAuthorized) return;
	if (authorizationStatus == AVAuthorizationStatusNotDetermined) {
		[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:nil];
		return;
	}
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Camera access denied", nil)
																			 message:[NSString stringWithFormat:NSLocalizedString(@"%@ requires camera access.", nil), appName]
																	  preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
														style:UIAlertActionStyleCancel
													  handler:NULL]];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(A3AppName_Settings, nil)
														style:UIAlertActionStyleDefault
													  handler:^(UIAlertAction *action) {
														  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
													  }]];
	[self presentViewController:alertController
					   animated:YES
					 completion:NULL];
}

- (void)presentWebViewControllerWithURL:(NSURL *)url {
	if (![[A3AppDelegate instance].reachability isReachable]) {
		[self alertInternetConnectionIsNotAvailable];
		return;
	}
	A3BasicWebViewController *viewController = [[A3BasicWebViewController alloc] init];
	viewController.url = url;
	if (IS_IPHONE) {
		[self.navigationController pushViewController:viewController animated:YES];
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[[[A3AppDelegate instance] rootViewController_iPad] presentViewController:navigationController animated:YES completion:NULL];
	}
}

#pragma mark -- Setup Banner view for gathering information

/**
 *  Create GADBannerView with given unitID, keywords, and gender
 *
 *  @param unitID   AdMob ad unit id
 *  @param keywords keywords list
 *  @param gender   gender information
 */
- (void)setupBannerViewForAdUnitID:(NSString *)unitID keywords:(NSArray *)keywords gender:(GADGender)gender adSize:(GADAdSize)adSize {
	if (![[A3AppDelegate instance] shouldPresentAd]) return;

	GADRequest *adRequest = [GADRequest request];
	adRequest.keywords = keywords;
	adRequest.gender = gender;

	GADBannerView *bannerView = [GADBannerView new];
	bannerView.adUnitID = unitID;
	bannerView.rootViewController = self;
	bannerView.adSize = adSize;
	bannerView.delegate = (id<GADBannerViewDelegate>)self;
	[bannerView loadRequest:adRequest];
	objc_setAssociatedObject(self, key_adBannerView, bannerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setupBannerViewForAdUnitID:(NSString *)unitID keywords:(NSArray *)keywords gender:(GADGender)gender {
	if (![[A3AppDelegate instance] shouldPresentAd]) return;

	[self setupBannerViewForAdUnitID:unitID keywords:keywords gender:gender adSize:kGADAdSizeBanner];
}

- (void)setupBannerViewForAdUnitID:(NSString *)unitID keywords:(NSArray *)keywords {
	if (![[A3AppDelegate instance] shouldPresentAd]) return;

	[self setupBannerViewForAdUnitID:unitID keywords:keywords gender:kGADGenderUnknown adSize:kGADAdSizeBanner];
}

/**
 *  광고를 받으면 폐기한다.
 *  현재 이 요청의 목적은 광고 수요를 파악하는데 있으므로, 광고를 게재하지는 않는다.
 *
 *  @param bannerView <#bannerView description#>
 */
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
	[bannerView removeFromSuperview];
	objc_setAssociatedObject(self, key_adBannerView, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
	FNLOG(@"%@", error.localizedDescription);
}

- (GADBannerView *)bannerView {
	return objc_getAssociatedObject(self, key_adBannerView);
}

@end
