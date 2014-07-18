//
//  WalletItem+Favorite.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletItem+Favorite.h"
#import "WalletFavorite.h"
#import "NSMutableArray+A3Sort.h"
#import "WalletFavorite+initialize.h"


@implementation WalletItem (Favorite)

- (void)changeFavorite:(BOOL)isAdd
{
    if (isAdd) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID == %@", self.uniqueID];
        if ([WalletFavorite MR_countOfEntitiesWithPredicate:predicate] == 0) {
            WalletFavorite *favorite = [WalletFavorite MR_createEntity];
			favorite.uniqueID = self.uniqueID;
			favorite.updateDate = [NSDate date];
			favorite.itemID = self.uniqueID;
			[favorite assignOrder];

            // order set
            NSArray *favors = [WalletFavorite MR_findAllSortedBy:@"order" ascending:YES];
            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:favors];
            [tmp addObjectToSortedArray:favorite];

			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
    }
    else {
		NSArray *favors = [WalletFavorite MR_findByAttribute:@"itemID" withValue:self.uniqueID];
		for (WalletFavorite *favor in favors) {
			[favor MR_deleteEntity];
		}

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    }
}

@end
