//
//  A3AppDelegate+passcode.h
//  AppBox3
//
//  Created by A3 on 12/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate.h"

@interface A3AppDelegate (passcode)

- (BOOL)didPasscodeTimerEnd;
- (void)saveTimerStartTime;
- (BOOL)isSimplePasscode;
- (void)applicationDidEnterBackground_passcode;
- (void)applicationDidBecomeActive_passcode;
- (void)applicationWillEnterForeground_passcode;
- (void)applicationWillResignActive_passcode;
- (CGFloat)timerDuration;

@end

extern NSString *const kUserDefaultTimerStart;
extern NSString *const kUserDefaultsKeyForTimerDuration;
extern NSString *const kUserDefaultsKeyForPasscodeTime;
extern NSString *const kUserDefaultsKeyForUseSimplePasscode;
extern NSString *const kUserDefaultsKeyForAskPasscodeForStarting;
extern NSString *const kUserDefaultsKeyForAskPasscodeForSettings;
extern NSString *const kUserDefaultsKeyForAskPasscodeForDaysCounter;
extern NSString *const kUserDefaultsKeyForAskPasscodeForLadyCalendar;
extern NSString *const kUserDefaultsKeyForAskPasscodeForWallet;
