//
//  A3SearchViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/31/13 12:12 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3UIDevice.h"
#import "UIViewController+A3AppCategory.h"
#import "A3CurrencySelectViewController.h"
#import "UIViewController+A3Addition.h"
#import "UITableViewController+standardDimension.h"

@implementation A3SearchTargetItem
@end

@interface A3SearchViewController () <UISearchDisplayDelegate>
@end

@implementation A3SearchViewController {

}
- (void)viewDidLoad {
    [super viewDidLoad];

	[self configureSections];

	self.view.backgroundColor = [UIColor whiteColor];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.separatorColor = A3UITableViewSeparatorColor;
	_tableView.separatorInset = A3UITableViewSeparatorInset;
	_tableView.contentInset = UIEdgeInsetsMake(kSearchBarHeight + 4, 0, 0, 0);
	[self.view addSubview:_tableView];

	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];

	[self.view addSubview:self.searchBar];
	[self mySearchDisplayController];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([_placeHolder length]) {
		self.searchBar.text = _placeHolder;
		[self filterContentForSearchText:_placeHolder];
	}
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if ([_delegate respondsToSelector:@selector(willDismissSearchViewController)]) {
		[_delegate willDismissSearchViewController];
	}

	if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
	} else {
		if (_shouldPopViewController) {
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

- (UISearchDisplayController *)mySearchDisplayController {
	if (!_mySearchDisplayController) {
		_mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
		_mySearchDisplayController.delegate = self;
		_mySearchDisplayController.searchBar.delegate = self;
		_mySearchDisplayController.searchResultsTableView.delegate = self;
		_mySearchDisplayController.searchResultsTableView.dataSource = self;
		_mySearchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
		_mySearchDisplayController.searchResultsTableView.showsVerticalScrollIndicator = NO;

	}
	return _mySearchDisplayController;
}

- (UISearchBar *)searchBar {
	if (!_searchBar) {
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 64.0, self.view.bounds.size.width, kSearchBarHeight)];
		_searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_searchBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
		_searchBar.delegate = self;
	}
	return _searchBar;
}

- (void)callDelegate:(NSString *)selectedItem {
	if ([_delegate respondsToSelector:@selector(searchViewController:itemSelectedWithItem:)]) {
		[_delegate searchViewController:self itemSelectedWithItem:selectedItem];
	}
	if (IS_IPHONE) {
		if (_shouldPopViewController) {
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	} else {
		if (self.showCancelButton) {
			[self dismissViewControllerAnimated:YES completion:nil];
		} else if (self.A3RootViewController.showRightView) {
			[self.A3RootViewController dismissRightSideViewController];
		} else {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	_searchBar.text = @"";
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self filterContentForSearchText:searchText];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

#pragma mark UISearchDisplayControllerDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
	[self.tableView setHidden:YES];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
	[self.tableView setHidden:NO];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {

}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {

}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {

	CGRect frame = _searchBar.frame;
	frame.origin.y = 20.0;
	_searchBar.frame = frame;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	CGRect frame = _searchBar.frame;
	frame.origin.y = 64.0;
	_searchBar.frame = frame;
}

- (UILocalizedIndexedCollation *)collation {
	if (!_collation) {
		[self configureSections];
	}
	return _collation;
}

- (void)configureSections {
	// Get the current collation and keep a reference to it.
	_collation = [UILocalizedIndexedCollation currentCollation];

	NSInteger index, sectionTitlesCount = [[self.collation sectionTitles] count];

	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];

	// Set up the sections array: elements are mutable arrays that will contain the time zones for that section.
	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
	}

	// Segregate the time zones into the appropriate arrays.
	for (id object in self.allData) {

		// Ask the collation which section number the time zone belongs in, based on its locale name.
		NSInteger sectionNumber = [self.collation sectionForObject:object collationStringSelector:NSSelectorFromString(@"displayName")];

		// Get the array for the section.
		NSMutableArray *sections = newSectionsArray[sectionNumber];

		//  Add the time zone to the section.
		[sections addObject:object];
	}

	// Now that all the data's in place, each section array needs to be sorted.
	for (index = 0; index < sectionTitlesCount; index++) {

		NSMutableArray *dataArrayForSection = newSectionsArray[index];

		// If the table view or its contents were editable, you would make a mutable copy here.
		NSArray *sortedDataArrayForSection = [self.collation sortedArrayFromArray:dataArrayForSection collationStringSelector:NSSelectorFromString(@"displayName")];

		// Replace the existing array with the sorted array.
		newSectionsArray[index] = sortedDataArrayForSection;
	}

	self.sectionsArray = newSectionsArray;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	NSString *query = searchText;
	if (query && query.length) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayName contains[cd] %@", query];
		_filteredResults = [self.allData filteredArrayUsingPredicate:predicate];
	} else {
		_filteredResults = nil;
	}
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		return 1;
	} else {
		return [[self.collation sectionTitles] count];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		return [_filteredResults count];
	} else {
		NSArray *rowsInSection = (self.sectionsArray)[section];

		return [rowsInSection count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (tableView == self.tableView) {
		return [self.collation sectionTitles][section];
	}
	return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if (tableView == self.tableView) {
		return [self.collation sectionIndexTitles];
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [self.collation sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

@end
