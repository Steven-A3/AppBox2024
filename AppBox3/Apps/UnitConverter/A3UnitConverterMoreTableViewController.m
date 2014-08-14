//
//  A3UnitConverterMoreTableViewController.m
//  AppBox3
//
//  Created by A3 on 4/10/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterMoreTableViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3UnitConverterConvertTableViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UnitDataManager.h"
#import "A3MoreTableViewCell.h"
#import "A3UnitConverterTabBarController.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

@interface A3UnitConverterMoreTableViewController ()

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *sections;

@end

NSString *const A3UnitConverterMoreTableViewCellIdentifier = @"Cell";

@implementation A3UnitConverterMoreTableViewController

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

	self.title = NSLocalizedString(@"More", @"More");

	if (_isEditing) {
		[self rightBarButtonDoneButton];
	} else {
		[self leftBarButtonAppsButton];
		[self rightBarButtonEditButton];
	}

	[self.tableView registerClass:[A3MoreTableViewCell class] forCellReuseIdentifier:A3UnitConverterMoreTableViewCellIdentifier];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.tableView.showsVerticalScrollIndicator = NO;

    NSInteger unitID = [[A3SyncManager sharedSyncManager] integerForKey:A3UnitConverterDefaultSelectedCategoryID];
	NSInteger vcIdx = [self.categories indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [obj[ID_KEY] unsignedIntegerValue] == unitID;
	}];
    if (vcIdx > [self.tabBarController.viewControllers count] - 2) {
        NSDictionary *categoryData = self.sections[0][vcIdx - [self.tabBarController.viewControllers count] + 1];
        A3UnitConverterConvertTableViewController *viewController = [[A3UnitConverterConvertTableViewController alloc] init];
		viewController.dataManager = _dataManager;
        viewController.categoryID = [categoryData[ID_KEY] unsignedIntegerValue];
		viewController.title = categoryData[NAME_KEY];
        viewController.isFromMoreTableViewController = YES;
        
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)cloudStoreDidImport {
	_categories = nil;
	[self.tableView reloadData];
}

- (void)rightBarButtonEditButton {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction:)];
	self.navigationItem.rightBarButtonItem = editButton;
}

- (void)editButtonAction:(UIBarButtonItem *)editButton {
	A3UnitConverterMoreTableViewController *editingViewController = [[A3UnitConverterMoreTableViewController alloc] init];
	editingViewController.dataManager = _dataManager;
	editingViewController.mainTabBarController = self.mainTabBarController;
	editingViewController.isEditing = YES;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editingViewController];
	[self.mainTabBarController presentViewController:navigationController animated:YES completion:nil];
	return;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	NSMutableArray *modifiedCategories = [NSMutableArray arrayWithArray:_sections[0]];
	[modifiedCategories addObjectsFromArray:_sections[1]];
	[_dataManager saveUnitData:modifiedCategories forKey:A3UnitConverterDataEntityUnitCategories];

	[self.mainTabBarController setupTabBar];

	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Prepare Data

- (NSArray *)categories {
	if (nil == _categories) {
		_categories = [self.dataManager allCategories];
	}
	return _categories;
}

- (NSUInteger)numberOfItemsOnTapBar {
	return IS_IPHONE ? 4 : 7;
}

- (NSArray *)sections {
	if (!_sections) {
		NSUInteger numberOfItemsOnTapBar = [self numberOfItemsOnTapBar];
		NSUInteger idx = 0;

		NSMutableArray *sections = [NSMutableArray new];

		if (self.isEditing) {
			NSMutableArray *section0 = [NSMutableArray new];
			for (; idx < numberOfItemsOnTapBar; idx++) {
				[section0 addObject:self.categories[idx]];
			}
			[sections addObject:section0];
		} else {
			idx = numberOfItemsOnTapBar;
		}

		NSMutableArray *section1 = [NSMutableArray new];
		for (; idx < [self.categories count]; idx++) {
			[section1 addObject:self.categories[idx]];
		}
		[sections addObject:section1];
		_sections = sections;
	}

	return _sections;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (self.isEditing) {
		if (section == 0) return NSLocalizedString(@"Units on the bar", @"Units on the bar");
		return NSLocalizedString(@"Units in more", @"Units in more");
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    A3MoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:A3UnitConverterMoreTableViewCellIdentifier forIndexPath:indexPath];

	NSDictionary *category = self.sections[indexPath.section][indexPath.row];
	cell.cellImageView.image = [UIImage imageNamed:[_dataManager iconNameForID:[category[ID_KEY] unsignedIntegerValue]]];
	cell.cellTitleLabel.text = [_dataManager localizedCategoryNameForID:[category[ID_KEY] unsignedIntegerValue]] ;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.separatorInset = A3UITableViewSeparatorInset;

	[cell.cellImageView sizeToFit];
	[cell layoutIfNeeded];

    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	FNLOG(@"%ld - %ld, %ld - %ld", (long)fromIndexPath.section, (long)fromIndexPath.row, (long)toIndexPath.section, (long)toIndexPath.row);
	if (fromIndexPath.section == toIndexPath.section) {
		NSMutableArray *section = self.sections[fromIndexPath.section];
		id movingObject = section[fromIndexPath.row];
		[section removeObjectAtIndex:fromIndexPath.row];
		[section insertObject:movingObject atIndex:toIndexPath.row];
	} else {
		NSMutableArray *fromSection = self.sections[fromIndexPath.section];
		id movingObject = fromSection[fromIndexPath.row];
		[fromSection removeObjectAtIndex:fromIndexPath.row];
		NSMutableArray *toSection = self.sections[toIndexPath.section];
		[toSection insertObject:movingObject atIndex:toIndexPath.row];

		dispatch_async(dispatch_get_main_queue(), ^{
			id movingObject;
			if (fromIndexPath.section == 0) {
				movingObject = toSection[0];
				[toSection removeObjectAtIndex:0];
				[fromSection addObject:movingObject];
				[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] toIndexPath:[NSIndexPath indexPathForRow:[fromSection count] - 1 inSection:0]];
			} else {
				NSUInteger movingRow = [toSection count] - 1;
				movingObject = toSection[movingRow];
				[toSection removeObjectAtIndex:movingRow];
				[fromSection insertObject:movingObject atIndex:0];
				[self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:movingRow inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
			}
		});
	}
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSDictionary *categoryData = self.sections[indexPath.section][indexPath.row];
	A3UnitConverterConvertTableViewController *viewController = [[A3UnitConverterConvertTableViewController alloc] init];
	viewController.dataManager = _dataManager;
	viewController.categoryID = [categoryData[ID_KEY] unsignedIntegerValue];
	viewController.title = categoryData[NAME_KEY];
	viewController.isFromMoreTableViewController = YES;

	[self.navigationController pushViewController:viewController animated:YES];
}

@end
