//
//  WalletItem+initialize.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 30..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletItem.h"

@class WalletField;
@class WalletFieldItem;

@interface WalletItem (initialize)

- (NSArray *)fieldItemsArray;

- (void)assignOrder;

- (void)verifyNULLField;

- (WalletField *)fieldForFieldItem:(WalletFieldItem *)fieldItem;

- (void)deleteWalletItem;
@end
