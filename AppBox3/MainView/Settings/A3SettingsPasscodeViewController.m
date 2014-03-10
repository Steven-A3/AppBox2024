//
//  A3SettingsPasscodeViewController.m
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsPasscodeViewController.h"
#import "A3AppDelegate+passcode.h"
#import "A3PasscodeViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3PasswordViewController.h"
#import "A3KeychainUtils.h"
#import "A3UIDevice.h"
#import "UITableViewController+standardDimension.h"

@interface A3SettingsPasscodeViewController () <A3PasscodeViewControllerDelegate>

@property (nonatomic, strong) UISwitch *useSimpleCodeSwitch;
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
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
	if (section == 1) return UITableViewAutomaticDimension;
	return [self standardHeightForFooterInSection:section];
}

- (BOOL)passcodeEnabled {
	return [[A3KeychainUtils getPassword] length] > 0;
}

- (void)willDisplaySection0Cell:(UITableViewCell *)cell forRow:(NSInteger)row {
	BOOL passcodeEnabled = [self passcodeEnabled];
	switch (row) {
		case 0:
			cell.textLabel.text =  passcodeEnabled ? @"Turn Passcode Off" : @"Turn Passcode On";
			cell.textLabel.textColor = [self.view tintColor];
			break;
		case 1:
			cell.selectionStyle = passcodeEnabled ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
			cell.textLabel.textColor = passcodeEnabled ? A3_TEXT_COLOR_DEFAULT : A3_TEXT_COLOR_DISABLED;
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
			if (!_useSimpleCodeSwitch) {
				_useSimpleCodeSwitch = [UISwitch new];
				[_useSimpleCodeSwitch addTarget:self action:@selector(useSimplePasscodeValuedChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_useSimpleCodeSwitch setOn:[[A3AppDelegate instance] isSimplePasscode]];
			cell.accessoryView = _useSimpleCodeSwitch;
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
			[_askPasscodeForStarting setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForStarting]];
			cell.accessoryView = _askPasscodeForStarting;
			break;
		case 1:
			if (!_askPasscodeForSettings) {
				_askPasscodeForSettings = [UISwitch new];
				[_askPasscodeForSettings addTarget:self action:@selector(askPasscodeForSettingsValueChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_askPasscodeForSettings setEnabled:passcodeEnabled];
			[_askPasscodeForSettings setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForSettings]];
			cell.accessoryView = _askPasscodeForSettings;
			break;
		case 2:
			if (!_askPasscodeForDaysCounter) {
				_askPasscodeForDaysCounter = [UISwitch new];
				[_askPasscodeForDaysCounter addTarget:self action:@selector(askPasscodeForDaysCounterValueChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_askPasscodeForDaysCounter setEnabled:passcodeEnabled];
			[_askPasscodeForDaysCounter setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForDaysCounter]];
			cell.accessoryView = _askPasscodeForDaysCounter;
			break;
		case 3:
			if (!_askPasscodeForLadyCalendar) {
				_askPasscodeForLadyCalendar = [UISwitch new];
				[_askPasscodeForLadyCalendar addTarget:self action:@selector(askPasscodeForLadyCalendarValuedChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_askPasscodeForLadyCalendar setEnabled:passcodeEnabled];
			[_askPasscodeForLadyCalendar setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar]];
			cell.accessoryView = _askPasscodeForLadyCalendar;
			break;
		case 4:
			if (!_askPasscodeForWallet) {
				_askPasscodeForWallet = [UISwitch new];
				[_askPasscodeForWallet addTarget:self action:@selector(askPasscodeForWalletValuedChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_askPasscodeForWallet setEnabled:passcodeEnabled];
			[_askPasscodeForWallet setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForWallet]];
			cell.accessoryView = _askPasscodeForWallet;
			break;
	}
}

- (void)askPasscodeForStartingValueChanged:(UISwitch *)control {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:control.isOn forKey:kUserDefaultsKeyForAskPasscodeForStarting];
	[defaults synchronize];
}

- (void)askPasscodeForSettingsValueChanged:(UISwitch *)control {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:control.isOn forKey:kUserDefaultsKeyForAskPasscodeForSettings];
	[defaults synchronize];
}

- (void)askPasscodeForDaysCounterValueChanged:(UISwitch *)control {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:control.isOn forKey:kUserDefaultsKeyForAskPasscodeForDaysCounter];
	[defaults synchronize];
}

- (void)askPasscodeForLadyCalendarValuedChanged:(UISwitch *)control {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:control.isOn forKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar];
	[defaults synchronize];
}

- (void)askPasscodeForWalletValuedChanged:(UISwitch *)control {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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
		[_passcodeViewController showLockscreenInViewController:self];
	} else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:control.isOn forKey:kUserDefaultsKeyForUseSimplePasscode];
		[defaults synchronize];
	}
}

#pragma mark - A3PasscodeViewControllerDelegate

- (void)passcodeViewControllerWasDismissedWithSuccess:(BOOL)success {
	_passcodeViewController = nil;

	if (_changingPasscodeType) {
		if (!_passwordConfirmedWhileSwitchingSimplePasscodeUse) {
			if (success) {
				_passwordConfirmedWhileSwitchingSimplePasscodeUse = YES;
			} else {
				[_useSimpleCodeSwitch setOn:!_useSimpleCodeSwitch.isOn];
				_changingPasscodeType = NO;
			}
		} else {
			_changingPasscodeType = NO;
			_passwordConfirmedWhileSwitchingSimplePasscodeUse = NO;
		}
	} else {
		[self.tableView reloadData];
	}
}

- (void)passcodeViewDidDisappearWithSuccess:(BOOL)success {
	if (_changingPasscodeType) {
		if (_passwordConfirmedWhileSwitchingSimplePasscodeUse) {
			if ([_useSimpleCodeSwitch isOn]) {
				_passcodeViewController = [[A3PasscodeViewController alloc] initWithDelegate:self];
			} else {
				_passcodeViewController = [[A3PasswordViewController alloc] initWithDelegate:self];
			}
			[_passcodeViewController showForEnablingPasscodeInViewController:self];
		} else {
			_changingPasscodeType = NO;
			_passwordConfirmedWhileSwitchingSimplePasscodeUse = NO;
		}
	}
}

@end
