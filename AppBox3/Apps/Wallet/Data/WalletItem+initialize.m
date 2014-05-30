//
//  WalletItem+initialize.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 30..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletItem+initialize.h"
#import "WalletItem+Favorite.h"
#import "WalletFavorite.h"
#import "WalletFieldItem+initialize.h"
#import "NSString+conversion.h"
#import "WalletField.h"
#import "WalletData.h"

@implementation WalletItem (initialize)

- (NSArray *)fieldItemsArray
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"field.order" ascending:YES];
    return [self.fieldItems sortedArrayUsingDescriptors:@[sortDescriptor]];
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
	for (WalletFieldItem *fieldItem in self.fieldItems.allObjects) {
		if (fieldItem.image && ![fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
			fieldItem.field = nil;
			continue;
		}
		if (fieldItem.video && ![fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
			fieldItem.field = nil;
		}
	}

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"walletItem.uniqueID == %@ AND field == NULL", self.uniqueID];
	NSArray *fieldItemsFieldEqualsNULL = [WalletFieldItem MR_findAllWithPredicate:predicate];
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	NSMutableString *collectedTexts = [NSMutableString new];
	for (WalletFieldItem *fieldItem in fieldItemsFieldEqualsNULL) {
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

@end
