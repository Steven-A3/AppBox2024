//
//  A3SettingsRequireForViewController.m
//  AppBox3
//
//  Created by A3 on 12/27/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsRequireForViewController.h"
#import "A3AppDelegate+passcode.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UserDefaultsKeys.h"
#import "A3UserDefaults.h"

@interface A3SettingsRequireForViewController ()

@end

@implementation A3SettingsRequireForViewController

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

- (NSArray *)durations {
	return @[@(0.0), @(60.0), @(60.0 * 5.0), @(60.0 * 15.0), @(60.0 * 60.0), @(60.0 * 60.0 * 4.0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (([self.tableView numberOfSections] - 1) == section) {
		return UITableViewAutomaticDimension;
	}
	return [self standardHeightForFooterIsLastSection:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([[A3AppDelegate instance] useTouchID]) return 1;
	return [super tableView:tableView numberOfRowsInSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	double seconds = [[A3UserDefaults standardUserDefaults] doubleForKey:kUserDefaultsKeyForPasscodeTimerDuration];

	cell.accessoryType = seconds == [self.durations[indexPath.row] doubleValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[A3UserDefaults standardUserDefaults] setObject:self.durations[indexPath.row] forKey:kUserDefaultsKeyForPasscodeTimerDuration];
	[[A3UserDefaults standardUserDefaults] synchronize];

	[self.tableView reloadData];
}

@end
