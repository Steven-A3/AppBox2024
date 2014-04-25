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

@implementation WalletItem (initialize)

- (NSArray *)fieldItemsArray
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"field.order" ascending:YES];
    return [self.fieldItems sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (void)assignOrder {
	WalletItem *item = [WalletItem MR_findFirstOrderedByAttribute:@"order" ascending:NO];
	if (item) {
		NSInteger latestOrder = [item.order integerValue];
		self.order = [NSString orderStringWithOrder:latestOrder + 1000000];
	} else {
		self.order = [NSString orderStringWithOrder:1000000];
	}
}

@end
