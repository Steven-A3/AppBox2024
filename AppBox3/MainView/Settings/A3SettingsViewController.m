//
//  A3SettingsViewController.m
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+NumberKeyboard.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "A3SettingsViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3UserDefaults+A3Addition.h"
#import "A3KeychainUtils.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "Reachability.h"
#import "A3SyncManager.h"
#import "A3SettingsHomeStyleSelectTableViewCell.h"

typedef NS_ENUM(NSInteger, A3SettingsTableViewRow) {
	A3SettingsRowUseiCloud = 1100,
	A3SettingsRowPasscodeLock = 2100,
	A3SettingsRowWalletSecurity = 2200,
	A3SettingsRowStartingApp = 3100,
	A3SettingsRowEditFavorites = 3200,
	A3SettingsRowRecentToKeep = 3300,
	A3SettingsRowThemeColor = 4100,
	A3SettingsRowLunarCalendar = 4200,
	A3SettingsRowMainMenuStyle = 5200,
};

@interface A3SettingsViewController () <A3PasscodeViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIViewController<A3PasscodeViewControllerProtocol> *passcodeViewController;
@property (nonatomic, strong) UIButton *colorButton;
@property (nonatomic, strong) UISwitch *iCloudSwitch;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, copy) NSString *previousMainMenuStyle;

@end

@implementation A3SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		_previousMainMenuStyle = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];
		if (!_previousMainMenuStyle) {
			_previousMainMenuStyle = A3SettingsMainMenuStyleHexagon;
		}
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self makeBackButtonEmptyArrow];
	[self leftBarButtonAppsButton];
	self.navigationItem.hidesBackButton = YES;

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
		[self leftBarButtonAppsButton];
		[self.tableView reloadData];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 1) return 0;
	return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 0) return UITableViewAutomaticDimension;
	BOOL isLastSection = ([self.tableView numberOfSections] - 1) == section;
	return [self standardHeightForFooterIsLastSection:isLastSection];
}

- (BOOL)isMainMenuStyleList {
	NSString *mainMenuStyle = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];
	return [mainMenuStyle isEqualToString:A3SettingsMainMenuStyleTable];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2 && indexPath.row == 0) return 160.0;

	if (indexPath.section == 2 && indexPath.row > 0) {
		return [self isMainMenuStyleList] ? UITableViewAutomaticDimension : 0.0;
	}
	return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	A3SettingsTableViewRow row = (A3SettingsTableViewRow) cell.tag;
	switch (row) {
		case A3SettingsRowUseiCloud:
			if (!_iCloudSwitch) {
				_iCloudSwitch = [UISwitch new];
				_iCloudSwitch.on = [[A3SyncManager sharedSyncManager] isCloudEnabled];
				[_iCloudSwitch addTarget:self action:@selector(toggleCloud:) forControlEvents:UIControlEventValueChanged];
			}
			cell.accessoryView = _iCloudSwitch;
			break;
		case A3SettingsRowPasscodeLock:
			cell.detailTextLabel.text = [[A3KeychainUtils getPassword] length] ? [A3KeychainUtils passcodeTimeString] : NSLocalizedString(@"Passcode_Off", nil);
			break;
		case A3SettingsRowWalletSecurity:
			break;
		case A3SettingsRowStartingApp: {
			NSString *startAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
			if ([startAppName length]) {
				cell.detailTextLabel.text = NSLocalizedString(startAppName, nil);
			} else {
				cell.detailTextLabel.text = NSLocalizedString(@"None", @"None");
			}
			break;
		}
		case A3SettingsRowEditFavorites:
			if ([self isMainMenuStyleList]) {
				[cell.textLabel setHidden:NO];
				[cell.detailTextLabel setHidden:NO];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			} else {
				[cell.textLabel setHidden:YES];
				[cell.detailTextLabel setHidden:YES];
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			break;
		case A3SettingsRowRecentToKeep:
			cell.detailTextLabel.text = [[A3UserDefaults standardUserDefaults] stringForRecentToKeep];
			if ([self isMainMenuStyleList]) {
				[cell.textLabel setHidden:NO];
				[cell.detailTextLabel setHidden:NO];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			} else {
				[cell.textLabel setHidden:YES];
				[cell.detailTextLabel setHidden:YES];
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			break;
		case A3SettingsRowThemeColor: {
			if (!_colorButton) {
				_colorButton = [UIButton buttonWithType:UIButtonTypeSystem];
				_colorButton.bounds = CGRectMake(0, 0, 30, 30);

				UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), YES, 0.0);
				UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				[_colorButton setImage:blank forState:UIControlStateNormal];
				[_colorButton addTarget:self action:@selector(themeColor) forControlEvents:UIControlEventTouchUpInside];

				[cell addSubview:_colorButton];
				[_colorButton makeConstraints:^(MASConstraintMaker *make) {
					make.centerY.equalTo(cell.centerY);
					make.right.equalTo(cell.right).with.offset(-35);
					make.width.equalTo(@30);
					make.height.equalTo(@30);
				}];
			}
			break;
		}
		case A3SettingsRowLunarCalendar:
			break;
		case A3SettingsRowMainMenuStyle: {
			A3SettingsHomeStyleSelectTableViewCell *homeStyleSelectCell = (A3SettingsHomeStyleSelectTableViewCell *) cell;
			homeStyleSelectCell.tableView = tableView;
			if ([self isMainMenuStyleList]) {
				cell.separatorInset = A3UITableViewSeparatorInset;
			} else {
				cell.separatorInset = UIEdgeInsetsZero;
				cell.indentationWidth = 0;
			}
			break;
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 1:
			if (indexPath.row == 0) {
				if ([A3KeychainUtils getPassword] != nil) {
					void(^presentPasscodeViewControllerBlock)(void) = ^(){
						_passcodeViewController = [UIViewController passcodeViewControllerWithDelegate:self];
						[_passcodeViewController showLockScreenInViewController:self];
					};
					if (IS_IOS7 || ![[A3AppDelegate instance] useTouchID]) {
						presentPasscodeViewControllerBlock();
					} else {
						LAContext *context = [LAContext new];
						NSError *error;
						if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
							[[A3AppDelegate instance] addSecurityCoverView];
							[[UIApplication sharedApplication] setStatusBarHidden:YES];
							[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
							[context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
									localizedReason:NSLocalizedString(@"Unlock AppBox Pro", @"Unlock AppBox Pro")
											  reply:^(BOOL success, NSError *error) {
												  dispatch_async(dispatch_get_main_queue(), ^{
													  [[UIApplication sharedApplication] setStatusBarHidden:NO];
													  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
													  
													  [[A3AppDelegate instance] removeSecurityCoverView];
													  if (success) {
														  [self performSegueWithIdentifier:@"passcode" sender:nil];
													  } else {
														  presentPasscodeViewControllerBlock();
													  }
												  });
												  
											  }];
						} else {
							presentPasscodeViewControllerBlock();
						}
					}
				} else {
					[self performSegueWithIdentifier:@"passcode" sender:nil];
				}
			}
			break;
		case 4:
			switch (indexPath.row) {
				case 0:
					[[A3AppDelegate instance] startRemoveAds];
					break;
				case 1:
					[[A3AppDelegate instance] startRestorePurchase];
					break;
				default:
					break;
			}
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			break;
		default:
			break;
	}
}

- (void)toggleCloud:(UISwitch *)switchControl {
	if ([switchControl isOn]) {
		if (![[A3SyncManager sharedSyncManager] isCloudAvailable]) {
			[self alertCloudNotEnabled];
			[switchControl setOn:NO animated:YES];
			return;
		}
		if (![[A3SyncManager sharedSyncManager] canSyncStart]) {
			[switchControl setOn:NO animated:YES];
			return;
		}
	}
	[[A3AppDelegate instance] setCloudEnabled:switchControl.on];
}

- (void)themeColor {
	[self performSegueWithIdentifier:@"themeColor" sender:nil];
}

- (void)passcodeViewControllerDidDismissWithSuccess:(BOOL)success {
    if (success) {
        [self performSegueWithIdentifier:@"passcode" sender:nil];
    }
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[super appsButtonAction:barButtonItem];

	NSString *currentMainMenuStyle = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];
	if (currentMainMenuStyle && ![currentMainMenuStyle isEqualToString:_previousMainMenuStyle]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[A3AppDelegate instance] reloadRootViewController];
		});
	}
}

#pragma mark - UIActionSheet Delegate

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
	if ([identifier isEqualToString:@"pushDropboxBackup"]) {
		if (![[A3AppDelegate instance].reachability isReachable]) {
			[self alertInternetConnectionIsNotAvailable];
			NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
			return NO;
		}
	}
	return YES;
}

@end
