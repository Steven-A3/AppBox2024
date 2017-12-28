//
//  A3PasswordViewController.m
//  AppBox3
//
//  Created by A3 on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3PasswordViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3KeychainUtils.h"
#import "A3StandardTableViewCell.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UserDefaultsKeys.h"
#import "A3UserDefaults.h"
#import "JVFloatLabeledTextField.h"

#define kFailedAttemptLabelBackgroundColor [UIColor colorWithRed:0.8f green:0.1f blue:0.2f alpha:1.000f]
#define kLabelFont (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [UIFont fontWithName: @"AvenirNext-Regular" size: kLabelFontSize * kFontSizeModifier] : [UIFont fontWithName: @"AvenirNext-Regular" size: kLabelFontSize])

@interface A3PasswordViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) JVFloatLabeledTextField *passwordField;
@property (nonatomic, strong) JVFloatLabeledTextField *aNewPasswordField;
@property (nonatomic, strong) JVFloatLabeledTextField *confirmPasswordField;
@property (nonatomic, strong) JVFloatLabeledTextField *passwordHintField;
@property (nonatomic, strong) UIResponder *currentResponder;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *failedAttemptLabel;
@property (nonatomic, strong) MASConstraint *labelWidth;
@property (nonatomic, strong) MASConstraint *labelHeight;
@property (nonatomic, strong) MASConstraint *headerY;
@property (nonatomic, strong) MASConstraint *footerY;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL shouldDismissViewController;
@property (nonatomic, strong) UILabel *sectionHeaderLabel;

@end

@implementation A3PasswordViewController {
	BOOL _isWalletEncryptionKeyMode;
	BOOL _isUserBeingAskedForNewPasscode;
	BOOL _isUserTurningPasscodeOff;
	BOOL _isUserChangingPasscode;
	BOOL _isUserEnablingPasscode;
	BOOL _showCancelButton;
	NSInteger _failedAttempts;
	BOOL _passcodeValid;
	BOOL _beingPresentedInViewController;
	BOOL _userPressedCancelButton;
}

- (id)initWithDelegate:(id<A3PasscodeViewControllerDelegate>)delegate {
	self = [super init];
	if (self) {
		self.delegate = delegate;
		_failedAttempts = 0;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
	self.tableView.scrollEnabled = NO;
	[self.view addSubview:self.tableView];

	[self.tableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, [self keyboardHeight], 0);

    if (!(_isUserChangingPasscode && IS_IPHONE35)) {
        _headerLabel = [UILabel new];
        _headerLabel.font = [UIFont systemFontOfSize:17];
        _headerLabel.textColor = [UIColor colorWithWhite:0.31f alpha:1.0f];
        if (_isWalletEncryptionKeyMode) {
            if (_beingPresentedInViewController) {
                _headerLabel.text = NSLocalizedString(@"Data migration is in progress.", nil);
            } else {
                _headerLabel.text = NSLocalizedString(@"Data migration is in progress.\nEnter Encryption Key for Wallet.", nil);
				NSArray *components = [_headerLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
				_headerLabel.numberOfLines = [components count];
            }
        } else {
            _headerLabel.text = NSLocalizedString(@"Enter your passcode", @"Enter your passcode");
        }
        _headerLabel.textAlignment = NSTextAlignmentCenter;
        _headerLabel.numberOfLines = 0;
        [self.view addSubview:_headerLabel];
    }

	CGFloat offset = _beingPresentedInViewController ? 64 : 0;
	CGFloat headerHeight = [self tableView:self.tableView heightForHeaderInSection:0];
	[_headerLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(15);
        make.right.equalTo(self.view.right).with.offset(-15);
		_headerY = make.centerY.equalTo(self.view.top).with.offset(headerHeight * 0.6 + offset);
	}];

	offset += 44.0 * [self tableView:self.tableView numberOfRowsInSection:0];
	_failedAttemptLabel = [UILabel new];
	_failedAttemptLabel.font = [UIFont systemFontOfSize:17];
	_failedAttemptLabel.textColor = [UIColor colorWithWhite:0.31f alpha:1.0f];
	_failedAttemptLabel.text = NSLocalizedString(@"Enter your passcode", @"Enter your passcode");
	_failedAttemptLabel.textAlignment = NSTextAlignmentCenter;
	_failedAttemptLabel.hidden = YES;
	_failedAttemptLabel.layer.cornerRadius = 22 * 0.5;
	[self.view addSubview:_failedAttemptLabel];

	[_failedAttemptLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		_footerY = make.centerY.equalTo(self.view.top).with.offset(headerHeight + headerHeight/2.0 + offset);
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (_isUserChangingPasscode && IS_IPHONE35) {
		[_headerLabel setHidden:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	
	if (_isUserEnablingPasscode) {
        if (_aNewPasswordField) {
            [_aNewPasswordField becomeFirstResponder];
        } else {
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [_aNewPasswordField becomeFirstResponder];
            });
        }
	}
    else
    {
		if (_passwordField) {
			[_passwordField becomeFirstResponder];
		} else {
			double delayInSeconds = 0.5;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[_passwordField becomeFirstResponder];
			});
		}
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

}

#pragma mark - Preparing

- (void)prepareAsLockscreen {
	_isUserTurningPasscodeOff = NO;
	_isUserChangingPasscode = NO;
	_isUserEnablingPasscode = NO;
	[self resetUI];
}

- (void)prepareForChangingPasscode {
	_isUserTurningPasscodeOff = NO;
	_isUserChangingPasscode = YES;
	_isUserEnablingPasscode = NO;
	[self resetUI];
}

- (void)prepareForTurningOffPasscode {
	_isUserTurningPasscodeOff = YES;
	_isUserChangingPasscode = NO;
	_isUserEnablingPasscode = NO;
	[self resetUI];
}


- (void)prepareForEnablingPasscode {
	_isUserTurningPasscodeOff = NO;
	_isUserChangingPasscode = NO;
	_isUserEnablingPasscode = YES;
	[self resetUI];
}

- (void)resetUI {
	[self.tableView reloadData];
}

- (void)prepareNavigationControllerWithController:(UIViewController *)viewController {
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: self];
	[viewController presentViewController: navController animated:NO completion: nil];

	if (_showCancelButton) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
																							   target: self
																							   action: @selector(cancelButtonAction:)];
	}
}

- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem {
	_userPressedCancelButton = YES;
	[self cancelAndDismissMe];
}

- (void)cancelAndDismissMe {
	_passcodeValid = NO;

	[_passwordField resignFirstResponder];
	[_aNewPasswordField resignFirstResponder];
	[_confirmPasswordField resignFirstResponder];
	[_passwordHintField resignFirstResponder];

	if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidDismissWithSuccess:)]) {
		[self.delegate passcodeViewControllerDidDismissWithSuccess:NO];
	}
	if (_beingPresentedInViewController || _shouldDismissViewController) {
		[self dismissViewControllerAnimated:YES completion:nil];
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([self.delegate respondsToSelector:@selector(passcodeViewDidDisappearWithSuccess:)]) {
				[self.delegate passcodeViewDidDisappearWithSuccess:NO ];
			}
		});
	} else {
		[self.view removeFromSuperview];
		if (!IS_IOS7) {
			[self removeFromParentViewController];
		}
		if ([self.delegate respondsToSelector:@selector(passcodeViewDidDisappearWithSuccess:)]) {
			[self.delegate passcodeViewDidDisappearWithSuccess:NO ];
		}
	}
}

- (void)showEncryptionKeyScreenInViewController:(UIViewController *)viewController {
	_isWalletEncryptionKeyMode = YES;
	[self showLockScreenInViewController:viewController];
	self.title = NSLocalizedString(@"Encryption Key for Wallet", @"");
}

- (void)showEncryptionKeyCheckScreen {
	_isWalletEncryptionKeyMode = YES;
	[self showLockScreenWithAnimation:NO showCacelButton:NO];
}

- (void)showLockScreenWithAnimation:(BOOL)animated showCacelButton:(BOOL)showCancelButton {
	FNLOG();
	_beingDisplayedAsLockscreen = YES;
	_showCancelButton = showCancelButton;
	_beingPresentedInViewController = NO;

	[self prepareAsLockscreen];

	UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
	if (!mainWindow) {
		UIViewController *rootViewController = IS_IPAD ? [[A3AppDelegate instance] rootViewController_iPad] : [[A3AppDelegate instance] rootViewController_iPhone];
		[rootViewController presentViewController:self animated:NO completion:NULL];
		_shouldDismissViewController = YES;
	} else {
		[[A3AppDelegate instance].currentMainNavigationController setNavigationBarHidden:YES];
		[mainWindow addSubview: self.view];
		
		if (IS_IOS7) {
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(statusBarFrameOrOrientationChanged:)
														 name:UIApplicationDidChangeStatusBarOrientationNotification
													   object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(statusBarFrameOrOrientationChanged:)
														 name:UIApplicationDidChangeStatusBarFrameNotification
													   object:nil];
			
			[self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
		} else {
			[mainWindow.rootViewController addChildViewController: self];
		}
	}

	self.title = NSLocalizedString(@"Enter Passcode", @"");
}

- (void)showLockScreenInViewController:(UIViewController *)viewController {
	_showCancelButton = YES;
	_beingDisplayedAsLockscreen = YES;
	_beingPresentedInViewController = viewController != nil;

	[self prepareAsLockscreen];
	[self prepareNavigationControllerWithController:viewController];
	self.title = NSLocalizedString(@"Passcode", @"View title while confirm passcode");
}

- (void)showForEnablingPasscodeInViewController:(UIViewController *)viewController {
	FNLOG();
	_showCancelButton = YES;
	_beingPresentedInViewController = YES;

	[self prepareForEnablingPasscode];
	[self prepareNavigationControllerWithController: viewController];
	self.title = NSLocalizedString(@"Set Passcode", @"");
}

- (void)showForChangingPasscodeInViewController:(UIViewController *)viewController {
	FNLOG();
	_showCancelButton = YES;
	_beingPresentedInViewController = YES;
	[self prepareForChangingPasscode];
	[self prepareNavigationControllerWithController: viewController];
	self.title = NSLocalizedString(@"Change Passcode", @"");
}

- (void)showForTurningOffPasscodeInViewController:(UIViewController *)viewController {
	FNLOG();
	_showCancelButton = YES;
	_beingPresentedInViewController = YES;
	[self prepareForTurningOffPasscode];
	[self prepareNavigationControllerWithController: viewController];
	self.title = NSLocalizedString(@"Turn Off Passcode", @"");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_isUserEnablingPasscode) return 3;		// New passcode, Confirm Passcode, Password Hint
	if (_isUserChangingPasscode) return 4;		// Old passcode, New, Confirm, Hint
	if (_beingDisplayedAsLockscreen) return 1;
	if (_isUserTurningPasscodeOff) return 1;
    return 1;									// Passcode
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const cellReuseIdentifier = @"passwordCell";
	A3StandardTableViewCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
	if (!cell) {
		cell = [[A3StandardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.font = [UIFont systemFontOfSize:17];
	
    if (_isUserEnablingPasscode) {
		[self setupCell:cell forRowEnablingPasscodeAtIndexPath:indexPath];
		return cell;
	}
	if (_isUserChangingPasscode) {
		[self setupCell:cell forRowChangingPasscodeAtIndexPath:indexPath];
		return cell;
	}

	[self setupCell:cell forRowAskingPasscodeAtIndexPath:indexPath];
    return cell;
}

- (CGFloat)keyboardHeight {
    CGFloat keyboardHeight;
	if (IS_IPHONE) {
        keyboardHeight = 216;
    } else {
        keyboardHeight = IS_LANDSCAPE ? 352 : 264;
    }
    if (_isUserChangingPasscode && !IS_IOS7) keyboardHeight += 40.0;
	return keyboardHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_isUserChangingPasscode && IS_IPHONE35) {
        return 23.0;
    }
	NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:section];

	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	CGFloat navigationBarHeight = _beingPresentedInViewController ? 64.0 : 0.0;
	CGFloat sectionHeight = (screenBounds.size.height - (44.0 * numberOfRows + [self keyboardHeight] + navigationBarHeight )) / 2.0;
	return sectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (_isUserChangingPasscode && IS_IPHONE35) {
		UIView *sectionHeaderView = [UIView new];
		_sectionHeaderLabel = [UILabel new];
		_sectionHeaderLabel.font = [UIFont systemFontOfSize:14];
		_sectionHeaderLabel.textColor = [UIColor colorWithWhite:0.31f alpha:1.0f];
		_sectionHeaderLabel.textAlignment = NSTextAlignmentCenter;
		_sectionHeaderLabel.text = NSLocalizedString(@"Enter your passcode", @"Enter your passcode");
		[sectionHeaderView addSubview:_sectionHeaderLabel];

		[_sectionHeaderLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(sectionHeaderView.left).with.offset(10);
			make.right.equalTo(sectionHeaderView.right).with.offset(-10);
			make.centerY.equalTo(sectionHeaderView.centerY);
		}];
		return sectionHeaderView;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (_isUserChangingPasscode && IS_IPHONE35) {
        return 0;
    }
	return [self tableView:tableView heightForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	// Show hint
	if (_isWalletEncryptionKeyMode) {
		NSString *hintString = [self.delegate encryptionKeyHintStringForEncryptionKeyCheckViewController];
		[self showHint:hintString];
	} else {
		NSString *hintString = [A3KeychainUtils getHint];
		[self showHint:hintString];
	}
}

- (JVFloatLabeledTextField *)setupPasscodeField {
	JVFloatLabeledTextField *textField = [JVFloatLabeledTextField new];
	textField.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
	textField.floatingLabelTextColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
	textField.font = [UIFont systemFontOfSize:17];
	textField.floatingLabelFont = [UIFont systemFontOfSize:13];
	textField.floatingLabelYPadding = 0;
	textField.secureTextEntry = YES;
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.delegate = self;
	return textField;
}

- (void)setupCell:(UITableViewCell *)cell forRowAskingPasscodeAtIndexPath:(NSIndexPath *)indexPath {
    FNLOG();
	if (!_passwordField) {
		_passwordField = (JVFloatLabeledTextField *) [UITextField new];
		_passwordField.secureTextEntry = YES;
		_passwordField.keyboardType = UIKeyboardTypeDefault;
		_passwordField.delegate = self;
	}
	[cell addSubview:_passwordField];
	[_passwordField makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(cell.left).with.offset(IS_IPHONE ? 15 : 28);
		make.top.equalTo(cell.top).with.offset(10);
		make.bottom.equalTo(cell.bottom).with.offset(-10);
		make.right.equalTo(cell.right).with.offset(-50);
	}];

	if ([A3KeychainUtils getHint]) {
		cell.accessoryType = UITableViewCellAccessoryDetailButton;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}

- (void)makeConstraintForTextField:(UITextField *)textField inCell:(UITableViewCell *)cell {
	[cell addSubview:textField];
	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	[textField makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(cell.left).with.offset(leading);
		make.top.equalTo(cell.top);
		make.bottom.equalTo(cell.bottom);
		make.right.equalTo(cell.right).with.offset(leading);
	}];
}

- (void)setupCell:(UITableViewCell *)cell forRowEnablingPasscodeAtIndexPath:(NSIndexPath *)indexPath {
	JVFloatLabeledTextField *textField;
	switch (indexPath.row) {
		case 0:
			if (!_aNewPasswordField) {
				_aNewPasswordField = [self setupPasscodeField];
			}
			_aNewPasswordField.placeholder = NSLocalizedString(@"New Passcode", @"New Passcode");
			textField = _aNewPasswordField;
			break;
		case 1:
			if (!_confirmPasswordField) {
				_confirmPasswordField = [self setupPasscodeField];
			}
			_confirmPasswordField.placeholder = NSLocalizedString(@"Confirm Passcode", @"Confirm Passcode");
			textField = _confirmPasswordField;
			break;
		case 2:
			if (!_passwordHintField) {
				_passwordHintField = [self setupPasscodeField];
				_passwordHintField.secureTextEntry = NO;
			}
			_passwordHintField.placeholder = NSLocalizedString(@"Hint", @"Hint");
			textField = _passwordHintField;
			break;
	}
	[self makeConstraintForTextField:textField inCell:cell];
}

- (void)setupCell:(UITableViewCell *)cell forRowChangingPasscodeAtIndexPath:(NSIndexPath *)indexPath {
	UITextField *textField;
	switch (indexPath.row) {
		case 0:
			if (!_passwordField) {
				_passwordField = [self setupPasscodeField];
				_passwordField.placeholder = NSLocalizedString(@"Old Passcode", @"Old Passcode");
			}
			textField = _passwordField;
			break;
		case 1:
			if (!_aNewPasswordField) {
				_aNewPasswordField = [self setupPasscodeField];
				_aNewPasswordField.placeholder = NSLocalizedString(@"New Passcode", @"New Passcode");
			}
			textField = _aNewPasswordField;
			break;
		case 2:
			if (!_confirmPasswordField) {
				_confirmPasswordField = [self setupPasscodeField];
				_confirmPasswordField.placeholder = NSLocalizedString(@"Confirm Passcode", @"Confirm Passcode");
			}
			textField = _confirmPasswordField;
			break;
		case 3:
			if (!_passwordHintField) {
				_passwordHintField = [self setupPasscodeField];
				_passwordHintField.secureTextEntry = NO;
				_passwordHintField.placeholder = NSLocalizedString(@"Hint", @"Hint");
			}
			textField = _passwordHintField;
			break;
	}
	[self makeConstraintForTextField:textField inCell:cell];
}

#pragma mark - UITextField delegate +

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.currentResponder = textField;
	if (_beingDisplayedAsLockscreen || _isUserTurningPasscodeOff) {
		textField.returnKeyType = UIReturnKeyDone;
	} else {
		if (textField == _passwordHintField) {
			textField.returnKeyType = UIReturnKeyDone;
		} else {
			textField.returnKeyType = UIReturnKeyNext;
		}
		if (textField != _passwordHintField) {
			[self setMessage:nil];
            if (_isUserChangingPasscode && IS_IPHONE35) {
                _sectionHeaderLabel.text = NSLocalizedString(@"Enter your passcode", @"Enter your passcode");
            } else {
                _headerLabel.text = NSLocalizedString(@"Enter your passcode", @"Enter your passcode");
            }
		}
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	_failedAttemptLabel.hidden = YES;
	_failedAttemptLabel.text = @"";
	
	return YES;
}

- (void)dismissMe {
	if (_beingPresentedInViewController || _shouldDismissViewController) {
		if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidDismissWithSuccess:)]) {
			[self.delegate passcodeViewControllerDidDismissWithSuccess:YES];
		}
		[self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([self.delegate respondsToSelector:@selector(passcodeViewDidDisappearWithSuccess:)]) {
				[self.delegate passcodeViewDidDisappearWithSuccess:_passcodeValid ];
			}
		});

	} else {
		[self.view removeFromSuperview];
		if (!IS_IOS7) {
			[self removeFromParentViewController];
		}

        if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidDismissWithSuccess:)]) {
            [self.delegate passcodeViewControllerDidDismissWithSuccess:_passcodeValid];
        }

        if ([self.delegate respondsToSelector:@selector(passcodeViewDidDisappearWithSuccess:)]) {
            [self.delegate passcodeViewDidDisappearWithSuccess:_passcodeValid ];
        }
	}
}

- (void)denyAccess {
	_passwordField.text = @"";
	_failedAttempts++;

//	if (kMaxNumberOfAllowedFailedAttempts > 0 &&
//			_failedAttempts == kMaxNumberOfAllowedFailedAttempts &&
//			[self.delegate respondsToSelector: @selector(maxNumberOfFailedAttemptsReached)])
//		[self.delegate maxNumberOfFailedAttemptsReached];
//	Or, if you prefer by notifications:
//	[[NSNotificationCenter defaultCenter] postNotificationName: @"maxNumberOfFailedAttemptsReached"
//														object: self
//													  userInfo: nil];

	if (_isWalletEncryptionKeyMode) {
		[self setMessage:NSLocalizedString(@"Encryption key did not match.", @"")];
	} else {
		if (_failedAttempts == 1) {
			[self setMessage:NSLocalizedString(@"1 Passcode Failed Attempt", @"")];
		} else {
			[self setMessage:[NSString stringWithFormat: NSLocalizedString(@"%li Passcode Failed Attempts", @""), (long)_failedAttempts]];
		}
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (_userPressedCancelButton) return;

	if (_isUserChangingPasscode) {
		if (textField == _passwordField) {
			[self isPasswordValid];
		} else if (textField == _confirmPasswordField) {
			[self isNewPasscodeValid];
		}
	} else if (_isUserEnablingPasscode) {
		if (textField == _aNewPasswordField && ![_aNewPasswordField.text length]) {
			[self setMessage:NSLocalizedString(@"Please enter new passcode.", @"Please enter new passcode.")];
		} else {
			_failedAttemptLabel.text = @"";
			_failedAttemptLabel.hidden = YES;
		}
		if (textField == _confirmPasswordField) {
			[self isNewPasscodeValid];
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (_isWalletEncryptionKeyMode) {
		if ([_passwordField.text length] && [self.delegate verifyEncryptionKeyEncryptionKeyCheckViewController:_passwordField.text]) {
			_passcodeValid = YES;
			[self dismissMe];
			return YES;
		} else {
			[self denyAccess];
		}
		return NO;
	}
	if (_beingDisplayedAsLockscreen || _isUserTurningPasscodeOff) {
		if ([self isPasswordValid]) {
			if (_isUserTurningPasscodeOff) {
				[A3KeychainUtils removePassword];
			} else {
				[[A3AppDelegate instance] saveTimerStartTime];
			}
			_passcodeValid = YES;

			[self dismissMe];
		} else {
			[self denyAccess];
		}
	} else if (_isUserChangingPasscode) {
		UITextField *nextTextField = [self nextTextFieldOf:textField];
		if (!nextTextField) {
			BOOL passcodeValid = [self isPasswordValid];
			if (passcodeValid && [self isNewPasscodeValid]) {
				[[A3AppDelegate instance] saveTimerStartTime];
				[A3KeychainUtils storePassword:_aNewPasswordField.text hint:_passwordHintField.text];
				A3UserDefaults *defaults = [A3UserDefaults standardUserDefaults];
				[defaults setBool:NO forKey:kUserDefaultsKeyForUseSimplePasscode];
				[defaults synchronize];

				_passcodeValid = YES;

				[self dismissMe];
				return YES;
			}
			if (passcodeValid && ![_aNewPasswordField.text length] && ![_confirmPasswordField.text length]) {
				[self setMessage:NSLocalizedString(@"Please enter new passcode.", @"Please enter new passcode.")];
			}
			return NO;
		}
		[nextTextField becomeFirstResponder];
	} else if (_isUserEnablingPasscode) {
		UITextField *nextTextField = [self nextTextFieldOf:textField];
		if (nextTextField) {
			[nextTextField becomeFirstResponder];
		} else {
			if ([self isNewPasscodeValid]) {
				[[A3AppDelegate instance] saveTimerStartTime];
				[A3KeychainUtils storePassword:_aNewPasswordField.text hint:_passwordHintField.text];
				A3UserDefaults *defaults = [A3UserDefaults standardUserDefaults];
				[defaults setBool:NO forKey:kUserDefaultsKeyForUseSimplePasscode];
				[defaults synchronize];

				_passcodeValid = YES;

				[self dismissMe];
			}
		}
	}
	return YES;
}

- (UITextField *)nextTextFieldOf:(UITextField *)textField {
	UITextField *nextTextField = nil;
	if (textField == _passwordField) {
		nextTextField = _aNewPasswordField;
	} else if (textField == _aNewPasswordField) {
		nextTextField = _confirmPasswordField;
	} else if (textField == _confirmPasswordField) {
		nextTextField = _passwordHintField;
	}
	return nextTextField;
}

- (BOOL)isNewPasscodeValid {
	if ([_aNewPasswordField.text length] && [_aNewPasswordField.text isEqualToString:_confirmPasswordField.text]) {
		_failedAttemptLabel.hidden = YES;
		return YES;
	} else {
		if (![_aNewPasswordField.text length] && ![_confirmPasswordField.text length]) {
			return NO;
		} else if (![_aNewPasswordField.text length]) {
			[self setMessage:NSLocalizedString(@"Please enter new passcode.", @"Please enter new passcode.")];
		} else if (![_confirmPasswordField.text length]) {
			[self setMessage:NSLocalizedString(@"Please enter confirm passcode.", @"Please enter confirm passcode.")];
		} else {
			[self setMessage:NSLocalizedString(@"Passcode did not match. Try again.", @"")];
		}
	}
	return NO;
}

- (BOOL)isPasswordValid {
	NSString *savedPasscode = [A3KeychainUtils getPassword];
	if ([_passwordField.text length] && [savedPasscode isEqualToString:_passwordField.text]) {
		_failedAttemptLabel.hidden = YES;
		return YES;
	}
	if ([_passwordField.text length]) {
		[self setMessage:NSLocalizedString(@"Passcode did not match.", @"Passcode did not match.")];
	} else {
		[self setMessage:NSLocalizedString(@"Please enter passcode.", @"Please enter passcode.")];
	}
	return NO;
}

- (void)setMessage:(NSString *)text {
	if ((!IS_IOS7 || IS_IPHONE35) && (_isUserEnablingPasscode || _isUserChangingPasscode)) {
		_headerLabel.text = text;
		if (IS_IPHONE35) {
			_sectionHeaderLabel.text = text;
		}
	} else {
		_failedAttemptLabel.text = text;
		_failedAttemptLabel.hidden = NO;
	}
}

- (void)showHint:(NSString *)text {
	[self setMessage:text];

	double delayInSeconds = 3.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		_failedAttemptLabel.hidden = YES;
	});
}

- (void)viewWillLayoutSubviews {
	CGFloat headerHeight = [self tableView:self.tableView heightForHeaderInSection:0];
	FNLOG(@"%f", headerHeight);
	CGFloat offset = _beingPresentedInViewController ? 64 : 0;
    if (_headerY) {
        _headerY.with.offset(headerHeight * 0.6 + offset);
    }
	offset += 44.0 * [self tableView:self.tableView numberOfRowsInSection:0];
	_footerY.with.offset(headerHeight + headerHeight/2.0 + offset);
	[self.view layoutIfNeeded];
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

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations {
    [super rotateAccordingToStatusBarOrientationAndSupportedOrientations];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, [self keyboardHeight], 0);
}

@end
