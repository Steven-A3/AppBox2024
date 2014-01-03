//
//  A3PasscodeViewControllerProtocol.h
//  AppBox3
//
//  Created by A3 on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#ifndef AppBox3_A3PasscodeViewControllerProtocol_h
#define AppBox3_A3PasscodeViewControllerProtocol_h

@protocol A3PasscodeViewControllerDelegate <NSObject>
@optional
- (void)passcodeViewControllerWasDismissedWithSuccess:(BOOL)success;
- (void)maxNumberOfFailedAttemptsReached;
- (void)passcodeViewDidDisappear;
@end

@protocol A3PasscodeViewControllerProtocol <NSObject>
@optional

- (void)showLockscreenWithAnimation:(BOOL)animated showCacelButton:(BOOL)showCancelButton;
- (void)showLockscreenInViewController:(UIViewController *)viewController;
- (void)showForEnablingPasscodeInViewController:(UIViewController *)viewController;
- (void)showForChangingPasscodeInViewController:(UIViewController *)viewController;
- (void)showForTurningOffPasscodeInViewController:(UIViewController *)viewController;

@end

#endif
