//
//  A3SettingsRecentToKeepViewController.m
//  AppBox3
//
//  Created by A3 on 1/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsRecentToKeepViewController.h"
#import "A3AppDelegate.h"
#import "A3AppDelegate+mainMenu.h"
#import "UITableViewController+standardDimension.h"
#import "A3AppDelegate+appearance.h"

@interface A3SettingsRecentToKeepViewController ()

@end

@implementation A3SettingsRecentToKeepViewController

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

	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	@autoreleasepool {
		NSDictionary *recentMenus = [[NSUserDefaults standardUserDefaults] objectForKey:kA3MainMenuRecentlyUsed];
		return recentMenus ? 2 : 1;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger maxMenus = [[A3AppDelegate instance] maximumRecentlyUsedMenus];
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				cell.accessoryType = maxMenus == 1 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
				cell.tag = 1;
				break;
			case 1:
				cell.accessoryType = maxMenus == 2 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
				cell.tag = 2;
				break;
			case 2:
				cell.accessoryType = maxMenus == 3 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
				cell.tag = 3;
				break;
			case 3:
				cell.accessoryType = maxMenus == 5 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
				cell.tag = 5;
				break;
		}
	} else if (indexPath.section == 1) {
		cell.textLabel.textColor = [[A3AppDelegate instance] themeColor];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		[[A3AppDelegate instance] storeMaximumNumberRecentlyUsedMenus:(NSUInteger) cell.tag];

		[[NSNotificationCenter defaultCenter] postNotificationName:A3AppsMainMenuContentsChangedNotification object:self];
		
		[tableView reloadData];
	}
	else if (indexPath.section == 1)
	{
		[[A3AppDelegate instance] clearRecentlyUsedMenus];
		[self.tableView reloadData];

		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

		// Configure for text only and offset down
		hud.mode = MBProgressHUDModeText;
		hud.labelText = @"Recently used records are cleared.";
		hud.margin = 10.f;
		hud.yOffset = 150.f;
		hud.removeFromSuperViewOnHide = YES;

		[hud hide:YES afterDelay:3];

	}
}

@end
