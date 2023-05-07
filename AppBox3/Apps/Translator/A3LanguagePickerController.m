//
//  A3LanguagePickerController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/17/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LanguagePickerController.h"
#import "A3TranslatorLanguage.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3StandardLeft15Cell.h"
#import "UIColor+A3Addition.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

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

	self.title = NSLocalizedString(@"Select Language", @"Select Language");
	[self.tableView registerClass:[A3StandardLeft15Cell class] forCellReuseIdentifier:CellIdentifier];
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}

	if (IS_IPHONE) {
		[self leftBarButtonCancelButton];
	}

	[self registerContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
	if ([self.searchController isActive]) {
		[self.searchController setActive:NO];
	}
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem {
	[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
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
	if (self.filteredResults) {
		data = self.filteredResults[indexPath.row];
	} else {
		NSArray *rowsInSection = (self.sectionsArray)[indexPath.section];

		// Configure the cell with the time zone's name.
		data = rowsInSection[indexPath.row];
	}
	
	cell.textLabel.text = data.displayName;
	if (_selectedCodes && data.code && [_selectedCodes containsObject:data.code]) {
        if (_currentCode && [_currentCode isEqualToString:data.code]) {
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        }
        else {
            cell.textLabel.font = A3UITableViewTextLabelFont;
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = A3UITableViewTextLabelFont;
	}

	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	A3SearchTargetItem *data;
	if (self.filteredResults) {
		data = self.filteredResults[indexPath.row];
	} else {
		NSArray *countriesInSection = (self.sectionsArray)[indexPath.section];

		// Configure the cell with the time zone's name.
		data = countriesInSection[indexPath.row];
	}

	if ([self.delegate respondsToSelector:@selector(searchViewController:itemSelectedWithItem:)]) {
		[self.delegate searchViewController:self itemSelectedWithItem:data.code];
	}
    [self.searchController setActive:NO];
	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
