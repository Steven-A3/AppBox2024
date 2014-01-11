//
//  A3SettingsLunarViewController.m
//  AppBox3
//
//  Created by A3 on 12/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsLunarViewController.h"
#import "NSUserDefaults+A3Addition.h"

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (cell.tag) {
		case 1100:
			if (![[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsUseLunarCalendar]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			break;
		case 1200:
			if ([[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsUseLunarCalendar]) {
				if (![[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsUseKoreanCalendarForLunarConversion]) {
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				} else {
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			break;
		case 1300:
			if ([[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsUseLunarCalendar]) {
				if ([[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsUseKoreanCalendarForLunarConversion]) {
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				} else {
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
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
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:A3SettingsUseLunarCalendar];
			[[NSUserDefaults standardUserDefaults] synchronize];
			break;
		case 1200:
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsUseLunarCalendar];
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:A3SettingsUseKoreanCalendarForLunarConversion];
			[[NSUserDefaults standardUserDefaults] synchronize];
			break;
		case 1300:
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsUseLunarCalendar];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsUseKoreanCalendarForLunarConversion];
			[[NSUserDefaults standardUserDefaults] synchronize];
			break;
	}
	[tableView reloadData];
}

@end
