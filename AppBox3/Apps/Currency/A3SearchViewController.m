//
//  A3SearchViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/31/13 12:12 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3SearchViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "NSString+conversion.h"
#import "A3AppDelegate.h"

@implementation A3SearchTargetItem

- (NSString *)description {
    return [NSString stringWithFormat:@"code: %@, name: %@, displayName: %@", _code, _name, _displayName];
}

@end

@interface A3SearchViewController () <UISearchDisplayDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic) UILocalizedIndexedCollation *collation;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *sectionIndexTitles;

@end

@implementation A3SearchViewController {
    BOOL _didAdjustContentInset;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[self configureSections];

	self.view.backgroundColor = [UIColor whiteColor];

	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.separatorColor = A3UITableViewSeparatorColor;
	_tableView.separatorInset = A3UITableViewSeparatorInset;
	[self.view addSubview:_tableView];

	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];

	if ([_tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		_tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([_tableView respondsToSelector:@selector(layoutMargins)]) {
		_tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
    if (IS_IPHONEX) {
        if (@available(iOS 11.0, *)) {
            // For iOS 11 and later, we place the search bar in the navigation bar.
            self.navigationController.navigationBar.prefersLargeTitles = NO;
            self.navigationItem.searchController = self.searchController;
            
            // We want the search bar visible all the time.
            self.navigationItem.hidesSearchBarWhenScrolling = NO;
        }
    } else {
        _tableView.tableHeaderView = self.searchController.searchBar;
    }
    
    self.definesPresentationContext = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([_placeHolder length]) {
		self.searchController.searchBar.text = _placeHolder;
		[self filterContentForSearchText:_placeHolder];
	}
}

- (BOOL)resignFirstResponder {
	[self.searchController.searchBar resignFirstResponder];
	return [super resignFirstResponder];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if ([_delegate respondsToSelector:@selector(willDismissSearchViewController)]) {
		[_delegate willDismissSearchViewController];
	}

	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
	} else {
		if (_shouldPopViewController) {
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self.navigationController dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

- (UISearchController *)searchController {
	if (!_searchController) {
		_searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.delegate = self;
		_searchController.searchBar.delegate = self;
        _searchController.searchResultsUpdater = self;
        _searchController.dimsBackgroundDuringPresentation = NO;
        [_searchController.searchBar sizeToFit];
	}
	return _searchController;
}

- (void)callDelegate:(NSString *)selectedItem {
	if ([_delegate respondsToSelector:@selector(searchViewController:itemSelectedWithItem:)]) {
		[_delegate searchViewController:self itemSelectedWithItem:selectedItem];
	}
	if (IS_IPHONE) {
		if (_shouldPopViewController) {
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self.navigationController dismissViewControllerAnimated:YES completion:nil];
		}
	} else {
        if ([self.searchController isActive]) {
            [self.searchController setActive:NO];
        }
		if (self.showCancelButton) {
			[self dismissViewControllerAnimated:YES completion:nil];
		} else if ([[A3AppDelegate instance] rootViewController_iPad].showRightView) {
			[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
		} else {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	self.searchController.searchBar.text = @"";
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

	NSMutableArray *dataContainingSectionsArray = [NSMutableArray new];
	NSMutableArray *sectionTitles = [NSMutableArray new];
	NSMutableArray *sectionIndexTitles = [NSMutableArray new];

	// Now that all the data's in place, each section array needs to be sorted.
	for (index = 0; index < sectionTitlesCount; index++) {

		NSMutableArray *dataArrayForSection = newSectionsArray[index];

		if ([dataArrayForSection count]) {
			// If the table view or its contents were editable, you would make a mutable copy here.
			NSArray *sortedDataArrayForSection = [self.collation
                    sortedArrayFromArray:dataArrayForSection
                 collationStringSelector:NSSelectorFromString(@"displayName")];

			A3SearchTargetItem *firstItem = sortedDataArrayForSection[0];
			NSString *firstLetter = [[[firstItem displayName] substringToIndex:1] componentsSeparatedByKorean];
			[dataContainingSectionsArray addObject:sortedDataArrayForSection];
			NSInteger sectionTitleIndex = [[_collation sectionTitles] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
				return [obj isEqualToString:firstLetter];
			}];
			if (sectionTitleIndex != NSNotFound) {
				[sectionTitles addObject:[_collation sectionTitles][sectionTitleIndex]];
				[sectionIndexTitles addObject:[_collation sectionTitles][sectionTitleIndex]];
			} else {
				[sectionTitles addObject:[_collation sectionTitles][index]];
				[sectionIndexTitles addObject:[_collation sectionTitles][index]];
			}
		}
	}

	self.sectionsArray = dataContainingSectionsArray;
	self.sectionTitles = sectionTitles;
	self.sectionIndexTitles = sectionIndexTitles;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	NSString *query = searchText;
	if (query && query.length) {
		NSPredicate *predicate =
                [NSPredicate predicateWithFormat:@"displayName contains[cd] %@",
                 query];
		_filteredResults = [self.allData filteredArrayUsingPredicate:predicate];
	} else {
		_filteredResults = nil;
	}
	[_tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (_filteredResults) {
		return 1;
	} else {
		return [self.sectionTitles count];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_filteredResults) {
		return [_filteredResults count];
	} else {
		NSArray *rowsInSection = (self.sectionsArray)[section];

		return [rowsInSection count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (_filteredResults == nil) {
		return self.sectionTitles[section];
	}
	return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (_filteredResults == nil) {
		return self.sectionIndexTitles;
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

#pragma mark - UISearchResutsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self filterContentForSearchText:searchController.searchBar.text];
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    if (IS_IPHONEX) return;
    
    if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11") {
        FNLOGRECT(searchController.view.frame);
        CGRect frame = searchController.searchBar.frame;
        frame.origin.y = 20;
        searchController.searchBar.frame = frame;
        FNLOGRECT(searchController.searchBar.frame);
    
        if (!_didAdjustContentInset) {
            UIEdgeInsets contentInset = self.tableView.contentInset;
            FNLOGINSETS(contentInset);
            contentInset.top -= 6;
            self.tableView.contentInset = contentInset;
            
            _didAdjustContentInset = YES;
        }
    }
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    if (IS_IPHONEX) return;
    
    if (_didAdjustContentInset) {
        UIEdgeInsets contentInset = self.tableView.contentInset;
        FNLOGINSETS(contentInset);
        contentInset.top += 6;
        self.tableView.contentInset = contentInset;
        _didAdjustContentInset = NO;
    }
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    if (IS_IPHONEX) return;
    
    self.tableView.contentOffset = CGPointMake(0, -64);
}

- (void)presentSearchController:(UISearchController *)searchController {

}

@end
