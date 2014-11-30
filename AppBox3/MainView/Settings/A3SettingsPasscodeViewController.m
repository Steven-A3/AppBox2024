//
//  A3SettingsPasscodeViewController.m
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>
#import "A3SettingsPasscodeViewController.h"
#import "A3AppDelegate+passcode.h"
#import "A3PasscodeViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3KeychainUtils.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "Reachability.h"
#import "A3UserDefaults.h"

@interface A3SettingsPasscodeViewController () <A3PasscodeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UISwitch *useSimpleCodeSwitch;
@property (nonatomic, strong) UISwitch *touchIDSwitch;
@property (nonatomic, strong) UISwitch *askPasscodeForStarting;
@property (nonatomic, strong) UISwitch *askPasscodeForSettings;
@property (nonatomic, strong) UISwitch *askPasscodeForDaysCounter;
@property (nonatomic, strong) UISwitch *askPasscodeForLadyCalendar;
@property (nonatomic, strong) UISwitch *askPasscodeForWallet;
@property (nonatomic, strong) UIViewController<A3PasscodeViewControllerProtocol> *passcodeViewController;

@end

@implementation A3SettingsPasscodeViewController {
	BOOL _changingPasscodeType;
	BOOL _passwordConfirmedWhileSwitchingSimplePasscodeUse;
	BOOL _touchIDAvailable;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	if (!IS_IOS7) {
		LAContext *context = [LAContext new];
		NSError *error;
		_touchIDAvailable = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
	}

	[self makeBackButtonEmptyArrow];

	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (![self isMovingToParentViewController]) {
		if (!_changingPasscodeType) {
			[self.tableView reloadData];
		}
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			[self willDisplaySection0Cell:cell forRow:indexPath.row];
			break;
		case 1:
			[self willDisplaySection1Cell:cell forRow:indexPath.row];
			break;
		case 2:
			[self willDisplaySection2Cell:cell forRow:indexPath.row];
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 2) return UITableViewAutomaticDimension;
	return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section < 2) return UITableViewAutomaticDimension;
	BOOL isLastSection = ([self.tableView numberOfSections] - 1) == section;
	return [self standardHeightForFooterIsLastSection:isLastSection];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && indexPath.row == 1) {
		if (!_touchIDAvailable) {
			return 0;
		}
	}
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (BOOL)passcodeEnabled {
	return [[A3KeychainUtils getPassword] length] > 0;
}

- (void)willDisplaySection0Cell:(UITableViewCell *)cell forRow:(NSInteger)row {
	BOOL passcodeEnabled = [self passcodeEnabled];
	switch (row) {
		case 0:
			cell.textLabel.text =  passcodeEnabled ? NSLocalizedString(@"Turn Passcode Off", @"Turn Passcode Off") : NSLocalizedString(@"Turn Passcode On", @"Turn Passcode On");
			cell.textLabel.textColor = [self.view tintColor];
			break;
		case 1:
			cell.selectionStyle = passcodeEnabled ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
			cell.textLabel.textColor = passcodeEnabled ? [self.view tintColor] : A3_TEXT_COLOR_DISABLED;
			break;
	}
}

- (void)willDisplaySection1Cell:(UITableViewCell *)cell forRow:(NSInteger)row {
	switch (row) {
		case 0: {
			cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
			cell.detailTextLabel.minimumScaleFactor = 0.5;
			cell.detailTextLabel.text = [A3KeychainUtils passcodeTimeString];
			break;
		}
		case 1: {
			if (_touchIDAvailable) {
				if (!_touchIDSwitch) {
					_touchIDSwitch = [UISwitch new];
					[_touchIDSwitch addTarget:self action:@selector(touchIDSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
				}
				[_touchIDSwitch setOn:[[A3AppDelegate instance] useTouchID]];
				cell.accessoryView = _touchIDSwitch;
			}
			break;
		}
		case 2: {
			if (!_useSimpleCodeSwitch) {
				_useSimpleCodeSwitch = [UISwitch new];
				[_useSimpleCodeSwitch addTarget:self action:@selector(useSimplePasscodeValuedChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_useSimpleCodeSwitch setOn:[[A3AppDelegate instance] isSimplePasscode]];
			cell.accessoryView = _useSimpleCodeSwitch;
			break;
		}
	 }
}

- (void)willDisplaySection2Cell:(UITableViewCell *)cell forRow:(NSInteger)row {
	BOOL passcodeEnabled = [self passcodeEnabled];
	switch (row) {
		case 0:
			if (!_askPasscodeForStarting) {
				_askPasscodeForStarting = [UISwitch new];
				[_askPasscodeForStarting addTarget:self action:@selector(askPasscodeForStartingValueChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_askPasscodeForStarting setEnabled:passcodeEnabled];
			[_askPasscodeForStarting setOn:[[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForStarting]];
			cell.accessoryView = _askPasscodeForStarting;
			break;
		case 1:
			if (!_askPasscodeForSettings) {
				_askPasscodeForSettings = [UISwitch new];
				[_askPasscodeForSettings addTarget:self action:@selector(askPasscodeForSettingsValueChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_askPasscodeForSettings setEnabled:passcodeEnabled];
			[_askPasscodeForSettings setOn:[[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForSettings]];
			cell.accessoryView = _askPasscodeForSettings;
			break;
		case 2:
			if (!_askPasscodeForDaysCounter) {
				_askPasscodeForDaysCounter = [UISwitch new];
				[_askPasscodeForDaysCounter addTarget:self action:@selector(askPasscodeForDaysCounterValueChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_askPasscodeForDaysCounter setEnabled:passcodeEnabled];
			[_askPasscodeForDaysCounter setOn:[[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForDaysCounter]];
			cell.accessoryView = _askPasscodeForDaysCounter;
			break;
		case 3:
			if (!_askPasscodeForLadyCalendar) {
				_askPasscodeForLadyCalendar = [UISwitch new];
				[_askPasscodeForLadyCalendar addTarget:self action:@selector(askPasscodeForLadyCalendarValuedChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_askPasscodeForLadyCalendar setEnabled:passcodeEnabled];
			[_askPasscodeForLadyCalendar setOn:[[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar]];
			cell.accessoryView = _askPasscodeForLadyCalendar;
			break;
		case 4:
			if (!_askPasscodeForWallet) {
				_askPasscodeForWallet = [UISwitch new];
				[_askPasscodeForWallet addTarget:self action:@selector(askPasscodeForWalletValuedChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_askPasscodeForWallet setEnabled:passcodeEnabled];
			[_askPasscodeForWallet setOn:[[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForWallet]];
			cell.accessoryView = _askPasscodeForWallet;
			break;
	}
}

- (void)touchIDSwitchValueChanged:(UISwitch *)control {
	[[A3AppDelegate instance] setUseTouchID:control.on];
	if ([control isOn]) {
		[[A3UserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKeyForPasscodeTimerDuration];
		[[A3UserDefaults standardUserDefaults] synchronize];

		[self.tableView reloadData];
	}
}

- (void)askPasscodeForStartingValueChanged:(UISwitch *)control {
	[[A3AppDelegate instance] setEnableAskPasscodeForStarting:control.on];
	[self.tableView reloadData];
}

- (void)askPasscodeForSettingsValueChanged:(UISwitch *)control {
	A3UserDefaults *defaults = [A3UserDefaults standardUserDefaults];
	[defaults setBool:control.isOn forKey:kUserDefaultsKeyForAskPasscodeForSettings];
	[defaults synchronize];
}

- (void)askPasscodeForDaysCounterValueChanged:(UISwitch *)control {
	A3UserDefaults *defaults = [A3UserDefaults standardUserDefaults];
	[defaults setBool:control.isOn forKey:kUserDefaultsKeyForAskPasscodeForDaysCounter];
	[defaults synchronize];
}

- (void)askPasscodeForLadyCalendarValuedChanged:(UISwitch *)control {
	A3UserDefaults *defaults = [A3UserDefaults standardUserDefaults];
	[defaults setBool:control.isOn forKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar];
	[defaults synchronize];
}

- (void)askPasscodeForWalletValuedChanged:(UISwitch *)control {
	A3UserDefaults *defaults = [A3UserDefaults standardUserDefaults];
	[defaults setBool:control.isOn forKey:kUserDefaultsKeyForAskPasscodeForWallet];
	[defaults synchronize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			[self didSelectRowAtSection0:indexPath.row];
			break;
		case 1:
			[self didSelectRowAtSection1:indexPath.row];
			break;
		case 3:
			[self alertSecurityInfo];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			break;
	}

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 3) {
		[self alertSecurityInfo];
	}
}

- (void)alertSecurityInfo {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
														message:NSLocalizedString(@"SECURITY_INFO", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:NSLocalizedString(@"How To Enable Data Protection", @"How To Enable Data Protection"), NSLocalizedString(@"Learn about iOS Security", @"Learn about iOS Security"), nil];
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex != alertView.cancelButtonIndex) {
		if (![[A3AppDelegate instance].reachability isReachable]) {
			[self alertInternetConnectionIsNotAvailable];
			return;
		}
		if (buttonIndex == 1) {
			NSArray *availableLocales = @[@"en_US", @"cs_CZ", @"da_DK", @"de_DE", @"el_GR", @"es_ES", @"fi_FI", @"fr_FR",
					@"hr_HR", @"hu_HU", @"id_ID", @"it_IT", @"ja_JP", @"ko_KR", @"nl_NL", @"no_NO", @"pl_PL", @"pt_BR",
					@"pt_PT", @"ro_RO", @"ru_RU", @"sk_SK", @"sv_SE", @"th_TH", @"tr_TR", @"zh_CN", @"zh_TW"
			];
			NSString *currentLanguageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
			NSUInteger languageIndex = [availableLocales indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
				BOOL result = [currentLanguageCode isEqualToString:[obj substringToIndex:2]];
				if (result) *stop = YES;
				return result;
			}];
			if (languageIndex == NSNotFound) {
				languageIndex = 0;
			}
			NSString *urlString = [NSString stringWithFormat:@"http://support.apple.com/kb/HT4175?viewlocale=%@", availableLocales[languageIndex]];
			NSURL *url = [NSURL URLWithString:urlString];
			[[UIApplication sharedApplication] openURL:url];
		} else if (buttonIndex == 2) {
			NSURL *url = [NSURL URLWithString:@"https://www.apple.com/iphone/business/it/security.html"];
			[[UIApplication sharedApplication] openURL:url];
		}
	}
}

- (void)didSelectRowAtSection0:(NSInteger)row {
	BOOL passcodeEnabled = [self passcodeEnabled];

	switch (row) {
		case 0:{
			if ([_useSimpleCodeSwitch isOn]) {
				_passcodeViewController = [[A3PasscodeViewController alloc] initWithDelegate:self];
			} else {
				_passcodeViewController = [[A3PasswordViewController alloc] initWithDelegate:self];
			}
			if (passcodeEnabled) {
				[_passcodeViewController showForTurningOffPasscodeInViewController:self];
			} else {
				[_passcodeViewController showForEnablingPasscodeInViewController:self];
			}
			break;
		}
		case 1: {
			if (passcodeEnabled) {
				if ([_useSimpleCodeSwitch isOn]) {
					_passcodeViewController = [[A3PasscodeViewController alloc] initWithDelegate:self];
				} else {
					_passcodeViewController = [[A3PasswordViewController alloc] initWithDelegate:self];
				}
				[_passcodeViewController showForChangingPasscodeInViewController:self];
			}
		}
	}
}

- (void)didSelectRowAtSection1:(NSInteger)row {
}

- (void)useSimplePasscodeValuedChanged:(UISwitch *)control {
	if ([A3KeychainUtils getPassword]) {
		_changingPasscodeType = YES;
		_passwordConfirmedWhileSwitchingSimplePasscodeUse = NO;
		// Need confirm old style passcode
		if ([_useSimpleCodeSwitch isOn]) {
			_passcodeViewController = [[A3PasswordViewController alloc] initWithDelegate:self];
		} else {
			_passcodeViewController = [[A3PasscodeViewController alloc] initWithDelegate:self];
		}
		[_passcodeViewController showLockScreenInViewController:self];
	} else {
		A3UserDefaults *defaults = [A3UserDefaults standardUserDefaults];
		[defaults setBool:control.isOn forKey:kUserDefaultsKeyForUseSimplePasscode];
		[defaults synchronize];
	}
}

#pragma mark - A3PasscodeViewControllerDelegate

- (void)passcodeViewDidDisappearWithSuccess:(BOOL)success {
	if (_changingPasscodeType) {
		if (!_passwordConfirmedWhileSwitchingSimplePasscodeUse) {
			if (success) {
				_passwordConfirmedWhileSwitchingSimplePasscodeUse = YES;
			} else {
				[_useSimpleCodeSwitch setOn:!_useSimpleCodeSwitch.isOn];
				_changingPasscodeType = NO;
			}
			if (![[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForUseSimplePasscode]) {
				_passcodeViewController = [[A3PasscodeViewController alloc] initWithDelegate:self];
			} else {
				_passcodeViewController = [[A3PasswordViewController alloc] initWithDelegate:self];
			}
			[_passcodeViewController showForEnablingPasscodeInViewController:self];
		} else {
			_changingPasscodeType = NO;
			_passwordConfirmedWhileSwitchingSimplePasscodeUse = NO;
		}
	} else {
		_passcodeViewController = nil;
		[self.tableView reloadData];
	}
}

@end
