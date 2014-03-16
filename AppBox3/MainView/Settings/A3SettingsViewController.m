//
//  A3SettingsViewController.m
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsViewController.h"
#import "UIViewController+A3Addition.h"
#import "NSUserDefaults+A3Addition.h"
#import "A3KeychainUtils.h"
#import "A3AppDelegate+appearance.h"
#import "A3UIDevice.h"
#import "UITableViewController+standardDimension.h"
#import "A3AppDelegate+iCloud.h"

typedef NS_ENUM(NSInteger, A3SettingsTableViewRow) {
	A3SettingsRowUseiCloud = 1100,
	A3SettingsRowPasscodeLock = 2100,
	A3SettingsRowWalletSecurity = 2200,
	A3SettingsRowEditFavorites = 3100,
	A3SettingsRowRecentToKeep = 3200,
	A3SettingsRowThemeColor = 4100,
	sA3SettingsRowLunarCalendar = 4200,
};

@interface A3SettingsViewController () <A3PasscodeViewControllerDelegate>

@property (nonatomic, strong) UIViewController<A3PasscodeViewControllerProtocol> *passcodeViewController;
@property (nonatomic, strong) UIButton *colorButton;
@property (nonatomic, strong) UISwitch *iCloudSwitch;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation A3SettingsViewController

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
	[self leftBarButtonAppsButton];
	self.navigationItem.hidesBackButton = YES;

	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (![self isMovingToParentViewController]) {
		[self.tableView reloadData];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 1) return UITableViewAutomaticDimension;
	return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 0) return UITableViewAutomaticDimension;
	return [self standardHeightForFooterInSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	A3SettingsTableViewRow row = (A3SettingsTableViewRow) cell.tag;
	switch (row) {
		case A3SettingsRowUseiCloud:
			if (!_iCloudSwitch) {
				_iCloudSwitch = [UISwitch new];
				_iCloudSwitch.on = [[A3AppDelegate instance].ubiquityStoreManager cloudEnabled];
				[_iCloudSwitch addTarget:self action:@selector(toggleCloud:) forControlEvents:UIControlEventValueChanged];
			}
			cell.accessoryView = _iCloudSwitch;
			break;
		case A3SettingsRowPasscodeLock:
			cell.detailTextLabel.text = [[A3KeychainUtils getPassword] length] ? [A3KeychainUtils passcodeTimeString] : NSLocalizedString(@"Off", nil);
			break;
		case A3SettingsRowWalletSecurity:
			break;
		case A3SettingsRowEditFavorites:
			break;
		case A3SettingsRowRecentToKeep:
			cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForRecentToKeep];
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
		case sA3SettingsRowLunarCalendar:
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0 && indexPath.section == 1) {
		if ([self checkPasscode]) {
			_passcodeViewController = [UIViewController passcodeViewControllerWithDelegate:self];
			[_passcodeViewController showLockscreenInViewController:self];
		} else {
			[self performSegueWithIdentifier:@"passcode" sender:nil];
		}
	}
}

- (void)toggleCloud:(UISwitch *)switchControl {
	if ([switchControl isOn] && ![[A3AppDelegate instance].ubiquityStoreManager cloudAvailable]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"iCloud" message:@"Please goto Settings of your device. Enable iCloud and Documents and Data storages in your Settings to gain access to this feature." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[switchControl setOn:NO animated:YES];
		return;
	}
	[[A3AppDelegate instance] setCloudEnabled:switchControl.on];
}

- (void)themeColor {
	[self performSegueWithIdentifier:@"themeColor" sender:nil];
}

- (void)passcodeViewDidDisappearWithSuccess:(BOOL)success {
	if (success) {
		[self performSegueWithIdentifier:@"passcode" sender:nil];
	}
}

@end
