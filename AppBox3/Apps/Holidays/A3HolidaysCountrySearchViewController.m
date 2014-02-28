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


static NSString *const HolidayCountryCode = @"code";
static NSString *const HolidayCountryDisplayName = @"name";
static NSString *const CellIdentifier = @"Cell";

@interface A3HolidaysCountrySearchViewController ()

@end

@implementation A3HolidaysCountrySearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.searchBar.placeholder = @"Search";
	self.title = @"Select Country";

	[self.mySearchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];

	[self leftBarButtonCancelButton];
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
			object.displayName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:obj[kHolidayCountryCode]];
			[_allData addObject:object];
		}];
        
        [super setAllData:_allData];
	}
	return _allData;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	A3SearchTargetItem *data;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		data = self.filteredResults[indexPath.row];
	} else {
		NSArray *countriesInSection = (self.sectionsArray)[indexPath.section];

		// Configure the cell with the time zone's name.
		data = countriesInSection[indexPath.row];
	}
	cell.textLabel.text = data.displayName;

	NSArray *existingCountries = [HolidayData userSelectedCountries];
	cell.textLabel.textColor = [existingCountries containsObject:data.code] ? [UIColor colorWithRed:142.0 / 255.0 green:142.0 / 255.0 blue:147.0 / 255.0 alpha:1.0] : [UIColor blackColor];

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
