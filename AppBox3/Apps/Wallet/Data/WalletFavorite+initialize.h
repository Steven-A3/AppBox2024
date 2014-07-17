//
//  WalletFavorite+initialize.h
//  AppBox3
//
//  Created by A3 on 4/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "WalletFavorite.h"

@interface WalletFavorite (initialize)

+ (BOOL)isFavoriteForItemID:(NSString *)itemID;

- (void)assignOrder;
@end
