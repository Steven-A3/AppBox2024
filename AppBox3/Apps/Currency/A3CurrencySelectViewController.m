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

@interface A3CurrencySelectViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@end

@implementation A3CurrencySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.placeholder = @"Search Currency";
    self.title = @"Select Currency";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The method to change the predicate of the FRC
- (void)filterContentForSearchText:(NSString*)searchText
{
	NSString *query = searchText;
	if (query && query.length) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ or currencyCode contains[cd] %@", query, query];
		self.fetchedResultsController = [CurrencyItem MR_fetchAllSortedBy:A3KeyCurrencyCode ascending:YES withPredicate:predicate groupBy:nil delegate:nil];
	} else {
		self.fetchedResultsController = nil;
	}
	[self.tableView reloadData];
}

#pragma mark - Table view data source

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
	if (self.allowChooseFavorite) {
		textColor = [UIColor blackColor];
	} else {
		if ([self isFavoriteItemForCurrencyItem:currencyItem]) {
			textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
		} else {
            textColor = [UIColor blackColor];
        }
	}

	NSAttributedString *codeString = [[NSAttributedString alloc] initWithString:currencyItem.currencyCode
																	 attributes:[self codeStringAttributeWithColor:textColor ]];
	NSAttributedString *nameString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"   %@", currencyItem.name]
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
	if (!self.allowChooseFavorite && [self isFavoriteItemForCurrencyItem:currencyItem]) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}

	[self callDelegate:currencyItem.currencyCode];
}

@end
