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

typedef NS_ENUM(NSInteger, A3SettingsTableViewRow) {
	A3SettingsRowSync = 1100,
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

//	self.title = NSLocalizedString(@"Settings", @"Settings view title");
	
	[self makeBackButtonEmptyArrow];
	[self leftBarButtonAppsButton];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
	return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return [self standardHeightForFooterInSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	A3SettingsTableViewRow row = (A3SettingsTableViewRow) cell.tag;
	switch (row) {
		case A3SettingsRowSync:
			cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForSyncMethod];
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
			cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForLunarCalendarCountry];
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

- (void)themeColor {
	[self performSegueWithIdentifier:@"themeColor" sender:nil];
}

- (void)passcodeViewDidDisappearWithSuccess:(BOOL)success {
	if (success) {
		[self performSegueWithIdentifier:@"passcode" sender:nil];
	}
}

@end
