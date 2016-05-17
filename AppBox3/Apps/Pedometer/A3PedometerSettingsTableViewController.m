//
//  A3PedometerSettingsTableViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/10/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3PedometerSettingsTableViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3PedometerHandler.h"

@interface A3PedometerSettingsTableViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

@end

@implementation A3PedometerSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	[self.navigationController setNavigationBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

	self.title = NSLocalizedString(@"Settings", @"Settings");
	FNLOG(@"%@", self.navigationController.navigationBar.titleTextAttributes);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	double goalSteps = [[NSUserDefaults standardUserDefaults] doubleForKey:A3PedometerSettingsNumberOfGoalSteps];
	[self.pickerView selectRow:goalSteps / 1000 - 1 inComponent:0 animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell.accessoryType = [self.pedometerHandler usesMetricSystem] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		} else {
			cell.accessoryType = ![self.pedometerHandler usesMetricSystem] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		}
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			NSNumber *goalSteps = [[NSUserDefaults standardUserDefaults] objectForKey:A3PedometerSettingsNumberOfGoalSteps];
			cell.detailTextLabel.text = [self.pedometerHandler.numberFormatter stringFromNumber:goalSteps];
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		[[NSUserDefaults standardUserDefaults] setBool:indexPath.row == 0 forKey:A3PedometerSettingsUsesMetricSystem];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	}
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 100;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [self.pedometerHandler.numberFormatter stringFromNumber:@((row + 1)* 1000)];;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	[[NSUserDefaults standardUserDefaults] setObject:@((row + 1) * 1000) forKey:A3PedometerSettingsNumberOfGoalSteps];
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

@end
