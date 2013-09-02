//
//  A3SearchViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/31/13 12:12 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "UIViewController+navigation.h"
#import "A3UIDevice.h"
#import "UIViewController+A3AppCategory.h"
#import "CurrencyItem+name.h"
#import "CurrencyItem.h"
#import "CommonUIDefinitions.h"
#import "A3CurrencySelectViewController.h"
#import "A3SearchViewController.h"


@interface A3SearchViewController ()
@end

@implementation A3SearchViewController {

}
- (void)viewDidLoad {
    [super viewDidLoad];

	[self rightBarButtonDoneButton];
	[self mySearchDisplayController];
	self.tableView.tableHeaderView = self.searchBar;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([_placeHolder length]) {
		self.searchBar.text = _placeHolder;
		[self filterContentForSearchText:_placeHolder];
	}
	[self.mySearchDisplayController setActive:YES];
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
		_mySearchDisplayController.searchBar.delegate = self;
		_mySearchDisplayController.searchResultsTableView.delegate = self;
		_mySearchDisplayController.searchResultsTableView.dataSource = self;
		_mySearchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
	}
	return _mySearchDisplayController;
}

- (UISearchBar *)searchBar {
	if (!_searchBar) {
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, kSearchBarHeight)];
		_searchBar.delegate = self;
		_searchBar.barTintColor = [UIColor colorWithWhite:0.0 alpha:0.1];
	}
	return _searchBar;
}

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
		[self.A3RootViewController dismissRightSideViewController];
	}
}

// The method to change the predicate of the FRC
- (void)filterContentForSearchText:(NSString*)searchText
{
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	_searchBar.text = @"";
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self filterContentForSearchText:searchText];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self doneButtonAction:nil];

}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}
@end