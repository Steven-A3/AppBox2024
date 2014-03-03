//
//  A3LanguagePickerController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/17/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LanguagePickerController.h"
#import "A3TranslatorLanguage.h"
#import "A3UIDevice.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+A3Addition.h"
#import "UITableViewController+standardDimension.h"

@interface A3LanguagePickerController () <UISearchBarDelegate>

@end

@implementation A3LanguagePickerController

- (instancetype)initWithLanguages:(NSArray *)languages {
	self = [super init];
	if (self) {
		NSMutableArray *array = [NSMutableArray new];
		for (A3TranslatorLanguage *language in languages) {
			A3SearchTargetItem *searchItem = [A3SearchTargetItem new];
			searchItem.code = language.code;
			searchItem.displayName = language.name;
			[array addObject:searchItem];
		}
		self.allData = array;

	}
	return self;
}

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	self.title = @"Select Language";
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
	[self.mySearchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];

	[self leftBarButtonCancelButton];

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	A3SearchTargetItem *data;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		data = self.filteredResults[indexPath.row];
	} else {
		NSArray *rowsInSection = (self.sectionsArray)[indexPath.section];

		// Configure the cell with the time zone's name.
		data = rowsInSection[indexPath.row];
	}
	cell.textLabel.font = A3UITableViewTextLabelFont;
	cell.textLabel.text = data.displayName;

	return cell;
}

#pragma mark - UITableViewDelegate

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

	if ([self.delegate respondsToSelector:@selector(searchViewController:itemSelectedWithItem:)]) {
		[self.delegate searchViewController:self itemSelectedWithItem:data.code];
	}
	if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
