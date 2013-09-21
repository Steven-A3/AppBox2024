//
//  A3CurrencySelectViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencySelectViewController.h"
#import "CurrencyItem.h"
#import "CurrencyItem+name.h"
#import "CurrencyFavorite.h"
#import "UIViewController+A3AppCategory.h"

@interface A3CurrencySelectViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@end

@implementation A3CurrencySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	@autoreleasepool {
		self.searchBar.placeholder = @"Search Currency";
		self.title = @"Select Currency";

		[self registerContentSizeCategoryDidChangeNotification];
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

- (NSMutableArray *)allData {
	NSMutableArray *allData=nil;
	@autoreleasepool {
		allData = [super allData];
		if (!allData) {
			allData = [NSMutableArray new];
			NSArray *allCurrencies = [CurrencyItem MR_findAll];
			for (CurrencyItem *item in allCurrencies) {
				A3SearchTargetItem *searchTargetItem = [A3SearchTargetItem new];
				searchTargetItem.code = item.currencyCode;
				searchTargetItem.name = item.localizedName;
				// displayName will be used for search target.
				searchTargetItem.displayName = [NSString stringWithFormat:@"%@ %@", searchTargetItem.code, searchTargetItem.name];
				[allData addObject:searchTargetItem];
			}
		}
	}
	return allData;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	@autoreleasepool {
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
				textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
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
}

- (NSDictionary *)codeStringAttributeWithColor:(UIColor *)color {
	return @{
			NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline],
			NSForegroundColorAttributeName:color};
}

- (NSDictionary *)nameStringAttributeWithColor:(UIColor *)color {
	return @{
			NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline],
			NSForegroundColorAttributeName:color};
}

- (BOOL)isFavoriteItemForCurrencyItem:(id)object {
	NSArray *result = [CurrencyFavorite MR_findByAttribute:@"currencyItem.currencyCode" withValue:object];
	return [result count] > 0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	@autoreleasepool {
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
}

@end
