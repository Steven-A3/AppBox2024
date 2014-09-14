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
- (void)passcodeViewControllerDidDismissWithSuccess:(BOOL)success;
- (void)maxNumberOfFailedAttemptsReached;
- (void)passcodeViewDidDisappearWithSuccess:(BOOL)success;

- (NSString *)encryptionKeyHintStringForEncryptionKeyCheckViewController;
- (BOOL)verifyEncryptionKeyEncryptionKeyCheckViewController:(NSString *)key;

@end

@protocol A3PasscodeViewControllerProtocol <NSObject>
@optional

- (void)showLockScreenWithAnimation:(BOOL)animated showCacelButton:(BOOL)showCancelButton;
- (void)showLockScreenInViewController:(UIViewController *)viewController;
- (void)showForEnablingPasscodeInViewController:(UIViewController *)viewController;
- (void)showForChangingPasscodeInViewController:(UIViewController *)viewController;
- (void)showForTurningOffPasscodeInViewController:(UIViewController *)viewController;
- (void)cancelAndDismissMe;

@end

#endif
