//
//  A3SettingsSyncViewController.m
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsSyncViewController.h"
#import "NSUserDefaults+A3Addition.h"
#import "A3AppDelegate.h"
#import "A3AppDelegate+iCloud.h"

@interface A3SettingsSyncViewController ()

@property (nonatomic, strong) UISwitch *iCloudSwitch;

@end

@implementation A3SettingsSyncViewController

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

	self.title = NSLocalizedString(@"Sync", @"It is a title for a view configuring Syncing through iCloud.");

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (cell.tag == 1100) {
		if (!_iCloudSwitch) {
			_iCloudSwitch = [UISwitch new];
			[_iCloudSwitch setEnabled:[[A3AppDelegate instance].ubiquityStoreManager cloudAvailable]];
			_iCloudSwitch.on = [[A3AppDelegate instance].ubiquityStoreManager cloudEnabled];
			[_iCloudSwitch addTarget:self action:@selector(toggleCloud:) forControlEvents:UIControlEventValueChanged];
		}
		cell.accessoryView = _iCloudSwitch;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		if (![[A3AppDelegate instance].ubiquityStoreManager cloudAvailable]) {
			return @"Enable iCloud and Documents and Data storages in your Settings to gain access to this feature.";
		}
	}
	return nil;
}

- (void)toggleCloud:(UISwitch *)switchControl {
	[[A3AppDelegate instance] setCloudEnabled:switchControl.on];
}

@end
