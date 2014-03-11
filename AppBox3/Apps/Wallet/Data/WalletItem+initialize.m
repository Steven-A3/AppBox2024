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

@implementation WalletItem (initialize)

- (NSArray *)fieldItemsArray
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"field.order" ascending:YES];
    return [self.fieldItems sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (void)deleteAndClearRelated
{
    NSArray *fieldItems = [self fieldItemsArray];
    for (int i=0; i<fieldItems.count; i++) {
        WalletFieldItem *fieldItem = fieldItems[i];
        [fieldItem deleteAndClearRelated];
    }
    
    if ([self isFavored]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item==%@", self];
        NSArray *favors = [WalletFavorite MR_findAllWithPredicate:predicate];
        
        for (WalletFavorite *favor in favors) {
            [favor MR_deleteEntity];
        }
    }
    
    [self MR_deleteEntity];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

@end
