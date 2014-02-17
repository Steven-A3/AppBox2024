//
//  A3PasswordViewController.m
//  AppBox3
//
//  Created by A3 on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3PasswordViewController.h"
#import "A3UIDevice.h"
#import "UIViewController+A3Addition.h"
#import "A3AppDelegate+passcode.h"
#import "A3KeychainUtils.h"

#define kFailedAttemptLabelBackgroundColor [UIColor colorWithRed:0.8f green:0.1f blue:0.2f alpha:1.000f]
static CGFloat const kLabelFontSize = 15.0f;
static CGFloat const kFontSizeModifier = 1.5f;
#define kLabelFont (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [UIFont fontWithName: @"AvenirNext-Regular" size: kLabelFontSize * kFontSizeModifier] : [UIFont fontWithName: @"AvenirNext-Regular" size: kLabelFontSize])

@interface A3PasswordViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *aNewPasswordField;
@property (nonatomic, strong) UITextField *confirmPasswordField;
@property (nonatomic, strong) UITextField *passwordHintField;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *failedAttemptLabel;
@property (nonatomic, strong) MASConstraint *labelWidth;
@property (nonatomic, strong) MASConstraint *labelHeight;

@end

@implementation A3PasswordViewController {
	BOOL _isUserBeingAskedForNewPasscode;
	BOOL _isUserTurningPasscodeOff;
	BOOL _isUserChangingPasscode;
	BOOL _isUserEnablingPasscode;
	BOOL _beingDisplayedAsLockscreen;
	BOOL _showCancelButton;
	NSInteger _failedAttempts;
	BOOL _passcodeValid;
	BOOL _beingPresentedInViewController;
}

- (id)initWithDelegate:(id<A3PasscodeViewControllerDelegate>)delegate {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		_delegate = delegate;
		_failedAttempts = 0;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	FNLOG();

	[self.tableView reloadData];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self isMovingToParentViewController]) {
		if (_isUserEnablingPasscode) {
			[_aNewPasswordField becomeFirstResponder];
		} else {
			[_passwordField becomeFirstResponder];
		}
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	if ([_delegate respondsToSelector:@selector(passcodeViewDidDisappearWithSuccess:)]) {
		[_delegate passcodeViewDidDisappearWithSuccess:_passcodeValid ];
	}
}


#pragma mark - Preparing

- (void)prepareAsLockscreen {
	_beingDisplayedAsLockscreen = YES;
	_isUserTurningPasscodeOff = NO;
	_isUserChangingPasscode = NO;
	_isUserEnablingPasscode = NO;
	[self resetUI];
}


- (void)prepareForChangingPasscode {
	_beingDisplayedAsLockscreen = NO;
	_isUserTurningPasscodeOff = NO;
	_isUserChangingPasscode = YES;
	_isUserEnablingPasscode = NO;
	[self resetUI];
}

- (void)prepareForTurningOffPasscode {
	_beingDisplayedAsLockscreen = NO;
	_isUserTurningPasscodeOff = YES;
	_isUserChangingPasscode = NO;
	_isUserEnablingPasscode = NO;
	[self resetUI];
}


- (void)prepareForEnablingPasscode {
	_beingDisplayedAsLockscreen = NO;
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
	[viewController presentViewController: navController animated: YES completion: nil];

	if (_showCancelButton) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
																							   target: self
																							   action: @selector(cancelAndDismissMe)];
	}
}

- (void)cancelAndDismissMe {
	_passcodeValid = NO;

	[_passwordField resignFirstResponder];
	[_aNewPasswordField resignFirstResponder];
	[_confirmPasswordField resignFirstResponder];
	[_passwordHintField resignFirstResponder];

	if ([_delegate respondsToSelector:@selector(passcodeViewControllerWasDismissedWithSuccess:)]) {
		[_delegate passcodeViewControllerWasDismissedWithSuccess:NO];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showLockscreenWithAnimation:(BOOL)animated showCacelButton:(BOOL)showCancelButton {
	FNLOG();
	_showCancelButton = showCancelButton;
	_beingPresentedInViewController = NO;

	[self prepareAsLockscreen];

	UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;

	[mainWindow addSubview: self.view];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(statusBarFrameOrOrientationChanged:)
												 name:UIApplicationDidChangeStatusBarOrientationNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(statusBarFrameOrOrientationChanged:)
												 name:UIApplicationDidChangeStatusBarFrameNotification
											   object:nil];
	[mainWindow.rootViewController addChildViewController: self];
	// All this hassle because a view added to UIWindow does not rotate automatically
	// and if we would have added the view anywhere else, it wouldn't display properly
	// (having a modal on screen when the user leaves the app, for example).

//	CGPoint newCenter;
//	if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
//		self.view.center = CGPointMake(self.view.center.x * -1.f, self.view.center.y);
//		newCenter = CGPointMake(mainWindow.center.x - self.navigationController.navigationBar.frame.size.height / 2,
//				mainWindow.center.y);
//	}
//	else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
//		self.view.center = CGPointMake(self.view.center.x * 2.f, self.view.center.y);
//		newCenter = CGPointMake(mainWindow.center.x + self.navigationController.navigationBar.frame.size.height / 2,
//				mainWindow.center.y);
//	}
//	else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
//		self.view.center = CGPointMake(self.view.center.x, self.view.center.y * -1.f);
//		newCenter = CGPointMake(mainWindow.center.x,
//				mainWindow.center.y - self.navigationController.navigationBar.frame.size.height / 2);
//	}
//	else {
//		self.view.center = CGPointMake(self.view.center.x, self.view.center.y * 2.f);
//		newCenter = CGPointMake(mainWindow.center.x,
//				mainWindow.center.y + self.navigationController.navigationBar.frame.size.height / 2);
//	}
//	if (animated) {
//		[UIView animateWithDuration: 0.15 animations: ^{
//			self.view.center = newCenter;
//		}];
//	} else {
//		self.view.center = newCenter;
//	}

	self.title = NSLocalizedString(@"Enter Passcode", @"");
}

- (void)statusBarFrameOrOrientationChanged:(id)statusBarFrameOrOrientationChanged {

}

- (void)showLockscreenInViewController:(UIViewController *)viewController {
	_showCancelButton = YES;
	_beingPresentedInViewController = YES;

	[self prepareAsLockscreen];
	[self prepareNavigationControllerWithController:viewController];
	self.title = NSLocalizedString(@"Passcode", @"View title while confirm passcode");
}

- (void)showForEnablingPasscodeInViewController:(UIViewController *)viewController {
	FNLOG();
	_showCancelButton = YES;
	[self prepareForEnablingPasscode];
	[self prepareNavigationControllerWithController: viewController];
	self.title = NSLocalizedString(@"Enable Passcode", @"");
}

- (void)showForChangingPasscodeInViewController:(UIViewController *)viewController {
	FNLOG();
	_showCancelButton = YES;
	[self prepareForChangingPasscode];
	[self prepareNavigationControllerWithController: viewController];
	self.title = NSLocalizedString(@"Change Passcode", @"");
}

- (void)showForTurningOffPasscodeInViewController:(UIViewController *)viewController {
	FNLOG();
	_showCancelButton = YES;
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
    return 0;									// Passcode
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
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
	if (IS_IPHONE) return 216;
	return IS_LANDSCAPE ? 352 : 264;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:section];

	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	CGFloat navigationBarHeight = _beingPresentedInViewController ? 44.0 : 0.0;
	return (screenBounds.size.height - (44.0 * numberOfRows + [self keyboardHeight] + navigationBarHeight + 20.0 )) / 2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return [self tableView:tableView heightForHeaderInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (_beingDisplayedAsLockscreen || _isUserTurningPasscodeOff) {
		CGFloat viewHeight = [self tableView:tableView heightForHeaderInSection:section];
		UIView *view = [UIView new];
		CGRect frame = [self screenBoundsAdjustedWithOrientation];
		frame.size.height = viewHeight;
		[view setFrame:frame];

		_headerLabel = [UILabel new];
		_headerLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
		_headerLabel.textColor = [UIColor blackColor];
		_headerLabel.text = @"Enter your passcode";
		_headerLabel.textAlignment = NSTextAlignmentCenter;
		[view addSubview:_headerLabel];

		[_headerLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(view.left);
			make.right.equalTo(view.right);
			make.centerY.equalTo(view.top).with.offset(viewHeight * 0.6);
		}];

		return view;
	}
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	CGFloat viewHeight = [self tableView:tableView heightForHeaderInSection:section];
	UIView *view = [UIView new];
	CGRect frame = [self screenBoundsAdjustedWithOrientation];
	frame.size.height = viewHeight;
	[view setFrame:frame];

	if (!_failedAttemptLabel) {
		_failedAttemptLabel = [UILabel new];
		_failedAttemptLabel.font = kLabelFont;
		_failedAttemptLabel.textColor = [UIColor whiteColor];
		_failedAttemptLabel.text = @"Enter your passcode";
		_failedAttemptLabel.textAlignment = NSTextAlignmentCenter;
		_failedAttemptLabel.hidden = YES;
		_failedAttemptLabel.backgroundColor = kFailedAttemptLabelBackgroundColor;
		_failedAttemptLabel.layer.cornerRadius = 22 * 0.5;
	}
	[view addSubview:_failedAttemptLabel];

	CGSize size = [_failedAttemptLabel.text sizeWithAttributes:@{NSFontAttributeName:_failedAttemptLabel.font, NSForegroundColorAttributeName:[UIColor blackColor]}];
	[_failedAttemptLabel makeConstraints:^(MASConstraintMaker *make) {
		_labelWidth = make.width.equalTo(@(size.width));
		_labelHeight = make.height.equalTo(@(size.height));
		make.centerX.equalTo(view.centerX);
		make.centerY.equalTo(view.centerY);
	}];
	return view;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	// Show hint
	NSString *hintString = [A3KeychainUtils getHint];
	[self showHint:hintString];
}

- (UITextField *)setupPasscodeField {
	UITextField *textField = [UITextField new];
	textField.secureTextEntry = YES;
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.delegate = self;
	return textField;
}

- (void)setupCell:(UITableViewCell *)cell forRowAskingPasscodeAtIndexPath:(NSIndexPath *)indexPath {
	if (!_passwordField) {
		_passwordField = [self setupPasscodeField];
	}
	[cell addSubview:_passwordField];
	[_passwordField makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(cell.left).with.offset(IS_IPHONE ? 15 : 28);
		make.top.equalTo(cell.top).with.offset(10);
		make.bottom.equalTo(cell.bottom).with.offset(-10);
		make.right.equalTo(cell.right).with.offset(-50);
	}];
	
	cell.accessoryType = UITableViewCellAccessoryDetailButton;
}

- (void)makeConstraintForTextField:(UITextField *)textField inCell:(UITableViewCell *)cell {
	[cell addSubview:textField];
	[textField makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(cell.left).with.offset(170);
		make.top.equalTo(cell.top).with.offset(10);
		make.bottom.equalTo(cell.bottom).with.offset(-10);
		make.right.equalTo(cell.right).with.offset(IS_IPHONE ? 15 : 28);
	}];
}

- (void)setupCell:(UITableViewCell *)cell forRowEnablingPasscodeAtIndexPath:(NSIndexPath *)indexPath {
	UITextField *textField;
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"New Passcode";
			if (!_aNewPasswordField) {
				_aNewPasswordField = [self setupPasscodeField];
			}
			textField = _aNewPasswordField;
			break;
		case 1:
			cell.textLabel.text = @"Confirm Passcode";
			if (!_confirmPasswordField) {
				_confirmPasswordField = [self setupPasscodeField];
			}
			textField = _confirmPasswordField;
			break;
		case 2:
			cell.textLabel.text = @"Hint";
			if (!_passwordHintField) {
				_passwordHintField = [UITextField new];
				_passwordHintField.keyboardType = UIKeyboardTypeDefault;
				_passwordHintField.delegate = self;
			}
			textField = _passwordHintField;
			break;
	}
	[self makeConstraintForTextField:textField inCell:cell];
}

- (void)setupCell:(UITableViewCell *)cell forRowChangingPasscodeAtIndexPath:(NSIndexPath *)indexPath {
	UITextField *textField;
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Old Passcode";
			if (!_passwordField) {
				_passwordField = [self setupPasscodeField];
			}
			textField = _passwordField;
			break;
		case 1:
			cell.textLabel.text = @"New Passcode";
			if (!_aNewPasswordField) {
				_aNewPasswordField = [self setupPasscodeField];
			}
			textField = _aNewPasswordField;
			break;
		case 2:
			cell.textLabel.text = @"Confirm Passcode";
			if (!_confirmPasswordField) {
				_confirmPasswordField = [self setupPasscodeField];
			}
			textField = _confirmPasswordField;
			break;
		case 3:
			cell.textLabel.text = @"Hint";
			if (!_passwordHintField) {
				_passwordHintField = [UITextField new];
				_passwordHintField.keyboardType = UIKeyboardTypeDefault;
				_passwordHintField.delegate = self;
			}
			textField = _passwordHintField;
			break;
	}
	[self makeConstraintForTextField:textField inCell:cell];
}

#pragma mark - UITextField delegate +

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if (_beingDisplayedAsLockscreen || _isUserTurningPasscodeOff) {
		textField.returnKeyType = UIReturnKeyDone;
	} else {
		if (textField == _passwordHintField) {
			textField.returnKeyType = UIReturnKeyDone;
		} else {
			textField.returnKeyType = UIReturnKeyNext;
		}
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	_failedAttemptLabel.hidden = YES;
	_failedAttemptLabel.text = @"";
	
	return YES;
}

- (void)dismissMe {

	if ([self navigationController]) {
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		[self.view removeFromSuperview];
		[self removeFromParentViewController];
	}

	if ([_delegate respondsToSelector:@selector(passcodeViewControllerWasDismissedWithSuccess:)]) {
		[_delegate passcodeViewControllerWasDismissedWithSuccess:YES];
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

	if (_failedAttempts == 1) {
		[self setMessage:NSLocalizedString(@"1 Passcode Failed Attempt", @"")];
	} else {
		[self setMessage:[NSString stringWithFormat: NSLocalizedString(@"%li Passcode Failed Attempts", @""), (long)_failedAttempts]];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (_isUserChangingPasscode) {
		if (textField == _passwordField) {
			[self isPasswordValid];
		} else if (textField == _confirmPasswordField) {
			[self isNewPasscodeValid];
		}
	} else if (_isUserEnablingPasscode) {
		if (textField == _aNewPasswordField && ![_aNewPasswordField.text length]) {
			[self setMessage:@"Please enter new passcode."];
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
	if (_beingDisplayedAsLockscreen || _isUserTurningPasscodeOff) {
		if ([self isPasswordValid]) {
			if (_isUserTurningPasscodeOff) {
				[A3KeychainUtils removePassword];
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
				
				[A3KeychainUtils storePassword:_aNewPasswordField.text hint:_passwordHintField.text];
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				[defaults setBool:NO forKey:kUserDefaultsKeyForUseSimplePasscode];
				[defaults synchronize];

				_passcodeValid = YES;

				[self dismissMe];
				return YES;
			}
			if (passcodeValid && ![_aNewPasswordField.text length] && ![_confirmPasswordField.text length]) {
				[self setMessage:@"Please enter new passcode."];
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
				
				[A3KeychainUtils storePassword:_aNewPasswordField.text hint:_passwordHintField.text];
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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
			[self setMessage:@"Please enter new passcode."];
		} else if (![_confirmPasswordField.text length]) {
			[self setMessage:@"Please enter confirm passcode."];
		} else {
			[self setMessage:@"New Passcode and Confirm \nPasscode did not match."];
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
		[self setMessage:@"Passcode did not match."];
	} else {
		[self setMessage:@"Please enter passcode."];
	}
	return NO;
}

- (void)setMessage:(NSString *)text {
	@autoreleasepool {
		_failedAttemptLabel.text = text;
		_failedAttemptLabel.hidden = NO;
		NSArray *lines = [_failedAttemptLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
		_failedAttemptLabel.numberOfLines = [lines count];
		CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:_failedAttemptLabel.font, NSForegroundColorAttributeName:[UIColor blackColor]}];
		_labelWidth.equalTo(@(size.width + 20));
		_labelHeight.equalTo(@(size.height));
		[_failedAttemptLabel.superview layoutIfNeeded];
	}
}

- (void)showHint:(NSString *)text {
	@autoreleasepool {
		[self setMessage:text];
		_failedAttemptLabel.backgroundColor = [UIColor lightGrayColor];
		
		double delayInSeconds = 3.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			_failedAttemptLabel.hidden = YES;
			_failedAttemptLabel.backgroundColor = kFailedAttemptLabelBackgroundColor;
		});
	}
}

@end
