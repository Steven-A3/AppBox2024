//
//  A3SettingsLunarViewController.m
//  AppBox3
//
//  Created by A3 on 12/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsLunarViewController.h"
#import "NSUserDefaults+A3Addition.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UIViewController+A3Addition.h"

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

    if (IS_IPHONE) {
        [self makeBackButtonEmptyArrow];
    }
    else {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 15.0, 0, 0);
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (cell.tag) {
		case 1100:
			if (![[NSUserDefaults standardUserDefaults] useKoreanLunarCalendar]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			break;
		case 1200:
			if ([[NSUserDefaults standardUserDefaults] useKoreanLunarCalendar]) {
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
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:A3SettingsUseKoreanCalendarForLunarConversion];
			[[NSUserDefaults standardUserDefaults] synchronize];
			break;
		case 1200:
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsUseKoreanCalendarForLunarConversion];
			[[NSUserDefaults standardUserDefaults] synchronize];
			break;
	}
	[tableView reloadData];
}

@end
