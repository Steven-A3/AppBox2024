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
#import "TranslatorHistory+manager.h"

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

	TranslatorFavorite *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	TranslatorHistory *history = [TranslatorHistory MR_findFirstByAttribute:@"uniqueID" withValue:item.historyID];
	TranslatorGroup *group = [TranslatorGroup MR_findFirstByAttribute:@"uniqueID" withValue:history.groupID];
	cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ to %@", @"%@ to %@"), [A3TranslatorLanguage localizedNameForCode:group.sourceLanguage],
													 [A3TranslatorLanguage localizedNameForCode:group.targetLanguage]];
	cell.detailTextLabel.text = history.originalText;
	if (IS_IPAD) {
		cell.dateLabel.text = [history.updateDate timeAgo];
	} else {
        cell.textLabel.font = [UIFont systemFontOfSize:15];
		cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		TranslatorFavorite *favorite = [self.fetchedResultsController objectAtIndexPath:indexPath];
		[favorite MR_deleteEntity];
		[favorite.managedObjectContext MR_saveToPersistentStoreAndWait];

		[self.fetchedResultsController performFetch:nil];

		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSMutableArray *mutableArray = [self.fetchedResultsController.fetchedObjects mutableCopy];
	[mutableArray moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];

	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

	[self.fetchedResultsController performFetch:nil];
}

@end
