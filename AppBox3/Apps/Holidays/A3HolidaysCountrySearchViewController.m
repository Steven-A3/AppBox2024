//
//  A3HolidaysCountrySearchViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/31/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysCountrySearchViewController.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"
#import "UIViewController+A3Addition.h"
#import "A3StandardTableViewCell.h"


static NSString *const HolidayCountryCode = @"code";
static NSString *const HolidayCountryDisplayName = @"name";
static NSString *const CellIdentifier = @"Cell";

@interface A3HolidaysCountrySearchViewController ()

@end

@implementation A3HolidaysCountrySearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.searchBar.placeholder = NSLocalizedString(@"Search", @"Search");
	self.title = NSLocalizedString(@"Select Country", @"Select Country");

	[self.mySearchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
	[self.tableView registerClass:[A3StandardTableViewCell class] forCellReuseIdentifier:CellIdentifier];

	[self leftBarButtonCancelButton];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)allData {
    NSMutableArray *_allData = [super allData];
    if (!_allData) {
        _allData = [NSMutableArray new];
		NSArray *countryCodes = [HolidayData supportedCountries];
		_allData = [NSMutableArray new];
		[countryCodes enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
			A3SearchTargetItem *object = [A3SearchTargetItem new];
			object.code = obj[kHolidayCountryCode];
			object.displayName = [HolidayData displayNameForCountryCode:object.code];
			[_allData addObject:object];
		}];

		FNLOG(@"Supported Holidays Counter: %ld", (long)[countryCodes count]);
        
        [super setAllData:_allData];
	}
	return _allData;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    A3StandardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	A3SearchTargetItem *data;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		data = self.filteredResults[indexPath.row];
	} else {
		NSArray *countriesInSection = (self.sectionsArray)[indexPath.section];

		// Configure the cell with the time zone's name.
		data = countriesInSection[indexPath.row];
	}
	cell.textLabel.font = [UIFont systemFontOfSize:17];
	cell.textLabel.text = data.displayName;

	NSArray *existingCountries = [HolidayData userSelectedCountries];
	cell.accessoryType = [existingCountries containsObject:data.code] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	A3SearchTargetItem *data;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		data = self.filteredResults[indexPath.row];
	} else {
		NSArray *countriesInSection = (self.sectionsArray)[indexPath.section];

		// Configure the cell with the time zone's name.
		data = countriesInSection[indexPath.row];
	}
	NSArray *currentDataArray = [HolidayData userSelectedCountries];
	if ([currentDataArray containsObject:data.code]) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}

	if ([self.delegate respondsToSelector:@selector(searchViewController:itemSelectedWithItem:)]) {
		[self.delegate searchViewController:self itemSelectedWithItem:data.code];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
