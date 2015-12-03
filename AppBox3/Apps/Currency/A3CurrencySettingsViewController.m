//
//  A3CurrencySettingsViewController.m
//  AppBox3
//
//  Created by A3 on 11/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencySettingsViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UserDefaults+A3Defaults.h"
#import "A3CurrencyTableViewController.h"
#import "UIViewController+iPad_rightSideView.h"

@interface A3CurrencySettingsViewController ()

@property (nonatomic, strong) UISwitch *autoUpdateSwitch, *useCellularDataSwitch, *showFlagSwitch;

@end

NSString *const CellIdentifier = @"Cell";

@implementation A3CurrencySettingsViewController {
	BOOL _hasCellularNetwork;
}

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

//	_hasCellularNetwork = [A3UIDevice hasCellularNetwork];
	_hasCellularNetwork = NO;

	if (IS_IPHONE) {
		[self rightBarButtonDoneButton];
	}
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
	[super didMoveToParentViewController:parent];

	FNLOG(@"%@", parent);
	if (!parent) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationChildViewControllerDidDismiss object:self];
	}
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (IS_IPAD) {
		A3AppDelegate *appDelegate = (A3AppDelegate *) [[UIApplication sharedApplication] delegate];
		[appDelegate.rootViewController dismissRightSideViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _hasCellularNetwork ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [self standardHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	BOOL isLastSection = ([self.tableView numberOfSections] - 1) == section;
	return [self standardHeightForFooterIsLastSection:isLastSection];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"Auto Update", @"Auto Update");
			cell.accessoryView = self.autoUpdateSwitch;
			break;
		case 1:
			if (_hasCellularNetwork) {
				[self setAsCellularCell:cell];
			} else {
				[self setAsShowFlagCell:cell];
			}
			break;
		case 2:
			[self setAsShowFlagCell:cell];
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
	return cell;
}

- (void)setAsShowFlagCell:(UITableViewCell *)cell {
	cell.textLabel.text = NSLocalizedString(@"Show National Flag", @"Show National Flag");
	cell.accessoryView = self.showFlagSwitch;
}

- (void)setAsCellularCell:(UITableViewCell *)cell {
	cell.textLabel.text = NSLocalizedString(@"Use Cellular Data", @"Use Cellular Data");
	cell.accessoryView = self.useCellularDataSwitch;
}

- (UISwitch *)autoUpdateSwitch {
	if (!_autoUpdateSwitch) {
		_autoUpdateSwitch = [UISwitch new];
		[_autoUpdateSwitch setOn:[[A3UserDefaults standardUserDefaults] currencyAutoUpdate]];
		[_autoUpdateSwitch addTarget:self action:@selector(autoUpdateValueChanged:) forControlEvents:UIControlEventValueChanged];
	}
	return _autoUpdateSwitch;
}

- (void)autoUpdateValueChanged:(UISwitch *)control {
	[[A3UserDefaults standardUserDefaults] setCurrencyAutoUpdate:control.isOn];
}

- (UISwitch *)useCellularDataSwitch {
	if (!_useCellularDataSwitch) {
		_useCellularDataSwitch = [UISwitch new];
		[_useCellularDataSwitch setOn:[[A3UserDefaults standardUserDefaults] currencyUseCellularData]];
		[_useCellularDataSwitch addTarget:self action:@selector(useCellularDataValueChanged:) forControlEvents:UIControlEventValueChanged];
	}
	return _useCellularDataSwitch;
}

- (void)useCellularDataValueChanged:(UISwitch *)control {
	[[A3UserDefaults standardUserDefaults] setCurrencyUseCellularData:control.isOn];
}

- (UISwitch *)showFlagSwitch {
	if (!_showFlagSwitch) {
		_showFlagSwitch = [UISwitch new];
		[_showFlagSwitch setOn:[[A3UserDefaults standardUserDefaults] currencyShowNationalFlag]];
		[_showFlagSwitch addTarget:self action:@selector(showFlagValueChanged:) forControlEvents:UIControlEventValueChanged];
	}
	return _showFlagSwitch;
}

- (void)showFlagValueChanged:(UISwitch *)control {
	[[A3UserDefaults standardUserDefaults] setCurrencyShowNationalFlag:control.isOn];
	[[NSNotificationCenter defaultCenter] postNotificationName:A3CurrencySettingsChangedNotification object:nil];
}

@end
