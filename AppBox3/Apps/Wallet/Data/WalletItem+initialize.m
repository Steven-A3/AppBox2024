//
//  WalletItem+initialize.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 30..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletItem+initialize.h"
#import "WalletFavorite.h"
#import "WalletFieldItem+initialize.h"
#import "NSString+conversion.h"
#import "WalletData.h"

@implementation WalletItem (initialize)

- (NSArray *)fieldItemsArraySortedByFieldOrder
{
	NSDictionary *category = [WalletData categoryItemWithID:self.categoryID];
	NSArray *fields = category[W_FIELDS_KEY];
	NSArray *fieldIDs = [fields valueForKeyPath:W_ID_KEY];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItemID == %@ AND fieldID != NULL", self.uniqueID];
	NSArray *fieldItems = [WalletFieldItem MR_findAllWithPredicate:predicate inContext:self.managedObjectContext];
	fieldItems = [fieldItems sortedArrayUsingComparator:^NSComparisonResult(WalletFieldItem *obj1, WalletFieldItem *obj2) {
		NSUInteger idx1 = [fieldIDs indexOfObject:obj1.fieldID];
		NSUInteger idx2 = [fieldIDs indexOfObject:obj2.fieldID];
		return [@(idx1) compare:@(idx2)];
	}];
    return fieldItems;
}

- (void)assignOrder {
	WalletItem *item = [WalletItem MR_findFirstOrderedByAttribute:@"order" ascending:NO inContext:self.managedObjectContext];
	if (item) {
		NSInteger latestOrder = [item.order integerValue];
		self.order = [NSString orderStringWithOrder:latestOrder + 1000000];
	} else {
		self.order = [NSString orderStringWithOrder:1000000];
	}
}

- (void)verifyNULLField {
	NSArray *fieldItems = [self fieldItemsArraySortedByFieldOrder];
	NSMutableArray *fieldItemsFieldDoesNotExist = [NSMutableArray new];
	NSDictionary *category = [WalletData categoryItemWithID:self.categoryID];
	NSArray *fields = category[W_FIELDS_KEY];
	for (WalletFieldItem *fieldItem in fieldItems) {
		if (![fieldItem.fieldID length]) {
			[fieldItemsFieldDoesNotExist addObject:fieldItem];
			continue;
		}
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", W_ID_KEY, fieldItem.fieldID];
		NSArray *filteredArray = [fields filteredArrayUsingPredicate:predicate];
		if (![filteredArray count]) {
			fieldItem.fieldID = nil;
			[fieldItemsFieldDoesNotExist addObject:fieldItem];
			continue;
		}
		NSDictionary *field = filteredArray[0];
		if ([fieldItem.hasImage boolValue] && ![field[W_TYPE_KEY] isEqualToString:WalletFieldTypeImage]) {
			fieldItem.fieldID = nil;
			continue;
		}
		if ([fieldItem.hasVideo boolValue] && ![field[W_TYPE_KEY] isEqualToString:WalletFieldTypeVideo]) {
			fieldItem.fieldID = nil;
		}
	}
	if (![fieldItemsFieldDoesNotExist count]) return;

	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	NSMutableString *collectedTexts = [NSMutableString new];
	for (WalletFieldItem *fieldItem in fieldItemsFieldDoesNotExist) {
		if (fieldItem.date) {
			[collectedTexts appendFormat:@"%@\n", [dateFormatter stringFromDate:fieldItem.date]];
			[fieldItem MR_deleteEntity];
		} else if ([fieldItem.value length]) {
			[collectedTexts appendFormat:@"%@\n", fieldItem.value];
			[fieldItem MR_deleteEntity];
		}
	}
	if ([collectedTexts length]) {
		self.note = [NSString stringWithFormat:@"%@%@", [self.note length] ? [NSString stringWithFormat:@"%@\n", self.note] : @"", collectedTexts];
	}
	[[self managedObjectContext] MR_saveToPersistentStoreAndWait];
}

- (void)deleteWalletItem {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItemID == %@", self.uniqueID];
	NSArray *fieldItems = [WalletFieldItem MR_findAllWithPredicate:predicate];
	[fieldItems enumerateObjectsUsingBlock:^(WalletFieldItem *fieldItem, NSUInteger idx, BOOL *stop) {
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		BOOL result;
		if ([fieldItem.hasImage boolValue]) {
			if ([fileManager fileExistsAtPath:[fieldItem photoImageThumbnailPathInOriginal:NO]]) {
				result = [fileManager removeItemAtPath:[fieldItem photoImageThumbnailPathInOriginal:NO] error:NULL];
				NSAssert(result, @"result");
			}
			if ([fileManager fileExistsAtPath:[fieldItem photoImageThumbnailPathInOriginal:YES]]) {
				result = [fileManager removeItemAtPath:[fieldItem photoImageThumbnailPathInOriginal:YES] error:NULL];
				NSAssert(result, @"result");
			}
			if ([fileManager fileExistsAtPath:[[fieldItem photoImageURLInOriginalDirectory:NO] path]]) {
				result = [fileManager removeItemAtURL:[fieldItem photoImageURLInOriginalDirectory:NO] error:NULL];
				NSAssert(result, @"result");
			}
			if ([fileManager fileExistsAtPath:[[fieldItem photoImageURLInOriginalDirectory:YES] path]]) {
				[fileManager removeItemAtPath:[[fieldItem photoImageURLInOriginalDirectory:YES] path] error:NULL];
				NSAssert(result, @"result");
			}
		} else {
			if ([fileManager fileExistsAtPath:[fieldItem videoThumbnailPathInOriginal:NO]]) {
				result = [fileManager removeItemAtPath:[fieldItem videoThumbnailPathInOriginal:NO] error:NULL];
				NSAssert(result, @"result");
			}
			if ([fileManager fileExistsAtPath:[[fieldItem videoFileURLInOriginal:YES] path]]) {
				result = [fileManager removeItemAtURL:[fieldItem videoFileURLInOriginal:YES] error:NULL];
				NSAssert(result, @"result");
			}
		}
	}];
	[WalletFieldItem MR_deleteAllMatchingPredicate:predicate];
	predicate = [NSPredicate predicateWithFormat:@"itemID == %@", self.uniqueID];
	[WalletFavorite MR_deleteAllMatchingPredicate:predicate];
	[self MR_deleteEntity];
}

@end
