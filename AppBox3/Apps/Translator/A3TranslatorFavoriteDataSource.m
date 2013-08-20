//
//  A3TranslatorFavoriteDataSource.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorFavoriteDataSource.h"
#import "TranslatorHistory.h"
#import "NSManagedObject+MagicalFinders.h"
#import "A3TranslatorLanguage.h"
#import "NSDate+TimeAgo.h"
#import "A3TranslatorFavoriteCell.h"
#import "SFKImage.h"

@interface A3TranslatorFavoriteDataSource ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation A3TranslatorFavoriteDataSource

- (void)resetData {
	_fetchedResultsController = nil;
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite == YES"];
		_fetchedResultsController = [TranslatorHistory MR_fetchAllSortedBy:@"date" ascending:YES withPredicate:predicate groupBy:nil delegate:nil];
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

	[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:25.0]];
	[SFKImage setDefaultColor:cell.tintColor];
	UIImage *image = [SFKImage imageNamed:@"i"];
	cell.imageView.image = image;

	TranslatorHistory *item = [self.fetchedResultsController objectAtIndexPath:indexPath];

	cell.textLabel.text = [NSString stringWithFormat:@"%@ to %@", [A3TranslatorLanguage localizedNameForCode:item.originalLanguage],
			[A3TranslatorLanguage localizedNameForCode:item.translatedLanguage]];
	cell.detailTextLabel.text = item.translatedText;
	cell.dateLabel.text = [item.date timeAgoWithLimit:60*60*24 dateFormat:NSDateFormatterShortStyle andTimeFormat:NSDateFormatterShortStyle];

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TranslatorHistory *item = [self.fetchedResultsController objectAtIndexPath:indexPath];

	[_delegate translatorFavoriteItemSelected:item];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
