//
//  A3LanguagePickerController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/17/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LanguagePickerController.h"
#import "A3TranslatorLanguage.h"
#import "CommonUIDefinitions.h"
#import "A3UIDevice.h"
#import "UIViewController+A3AppCategory.h"

@interface A3LanguagePickerController () <UISearchBarDelegate>

@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *filteredContents;

@end

@implementation A3LanguagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	self.title = @"Select Language";
	[self rightBarButtonDoneButton];

	[self mySearchDisplayController];
	self.tableView.tableHeaderView = self.searchBar;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[_mySearchDisplayController setActive:YES];
	[_searchBar becomeFirstResponder];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UISearchDisplayController *)mySearchDisplayController {
	if (!_mySearchDisplayController) {
		_mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
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
		_searchBar.prompt = @"Select Language";
		_searchBar.placeholder = @"Search Language";
		_searchBar.barTintColor = [UIColor colorWithWhite:0.0 alpha:0.1];
	}
	return _searchBar;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_filteredContents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	// Configure the cell...
	A3TranslatorLanguage *language = _filteredContents[indexPath.row];
	cell.textLabel.text = [language name];

	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	A3TranslatorLanguage *language = _filteredContents[indexPath.row];
	if ([_delegate respondsToSelector:@selector(languagePickerController:didSelectLanguage:)]) {
		[_delegate languagePickerController:self didSelectLanguage:language];
	}
	[self doneButtonAction:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	_searchBar.text = @"";
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	_filteredContents = [A3TranslatorLanguage filteredArrayWithArray:_languages searchString:searchText includeDetectLanguage:YES ];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self doneButtonAction:nil];

//	_fetchedResultsController = nil;
//	[self.tableView reloadData];
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}


@end
