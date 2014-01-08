//
//  A3SettingsRequireForViewController.m
//  AppBox3
//
//  Created by A3 on 12/27/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsRequireForViewController.h"
#import "A3AppDelegate+passcode.h"

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

	self.title = @"Require Passcode";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)durations {
	return @[@(0.0), @(60.0), @(60.0 * 5.0), @(60.0 * 15.0), @(60.0 * 60.0), @(60.0 * 60.0 * 4.0)];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	double seconds = [[NSUserDefaults standardUserDefaults] doubleForKey:kUserDefaultsKeyForPasscodeTimerDuration];

	cell.accessoryType = seconds == [self.durations[indexPath.row] doubleValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[NSUserDefaults standardUserDefaults] setObject:self.durations[indexPath.row] forKey:kUserDefaultsKeyForPasscodeTimerDuration];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self.tableView reloadData];
}

@end
