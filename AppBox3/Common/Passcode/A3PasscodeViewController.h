//
//  A3PasscodeViewController.h
//  AppBox3
//
//  Created by A3 on 12/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3PasscodeViewControllerProtocol.h"

@interface A3PasscodeViewController : UIViewController <A3PasscodeViewControllerProtocol> {
	UIView *_animatingView;
	UITextField *_firstDigitTextField;
	UITextField *_secondDigitTextField;
	UITextField *_thirdDigitTextField;
	UITextField *_fourthDigitTextField;
	UITextField *_passcodeTextField;
	UILabel *_failedAttemptLabel;
	UILabel *_enterPasscodeLabel;
	int _failedAttempts;
	BOOL _isUserConfirmingPasscode;
	BOOL _isUserBeingAskedForNewPasscode;
	BOOL _isUserTurningPasscodeOff;
	BOOL _isUserChangingPasscode;
	BOOL _isUserEnablingPasscode;
	BOOL _beingDisplayedAsLockscreen;
	NSString *_tempPasscode;
	BOOL _timerStartInSeconds;
}

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, weak) id<A3PasscodeViewControllerDelegate> delegate;
@property (assign) BOOL isCurrentlyOnScreen;

- (id)initWithDelegate:(id <A3PasscodeViewControllerDelegate>)delegate;

- (void)prepareAsLockscreen;
- (void)prepareForChangingPasscode;
- (void)prepareForTurningOffPasscode;
- (void)prepareForEnablingPasscode;

@end
