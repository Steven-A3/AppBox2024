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

static NSString *const HolidayCountryCode = @"code";
static NSString *const HolidayCountryDisplayName = @"name";
static NSString *const CellIdentifier = @"Cell";

@interface A3HolidaysCountrySearchViewController ()

@property (nonatomic, strong) NSMutableArray *allCountries;
@property (nonatomic, strong) NSArray *filteredResults;

@end

@implementation A3HolidaysCountrySearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.searchBar.placeholder = @"Search Country";
	self.title = @"Select Country";

	self.mySearchDisplayController.searchResultsTableView.showsVerticalScrollIndicator = NO;
	[self.mySearchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
	self.tableView.showsVerticalScrollIndicator = NO;
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)allCountries {
	if (!_allCountries) {
		NSArray *countryCodes = [HolidayData supportedCountries];
		_allCountries = [NSMutableArray new];
		[countryCodes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[_allCountries addObject:@{
					HolidayCountryCode:obj,
					HolidayCountryDisplayName:[[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:obj]
			}];
		}];
		[_allCountries sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			return [obj1[HolidayCountryDisplayName] compare:obj2[HolidayCountryDisplayName] ];
		}];
	}
	return _allCountries;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	NSString *query = searchText;
	if (query && query.length) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", HolidayCountryDisplayName, query];
		_filteredResults = [self.allCountries filteredArrayUsingPredicate:predicate];
	} else {
		_filteredResults = nil;
	}
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_filteredResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	NSDictionary *data = _filteredResults[indexPath.row];
	cell.textLabel.text = data[HolidayCountryDisplayName];

	NSArray *existingCountries = [HolidayData userSelectedCountries];
	cell.textLabel.textColor = [existingCountries containsObject:data[HolidayCountryCode]] ? [UIColor colorWithRed:142.0 / 255.0 green:142.0 / 255.0 blue:147.0 / 255.0 alpha:1.0] : [UIColor blackColor];

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *data = _filteredResults[indexPath.row];
	NSArray *currentDataArray = [HolidayData userSelectedCountries];
	if ([currentDataArray containsObject:data[HolidayCountryCode] ]) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}

	[self callDelegate:data[HolidayCountryCode]];

	if ([self.delegate respondsToSelector:@selector(searchViewController:itemSelectedWithItem:)]) {
		[self.delegate searchViewController:self itemSelectedWithItem:data[HolidayCountryCode]];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
