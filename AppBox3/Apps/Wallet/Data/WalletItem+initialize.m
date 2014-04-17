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

@end
