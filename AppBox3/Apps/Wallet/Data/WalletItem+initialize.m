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
#import "WalletCategory.h"
#import "WalletField.h"
#import "A3UserDefaultsKeys.h"
#import "A3AppDelegate.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"

@implementation WalletItem (initialize)

/*! 다른 조건 없이 오로지 이 아이템 ID를 가지고 있는 field item 을 순서에 관계없이 찾는다. 순서가 의미가 없는 경우에 한함
 *  Field 의 순서를 따라야 한다면, fieldItemsArraySortedByFieldOrder 를 써야 한다.
 * \param
 * \returns
 */
- (NSArray *)fieldItems {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItemID == %@", self.uniqueID];
	return [WalletFieldItem findAllWithPredicate:predicate];
}

- (NSArray *)fieldItemsArraySortedByFieldOrder
{
	WalletCategory *category = [WalletData categoryItemWithID:self.categoryID];
	NSArray *fields = [WalletField findByAttribute:@"categoryID" withValue:category.uniqueID andOrderBy:@"order" ascending:YES];
	NSArray *fieldIDs = [fields valueForKeyPath:ID_KEY];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItemID == %@", self.uniqueID];
	NSArray *fieldItems = [WalletFieldItem findAllWithPredicate:predicate];
	fieldItems = [fieldItems sortedArrayUsingComparator:^NSComparisonResult(WalletFieldItem *obj1, WalletFieldItem *obj2) {
		NSUInteger idx1 = [fieldIDs indexOfObject:obj1.fieldID];
		NSUInteger idx2 = [fieldIDs indexOfObject:obj2.fieldID];
		return [@(idx1) compare:@(idx2)];
	}];
    return fieldItems;
}

- (void)assignOrder {
	WalletItem *item = [WalletItem findFirstOrderedByAttribute:@"order" ascending:NO];
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
	WalletCategory *category = [WalletData categoryItemWithID:self.categoryID];
	NSArray *fields = [WalletField findByAttribute:@"categoryID" withValue:category.uniqueID andOrderBy:@"order" ascending:YES];
	for (WalletFieldItem *fieldItem in fieldItems) {
		if (![fieldItem.fieldID length]) {
			[fieldItemsFieldDoesNotExist addObject:fieldItem];
			continue;
		}
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", ID_KEY, fieldItem.fieldID];
		NSArray *filteredArray = [fields filteredArrayUsingPredicate:predicate];
		if (![filteredArray count]) {
			fieldItem.fieldID = nil;
			[fieldItemsFieldDoesNotExist addObject:fieldItem];
			continue;
		}
		WalletField *field = filteredArray[0];
		if ([fieldItem.hasImage boolValue] && ![field.type isEqualToString:WalletFieldTypeImage]) {
			fieldItem.fieldID = nil;
			continue;
		}
		if ([fieldItem.hasVideo boolValue] && ![field.type isEqualToString:WalletFieldTypeVideo]) {
			fieldItem.fieldID = nil;
		}
	}
	if (![fieldItemsFieldDoesNotExist count]) return;

	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	NSMutableString *collectedTexts = [NSMutableString new];
    NSManagedObjectContext *context = [[A3AppDelegate instance] managedObjectContext];
    for (WalletFieldItem *fieldItem in fieldItemsFieldDoesNotExist) {
        if (fieldItem.date) {
            [collectedTexts appendFormat:@"%@\n", [dateFormatter stringFromDate:fieldItem.date]];
            [context deleteObject:fieldItem];
        } else if ([fieldItem.value length]) {
            [collectedTexts appendFormat:@"%@\n", fieldItem.value];
            [context deleteObject:fieldItem];
        }
    }
    if ([collectedTexts length]) {
        self.note = [NSString stringWithFormat:@"%@%@", [self.note length] ? [NSString stringWithFormat:@"%@\n", self.note] : @"", collectedTexts];
    }
    [context saveContext];
}

- (void)deleteWalletItem {
    NSManagedObjectContext *context = [[A3AppDelegate instance] managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItemID == %@", self.uniqueID];
	NSArray *fieldItems = [WalletFieldItem findAllWithPredicate:predicate];
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
	[WalletFieldItem deleteAllMatchingPredicate:predicate];
	predicate = [NSPredicate predicateWithFormat:@"itemID == %@", self.uniqueID];
	[WalletFavorite deleteAllMatchingPredicate:predicate];
    [context deleteObject:self];
}

@end
