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

typedef NS_ENUM(NSInteger, A3SettingsTableViewRow) {
	A3SettingsRowSync = 1100,
	A3SettingsRowPasscodeLock = 2100,
	A3SettingsRowWalletSecurity = 2200,
	A3SettingsRowEditFavorites = 3100,
	A3SettingsRowRecentToKeep = 3200,
	A3SettingsRowThemeColor = 4100,
	sA3SettingsRowLunarCalendar = 4200,
};

@interface A3SettingsViewController ()

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

	self.title = NSLocalizedString(@"Settings", @"Settings view title");
	
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	A3SettingsTableViewRow row = (A3SettingsTableViewRow) cell.tag;
	switch (row) {
		case A3SettingsRowSync:
			cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForSyncMethod];
			break;
		case A3SettingsRowPasscodeLock:
			cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForPasscodeLock];
			break;
		case A3SettingsRowWalletSecurity:
			break;
		case A3SettingsRowEditFavorites:
			break;
		case A3SettingsRowRecentToKeep:
			cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForRecentToKeep];
			break;
		case A3SettingsRowThemeColor:
			break;
		case sA3SettingsRowLunarCalendar:
			cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForLunarCalendarCountry];
			break;
	}
}

@end
