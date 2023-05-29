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
@import AppBoxKit;
#import "UIViewController+extension.h"
#import "A3PasswordViewController.h"

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
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (![self isMovingToParentViewController]) {
		if (!_changingPasscodeType) {
			[self.tableView reloadData];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
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
                if (@available(iOS 11.0, *)) {
                    LAContext *context = [LAContext new];
                    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
                    if (context.biometryType == LABiometryTypeFaceID) {
                        cell.textLabel.text = NSLocalizedString(@"Face ID", nil);
                    }
                }
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
			if (!_askPasscodeForDaysCounter) {
				_askPasscodeForDaysCounter = [UISwitch new];
				[_askPasscodeForDaysCounter addTarget:self action:@selector(askPasscodeForDaysCounterValueChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_askPasscodeForDaysCounter setEnabled:passcodeEnabled];
			[_askPasscodeForDaysCounter setOn:[[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForDaysCounter]];
			cell.accessoryView = _askPasscodeForDaysCounter;
			break;
		case 2:
			if (!_askPasscodeForLadyCalendar) {
				_askPasscodeForLadyCalendar = [UISwitch new];
				[_askPasscodeForLadyCalendar addTarget:self action:@selector(askPasscodeForLadyCalendarValuedChanged:) forControlEvents:UIControlEventValueChanged];
			}
			[_askPasscodeForLadyCalendar setEnabled:passcodeEnabled];
			[_askPasscodeForLadyCalendar setOn:[[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForLadyCalendar]];
			cell.accessoryView = _askPasscodeForLadyCalendar;
			break;
		case 3:
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
            // Turn passcode On
            // Change passcode
			[self didSelectRowAtSection0:indexPath.row];
			break;
		case 1:
            // Require Passcode
            // Face ID
            // Simple passcode
			[self didSelectRowAtSection1:indexPath.row];
			break;
		case 3:
            // More Information About Security
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
    UIAlertController *alertController = [self alertControllerWithTitle:NSLocalizedString(@"Info", @"Info")
                                                                message:NSLocalizedString(@"SECURITY_INFO", nil)];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"How To Enable Data Protection", @"How To Enable Data Protection")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(__kindof UIAlertAction * _Nonnull action) {
        NSString *language = [NSLocale preferredLanguages][0];
        NSString *urlString = [NSString stringWithFormat:@"https://help.apple.com/iphone/10/?lang=%@#/iph14a867ae", language];
        NSURL *url = [NSURL URLWithString:urlString];
        [self presentWebViewControllerWithURL:url];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Learn about iOS Security", @"Learn about iOS Security")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(__kindof UIAlertAction * _Nonnull action) {
        // 언어가 영어인 경우에는 지역 코드가 없는 URL을 사용한다.
        NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
//            NSString *countryCode = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];

        if ([languageCode isEqualToString:@"en"]) {
            // 2017년 4월 27일
            // Mar 2017 버전 Security 문서는 현재 소수 국가 버전만 지원이 된다.
//                if ([countryCode isEqualToString:@"gb"]) {
//                    NSURL *url = [self securityInfoURLWithCountryCode:@"uk"];
//                    [self presentWebViewControllerWithURL:url];
//                    return;
//                }
//                NSArray *countriesSupported = @[@"ae", @"ca", @"au", @"za", @"in", @"ie", @"my", @"nz", @"sg"];
//                NSInteger indexOfCountry = [countriesSupported indexOfObject:countryCode];
//                if (indexOfCountry != NSNotFound) {
//                    NSURL *url = [self securityInfoURLWithCountryCode:countryCode];
//                    [self presentWebViewControllerWithURL:url];
//                    return;
//                }
            NSURL *url = [self securityInfoURLWithCountryCode:nil];
            [self presentWebViewControllerWithURL:url];
            return;
        }
        NSDictionary *languageCodes = @{
                                        @"ja":@"jp",
                                        @"zh-hans":@"cn",
                                        @"zh-hant":@"tw",
                                        @"es":@"es",
                                        @"fr":@"fr",
                                        @"it":@"it",
                                        @"de":@"de",
                                        };
        NSString *targetCountryCode = languageCodes[languageCode];
        if (targetCountryCode) {
            NSURL *url = [self securityInfoURLWithCountryCode:targetCountryCode];
            [self presentWebViewControllerWithURL:url];
            return;
        }

//            // dk, ko, jp, cn, ae, at, au, ru, no, nl, fi, tw, hk, tr, th, za, it, in, ca,
//            // de, es, fr, uk(for gb), hk, id, ie, my, nl, nz, se, sg
//            NSArray *countrisSupported = @[@"dk", @"ko", @"jp", @"cn", @"ae", @"at",
//                                           @"au", @"ru", @"no", @"fi", @"nl", @"tw",
//                                           @"hk", @"tr", @"th", @"za", @"it", @"in",
//                                           @"ca", @"de", @"es", @"fr", @"id", @"ie",
//                                           @"my", @"nl", @"nz", @"se", @"sg"];
//            if ([countrisSupported indexOfObject:countryCode] != NSNotFound) {
//                NSURL *url = [self securityInfoURLWithCountryCode:countryCode];
//                [self presentWebViewControllerWithURL:url];
//                return;
//            }
        NSURL *url = [self securityInfoURLWithCountryCode:nil];
        [self presentWebViewControllerWithURL:url];
    }]];
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (NSURL *)securityInfoURLWithCountryCode:(NSString *)countryCode {
	if (countryCode == nil) {
		return [NSURL URLWithString:@"https://images.apple.com/business/docs/iOS_Security_Guide.pdf"];
	}
	return [NSURL URLWithString:[NSString stringWithFormat:@"https://images.apple.com/%@/business/docs/iOS_Security_Guide.pdf", countryCode]];
}

- (void)didSelectRowAtSection0:(NSInteger)row {
	BOOL passcodeEnabled = [self passcodeEnabled];

	switch (row) {
		case 0:{
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];

			if ([_useSimpleCodeSwitch isOn]) {
				_passcodeViewController = [[A3PasscodeViewController alloc] initWithDelegate:self];
			} else {
				_passcodeViewController = [[A3PasswordViewController alloc] initWithDelegate:self];
			}
			if (passcodeEnabled) {
                UIViewController *viewController = [PasswordViewFactory makeAskPasswordViewWithCompletionHandler:^(BOOL success) {
                    [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
                    
                    if (success) {
                        [A3KeychainUtils removePassword];
                    }
                    double delayInSeconds = 0.1;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                        [self.tableView reloadData];
                    });
                }];
                [self presentViewController:viewController animated:YES completion:NULL];
//				[_passcodeViewController showForTurningOffPasscodeInViewController:self];
			} else {
                UIViewController *viewController = [PasswordViewFactory makePasswordViewWithCompletionHandler:^(BOOL success) {
                    [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
                    
                    double delayInSeconds = 0.1;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self.tableView reloadData];
                    });
                }];
                [self presentViewController:viewController animated:YES completion:nil];
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
				[_useSimpleCodeSwitch setOn:[[A3AppDelegate instance] isSimplePasscode]];
				_changingPasscodeType = NO;
				_passcodeViewController = nil;
				return;
			}
			if (![[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForUseSimplePasscode]) {
				_passcodeViewController = [[A3PasscodeViewController alloc] initWithDelegate:self];
			} else {
				_passcodeViewController = [[A3PasswordViewController alloc] initWithDelegate:self];
			}
			[_passcodeViewController showForEnablingPasscodeInViewController:self];
		} else {
			_passcodeViewController = nil;
			[_useSimpleCodeSwitch setOn:[[A3AppDelegate instance] isSimplePasscode]];
			_changingPasscodeType = NO;
		}
	} else {
		_passcodeViewController = nil;
		[self.tableView reloadData];
	}
}

@end
