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

@interface A3CurrencySelectViewController ()

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *searchBarPlaceholderView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic)	BOOL searchBarVisible;

@end

@implementation A3CurrencySelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        self.title = NSLocalizedString(@"Select Currency", @"Select Currency");
		_myTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_myTableView.delegate = self;
		_myTableView.dataSource = self;

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[CurrencyItem updateNames];
		});
	}

	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	_myTableView.frame = self.view.bounds;
	[self.view addSubview:_myTableView];

	self.myTableView.tableHeaderView = self.searchBarPlaceholderView;
	[self.searchBarPlaceholderView addSubview:self.searchBar];
}

- (UIView *)searchBarPlaceholderView {
	if (nil == _searchBarPlaceholderView) {
		_searchBarPlaceholderView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.view.bounds), CGRectGetMinY(self.view.bounds), CGRectGetWidth(self.view.bounds), kSearchBarHeight)];
	}
	return _searchBarPlaceholderView;
}

- (UISearchBar *)searchBar {
	if (nil == _searchBar) {
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), kSearchBarHeight)];
		_searchBar.delegate = self;
		_searchBar.placeholder = @"USD";
		_searchBar.translucent = YES;
		_searchBar.text = @"";
		_searchBar.tintColor = [UIColor redColor];
	}
	return _searchBar;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGRect sbFrame = _searchBar.frame;
	sbFrame.origin.y = _searchBarPlaceholderView.frame.origin.y - scrollView.contentOffset.y;

	// it cannot move from the top of the screen
	if (sbFrame.origin.y > 0) {
		sbFrame.origin.y = 0;
	}

	_searchBar.frame = sbFrame;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if ((scrollView.contentOffset.y < kSearchBarHeight)) {
		if (scrollView.contentOffset.y <= 0) {
			_searchBarVisible = YES;
		} else {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			CGRect searchBarFrame = self.searchBar.frame;
			if (_searchBarVisible) {
				scrollView.contentOffset = CGPointMake(0.0, kSearchBarHeight);
				searchBarFrame.origin.y = -1.0 * kSearchBarHeight;
				_searchBarVisible = NO;
			} else {
				scrollView.contentOffset = CGPointMake(0.0, 0.0);
				searchBarFrame.origin.y = 0.0;
				_searchBarVisible = YES;
			}
			_searchBar.frame = searchBarFrame;
			[UIView commitAnimations];
		}
	}
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
	cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", currencyItem.currencyCode, currencyItem.name];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	CurrencyItem *currencyItem = [_fetchedResultsController objectAtIndexPath:indexPath];
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
		_fetchedResultsController = [CurrencyItem MR_fetchAllSortedBy:@"currencyCode" ascending:YES withPredicate:predicate groupBy:nil delegate:nil];
	} else {
		_fetchedResultsController = nil;
	}
	[_myTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self filterContentForSearchText:searchText];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	_fetchedResultsController = nil;
	[_myTableView reloadData];
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

@end
