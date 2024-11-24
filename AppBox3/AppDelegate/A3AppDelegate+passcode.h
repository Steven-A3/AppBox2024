//
//  A3AppDelegate+passcode.h
//  AppBox3
//
//  Created by A3 on 12/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate.h"

@interface A3AppDelegate (passcode) <A3PasscodeViewControllerDelegate, A3DataMigrationManagerDelegate>

- (BOOL)didPasscodeTimerEnd;
- (BOOL)isSimplePasscode;
- (BOOL)useTouchID;
- (void)setUseTouchID:(BOOL)use;
- (void)showLockScreenWithCompletion:(void (^)(BOOL showLockScreen))completion;

- (void)presentLockScreenShowCancelButton:(BOOL)showCancelButton;
- (BOOL)shouldProtectScreen;
- (void)applicationDidEnterBackground_passcode;

- (void)applicationDidBecomeActive_passcodeAfterLaunch:(BOOL)isAfterLaunch;
- (void)applicationWillEnterForeground_passcode;
- (void)applicationWillResignActive_passcode;
- (void)addSecurityCoverView;
- (void)removeSecurityCoverView;
- (BOOL)requirePasscodeForStartingApp;
- (BOOL)shouldAskPasscodeForStarting;
- (void)setEnableAskPasscodeForStarting:(BOOL)enable;
- (void)initializePasscodeUserDefaults;
- (BOOL)shouldAskPasscodeForSettings;
- (BOOL)shouldAskPasscodeForDaysCounter;
- (BOOL)shouldAskPasscodeForLadyCalendar;
- (BOOL)shouldAskPasscodeForWallet;
- (double)timerDuration;
- (void)handleRemoveSecurityCoverView;

@end

CGFloat UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation);
UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation);
