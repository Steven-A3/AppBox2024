//
//  A3SettingsStartingAppViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/25/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SettingsStartingAppViewController.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3AppDelegate.h"
#import "A3UserDefaults.h"

@interface A3SettingsStartingAppViewController ()

@property (nonatomic, strong) NSArray *allMenuItems;

@end

@implementation A3SettingsStartingAppViewController

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
	self.tableView.separatorInset = UIEdgeInsetsMake(0, 57, 0, 0);
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)allMenuItems {
	if (!_allMenuItems) {
		_allMenuItems = [[A3AppDelegate instance] allMenuItems];
		_allMenuItems = [_allMenuItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			return [NSLocalizedString(obj1[kA3AppsMenuName], nil) compare:NSLocalizedString(obj2[kA3AppsMenuName], nil)];
		}];
	}
	return _allMenuItems;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.allMenuItems count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"startingAppCell" forIndexPath:indexPath];

	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
    
    cell.textLabel.font = [UIFont systemFontOfSize:17];

	if (indexPath.row == 0) {
		cell.textLabel.text = NSLocalizedString(@"None", @"None");
		cell.imageView.image = nil;
		if (![startingAppName length]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	} else {
		NSDictionary *menuItem = self.allMenuItems[indexPath.row - 1];
		cell.textLabel.text = NSLocalizedString(menuItem[kA3AppsMenuName], nil);
		cell.imageView.image = [UIImage imageNamed:[[A3AppDelegate instance] imageNameForApp:menuItem[kA3AppsMenuName]]];
		if ([startingAppName isEqualToString:menuItem[kA3AppsMenuName]]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		[[A3UserDefaults standardUserDefaults] removeObjectForKey:kA3AppsStartingAppName];
	} else {
		NSDictionary *menuItem = self.allMenuItems[indexPath.row - 1];
		[[A3UserDefaults standardUserDefaults] setObject:menuItem[kA3AppsMenuName] forKey:kA3AppsStartingAppName];
	}
	[[A3UserDefaults standardUserDefaults] synchronize];

	[self.navigationController popViewControllerAnimated:YES];
}

@end
