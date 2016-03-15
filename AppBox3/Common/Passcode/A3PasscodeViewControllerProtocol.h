//
//  A3PasscodeViewControllerProtocol.h
//  AppBox3
//
//  Created by A3 on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

@protocol A3PasscodeViewControllerDelegate <NSObject>
@optional
- (void)passcodeViewControllerDidDismissWithSuccess:(BOOL)success;
- (void)maxNumberOfFailedAttemptsReached;
- (void)passcodeViewDidDisappearWithSuccess:(BOOL)success;

- (NSString *)encryptionKeyHintStringForEncryptionKeyCheckViewController;
- (BOOL)verifyEncryptionKeyEncryptionKeyCheckViewController:(NSString *)key;

@end

@protocol A3PasscodeViewControllerProtocol <NSObject>

@property (weak, nonatomic) id<A3PasscodeViewControllerDelegate> delegate;

@optional
- (void)showLockScreenWithAnimation:(BOOL)animated showCacelButton:(BOOL)showCancelButton;
- (void)showLockScreenInViewController:(UIViewController *)viewController;
- (void)showForEnablingPasscodeInViewController:(UIViewController *)viewController;
- (void)showForChangingPasscodeInViewController:(UIViewController *)viewController;
- (void)showForTurningOffPasscodeInViewController:(UIViewController *)viewController;
- (void)cancelAndDismissMe;

@end
