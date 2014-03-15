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
#import "A3UIDevice.h"
#import "UIViewController+MMDrawerController.h"

NSString *const kUserDefaultTimerStart = @"AppBoxPasscodeTimerStart";
NSString *const kUserDefaultsKeyForPasscodeTimerDuration = @"passcodeTimerDuration";
NSString *const kUserDefaultsKeyForUseSimplePasscode = @"passcodeUseSimplePasscode";
NSString *const kUserDefaultsKeyForAskPasscodeForStarting = @"passcodeAskPasscodeForStarting";
NSString *const kUserDefaultsKeyForAskPasscodeForSettings = @"passcodeAskPasscodeForSettings";
NSString *const kUserDefaultsKeyForAskPasscodeForDaysCounter = @"passcodAskPasscodeForDaysCounter";
NSString *const kUserDefaultsKeyForAskPasscodeForLadyCalendar = @"passcodeAskPasscodeForLadyCalendar";
NSString *const kUserDefaultsKeyForAskPasscodeForWallet = @"passcodeAskPasscodeForWallet";

@implementation A3AppDelegate (passcode)

- (double)timerDuration {
	return [[NSUserDefaults standardUserDefaults] doubleForKey:kUserDefaultsKeyForPasscodeTimerDuration];
}


- (NSTimeInterval)timerStartTime {
	NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultTimerStart];
	if (!date) return -1;
	return [date timeIntervalSinceReferenceDate];
}


- (void)saveTimerStartTime {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUserDefaultTimerStart];
}


- (BOOL)didPasscodeTimerEnd {
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	// startTime wasn't saved yet (first app use and it crashed, phone force closed, etc) if it returns -1.
	if (now - [self timerStartTime] >= [self timerDuration] || [self timerStartTime] == -1) return YES;
	return NO;
}


- (BOOL)isSimplePasscode {
	NSNumber *obj = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyForUseSimplePasscode];
	if (obj) {
		return [obj boolValue];
	}
	return YES;
}

- (void)showLockScreen {
	NSNumber *flag = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyForAskPasscodeForStarting];

	if ((!flag || [flag boolValue]) && [A3KeychainUtils getPassword] && [self didPasscodeTimerEnd]) {
		if (!self.passcodeViewController) {
			self.passcodeViewController = [UIViewController passcodeViewControllerWithDelegate:self];
			[self.passcodeViewController showLockscreenWithAnimation:NO showCacelButton:NO];
		}
	}
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
	if ([A3KeychainUtils getPassword] && [self didPasscodeTimerEnd]) {
		UIViewController *topViewController = [[self navigationController] topViewController];
		UIView *coverView = [topViewController.view viewWithTag:8080];
		[coverView removeFromSuperview];
	}
}

- (void)applicationWillEnterForeground_passcode {
	[self showLockScreen];
}

- (void)applicationWillResignActive_passcode {
	return;

	if ([A3KeychainUtils getPassword]) {
		[self saveTimerStartTime];

		if (!self.passcodeViewController) {
			UIViewController *topViewController = [[self navigationController] topViewController];
			UIView *coverView = [UIView new];
			coverView.tag = 8080;
			coverView.backgroundColor = [UIColor whiteColor];
			coverView.frame = [topViewController.view bounds];
			FNLOGRECT(coverView.frame);
			coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[topViewController.view addSubview:coverView];
		}
	}
}

- (void)passcodeViewControllerWasDismissedWithSuccess:(BOOL)success {
	self.passcodeViewController = nil;
}

- (void)passcodeViewDidDisappearWithSuccess:(BOOL)success {
	self.passcodeViewController = nil;
}

- (BOOL)askPasscodeForStarting {
	NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyForAskPasscodeForStarting];
	if (number) {
		return [number boolValue];
	} else {
		// Initialize Value with NO
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForAskPasscodeForStarting];
		[[NSUserDefaults standardUserDefaults] synchronize];
		return NO;
	}
}

- (void)setEnableAskPasscodeForStarting:(BOOL)enable {
	[[NSUserDefaults standardUserDefaults] setBool:enable forKey:kUserDefaultsKeyForAskPasscodeForStarting];
	[[NSUserDefaults standardUserDefaults] setBool:!enable forKey:kUserDefaultsKeyForAskPasscodeForSettings];
	[[NSUserDefaults standardUserDefaults] setBool:!enable forKey:kUserDefaultsKeyForAskPasscodeForDaysCounter];
	[[NSUserDefaults standardUserDefaults] setBool:!enable forKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar];
	[[NSUserDefaults standardUserDefaults] setBool:!enable forKey:kUserDefaultsKeyForAskPasscodeForWallet];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)askPasscodeForSettings {
	return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForSettings];
}

- (BOOL)askPasscodeForDaysCounter {
	return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForDaysCounter];
}

- (BOOL)askPasscodeForLadyCalendar {
	return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar];
}

- (BOOL)askPasscodeForWallet {
	return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForWallet];
}

@end
