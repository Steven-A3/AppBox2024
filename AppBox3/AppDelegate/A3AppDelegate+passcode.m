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

NSString *const kUserDefaultTimerStart = @"AppBoxPasscodeTimerStart";
NSString *const kUserDefaultsKeyForTimerDuration = @"passcodeTimerDuration";
NSString *const kUserDefaultsKeyForPasscodeTime = @"passcodeRequirePasscodeFor";
NSString *const kUserDefaultsKeyForUseSimplePasscode = @"passcodeUseSimplePasscode";
NSString *const kUserDefaultsKeyForAskPasscodeForStarting = @"passcodeAskPasscodeForStarting";
NSString *const kUserDefaultsKeyForAskPasscodeForSettings = @"passcodeAskPasscodeForSettings";
NSString *const kUserDefaultsKeyForAskPasscodeForDaysCounter = @"passcodAskPasscodeForDaysCounter";
NSString *const kUserDefaultsKeyForAskPasscodeForLadyCalendar = @"passcodeAskPasscodeForLadyCalendar";
NSString *const kUserDefaultsKeyForAskPasscodeForWallet = @"passcodeAskPasscodeForWallet";

@implementation A3AppDelegate (passcode)

- (CGFloat)timerDuration {
	return [[NSUserDefaults standardUserDefaults] floatForKey: kUserDefaultsKeyForTimerDuration];
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

#pragma mark - Notification Observers

- (void)applicationDidEnterBackground_passcode {

}


- (void)applicationDidBecomeActive_passcode {

}

- (void)applicationWillEnterForeground_passcode {
	if ([A3KeychainUtils getPassword] && [self didPasscodeTimerEnd]) {
		UIViewController *visibleViewController = [self visibleViewController];
		if ([visibleViewController isKindOfClass:[A3PasscodeViewController class]]) {
			[(A3PasscodeViewController *) visibleViewController showLockscreenWithAnimation:YES showCacelButton:NO ];
		} else {
			A3PasscodeViewController *passcodeViewController = [[A3PasscodeViewController alloc] init];
			[passcodeViewController showLockscreenWithAnimation:YES showCacelButton:NO ];
		}
	}
}

- (void)applicationWillResignActive_passcode {
	if ([A3KeychainUtils getPassword]) {
		[self saveTimerStartTime];
	}
}

@end
