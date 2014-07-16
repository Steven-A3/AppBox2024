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
        if (self.favorite == nil) {
            WalletFavorite *favorite = [WalletFavorite MR_createEntity];
			favorite.uniqueID = [[NSUUID UUID] UUIDString];
			favorite.updateDate = [NSDate date];
			[favorite assignOrder];
			self.favorite = favorite;
            
            // order set
            NSArray *favors = [WalletFavorite MR_findAllSortedBy:@"order" ascending:YES];
            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:favors];
            [tmp addObjectToSortedArray:favorite];

			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
    }
    else {
        if (self.favorite != nil) {
            NSArray *favors = [WalletFavorite MR_findByAttribute:@"item" withValue:self];
            for (WalletFavorite *favor in favors) {
                [favor MR_deleteEntity];
            }

			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
    }
}

@end
