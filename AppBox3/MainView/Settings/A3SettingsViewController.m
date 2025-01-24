//
//  A3SettingsViewController.m
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+NumberKeyboard.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <StoreKit/StoreKit.h>
#import "A3SettingsViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3UserDefaults+A3Addition.h"
#import "A3KeychainUtils.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "Reachability.h"
#import "A3SyncManager.h"
#import "A3SettingsHomeStyleSelectTableViewCell.h"
#import "A3AboutViewController.h"
#import "A3PriceTagLabel.h"
#import "A3AppDelegate.h"
#import "WalletData.h"
@import MessageUI;
#import "AppBox3-swift.h"
#import "UIViewController+extension.h"
#import "A3BackupRestoreManager.h"

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
	A3SettingsRowRestorePurchase = 6200,
};

@interface A3SettingsViewController () <A3PasscodeViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, A3BackupRestoreManagerDelegate>

@property (nonatomic, strong) UIViewController<A3PasscodeViewControllerProtocol> *passcodeViewController;
@property (nonatomic, strong) UIButton *colorButton;
@property (nonatomic, strong) UISwitch *iCloudSwitch;
@property (nonatomic, strong) UISwitch *hideOtherAppLinksSwitch;
@property (nonatomic, strong) UISwitch *useGrayIconsSwitch;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, copy) NSString *previousMainMenuStyle;
@property (nonatomic, strong) A3BackupRestoreManager *backupRestoreManager;

@end

@implementation A3SettingsViewController {
	BOOL _didResetHomeScreenLayout;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_previousMainMenuStyle = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];

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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:A3NotificationAppsMainMenuContentsChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adWillDismissScreen) name:A3NotificationsAdsWillDismissScreen object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationDidBecomeActive {
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (![self isMovingToParentViewController]) {
		[self leftBarButtonAppsButton];
		[self.tableView reloadData];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([self.navigationController.navigationBar isHidden]) {
		[self showNavigationBarOn:self.navigationController];
	}
}

- (void)adWillDismissScreen {
	UINavigationController *target = [[A3AppDelegate instance] currentMainNavigationController];
	[self showNavigationBarOn:target];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationAppsMainMenuContentsChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationsAdsWillDismissScreen object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)reloadTableView {
	_didResetHomeScreenLayout = YES;

	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 2) {
		A3AppDelegate *appDelegate = [A3AppDelegate instance];
		if ([appDelegate isMainMenuStyleList]) {
			return 3;
		}
        NSString *menuStyle = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];
        if ([menuStyle isEqualToString:A3SettingsMainMenuStyleHexagon]) {
            // row 0: Style
            // row 1: Reset Home Screen Layout
            // row 2: Hide Other app Icons ( 광고를 표시하지 않는 경우에만 표시 )
            // 다른 앱 광고는 기존 앱 사용자에게만 보여준다. 인앱 사용자에게는 보여주지 않는다.
            if ([[NSUserDefaults standardUserDefaults] integerForKey:kA3ApplicationNumberOfDidBecomeActive] <= 8) {
                return 2;
            }
            return 2;
        }

        // Home Style Grid
        // row 0: Style
        // row 1: Reset Home Screen Layout
        // row 2: Use gray color icons
        // row 3: Hide other app icons ( 광고를 표시하지 않는 경우에만 표시 )
        // 다른 앱 광고는 기존 앱 사용자에게만 보여준다. 인앱 사용자에게는 보여주지 않는다.
        if ([[NSUserDefaults standardUserDefaults] integerForKey:kA3ApplicationNumberOfDidBecomeActive] <= 8) {
            return 3;
        }
        return [A3AppDelegate instance].isOldPaidUser ? 4 : 3;
	}
	return [super tableView:tableView numberOfRowsInSection:section];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 1) return 0;
	if (section == 2) return IS_RETINA ? 38.5 : 38.0;
	return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 0) return UITableViewAutomaticDimension;
	BOOL isLastSection = ([self.tableView numberOfSections] - 1) == section;
	return [self standardHeightForFooterIsLastSection:isLastSection];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2 && indexPath.row == 0) return 160.0;

	return UITableViewAutomaticDimension;
}

- (void)prepareCellForResetHomeScreenLayout:(UITableViewCell *)cell {
    cell.textLabel.text = NSLocalizedString(@"Reset Home Screen Layout", @"Reset Home Screen Layout");
    cell.textLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.4;
    [cell.detailTextLabel setHidden:YES];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)prepareCellForHideOtherApps:(UITableViewCell *)cell {
    cell.textLabel.text = NSLocalizedString(@"Hide Other App Links", @"Hide Other App Links");
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
    [cell.textLabel setHidden:NO];
    [cell.detailTextLabel setHidden:YES];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = self.hideOtherAppLinksSwitch;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row > 0) {
        NSString *menuStyle = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];
        if ([menuStyle isEqualToString:A3SettingsMainMenuStyleTable]) {
            switch (indexPath.row) {
                case 1:
                    [cell.textLabel setHidden:NO];
                    cell.textLabel.text = NSLocalizedString(@"Favorites", @"Favorites");
                    cell.textLabel.textColor = [UIColor blackColor];
                    [cell.detailTextLabel setHidden:NO];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 2:
                    cell.textLabel.text = NSLocalizedString(@"Recent to Keep", nil);
                    cell.accessoryView = nil;
                    cell.detailTextLabel.text = [[A3UserDefaults standardUserDefaults] stringForRecentToKeep];
                    [cell.textLabel setHidden:NO];
                    [cell.detailTextLabel setHidden:NO];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    break;
            }
            return;
        }
        if ([menuStyle isEqualToString:A3SettingsMainMenuStyleHexagon]) {
            switch (indexPath.row) {
                case 1:
                    [self prepareCellForResetHomeScreenLayout:cell];
                    break;
                case 2:
                    [self prepareCellForHideOtherApps:cell];
                    break;
            }
            return;
        }
        if ([menuStyle isEqualToString:A3SettingsMainMenuStyleIconGrid]) {
            switch (indexPath.row) {
                case 1:
                    [self prepareCellForResetHomeScreenLayout:cell];
                    break;
                case 2:
                    cell.textLabel.text = NSLocalizedString(@"Use Gray Icons", nil);
                    cell.textLabel.adjustsFontSizeToFitWidth = YES;
                    cell.textLabel.minimumScaleFactor = 0.5;
                    [cell.textLabel setHidden:NO];
                    [cell.detailTextLabel setHidden:YES];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.accessoryView = self.useGrayIconsSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 3:
                    [self prepareCellForHideOtherApps:cell];
                    break;
            }
        }
        return;
    }
    
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
            // Section 2, indexPath > 0 에서 처리
            break;
        case A3SettingsRowRecentToKeep:
            // Section 2, indexPath > 0 에서 처리
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
			A3SettingsHomeStyleSelectTableViewCell *homeStyleSelectCell = (id) cell;
			homeStyleSelectCell.tableView = tableView;
			[homeStyleSelectCell reloadButtonBorderColor];
			
			break;
		}
		case A3SettingsRowRestorePurchase: {
            cell.textLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
			break;
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 2) {
                if (@available(iOS 14.0, *)) {
                    [self performSegueWithIdentifier:@"backuprestore" sender:nil];
                } else {
                    [self alertFilesRequireiOS14];
                }
            } else if (indexPath.row == 3) {
                [self exportWalletContents];
            } else if (indexPath.row == 4) {
                [self exportPhotosVideos];
            }
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
		case 1:
			if (indexPath.row == 0) {
				if ([A3KeychainUtils getPassword] != nil) {
					void(^presentPasscodeViewControllerBlock)(void) = ^(){
						self.passcodeViewController = [UIViewController passcodeViewControllerWithDelegate:self];
						[self.passcodeViewController showLockScreenInViewController:self completion:NULL];
					};
					if (![[A3AppDelegate instance] useTouchID]) {
						presentPasscodeViewControllerBlock();
					} else {
						LAContext *context = [LAContext new];
						NSError *error;
						if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
							[[A3AppDelegate instance] addSecurityCoverView];
							[[UIApplication sharedApplication] setStatusBarHidden:YES];
							[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

							[A3AppDelegate instance].isSettingsEvaluatingTouchID = YES;
							
							[context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
									localizedReason:NSLocalizedString(@"Unlock AppBox Pro", @"Unlock AppBox Pro")
											  reply:^(BOOL success, NSError *error) {
												  dispatch_async(dispatch_get_main_queue(), ^{
													  FNLOG();
													  [[UIApplication sharedApplication] setStatusBarHidden:NO];
													  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
													  
													  [[A3AppDelegate instance] removeSecurityCoverView];
													  if (success && !error) {
														  [A3KeychainUtils saveTimerStartTime];
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
		case 2:{
			if (indexPath.row == 1) {
				if ([[A3AppDelegate instance] isMainMenuStyleList]) {
					[self performSegueWithIdentifier:@"editFavorites" sender:nil];
				} else {
					UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"This will reset your home screen layout to defaults.", @"This will reset your home screen layout to defaults.")
																			 delegate:self
																	cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
															   destructiveButtonTitle:NSLocalizedString(@"Reset Home Screen", nil)
																	otherButtonTitles:nil];
					actionSheet.tag = [[[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle] isEqualToString:A3SettingsMainMenuStyleHexagon] ? 1 : 2;
					[actionSheet showInView:self.view];
				}
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
			} else if (indexPath.row == 2) {
				if ([[A3AppDelegate instance] isMainMenuStyleList]) {
					[self performSegueWithIdentifier:@"recentToKeep" sender:nil];
				}
			}
			break;
		}
		case 4:
			switch (indexPath.row) {
                case 0:
                    if (@available(iOS 17.0, *)) {
                        [self presentSubscriptionViewControllerWithCompletion:^{
                            
                        }];
                    } else {
                        [self presentAlertWithTitle:NSLocalizedString(@"Ads Free Pass Unavailable", @"")
                                        message:NSLocalizedString(@"Upgrade to iOS 17 for Ads Free Pass. Visit Settings > General > Software Update.", @"")];
                    }
                    break;
                case 1: {
                    [[A3AppDelegate instance] evaluateSubscriptionWithCompletion:^{
                        if ([A3AppDelegate instance].isOldPaidUser) {
                            [self presentAlertWithTitle:@"" message:NSLocalizedString(@"Your purchases have been successfully restored.", @"")];
                        } else if ([A3AppDelegate instance].hasAdsFreePass) {
                            [self presentAlertWithTitle:@"" message:NSLocalizedString(@"Your subscription has been successfully restored.", @"")];
                        } else {
                            [self presentAlertWithTitle:@"" message:NSLocalizedString(@"There are no transactions available for restoration at this time.", @"")];
                        }
                    }];
                    break;
                }
				case 2: {
					[self presentAboutViewController];
					break;
				}
				default:
					break;
			}
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			break;
		default:
			break;
	}
}

- (A3BackupRestoreManager *)backupRestoreManager {
    if (_backupRestoreManager == nil) {
        _backupRestoreManager = [[A3BackupRestoreManager alloc] init];
        _backupRestoreManager.delegate = self;
        _backupRestoreManager.hostingView = self.navigationController.view;
        _backupRestoreManager.hostingViewController = self;
    }
    return _backupRestoreManager;
}

- (MBProgressHUD *)HUD {
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _HUD.mode = MBProgressHUDModeIndeterminate;
        _HUD.removeFromSuperViewOnHide = YES;
    }
    return _HUD;
}

- (void)exportPhotosVideos {
    [self.backupRestoreManager exportPhotosVideos];
}

- (void)alertNewDropboxBackupInfo {
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Info", @"Info")
                                        message:NSLocalizedString(@"Backup & Restore will use Files app. If you don't see Dropbox in the Locations, please install the Dropbox app and setup your account. Next time, tap using Files.", @"")
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"backuprestore" sender:nil];
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)alertFilesRequireiOS14 {
    [self presentAlertWithTitle:NSLocalizedString(@"Info", @"Info")
                        message:NSLocalizedString(@"Backup using Files app requires iOS 14 or later. Please update iOS to the latest version.", @"")];
}

- (void)exportWalletContents {
    if (![[A3AppDelegate instance].reachability isReachable]) {
        [self alertInternetConnectionIsNotAvailable];
        return;
    }

    NSString *title = NSLocalizedString(@"Export Function Usage Guide", @"");
    NSString *msg = NSLocalizedString(@"ExportUsage", @"");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        NSString *body = [WalletData htmlRepresentationOfContents];
        WalletExtension *extension = [[WalletExtension alloc] init];
        
        self.HUD.label.text = NSLocalizedString(@"Preparing", @"");
        self.HUD.progress = 0;
        [self.navigationController.view addSubview:self.HUD];
        [self.HUD showAnimated:YES];

        NSAttributedString *attributedString = [extension convertHtmlToAttributedStringWithHtmlString:body];
        
        [self.HUD hideAnimated:YES];
        
        UIActivityViewController *viewController = [[UIActivityViewController alloc] initWithActivityItems:@[attributedString] applicationActivities:NULL];
        viewController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            if (completed) {
                NSString *title = NSLocalizedString(@"Export Function Usage Guide", @"");
                NSString *msg = NSLocalizedString(@"ExportUsageAfterCopy", @"");
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                         message:msg
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                                 style:UIAlertActionStyleDefault
                                                               handler:NULL];
                [alertController addAction:action];
                [self presentViewController:alertController animated:YES completion:NULL];
}
        };
        [self presentViewController:viewController animated:YES completion:NULL];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentAboutViewController {
	UIStoryboard *aboutStoryboard = [UIStoryboard storyboardWithName:@"about" bundle:nil];
	A3AboutViewController *viewController = [aboutStoryboard instantiateInitialViewController];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		if (actionSheet.tag == 1) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:A3MainMenuHexagonMenuItems];
		} else {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:A3MainMenuGridMenuItems];
		}
		_didResetHomeScreenLayout = YES;
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
	NSString *currentMainMenuStyle = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];
	if (_didResetHomeScreenLayout || (currentMainMenuStyle && ![currentMainMenuStyle isEqualToString:_previousMainMenuStyle])) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[A3AppDelegate instance].isChangingRootViewController = YES;
			[[A3AppDelegate instance] reloadRootViewController];
		});
	} else {
		[super appsButtonAction:barButtonItem];
	}
}

- (void)applicationDidEnterBackground {
	NSString *currentMainMenuStyle = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];
	if (_didResetHomeScreenLayout || (currentMainMenuStyle && ![currentMainMenuStyle isEqualToString:_previousMainMenuStyle])) {
		A3AppDelegate *appDelegate = [A3AppDelegate instance];
		[appDelegate reloadRootViewController];
		if ([appDelegate shouldProtectScreen]) {
			[appDelegate addSecurityCoverView];
		}
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

- (UISwitch *)hideOtherAppLinksSwitch {
	if (!_hideOtherAppLinksSwitch) {
		_hideOtherAppLinksSwitch = [UISwitch new];
		[_hideOtherAppLinksSwitch addTarget:self action:@selector(hideOtherAppLinksSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
		[_hideOtherAppLinksSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kA3AppsHideOtherAppLinks]];
	}
	return _hideOtherAppLinksSwitch;
}

- (void)hideOtherAppLinksSwitchValueChanged {
	[[NSUserDefaults standardUserDefaults] setBool:_hideOtherAppLinksSwitch.isOn forKey:kA3AppsHideOtherAppLinks];
	_didResetHomeScreenLayout = YES;
}

- (UISwitch *)useGrayIconsSwitch {
    if (!_useGrayIconsSwitch) {
        _useGrayIconsSwitch = [UISwitch new];
        [_useGrayIconsSwitch addTarget:self action:@selector(useGrayIconsSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
        [_useGrayIconsSwitch setOn:[[A3UserDefaults standardUserDefaults] boolForKey:kA3AppsUseGrayIconsOnGridMenu]];
    }
    return _useGrayIconsSwitch;
}

- (void)useGrayIconsSwitchValueChanged {
    [[A3UserDefaults standardUserDefaults] setBool:_useGrayIconsSwitch.isOn forKey:kA3AppsUseGrayIconsOnGridMenu];
    [[A3UserDefaults standardUserDefaults] synchronize];
    _didResetHomeScreenLayout = YES;
}
    
@end
