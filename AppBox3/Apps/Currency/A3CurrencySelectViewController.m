//
//  A3CurrencySelectViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencySelectViewController.h"
#import "CurrencyFavorite.h"
#import "UIViewController+A3AppCategory.h"
#import "A3CacheStoreManager.h"
#import "CurrencyRateItem.h"
#import "A3CurrencyDataManager.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+navigation.h"

@interface A3CurrencySelectViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, weak) UIViewController *modalPresentingParentViewController;

@end

@implementation A3CurrencySelectViewController

- (instancetype)initWithPresentingViewController:(UIViewController *)modalPresentingParentViewController {
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		_modalPresentingParentViewController = modalPresentingParentViewController;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.searchBar.placeholder = @"Search";
	self.title = @"Select Currency";

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([self isMovingToParentViewController]) {
		if (self.showCancelButton) {
			[self leftBarButtonCancelButton];
		}
	}
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
	if (!parent) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationChildViewControllerDidDismiss object:self];
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonAction:(UIBarButtonItem *)barButtonItem {
	if (_modalPresentingParentViewController) {
		[_modalPresentingParentViewController dismissViewControllerAnimated:YES completion:NULL];
	} else {
		[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
	}
}

- (NSMutableArray *)allData {
	NSMutableArray *allData = [super allData];
	if (!allData) {
		allData = [NSMutableArray new];
		A3CurrencyDataManager *currencyDataManager = [A3CurrencyDataManager new];
		NSArray *allCurrencies = [CurrencyRateItem MR_findAllInContext:[A3AppDelegate instance].cacheStoreManager.context];
		for (CurrencyRateItem *item in allCurrencies) {
			A3SearchTargetItem *searchTargetItem = [A3SearchTargetItem new];
			searchTargetItem.code = item.currencyCode;
			searchTargetItem.name = [currencyDataManager localizedNameForCode:item.currencyCode];
			// displayName will be used for search target.
			searchTargetItem.displayName = [NSString stringWithFormat:@"%@ %@", searchTargetItem.code, searchTargetItem.name];
			[allData addObject:searchTargetItem];
		}
		[super setAllData:allData];
	}
	return allData;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell=nil;
	static NSString *CellIdentifier = @"Cell";
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	// Configure the cell...
	A3SearchTargetItem *data;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		data = self.filteredResults[indexPath.row];
	} else {
		NSArray *dataInSection = (self.sectionsArray)[indexPath.section];

		// Configure the cell with the time zone's name.
		data = dataInSection[indexPath.row];
	}

	UIColor *textColor;
	if (self.allowChooseFavorite) {
		textColor = [UIColor blackColor];
	} else {
		if ([self isFavoriteItemForCurrencyItem:data.code]) {
			textColor = A3_TEXT_COLOR_DISABLED;
		} else {
			textColor = [UIColor blackColor];
		}
	}

	NSAttributedString *codeString = [[NSAttributedString alloc] initWithString:data.code
																	 attributes:[self codeStringAttributeWithColor:textColor ]];
	NSAttributedString *nameString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"   %@", data.name]
																	 attributes:[self nameStringAttributeWithColor:textColor ]];
	NSMutableAttributedString *cellString = [[NSMutableAttributedString alloc] init];
	[cellString appendAttributedString:codeString];
	[cellString appendAttributedString:nameString];
	cell.textLabel.attributedText = cellString;
	return cell;
}

- (NSDictionary *)codeStringAttributeWithColor:(UIColor *)color {
	return @{
			NSFontAttributeName : [UIFont boldSystemFontOfSize:17],
			NSForegroundColorAttributeName:color};
}

- (NSDictionary *)nameStringAttributeWithColor:(UIColor *)color {
	return @{
			NSFontAttributeName : [UIFont systemFontOfSize:15],
			NSForegroundColorAttributeName:color};
}

- (BOOL)isFavoriteItemForCurrencyItem:(id)object {
	NSArray *result = [CurrencyFavorite MR_findByAttribute:@"currencyCode" withValue:object];
	return [result count] > 0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	A3SearchTargetItem *data;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		data = self.filteredResults[indexPath.row];
	} else {
		NSArray *dataInSection = (self.sectionsArray)[indexPath.section];

		// Configure the cell with the time zone's name.
		data = dataInSection[indexPath.row];
	}
	if (!self.allowChooseFavorite && [self isFavoriteItemForCurrencyItem:data.code]) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}

	[self callDelegate:data.code];
}

@end
