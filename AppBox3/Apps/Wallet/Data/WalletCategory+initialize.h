//
//  WalletCategory+initialize.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletCategory.h"

#define kWalletAllCateKey @"kWallet_AllCateKey"
#define kWalletFavCateKey @"kWallet_FavCateKey"

@interface WalletCategory (initialize)

+ (void)resetWalletCategory;
+ (NSArray *)iconList;
- (NSArray *)fieldsArray;

+ (WalletCategory *)allCategory;
+ (WalletCategory *)favCategory;

- (void)deleteAndClearRelated;

@end
