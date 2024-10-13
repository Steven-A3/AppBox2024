//
//  WalletItem+initialize.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 30..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

@interface WalletItem_ (initialize)

- (NSArray *)fieldItems;
- (NSArray *)fieldItemsArraySortedByFieldOrder;
- (void)assignOrder;
- (void)verifyNULLField;
- (void)deleteWalletItem;

@end
