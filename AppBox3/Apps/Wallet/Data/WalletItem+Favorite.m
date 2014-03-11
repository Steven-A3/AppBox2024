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


@implementation WalletItem (Favorite)

- (BOOL)isFavored
{
    NSArray *favors = [WalletFavorite MR_findByAttribute:@"item" withValue:self];
    
    if (favors.count > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)setFavor:(BOOL)onoff
{
    if (onoff) {
        if (![self isFavored]) {
            WalletFavorite *favorite = [WalletFavorite MR_createEntity];
            favorite.item = self;
            
            // order set
            NSArray *favors = [WalletFavorite MR_findAllSortedBy:@"order" ascending:YES];
            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:favors];
            [tmp addObjectToSortedArray:favorite];

			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
    }
    else {
        if ([self isFavored]) {
            NSArray *favors = [WalletFavorite MR_findByAttribute:@"item" withValue:self];
            for (WalletFavorite *favor in favors) {
                [favor MR_deleteEntity];
            }

			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
    }
}

@end
