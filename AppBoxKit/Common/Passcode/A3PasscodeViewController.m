//
//  A3PasscodeViewController.m
//  AppBox3
//
//  Created by A3 on 12/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3PasscodeViewController.h"
#import "A3AppDelegate+passcode.h"
#import "A3KeychainUtils.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3NumberKeyboardViewController.h"
#import "A3UserDefaultsKeys.h"
#import "A3UserDefaults.h"
#import "A3UIDevice.h"
#import "AppBoxKit/AppBoxKit-Swift.h"

static NSString *const kPasscodeCharacter = @"\u2014"; // A longer "-"
static CGFloat const kPasscodeFontSize = 33.0f;
static CGFloat const kFontSizeModifier = 1.5f;
static CGFloat const kiPhoneHorizontalGap = 40.0f;
//static CGFloat const kLockAnimationDuration = 0.15f;
static CGFloat const kSlideAnimationDuration = 0.15f;
// Set to 0 if you want to skip the check. If you don't, nothing happens,
// just maxNumberOfAllowedFailedAttempts protocol method is checked for and called.
static NSInteger const kMaxNumberOfAllowedFailedAttempts = 10;

// Gaps
// To have a properly centered Passcode, the horizontal gap difference between iPhone and iPad
// must have the same ratio as the font size difference between them.
#define kHorizontalGap ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? kiPhoneHorizontalGap * kFontSizeModifier : kiPhoneHorizontalGap)
#define kVerticalGap ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 60.0f : 25.0f)
#define kModifierForBottomVerticalGap ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 2.6f : 3.0f)
// Text Sizes
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define kPasscodeCharWidth [kPasscodeCharacter sizeWithAttributes: @{NSFontAttributeName : kPasscodeFont}].width
#define kFailedAttemptLabelWidth ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? [_failedAttemptLabel.text sizeWithAttributes: @{NSFontAttributeName : kLabelFont}].width + 60.0f : [_failedAttemptLabel.text sizeWithAttributes: @{NSFontAttributeName : kLabelFont}].width + 30.0f)
#define kFailedAttemptLabelHeight [_failedAttemptLabel.text sizeWithAttributes: @{NSFontAttributeName : kLabelFont}].height
#define kEnterPasscodeLabelWidth [_enterPasscodeLabel.text sizeWithAttributes: @{NSFontAttributeName : kLabelFont}].width
#else
// Thanks to Kent Nguyen - https://github.com/kentnguyen
	#define kPasscodeCharWidth [kPasscodeCharacter sizeWithFont:kPasscodeFont].width
	#define kFailedAttemptLabelWidth ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? [_failedAttemptLabel.text sizeWithFont:kLabelFont].width + 60.0f : [_failedAttemptLabel.text sizeWithFont:kLabelFont].width + 30.0f)
	#define kFailedAttemptLabelHeight [_failedAttemptLabel.text sizeWithFont:kLabelFont].height
	#define kEnterPasscodeLabelWidth [_enterPasscodeLabel.text sizeWithFont:kLabelFont].width
#endif
// Backgrounds
#define kEnterPasscodeLabelBackgroundColor [UIColor clearColor]
#define kBackgroundColor [UIColor colorWithRed:0.97f green:0.97f blue:1.0f alpha:1.00f]
#define kCoverViewBackgroundColor [UIColor colorWithRed:0.97f green:0.97f blue:1.0f alpha:1.00f]
#define kPasscodeBackgroundColor [UIColor clearColor]
#define kFailedAttemptLabelBackgroundColor [UIColor colorWithRed:0.8f green:0.1f blue:0.2f alpha:1.000f]
// Fonts
#define kLabelFont [UIFont systemFontOfSize:17]
#define kPasscodeFont ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? [UIFont fontWithName: @"AvenirNext-Regular" size: kPasscodeFontSize * kFontSizeModifier] : [UIFont fontWithName: @"AvenirNext-Regular" size: kPasscodeFontSize])
// Text Colors
#define kLabelTextColor [UIColor colorWithWhite:0.31f alpha:1.0f]
#define kPasscodeTextColor [UIColor colorWithWhite:0.31f alpha:1.0f]
#define kFailedAttemptLabelTextColor [UIColor whiteColor]

@interface A3PasscodeViewController () <UITextFieldDelegate>

@property (nonatomic, strong) A3NumberKeyboardViewController *passcodeKeyboardViewController;
@property (nonatomic, weak) UITextField *editingTextField;

@end

@implementation A3PasscodeViewController {
	UIView *_animatingView;
	UITextField *_firstDigitTextField;
	UITextField *_secondDigitTextField;
	UITextField *_thirdDigitTextField;
	UITextField *_fourthDigitTextField;
	UITextField *_passcodeTextField;
	UILabel *_failedAttemptLabel;
	UILabel *_enterPasscodeLabel;
	int _failedAttempts;
	NSString *_tempPasscode;
	BOOL _timerStartInSeconds;
	BOOL _passcodeValid;
	BOOL _shouldDismissViewController;
	BOOL _isNumberKeyboardVisible;
}

@dynamic delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
	self.view.backgroundColor = kBackgroundColor;
	if (!_beingDisplayedAsLockscreen) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
																							  target: self
																							  action: @selector(cancelAndDismissMe)];
	}

	_isCurrentlyOnScreen = NO;
	_failedAttempts = 0;
	_animatingView = [[UIView alloc] initWithFrame: self.view.frame];
	[self.view addSubview: _animatingView];

	_enterPasscodeLabel = [[UILabel alloc] initWithFrame: CGRectZero];
	_enterPasscodeLabel.backgroundColor = kEnterPasscodeLabelBackgroundColor;
	_enterPasscodeLabel.textColor = kLabelTextColor;
	_enterPasscodeLabel.font = [UIFont systemFontOfSize:17];
	_enterPasscodeLabel.textAlignment = NSTextAlignmentCenter;
	[_animatingView addSubview: _enterPasscodeLabel];

	// It is also used to display the "Passcode did not match" error message if the user fails to confirm the passcode.
	_failedAttemptLabel = [[UILabel alloc] initWithFrame: CGRectZero];
	_failedAttemptLabel.text = NSLocalizedString(@"1 Passcode Failed Attempt", @"1 Passcode Failed Attempt");
	_failedAttemptLabel.backgroundColor	= kFailedAttemptLabelBackgroundColor;
	_failedAttemptLabel.hidden = YES;
	_failedAttemptLabel.textColor = kFailedAttemptLabelTextColor;
	_failedAttemptLabel.font = kLabelFont;
	_failedAttemptLabel.textAlignment = NSTextAlignmentCenter;
	[_animatingView addSubview: _failedAttemptLabel];

	_firstDigitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
	_firstDigitTextField.backgroundColor = kPasscodeBackgroundColor;
	_firstDigitTextField.textAlignment = NSTextAlignmentCenter;
	_firstDigitTextField.text = kPasscodeCharacter;
	_firstDigitTextField.textColor = kPasscodeTextColor;
	_firstDigitTextField.font = kPasscodeFont;
	_firstDigitTextField.secureTextEntry = NO;
	[_firstDigitTextField setBorderStyle:UITextBorderStyleNone];
	_firstDigitTextField.userInteractionEnabled = NO;
	[_animatingView addSubview:_firstDigitTextField];

	_secondDigitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
	_secondDigitTextField.backgroundColor = kPasscodeBackgroundColor;
	_secondDigitTextField.textAlignment = NSTextAlignmentCenter;
	_secondDigitTextField.text = kPasscodeCharacter;
	_secondDigitTextField.textColor = kPasscodeTextColor;
	_secondDigitTextField.font = kPasscodeFont;
	_secondDigitTextField.secureTextEntry = NO;
	[_secondDigitTextField setBorderStyle:UITextBorderStyleNone];
	_secondDigitTextField.userInteractionEnabled = NO;
	[_animatingView addSubview:_secondDigitTextField];

	_thirdDigitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
	_thirdDigitTextField.backgroundColor = kPasscodeBackgroundColor;
	_thirdDigitTextField.textAlignment = NSTextAlignmentCenter;
	_thirdDigitTextField.text = kPasscodeCharacter;
	_thirdDigitTextField.textColor = kPasscodeTextColor;
	_thirdDigitTextField.font = kPasscodeFont;
	_thirdDigitTextField.secureTextEntry = NO;
	[_thirdDigitTextField setBorderStyle:UITextBorderStyleNone];
	_thirdDigitTextField.userInteractionEnabled = NO;
	[_animatingView addSubview:_thirdDigitTextField];

	_fourthDigitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
	_fourthDigitTextField.backgroundColor = kPasscodeBackgroundColor;
	_fourthDigitTextField.textAlignment = NSTextAlignmentCenter;
	_fourthDigitTextField.text = kPasscodeCharacter;
	_fourthDigitTextField.textColor = kPasscodeTextColor;
	_fourthDigitTextField.font = kPasscodeFont;
	_fourthDigitTextField.secureTextEntry = NO;
	[_fourthDigitTextField setBorderStyle:UITextBorderStyleNone];
	_fourthDigitTextField.userInteractionEnabled = NO;
	[_animatingView addSubview:_fourthDigitTextField];

	_passcodeTextField = [[UITextField alloc] initWithFrame: CGRectZero];
	_passcodeTextField.hidden = YES;
	_passcodeTextField.delegate = self;
	_passcodeTextField.keyboardType = UIKeyboardTypeNumberPad;
	[_animatingView addSubview:_passcodeTextField];

	_enterPasscodeLabel.text = _isUserChangingPasscode ? NSLocalizedString(@"Enter your old passcode", @"") : NSLocalizedString(@"Enter your passcode", @"");

	_enterPasscodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_failedAttemptLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_firstDigitTextField.translatesAutoresizingMaskIntoConstraints = NO;
	_secondDigitTextField.translatesAutoresizingMaskIntoConstraints = NO;
	_thirdDigitTextField.translatesAutoresizingMaskIntoConstraints = NO;
	_fourthDigitTextField.translatesAutoresizingMaskIntoConstraints = NO;

	// MARK: Please read
	// The controller works properly on all devices and orientations, but looks odd on iPhone's landscape.
	// Usually, lockscreens on iPhone are kept portrait-only, though. It also doesn't fit inside a modal when landscape.
	// That's why only portrait is selected for iPhone's supported orientations.
	// Modify this to fit your needs.

	CGFloat yOffsetFromCenter = -self.view.frame.size.height * 0.24;
	NSLayoutConstraint *enterPasscodeConstraintCenterX = [NSLayoutConstraint constraintWithItem: _enterPasscodeLabel
																					  attribute: NSLayoutAttributeCenterX
																					  relatedBy: NSLayoutRelationEqual
																						 toItem: self.view
																					  attribute: NSLayoutAttributeCenterX
																					 multiplier: 1.0f
																					   constant: 0.0f];
	NSLayoutConstraint *enterPasscodeConstraintCenterY = [NSLayoutConstraint constraintWithItem: _enterPasscodeLabel
																					  attribute: NSLayoutAttributeCenterY
																					  relatedBy: NSLayoutRelationEqual
																						 toItem: self.view
																					  attribute: NSLayoutAttributeCenterY
																					 multiplier: 1.0f
																					   constant: yOffsetFromCenter];
	[self.view addConstraint: enterPasscodeConstraintCenterX];
	[self.view addConstraint: enterPasscodeConstraintCenterY];

	NSLayoutConstraint *firstDigitX = [NSLayoutConstraint constraintWithItem: _firstDigitTextField
																   attribute: NSLayoutAttributeLeft
																   relatedBy: NSLayoutRelationEqual
																	  toItem: self.view
																   attribute: NSLayoutAttributeCenterX
																  multiplier: 1.0f
																	constant: - kHorizontalGap * 1.5f - 2.0f];
	NSLayoutConstraint *secondDigitX = [NSLayoutConstraint constraintWithItem: _secondDigitTextField
																	attribute: NSLayoutAttributeLeft
																	relatedBy: NSLayoutRelationEqual
																	   toItem: self.view
																	attribute: NSLayoutAttributeCenterX
																   multiplier: 1.0f
																	 constant: - kHorizontalGap * 2/3 - 2.0f];
	NSLayoutConstraint *thirdDigitX = [NSLayoutConstraint constraintWithItem: _thirdDigitTextField
																   attribute: NSLayoutAttributeLeft
																   relatedBy: NSLayoutRelationEqual
																	  toItem: self.view
																   attribute: NSLayoutAttributeCenterX
																  multiplier: 1.0f
																	constant: kHorizontalGap * 1/6 - 2.0f];
	NSLayoutConstraint *fourthDigitX = [NSLayoutConstraint constraintWithItem: _fourthDigitTextField
																	attribute: NSLayoutAttributeLeft
																	relatedBy: NSLayoutRelationEqual
																	   toItem: self.view
																	attribute: NSLayoutAttributeCenterX
																   multiplier: 1.0f
																	 constant: kHorizontalGap - 2.0f];
	NSLayoutConstraint *firstDigitY = [NSLayoutConstraint constraintWithItem: _firstDigitTextField
																   attribute: NSLayoutAttributeCenterY
																   relatedBy: NSLayoutRelationEqual
																	  toItem: _enterPasscodeLabel
																   attribute: NSLayoutAttributeBottom
																  multiplier: 1.0f
																	constant: kVerticalGap];
	NSLayoutConstraint *secondDigitY = [NSLayoutConstraint constraintWithItem: _secondDigitTextField
																	attribute: NSLayoutAttributeCenterY
																	relatedBy: NSLayoutRelationEqual
																	   toItem: _enterPasscodeLabel
																	attribute: NSLayoutAttributeBottom
																   multiplier: 1.0f
																	 constant: kVerticalGap];
	NSLayoutConstraint *thirdDigitY = [NSLayoutConstraint constraintWithItem: _thirdDigitTextField
																   attribute: NSLayoutAttributeCenterY
																   relatedBy: NSLayoutRelationEqual
																	  toItem: _enterPasscodeLabel
																   attribute: NSLayoutAttributeBottom
																  multiplier: 1.0f
																	constant: kVerticalGap];
	NSLayoutConstraint *fourthDigitY = [NSLayoutConstraint constraintWithItem: _fourthDigitTextField
																	attribute: NSLayoutAttributeCenterY
																	relatedBy: NSLayoutRelationEqual
																	   toItem: _enterPasscodeLabel
																	attribute: NSLayoutAttributeBottom
																   multiplier: 1.0f
																	 constant: kVerticalGap];
	[self.view addConstraint:firstDigitX];
	[self.view addConstraint:secondDigitX];
	[self.view addConstraint:thirdDigitX];
	[self.view addConstraint:fourthDigitX];
	[self.view addConstraint:firstDigitY];
	[self.view addConstraint:secondDigitY];
	[self.view addConstraint:thirdDigitY];
	[self.view addConstraint:fourthDigitY];

	NSLayoutConstraint *failedAttemptLabelCenterX = [NSLayoutConstraint constraintWithItem: _failedAttemptLabel
																				 attribute: NSLayoutAttributeCenterX
																				 relatedBy: NSLayoutRelationEqual
																					toItem: self.view
																				 attribute: NSLayoutAttributeCenterX
																				multiplier: 1.0f
																				  constant: 0.0f];
	NSLayoutConstraint *failedAttemptLabelCenterY = [NSLayoutConstraint constraintWithItem: _failedAttemptLabel
																				 attribute: NSLayoutAttributeCenterY
																				 relatedBy: NSLayoutRelationEqual
																					toItem: _enterPasscodeLabel
																				 attribute: NSLayoutAttributeBottom
																				multiplier: 1.0f
																				  constant: kVerticalGap * kModifierForBottomVerticalGap - 2.0f];
	NSLayoutConstraint *failedAttemptLabelWidth = [NSLayoutConstraint constraintWithItem: _failedAttemptLabel
																			   attribute: NSLayoutAttributeWidth
																			   relatedBy: NSLayoutRelationGreaterThanOrEqual
																				  toItem: nil
																			   attribute: NSLayoutAttributeNotAnAttribute
																			  multiplier: 1.0f
																				constant: kFailedAttemptLabelWidth];
	NSLayoutConstraint *failedAttemptLabelHeight = [NSLayoutConstraint constraintWithItem: _failedAttemptLabel
																				attribute: NSLayoutAttributeHeight
																				relatedBy: NSLayoutRelationEqual
																				   toItem: nil
																				attribute: NSLayoutAttributeNotAnAttribute
																			   multiplier: 1.0f
																				 constant: kFailedAttemptLabelHeight + 6.0f];
	[self.view addConstraint:failedAttemptLabelCenterX];
	[self.view addConstraint:failedAttemptLabelCenterY];
	[self.view addConstraint:failedAttemptLabelWidth];
	[self.view addConstraint:failedAttemptLabelHeight];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self presentNumberKeyboardForTextField:_passcodeTextField];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	if ([self.delegate respondsToSelector:@selector(passcodeViewDidDisappearWithSuccess:)]) {
		[self.delegate passcodeViewDidDisappearWithSuccess:_passcodeValid ];
	}
}

- (void)cancelAndDismissMe {
	_isCurrentlyOnScreen = NO;
	[self dismissNumberKeyboard];
	
	_isUserBeingAskedForNewPasscode = NO;
	_isUserChangingPasscode = NO;
	_isUserConfirmingPasscode = NO;
	_isUserEnablingPasscode = NO;
	_isUserTurningPasscodeOff = NO;
	[self resetUI];

	_passcodeValid = NO;

	if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidDismissWithSuccess:)]) {
		[self.delegate passcodeViewControllerDidDismissWithSuccess:NO];
	}
    if (self.completionBlock) {
        self.completionBlock(NO);
    }
	[self dismissViewControllerAnimated: YES completion: nil];
}

/*! dismissMe 는 암호가 확인이 되면 호출이 됨. 만약 암호가 틀리면 denyAccess 가 수행이 된다.
 * Cancel 을 눌렀을때는 cancelAndDismissMe 로 분기가 되는 것
 */
- (void)dismissMe {
	_isCurrentlyOnScreen = NO;
	[self resetUI];
	[self dismissNumberKeyboard];

	[A3KeychainUtils saveTimerStartTime];

    if (!_beingDisplayedAsLockscreen) {
        // Delete from Keychain
        if (_isUserTurningPasscodeOff) {
            [A3KeychainUtils removePassword];
        }
            // Update the Keychain if adding or changing passcode
        else {
            if (_isUserEnablingPasscode|| _isUserChangingPasscode) {
                [A3KeychainUtils saveTimerStartTime];
                [A3KeychainUtils storePassword:_tempPasscode hint:nil];

                A3UserDefaults *defaults = [A3UserDefaults standardUserDefaults];
                [defaults setBool:YES forKey:kUserDefaultsKeyForUseSimplePasscode];
                [defaults synchronize];
            }
        }
    }
    if (_beingDisplayedAsLockscreen && !_shouldDismissViewController) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];

        if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidDismissWithSuccess:)]) {
            [self.delegate passcodeViewControllerDidDismissWithSuccess:YES];
        }
        if (self.completionBlock) {
            self.completionBlock(YES);
        }

        if ([self.delegate respondsToSelector:@selector(passcodeViewDidDisappearWithSuccess:)]) {
            [self.delegate passcodeViewDidDisappearWithSuccess:_passcodeValid ];
        }
    }
    else {
        [self dismissViewControllerAnimated:NO completion: nil];

        if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidDismissWithSuccess:)]) {
            [self.delegate passcodeViewControllerDidDismissWithSuccess:YES];
        }
        if (self.completionBlock) {
            self.completionBlock(YES);
        }
    }

    _passcodeValid = YES;


	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIApplicationDidChangeStatusBarOrientationNotification
												  object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIApplicationDidChangeStatusBarFrameNotification
												  object: nil];
}


#pragma mark - Displaying

- (void)showLockScreenWithAnimation:(BOOL)animated showCacelButton:(BOOL)showCancelButton inViewController:(UIViewController *)rootViewController {
	_beingDisplayedAsLockscreen = YES;
//	// In case the user leaves the app while changing/disabling Passcode.
//	if (!_beingDisplayedAsLockscreen) [self cancelAndDismissMe];
	[self prepareAsLockscreen];

	if (showCancelButton) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
																							  target: self
																							  action: @selector(cancelAndDismissMe)];
	}
	
	// In case the user leaves the app while the lockscreen is already active.
	if (!_isCurrentlyOnScreen) {
		// MARK: Window changes. Please read:
		// Usually, the app's window is the first on the stack. I'm doing this because if an alertView or actionSheet
		// is open when presenting the lockscreen causes problems, because the av/as has it's own window that replaces the myKeyWindow
		// and due to how Apple handles said window internally.
		// Currently the lockscreen appears behind the av/as, which is the best compromise for now.
		// You can read and/or give a hand following one of the links below
		// http://stackoverflow.com/questions/19816142/uialertviews-uiactionsheets-and-keywindow-problems
		// https://github.com/rolandleth/LTHPasscodeViewController/issues/16
		// Usually not more than one window is needed, but your needs may vary; modify below.

		UIWindow *mainWindow = [UIApplication sharedApplication].myKeyWindow;
		if (!mainWindow) {
//			UIViewController *rootViewController = IS_IPAD ? [[A3AppDelegate instance] rootViewController_iPad] : [[A3AppDelegate instance] rootViewController_iPhone];
			[rootViewController presentViewController:self animated:NO completion:NULL];
			_shouldDismissViewController = YES;
		} else {
			[mainWindow addSubview: self.view];
			[mainWindow.rootViewController addChildViewController: self];
		}
		_isCurrentlyOnScreen = YES;
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (_isNumberKeyboardVisible && self.numberKeyboardViewController.view.superview) {
		UIView *keyboardView = self.numberKeyboardViewController.view;
		CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;

		FNLOGRECT(self.view.bounds);
		FNLOG(@"%f", keyboardHeight);
		CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		keyboardView.frame = CGRectMake(0, bounds.size.height - keyboardHeight, bounds.size.width, keyboardHeight);
		[self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	}
}

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification {

	UIInterfaceOrientation toInterfaceOrientation = self.view.window.windowScene.interfaceOrientation;
	if (_isNumberKeyboardVisible && self.numberKeyboardViewController.view.superview) {
		UIView *keyboardView = self.numberKeyboardViewController.view;
		CGFloat keyboardHeight = self.numberKeyboardViewController.keyboardHeight;

		FNLOGRECT(self.view.bounds);
		FNLOG(@"%f", keyboardHeight);
		CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		keyboardView.frame = CGRectMake(0, bounds.size.height - keyboardHeight, bounds.size.width, keyboardHeight);
		[self.numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	}
}

- (void)prepareNavigationControllerWithController:(UIViewController *)viewController {
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: self];
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
	[viewController presentViewController: navController animated: NO completion: nil];
//	[self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
																						  target: self
																						  action: @selector(cancelAndDismissMe)];
}

- (void)showLockScreenInViewController:(UIViewController *)viewController completion:(void (^)(BOOL))completion {
	[self prepareAsLockscreen];
	[self prepareNavigationControllerWithController:viewController];
	self.title = NSLocalizedString(@"Passcode", @"View title while confirm passcode");
}

- (void)showForEnablingPasscodeInViewController:(UIViewController *)viewController {
	[self prepareForEnablingPasscode];
	[self prepareNavigationControllerWithController: viewController];
	self.title = NSLocalizedString(@"Set Passcode", @"");
}

- (void)showForChangingPasscodeInViewController:(UIViewController *)viewController {
	[self prepareForChangingPasscode];
	[self prepareNavigationControllerWithController: viewController];
	self.title = NSLocalizedString(@"Change Passcode", @"");
}

- (void)showForTurningOffPasscodeInViewController:(UIViewController *)viewController {
	[self prepareForTurningOffPasscode];
	[self prepareNavigationControllerWithController: viewController];
	self.title = NSLocalizedString(@"Turn Off Passcode", @"");
}

#pragma mark - Preparing
- (void)prepareAsLockscreen {
	_isUserTurningPasscodeOff = NO;
	_isUserChangingPasscode = NO;
	_isUserConfirmingPasscode = NO;
	_isUserEnablingPasscode = NO;
	[self resetUI];
}


- (void)prepareForChangingPasscode {
	_isCurrentlyOnScreen = YES;
	_isUserTurningPasscodeOff = NO;
	_isUserChangingPasscode = YES;
	_isUserConfirmingPasscode = NO;
	_isUserEnablingPasscode = NO;
	[self resetUI];
}


- (void)prepareForTurningOffPasscode {
	_isCurrentlyOnScreen = YES;
	_isUserTurningPasscodeOff = YES;
	_isUserChangingPasscode = NO;
	_isUserConfirmingPasscode = NO;
	_isUserEnablingPasscode = NO;
	[self resetUI];
}

- (void)prepareForEnablingPasscode {
	_isCurrentlyOnScreen = YES;
	_isUserTurningPasscodeOff = NO;
	_isUserChangingPasscode = NO;
	_isUserConfirmingPasscode = NO;
	_isUserEnablingPasscode = YES;
	_isUserBeingAskedForNewPasscode = YES;
	[self resetUI];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	[self presentNumberKeyboardForTextField:textField];

	return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return !_isCurrentlyOnScreen;
}

- (void)presentNumberKeyboardForTextField:(UITextField *)textField {
	if (_isNumberKeyboardVisible) {
		return;
	}
	_editingTextField = textField;

	A3NumberKeyboardViewController *keyboardVC = [self passcodeKeyboard];
	self.numberKeyboardViewController = keyboardVC;
	keyboardVC.keyboardType = A3NumberKeyboardTypePasscode;
	keyboardVC.textInputTarget = textField;
	keyboardVC.delegate = self;

	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	FNLOGRECT(bounds);
	FNLOGRECT(self.view.bounds);
	
	CGFloat keyboardHeight = keyboardVC.keyboardHeight;
	UIView *keyboardView = keyboardVC.view;
	[self.view addSubview:keyboardView];

	_isNumberKeyboardVisible = YES;

	keyboardView.frame = CGRectMake(0, bounds.size.height, bounds.size.width, keyboardHeight);
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y -= keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
	}];
}

- (void)dismissNumberKeyboard {
	if (!_isNumberKeyboardVisible) {
		return;
	}

	A3NumberKeyboardViewController *keyboardViewController = self.numberKeyboardViewController;
	UIView *keyboardView = keyboardViewController.view;
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = keyboardView.frame;
		frame.origin.y += keyboardViewController.keyboardHeight;
		keyboardView.frame = frame;
	} completion:^(BOOL finished) {
		[keyboardView removeFromSuperview];
		self.numberKeyboardViewController = nil;
        self->_isNumberKeyboardVisible = NO;
	}];
}

- (void)keyboardViewControllerDidValueChange:(A3NumberKeyboardViewController *)vc {
	NSString *typedString = _editingTextField.text;

	if (typedString.length >= 1) _firstDigitTextField.secureTextEntry = YES;
	else _firstDigitTextField.secureTextEntry = NO;
	if (typedString.length >= 2) _secondDigitTextField.secureTextEntry = YES;
	else _secondDigitTextField.secureTextEntry = NO;
	if (typedString.length >= 3) _thirdDigitTextField.secureTextEntry = YES;
	else _thirdDigitTextField.secureTextEntry = NO;
	if (typedString.length == 4) _fourthDigitTextField.secureTextEntry = YES;
	else _fourthDigitTextField.secureTextEntry = NO;

    void(^deleteLastCharacter)(void) = ^{
		if ([self->_editingTextField.text length] > 2) {
            self->_editingTextField.text = [self->_editingTextField.text substringToIndex:[self->_editingTextField.text length] - 2];
			FNLOG(@"%@", self->_editingTextField.text);
		} else {
            self->_editingTextField.text = @"";
		}
	};

	if (typedString.length == 4) {
		NSString *savedPasscode = [A3KeychainUtils getPassword];

		// Entering from Settings. If savedPasscode is empty, it means
		// the user is setting a new Passcode now, or is changing his current Passcode.
		if ((_isUserChangingPasscode  || _isUserEnablingPasscode) && !_isUserTurningPasscodeOff) {
			// Either the user is being asked for a new passcode, confirmation comes next,
			// either he is setting up a new passcode, confirmation comes next, still.
			// We need the !_isUserConfirmingPasscode condition, because if he's adding a new Passcode,
			// then savedPasscode is still empty and the condition will always be true, not passing this point.
			if ((_isUserBeingAskedForNewPasscode) && !_isUserConfirmingPasscode) {
				_tempPasscode = typedString;
				// The delay is to give time for the last bullet to appear
				[self performSelector: @selector(askForConfirmationPasscode) withObject: nil afterDelay: 0.15f];
			}
				// User entered his Passcode correctly and we are at the confirming screen.
			else if (_isUserConfirmingPasscode) {
				// User entered the confirmation Passcode correctly
				if ([typedString isEqualToString: _tempPasscode]) {
					[self dismissMe];
				}
					// User entered the confirmation Passcode incorrectly, start over.
				else {
					[self performSelector: @selector(reAskForNewPasscode) withObject: nil afterDelay: 0.15f];
				}
			}
				// Changing Passcode and the entered Passcode is correct.
			else if ([typedString isEqualToString: savedPasscode]){
				[self performSelector: @selector(askForNewPasscode) withObject: nil afterDelay: 0.15f];
				_failedAttempts = 0;
			}
				// Acting as lockscreen and the entered Passcode is incorrect.
			else {
				[self performSelector: @selector(denyAccess) withObject: nil afterDelay: 0.15f];
				deleteLastCharacter();
				return;
			}
		}
			// App launch/Turning passcode off: Passcode OK -> dismiss, Passcode incorrect -> deny access.
		else {
			if ([typedString isEqualToString: savedPasscode]) {
				_passcodeValid = YES;
				[self dismissMe];
			}
			else {
				[self performSelector: @selector(denyAccess) withObject: nil afterDelay: 0.15f];
				deleteLastCharacter();
				return;
			}
		}
	}

	if (typedString.length > 4) {
		deleteLastCharacter();
		return;
	}
}

#pragma mark - Actions

- (void)askForNewPasscode {
	_isUserBeingAskedForNewPasscode = YES;
	_isUserConfirmingPasscode = NO;
	_failedAttemptLabel.hidden = YES;

	CATransition *transition = [CATransition animation];
	[self performSelector: @selector(resetUI) withObject: nil afterDelay: 0.1f];
	[transition setType: kCATransitionPush];
	[transition setSubtype: kCATransitionFromRight];
	[transition setDuration: kSlideAnimationDuration];
	[transition setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
	[[_animatingView layer] addAnimation: transition forKey: @"swipe"];
}

- (void)reAskForNewPasscode {
	_isUserBeingAskedForNewPasscode = YES;
	_isUserConfirmingPasscode = NO;
	_tempPasscode = @"";

	CATransition *transition = [CATransition animation];
	[self performSelector: @selector(resetUIForReEnteringNewPasscode) withObject: nil afterDelay: 0.1f];
	[transition setType: kCATransitionPush];
	[transition setSubtype: kCATransitionFromRight];
	[transition setDuration: kSlideAnimationDuration];
	[transition setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
	[[_animatingView layer] addAnimation: transition forKey: @"swipe"];
}


- (void)askForConfirmationPasscode {
	_isUserBeingAskedForNewPasscode = NO;
	_isUserConfirmingPasscode = YES;
	_failedAttemptLabel.hidden = YES;

	CATransition *transition = [CATransition animation];
	[self performSelector: @selector(resetUI) withObject: nil afterDelay: 0.1f];
	[transition setType: kCATransitionPush];
	[transition setSubtype: kCATransitionFromRight];
	[transition setDuration: kSlideAnimationDuration];
	[transition setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
	[[_animatingView layer] addAnimation: transition forKey: @"swipe"];
}


- (void)resetTextFields {
	if (![_passcodeTextField isFirstResponder])
		[_passcodeTextField becomeFirstResponder];
	_firstDigitTextField.secureTextEntry = NO;
	_secondDigitTextField.secureTextEntry = NO;
	_thirdDigitTextField.secureTextEntry = NO;
	_fourthDigitTextField.secureTextEntry = NO;
}


- (void)resetUI {
	[self resetTextFields];
	_failedAttemptLabel.backgroundColor	= kFailedAttemptLabelBackgroundColor;
	_failedAttemptLabel.textColor = kFailedAttemptLabelTextColor;
	_failedAttempts = 0;
	_failedAttemptLabel.hidden = YES;
	_passcodeTextField.text = @"";
	if (_isUserConfirmingPasscode) {
		if (_isUserEnablingPasscode) _enterPasscodeLabel.text = NSLocalizedString(@"Re-enter your passcode", @"");
		else if (_isUserChangingPasscode) _enterPasscodeLabel.text = NSLocalizedString(@"Re-enter your new passcode", @"");
	}
	else if (_isUserBeingAskedForNewPasscode) {
		if (_isUserEnablingPasscode || _isUserChangingPasscode) {
			_enterPasscodeLabel.text = NSLocalizedString(@"Enter your new passcode", @"");
		}
	}
	else _enterPasscodeLabel.text = NSLocalizedString(@"Enter your passcode", @"");
}


- (void)resetUIForReEnteringNewPasscode {
	[self resetTextFields];
	_passcodeTextField.text = @"";
	// If there's no passcode saved in Keychain, the user is adding one for the first time, otherwise he's changing his passcode.
	NSString *savedPasscode = [A3KeychainUtils getPassword];
	_enterPasscodeLabel.text = savedPasscode.length == 0 ? NSLocalizedString(@"Enter your passcode", @"") : NSLocalizedString(@"Enter your new passcode", @"");

	_failedAttemptLabel.hidden = NO;
	_failedAttemptLabel.text = NSLocalizedString(@"Passcode did not match. Try again.", @"");
	_failedAttemptLabel.backgroundColor = [UIColor clearColor];
	_failedAttemptLabel.layer.borderWidth = 0;
	_failedAttemptLabel.layer.borderColor = [UIColor clearColor].CGColor;
	_failedAttemptLabel.textColor = kLabelTextColor;
}


- (void)denyAccess {
	[self resetTextFields];
	_passcodeTextField.text = @"";
	_failedAttempts++;

	if (kMaxNumberOfAllowedFailedAttempts > 0 &&
			_failedAttempts == kMaxNumberOfAllowedFailedAttempts &&
			[self.delegate respondsToSelector: @selector(maxNumberOfFailedAttemptsReached)])
		[self.delegate maxNumberOfFailedAttemptsReached];
//	Or, if you prefer by notifications:
//	[[NSNotificationCenter defaultCenter] postNotificationName: @"maxNumberOfFailedAttemptsReached"
//														object: self
//													  userInfo: nil];

	if (_failedAttempts == 1) _failedAttemptLabel.text = NSLocalizedString(@"1 Passcode Failed Attempt", @"");
	else {
		_failedAttemptLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%li Passcode Failed Attempts", @""), (long)_failedAttempts];
	}
	_failedAttemptLabel.layer.cornerRadius = kFailedAttemptLabelHeight * 0.65f;
	_failedAttemptLabel.hidden = NO;
}

#pragma mark - Notification Observers

#pragma mark - Init

- (id)initWithDelegate:(id<A3PasscodeViewControllerDelegate>)delegate {
	self = [super init];
	if (self) {
		self.delegate = delegate;
	}
	return self;
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

@end
