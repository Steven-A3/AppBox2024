//
//  A3AppDelegate+passcode.h
//  AppBox3
//
//  Created by A3 on 12/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate.h"

@interface A3AppDelegate (passcode) <A3PasscodeViewControllerDelegate>

- (BOOL)didPasscodeTimerEnd;
- (void)saveTimerStartTime;
- (BOOL)isSimplePasscode;

- (BOOL)useTouchID;

- (void)setUseTouchID:(BOOL)use;

- (BOOL)showLockScreen;

- (void)presentLockScreen;

- (BOOL)shouldProtectScreen;

- (void)applicationDidEnterBackground_passcode;
- (void)applicationDidBecomeActive_passcode;
- (void)applicationWillEnterForeground_passcode;
- (void)applicationWillResignActive_passcode;

- (void)addSecurityCoverView;

- (void)removeSecurityCoverView;

- (BOOL)shouldAskPasscodeForStarting;

- (void)setEnableAskPasscodeForStarting:(BOOL)enable;

- (void)initializePasscodeUserDefaults;

- (BOOL)shouldAskPasscodeForSettings;

- (BOOL)shouldAskPasscodeForDaysCounter;

- (BOOL)shouldAskPasscodeForLadyCalendar;

- (BOOL)shouldAskPasscodeForWallet;

- (double)timerDuration;

@end

CGFloat UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation);
UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation);
