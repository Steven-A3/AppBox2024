//
//  A3HolidaysCountryViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysCountryViewController.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"
#import "A3HolidaysCountryViewCell.h"
#import "A3CurrencyTVActionCell.h"
#import "FMMoveTableView.h"
#import "A3HolidaysCountrySearchViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "A3HolidaysFlickrDownloadManager.h"
#import "NSMutableArray+MoveObject.h"

@interface A3HolidaysCountryViewController () <FMMoveTableViewDataSource, FMMoveTableViewDelegate, A3SearchViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *userSelectedCountries;
@property (nonatomic, strong) FMMoveTableView *tableView;

@end

@implementation A3HolidaysCountryViewController {
	BOOL _countryEdited;
}

static NSString *const HolidayCellIdentifier = @"HolidayCountryViewCell";

extern NSString *const A3CurrencyActionCellID;

- (void)viewDidLoad
{
	[super viewDidLoad];

	_countryEdited = NO;

	_tableView = [[FMMoveTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[self.view addSubview:_tableView];

	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[self.navigationController setNavigationBarHidden:YES];

	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;
 
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;

	self.view.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];

	self.tableView.rowHeight = 84;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.showsVerticalScrollIndicator = NO;
	[self.tableView registerClass:[A3HolidaysCountryViewCell class] forCellReuseIdentifier:HolidayCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:@"A3CurrencyTVActionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:A3CurrencyActionCellID];

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isBeingDismissed]) {
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	if (self.isMovingFromParentViewController) {
		[self removeObserver];
	}
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Data

- (NSMutableArray *)userSelectedCountries {
	if (!_userSelectedCountries) {
		NSArray *array = [HolidayData userSelectedCountries];
		_userSelectedCountries = [NSMutableArray arrayWithArray:array];
	}
	return _userSelectedCountries;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	NSInteger numberOfRows = [self.userSelectedCountries count] + 1;

	return numberOfRows;
}

- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

	if (indexPath.row == [self.userSelectedCountries count]) {
		A3CurrencyTVActionCell *plusCell = [tableView dequeueReusableCellWithIdentifier:A3CurrencyActionCellID forIndexPath:indexPath];

		[plusCell.centerButton addTarget:self action:@selector(plusButtonAction) forControlEvents:UIControlEventTouchUpInside];
		plusCell.backgroundColor = [UIColor clearColor];
		cell = plusCell;
	} else {
		A3HolidaysCountryViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:HolidayCellIdentifier forIndexPath:indexPath];
		normalCell.pageViewController = _pageViewController;

		if ([tableView indexPathIsMovingIndexPath:indexPath])
		{
			[normalCell prepareForMove];
		} else {
			// Configure the cell...
			if ([tableView movingIndexPath]) {
				indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
			}

			NSString *countryCode = self.userSelectedCountries[indexPath.row];

			[normalCell setCountryCode:countryCode];

			if (indexPath.row == 0) {
				[normalCell locationImageView];
			}
		}
		cell = normalCell;
	}
	return cell;
}

- (void)plusButtonAction {
	if ([self.userSelectedCountries count] >= 10) {
		NSString *msg = @"To add a new country, remove one first.";
		if (IS_IPHONE) {
			UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:msg delegate:nil cancelButtonTitle:@"OK" destructiveButtonTitle:nil	otherButtonTitles:nil];
			[sheet showInView:self.view];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
		return;
	}
	A3HolidaysCountrySearchViewController *viewController = [[A3HolidaysCountrySearchViewController alloc] initWithNibName:nil bundle:nil];
	viewController.delegate = self;

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedItem {
	_countryEdited = YES;

	[_userSelectedCountries addObject:selectedItem];
	[HolidayData setUserSelectedCountries:_userSelectedCountries];

	[self.tableView reloadData];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.userSelectedCountries count] == 1) {
		return NO;
	}
	// Return NO if you do not want the specified item to be editable.
	return indexPath.row != [self.userSelectedCountries count];
}

extern NSString *const kA3HolidayScreenImagePath;
extern NSString *const kA3HolidayScreenImageOwner;
extern NSString *const kA3HolidayScreenImageURL;
extern NSString *const kA3HolidayScreenImageDownloadDate;

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		_countryEdited = YES;

		[[A3HolidaysFlickrDownloadManager sharedInstance] deleteImageForCountryCode:self.userSelectedCountries[indexPath.row]];

		[self.userSelectedCountries removeObjectAtIndex:indexPath.row];
		[HolidayData setUserSelectedCountries:_userSelectedCountries];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[self.userSelectedCountries moveObjectFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
	[HolidayData setUserSelectedCountries:_userSelectedCountries];

	_countryEdited = YES;
}

- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.userSelectedCountries count] == 1 || indexPath.row == 0) {
		return NO;
	}
	// Return NO if you do not want the item to be re-orderable.
	return indexPath.row != [self.userSelectedCountries count];
}

- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {

	if (proposedDestinationIndexPath.row == [self.userSelectedCountries count]) {
		return [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row - 1 inSection:0];
	}
	if (proposedDestinationIndexPath.row == 0) {
		return [NSIndexPath indexPathForRow:1 inSection:0];
	}
	return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [_userSelectedCountries count]) {
		[self plusButtonAction];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	} else {
        [self dismissViewControllerAnimated:YES completion:nil];

		NSUInteger row = (NSUInteger) indexPath.row;

		[_delegate viewController:self didFinishPickingCountry:self.userSelectedCountries[row] dataChanged:_countryEdited];
	}
}

@end
