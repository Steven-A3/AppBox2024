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
#import "A3AppDelegate.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"

@interface A3TranslatorFavoriteDataSource ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) A3TranslatorLanguage *languageListManager;
@end

@implementation A3TranslatorFavoriteDataSource

- (A3TranslatorLanguage *)languageListManager {
    if (!_languageListManager) {
        _languageListManager = [A3TranslatorLanguage new];
    }
    return _languageListManager;
}

- (void)resetData {
	_fetchedResultsController = nil;
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
		_fetchedResultsController = [TranslatorFavorite fetchAllSortedBy:@"order" ascending:YES withPredicate:nil groupBy:nil delegate:nil];
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
	TranslatorHistory *history = [TranslatorHistory findFirstByAttribute:@"uniqueID" withValue:item.historyID];
	TranslatorGroup *group = [TranslatorGroup findFirstByAttribute:@"uniqueID" withValue:history.groupID];
	cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ to %@", @"%@ to %@"), [self.languageListManager localizedNameForCode:group.sourceLanguage],
													 [self.languageListManager localizedNameForCode:group.targetLanguage]];
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
        NSManagedObjectContext *context = [[A3AppDelegate instance] managedObjectContext];
		TranslatorFavorite *favorite = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:favorite];

		[self.fetchedResultsController performFetch:nil];

		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        [context saveContext];
	}
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSMutableArray *mutableArray = [self.fetchedResultsController.fetchedObjects mutableCopy];
	[mutableArray moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];

    NSManagedObjectContext *context = [[A3AppDelegate instance] managedObjectContext];
    [context saveContext];

	[self.fetchedResultsController performFetch:nil];
}

@end
