//
//  A3SettingsLunarViewController.m
//  AppBox3
//
//  Created by A3 on 12/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsLunarViewController.h"
#import "A3UserDefaults+A3Addition.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+A3Addition.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3UserDefaults.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

@interface A3SettingsLunarViewController ()

@end

@implementation A3SettingsLunarViewController

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
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}

    if (IS_IPHONE) {
        [self makeBackButtonEmptyArrow];
        [self rightBarButtonDoneButton];
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

-(void)doneButtonAction:(id)sender {
	if (IS_IPAD) {
		[[A3AppDelegate instance].rootViewController_iPad dismissRightSideViewController];
	} else {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [self standardHeightForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (cell.tag) {
		case 1100:
			if (![A3UIDevice useKoreanLunarCalendarForConversion]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			break;
		case 1200:
			if ([A3UIDevice useKoreanLunarCalendarForConversion]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	switch (cell.tag) {
		case 1100:
			[[A3UserDefaults standardUserDefaults] setBool:NO forKey:A3SettingsUseKoreanCalendarForLunarConversion];
			[[A3UserDefaults standardUserDefaults] synchronize];
			break;
		case 1200:
			[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsUseKoreanCalendarForLunarConversion];
			[[A3UserDefaults standardUserDefaults] synchronize];
			break;
	}
	[tableView reloadData];
}

@end
