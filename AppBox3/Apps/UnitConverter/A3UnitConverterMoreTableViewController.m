//
//  A3UnitConverterMoreTableViewController.m
//  AppBox3
//
//  Created by A3 on 4/10/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterMoreTableViewController.h"
#import "UnitType.h"
#import "UnitType+initialize.h"
#import "UIViewController+A3Addition.h"
#import "A3UnitConverterConvertTableViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "UITableViewController+standardDimension.h"
#import "A3MoreTableViewCell.h"

@interface A3UnitConverterMoreTableViewController ()

@property (nonatomic, strong) NSArray *unitTypes;
@property (nonatomic, strong) NSArray *sections;

@end

NSString *const A3UnitConverterMoreTableViewCellIdentifier = @"Cell";

@implementation A3UnitConverterMoreTableViewController {
	BOOL _isEditing;
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

	self.title = @"More";

	[self leftBarButtonAppsButton];
	[self rightBarButtonEditButton];

	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.tableView registerClass:[A3MoreTableViewCell class] forCellReuseIdentifier:A3UnitConverterMoreTableViewCellIdentifier];
}

- (void)rightBarButtonEditButton {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction:)];
	self.navigationItem.rightBarButtonItem = editButton;
}

- (void)editButtonAction:(UIBarButtonItem *)editButton {
	_unitTypes = nil;
	_sections = nil;
	_isEditing = YES;
	[self.tableView reloadData];
	[self.tableView setEditing:YES animated:YES];

	[self rightBarButtonDoneButton];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	_unitTypes = nil;
	_sections = nil;
	_isEditing = NO;
	[self.tableView reloadData];
	[self.tableView setEditing:NO animated:NO];

	[self rightBarButtonEditButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Prepare Data

- (NSArray *)unitTypes {
	if (nil == _unitTypes) {
		_unitTypes = [UnitType MR_findAllSortedBy:@"order" ascending:YES];
	}
	return _unitTypes;
}

- (NSUInteger)numberOfItemsOnTapBar {
	return IS_IPHONE ? 4 : 7;
}

- (NSArray *)sections {
	if (!_sections) {
		NSUInteger numberOfItemsOnTapBar = [self numberOfItemsOnTapBar];
		NSUInteger idx = 0;

		NSMutableArray *sections = [NSMutableArray new];

		if (_isEditing) {
			NSMutableArray *section0 = [NSMutableArray new];
			for (; idx < numberOfItemsOnTapBar; idx++) {
				[section0 addObject:self.unitTypes[idx]];
			}
			[sections addObject:section0];
		} else {
			idx = numberOfItemsOnTapBar;
		}

		NSMutableArray *section1 = [NSMutableArray new];
		for (; idx < [self.unitTypes count]; idx++) {
			[section1 addObject:self.unitTypes[idx]];
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
	if (_isEditing) {
		if (section == 0) return @"Units on the bar";
		return @"Units in more";
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	FNLOG();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    A3MoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:A3UnitConverterMoreTableViewCellIdentifier forIndexPath:indexPath];

	UnitType *unitType = self.sections[indexPath.section][indexPath.row];
	cell.cellImageView.image = [UIImage imageNamed:unitType.flagImagName];
	cell.cellTitleLabel.text = unitType.unitTypeName;
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
	FNLOG(@"%ld - %ld, %ld - %ld", fromIndexPath.section, fromIndexPath.row, toIndexPath.section, toIndexPath.row);
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

	// Update order and save to persistent store
	NSArray *section0 = self.sections[0];
	[section0 enumerateObjectsUsingBlock:^(UnitType *unitType, NSUInteger idx, BOOL *stop) {
		unitType.order = @(idx);
	}];
	NSInteger numberOfItemsOnTabBar = [self numberOfItemsOnTapBar];
	NSArray *section1 = self.sections[1];
	[section1 enumerateObjectsUsingBlock:^(UnitType *unitType, NSUInteger idx, BOOL *stop) {
		unitType.order = @(numberOfItemsOnTabBar + idx);
	}];
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
	FNLOG(@"%@, %@", section0, section1);

	double delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self refreshTabBarController];
	});
}

- (void)refreshTabBarController {
	NSArray *section0 = self.sections[0];
	[section0 enumerateObjectsUsingBlock:^(UnitType *unitType, NSUInteger idx, BOOL *stop) {
		UINavigationController *navigationController = self.tabBarController.viewControllers[idx];
		navigationController.tabBarItem.title = unitType.unitTypeName;
		navigationController.tabBarItem.image = [UIImage imageNamed:unitType.flagImagName];
		navigationController.tabBarItem.selectedImage = [UIImage imageNamed:unitType.selectedFlagImagName];
		A3UnitConverterConvertTableViewController *converterViewController = navigationController.viewControllers[0];
		converterViewController.unitType = unitType;
		converterViewController.title = unitType.unitTypeName;
	}];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

	UnitType *unitType = self.sections[indexPath.section][indexPath.row];
	A3UnitConverterConvertTableViewController *viewController = [[A3UnitConverterConvertTableViewController alloc] init];
	viewController.unitType = unitType;
	viewController.title = unitType.unitTypeName;

	[self.navigationController pushViewController:viewController animated:YES];
}

@end
