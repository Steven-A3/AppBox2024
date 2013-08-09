//
//  A3CurrencySelectViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencySelectViewController.h"
#import "CommonUIDefinitions.h"
#import "common.h"
#import "CurrencyItem.h"
#import "CurrencyItem+name.h"
#import "NSManagedObject+MagicalFinders.h"
#import "CurrencyFavorite.h"

@interface A3CurrencySelectViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic)	BOOL searchBarVisible;

@end

@implementation A3CurrencySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	[self mySearchDisplayController];
	self.tableView.tableHeaderView = self.searchBar;
    
    self.title = NSLocalizedString(@"Select Currency", @"Select Currency");
}

- (UISearchDisplayController *)mySearchDisplayController {
	if (!_mySearchDisplayController) {
		_mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
		_mySearchDisplayController.searchBar.delegate = self;
		_mySearchDisplayController.searchResultsTableView.delegate = self;
		_mySearchDisplayController.searchResultsTableView.dataSource = self;
	}
	return _mySearchDisplayController;
}

- (UISearchBar *)searchBar {
	if (!_searchBar) {
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, kSearchBarHeight)];
		_searchBar.delegate = self;
		_searchBar.placeholder = @"Search";
	}
	return _searchBar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// Display the authors' names as section headings.
	return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    // Configure the cell...
	CurrencyItem *currencyItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if (![currencyItem.name length]) {
		currencyItem.name = [currencyItem localizedName];
	}

	UIColor *textColor;
	if (_allowChooseFavorite) {
		textColor = [UIColor blackColor];
	} else {
		if ([self isFavoriteItemForCurrencyItem:currencyItem]) {
			textColor = self.view.tintColor;
		} else {
            textColor = [UIColor blackColor];
        }
	}

	NSAttributedString *codeString = [[NSAttributedString alloc] initWithString:currencyItem.currencyCode
																	 attributes:[self codeStringAttributeWithColor:textColor ]];
	NSAttributedString *nameString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" - %@", currencyItem.name]
																	 attributes:[self nameStringAttributeWithColor:textColor ]];
	NSMutableAttributedString *cellString = [[NSMutableAttributedString alloc] init];
	[cellString appendAttributedString:codeString];
	[cellString appendAttributedString:nameString];
	cell.textLabel.attributedText = cellString;
    
    return cell;
}

- (NSDictionary *)codeStringAttributeWithColor:(UIColor *)color {
	return @{
			NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline],
			NSForegroundColorAttributeName:color};
}

- (NSDictionary *)nameStringAttributeWithColor:(UIColor *)color {
	return @{
			NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
			NSForegroundColorAttributeName:color};
}

- (BOOL)isFavoriteItemForCurrencyItem:(id)object {
	NSArray *result = [CurrencyFavorite MR_findByAttribute:@"currencyItem" withValue:object];
	return [result count] > 0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	CurrencyItem *currencyItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if (!_allowChooseFavorite && [self isFavoriteItemForCurrencyItem:currencyItem]) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}

	if ([_delegate respondsToSelector:@selector(currencySelected:)]) {
		[_delegate currencySelected:currencyItem.currencyCode];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (NSFetchedResultsController *)fetchedResultsController {
	return _fetchedResultsController;
}

// The method to change the predicate of the FRC
- (void)filterContentForSearchText:(NSString*)searchText
{
	NSString *query = searchText;
	if (query && query.length) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ or currencyCode contains[cd] %@", query, query];
		_fetchedResultsController = [CurrencyItem MR_fetchAllSortedBy:A3KeyCurrencyCode ascending:YES withPredicate:predicate groupBy:nil delegate:nil];
	} else {
		_fetchedResultsController = nil;
	}
	[self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self filterContentForSearchText:searchText];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	_fetchedResultsController = nil;
	[self.tableView reloadData];
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

@end
