//
//  A3TranslatorFavoriteDataSource.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorFavoriteDataSource.h"
#import "TranslatorHistory.h"
#import "A3TranslatorLanguage.h"
#import "NSDate+TimeAgo.h"
#import "A3TranslatorFavoriteCell.h"
#import "TranslatorFavorite.h"
#import "TranslatorGroup.h"
#import "NSMutableArray+A3Sort.h"

@interface A3TranslatorFavoriteDataSource ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation A3TranslatorFavoriteDataSource

- (void)resetData {
	_fetchedResultsController = nil;
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
		_fetchedResultsController = [TranslatorFavorite MR_fetchAllSortedBy:@"order" ascending:YES withPredicate:nil groupBy:nil delegate:nil];
	}
	return _fetchedResultsController;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"A3TranslatorFavoriteCell";

	A3TranslatorFavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if(cell == nil) {
		cell = [[A3TranslatorFavoriteCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
	}

//	UIImage *image = [UIImage imageNamed:@"star02_full"];
//	cell.imageView.image = image;

	TranslatorFavorite *item = [self.fetchedResultsController objectAtIndexPath:indexPath];

	cell.textLabel.text = [NSString stringWithFormat:@"%@ to %@", [A3TranslatorLanguage localizedNameForCode:item.text.group.sourceLanguage],
														  [A3TranslatorLanguage localizedNameForCode:item.text.group.targetLanguage]];
	cell.detailTextLabel.text = item.text.originalText;
	if (IS_IPAD) {
		cell.dateLabel.text = [item.text.date timeAgo];
	} else {
		cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
	}

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TranslatorFavorite *item = [self.fetchedResultsController objectAtIndexPath:indexPath];

	[_delegate translatorFavoriteItemSelected:item];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSMutableArray *mutableArray = [self.fetchedResultsController.fetchedObjects mutableCopy];
	FNLOG(@"%@", mutableArray);
	[mutableArray moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
	FNLOG(@"%@", mutableArray);

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
	_fetchedResultsController = nil;
}

@end
