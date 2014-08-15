//
//  A3AppDelegate+passcode.m
//  AppBox3
//
//  Created by A3 on 12/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate+passcode.h"
#import "A3PasscodeViewController.h"
#import "A3KeychainUtils.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+MMDrawerController.h"
#import "A3SettingsViewController.h"
#import "A3DaysCounterSlideShowMainViewController.h"
#import "A3DaysCounterCalendarListMainViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "A3DaysCounterFavoriteListViewController.h"
#import "A3LadyCalendarViewController.h"
#import "A3WalletMainTabBarController.h"
#import "A3UserDefaults.h"

@implementation A3AppDelegate (passcode)

- (double)timerDuration {
	return [[A3UserDefaults standardUserDefaults] doubleForKey:kUserDefaultsKeyForPasscodeTimerDuration];
}

- (NSTimeInterval)timerStartTime {
	NSDate *date = [[A3UserDefaults standardUserDefaults] objectForKey:kUserDefaultTimerStart];
	if (!date) return -1;
	return [date timeIntervalSinceReferenceDate];
}


- (void)saveTimerStartTime {
	[[A3UserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUserDefaultTimerStart];
	FNLOG(@"**************************************************************");
	FNLOG(@"%@", [NSDate date]);
	FNLOG(@"**************************************************************");
}

- (BOOL)didPasscodeTimerEnd {
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	// startTime wasn't saved yet (first app use and it crashed, phone force closed, etc) if it returns -1.
	if (now - [self timerStartTime] >= [self timerDuration] || [self timerStartTime] == -1) return YES;
	return NO;
}

- (BOOL)isSimplePasscode {
	NSNumber *obj = [[A3UserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyForUseSimplePasscode];
	if (obj) {
		return [obj boolValue];
	}
	return YES;
}

- (void)showLockScreen {

	BOOL passwordEnabled = [A3KeychainUtils getPassword] != nil;
	BOOL passcodeTimerEnd = [self didPasscodeTimerEnd];

	if (!passwordEnabled || !passcodeTimerEnd) return;

	BOOL presentLockScreen = [self shouldProtectScreen];
	if (presentLockScreen) {
		if (!self.passcodeViewController) {
			self.passcodeViewController = [UIViewController passcodeViewControllerWithDelegate:self];
			[self.passcodeViewController showLockscreenWithAnimation:NO showCacelButton:NO];
		}
	}
}

- (BOOL)shouldProtectScreen {
	BOOL presentLockScreen = NO;
	BOOL shouldAskForStarting = [[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForStarting];
	if (shouldAskForStarting) {
		presentLockScreen = YES;
	} else {
		UINavigationController *navigationController = self.navigationController;
		if ([navigationController.viewControllers count] >= 2) {
			id activeViewController = navigationController.viewControllers[1];
			if ([activeViewController isKindOfClass:[A3SettingsViewController class]]) {
				presentLockScreen = [self shouldAskPasscodeForSettings];
			} else if ([activeViewController isKindOfClass:[A3DaysCounterSlideShowMainViewController class]] ||
					[activeViewController isKindOfClass:[A3DaysCounterCalendarListMainViewController class]] ||
					[activeViewController isKindOfClass:[A3DaysCounterReminderListViewController class]] ||
					[activeViewController isKindOfClass:[A3DaysCounterFavoriteListViewController class]] )
			{
				presentLockScreen = [self shouldAskPasscodeForDaysCounter];
			} else if ([activeViewController isKindOfClass:[A3LadyCalendarViewController class]]) {
				presentLockScreen = [self shouldAskPasscodeForLadyCalendar];
			} else if ([activeViewController isKindOfClass:[A3WalletMainTabBarController class]]) {
				presentLockScreen = [self shouldAskPasscodeForWallet];
			}
		}
	}
	return presentLockScreen;
}

#pragma mark - Notification Observers

- (void)applicationDidEnterBackground_passcode {
	if (IS_IPHONE) {
		[self.drawerController closeDrawerAnimated:NO completion:nil];
	} else {
		if (IS_PORTRAIT && self.rootViewController.showLeftView) {
			[self.rootViewController toggleLeftMenuViewOnOff];
		}
	}
}

- (void)applicationDidBecomeActive_passcode {
	[self removeSecurityCoverView];
}

- (void)applicationWillEnterForeground_passcode {
	[self showLockScreen];

	[self removeSecurityCoverView];
}

- (void)applicationWillResignActive_passcode {
	if ([A3KeychainUtils getPassword] && [self shouldProtectScreen]) {
		FNLOG(@"CoverView added to Window");
		[[UIApplication sharedApplication] ignoreSnapshotOnNextApplicationLaunch];

		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		self.coverView = [[UIImageView alloc] initWithFrame:screenBounds];
		self.coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.coverView.image = [UIImage imageNamed:[self getLaunchImageName]];
		[self.window addSubview:self.coverView];

		[self rotateAccordingToStatusBarOrientationAndSupportedOrientations];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(statusBarFrameOrOrientationChanged:)
													 name:UIApplicationDidChangeStatusBarOrientationNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
	}
	return;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
	return NO;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
	NSNumber *flag = [[A3UserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyForAskPasscodeForStarting];

	if ([flag boolValue] && [A3KeychainUtils getPassword]) {
		[application ignoreSnapshotOnNextApplicationLaunch];
	}
	return NO;
}

- (void)removeSecurityCoverView {
	if (self.coverView) {
		[self.coverView removeFromSuperview];
		self.coverView = nil;

		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
	}
}

- (void)passcodeViewControllerWasDismissedWithSuccess:(BOOL)success {
	self.passcodeViewController = nil;
}

- (void)passcodeViewDidDisappearWithSuccess:(BOOL)success {
	self.passcodeViewController = nil;
}

- (BOOL)shouldAskPasscodeForStarting {
	NSNumber *number = [[A3UserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyForAskPasscodeForStarting];
	if (number) {
		return [number boolValue];
	} else {
		// Initialize Value with NO
		[[A3UserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForAskPasscodeForStarting];
		[[A3UserDefaults standardUserDefaults] synchronize];
		return NO;
	}
}

- (void)setEnableAskPasscodeForStarting:(BOOL)enable {
	[[A3UserDefaults standardUserDefaults] setBool:enable forKey:kUserDefaultsKeyForAskPasscodeForStarting];
	[[A3UserDefaults standardUserDefaults] setBool:!enable forKey:kUserDefaultsKeyForAskPasscodeForSettings];
	[[A3UserDefaults standardUserDefaults] setBool:!enable forKey:kUserDefaultsKeyForAskPasscodeForDaysCounter];
	[[A3UserDefaults standardUserDefaults] setBool:!enable forKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar];
	[[A3UserDefaults standardUserDefaults] setBool:!enable forKey:kUserDefaultsKeyForAskPasscodeForWallet];
	[[A3UserDefaults standardUserDefaults] synchronize];
}

- (void)registerPasscodeUserDefaults {
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsKeyForAskPasscodeForStarting];
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsKeyForAskPasscodeForSettings];
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsKeyForAskPasscodeForDaysCounter];
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar];
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsKeyForAskPasscodeForWallet];
	[[A3UserDefaults standardUserDefaults] synchronize];
}

- (BOOL)shouldAskPasscodeForSettings {
	return [[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForSettings];
}

- (BOOL)shouldAskPasscodeForDaysCounter {
	return [[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForDaysCounter];
}

- (BOOL)shouldAskPasscodeForLadyCalendar {
	return [[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar];
}

- (BOOL)shouldAskPasscodeForWallet {
	return [[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForWallet];
}

#pragma mark - Security Cover View orientation change handling

- (NSUInteger)supportedInterfaceOrientations {
	if (IS_IPHONE) {
		return UIInterfaceOrientationMaskPortrait;
	} else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification {
	/*
	 This notification is most likely triggered inside an animation block,
	 therefore no animation is needed to perform this nice transition.
	 */
	[self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
}


// And to his AGWindowView: https://github.com/hfossli/AGWindowView
// Without the 'desiredOrientation' method, using showLockscreen in one orientation,
// then presenting it inside a modal in another orientation would display the view in the first orientation.
- (UIInterfaceOrientation)desiredOrientation {
	UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	UIInterfaceOrientationMask statusBarOrientationAsMask = UIInterfaceOrientationMaskFromOrientation(statusBarOrientation);
	if(self.supportedInterfaceOrientations & statusBarOrientationAsMask) {
		return statusBarOrientation;
	}
	else {
		if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
			return UIInterfaceOrientationPortrait;
		}
		else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
			return UIInterfaceOrientationLandscapeLeft;
		}
		else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
			return UIInterfaceOrientationLandscapeRight;
		}
		else {
			return UIInterfaceOrientationPortraitUpsideDown;
		}
	}
}

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations {
	UIInterfaceOrientation orientation = [self desiredOrientation];
	CGFloat angle = UIInterfaceOrientationAngleOfOrientation(orientation);
	CGAffineTransform transform = CGAffineTransformMakeRotation(angle);

	[self setIfNotEqualTransform: transform
						   frame: self.coverView.window.bounds];
}


- (void)setIfNotEqualTransform:(CGAffineTransform)transform frame:(CGRect)frame {
	if(!CGAffineTransformEqualToTransform(self.coverView.transform, transform)) {
		self.coverView.transform = transform;
	}
	if(!CGRectEqualToRect(self.coverView.frame, frame)) {
		self.coverView.frame = frame;
	}
}


CGFloat UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation) {
	CGFloat angle;

	switch (orientation) {
		case UIInterfaceOrientationPortraitUpsideDown:
			angle = M_PI;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			angle = -M_PI_2;
			break;
		case UIInterfaceOrientationLandscapeRight:
			angle = M_PI_2;
			break;
		default:
			angle = 0.0;
			break;
	}

	return angle;
}

UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation) {
	return 1 << orientation;
}

@end
