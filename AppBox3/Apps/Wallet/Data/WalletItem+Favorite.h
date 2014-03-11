//
//  WalletItem+Favorite.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletItem.h"

@interface WalletItem (Favorite)

- (BOOL)isFavored;
- (void)setFavor:(BOOL)onoff;

@end
