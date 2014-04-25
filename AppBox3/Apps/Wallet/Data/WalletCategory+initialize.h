//
//  WalletCategory+initialize.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletCategory.h"

extern NSString *const A3WalletUUIDAllCategory;
extern NSString *const A3WalletUUIDFavoriteCategory;
extern NSString *const A3WalletUUIDPhotoCategory;
extern NSString *const A3WalletUUIDVideoCategory;
extern NSString *const A3WalletUUIDMemoCategory;

@interface WalletCategory (initialize)

- (void)initValues;

+ (void)resetWalletCategory;
+ (NSArray *)iconList;
- (NSArray *)fieldsArray;

- (void)assignOrder;

+ (WalletCategory *)allCategory;
+ (WalletCategory *)favoriteCategory;

@end
