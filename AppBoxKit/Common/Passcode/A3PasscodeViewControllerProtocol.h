//
//  A3PasscodeViewControllerProtocol.h
//  AppBox3
//
//  Created by A3 on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

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
- (void)showLockScreenWithAnimation:(BOOL)animated showCacelButton:(BOOL)showCancelButton inViewController:(UIViewController *)rootViewController ;
- (void)showLockScreenInViewController:(UIViewController *)viewController completion:(void(^)(BOOL success))completion;
- (void)showForEnablingPasscodeInViewController:(UIViewController *)viewController;
- (void)showForChangingPasscodeInViewController:(UIViewController *)viewController;
- (void)showForTurningOffPasscodeInViewController:(UIViewController *)viewController;
- (void)cancelAndDismissMe;

@end
