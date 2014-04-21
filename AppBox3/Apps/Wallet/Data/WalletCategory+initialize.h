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

@interface WalletCategory (initialize)

+ (void)resetWalletCategory;
+ (NSArray *)iconList;
- (NSArray *)fieldsArray;

+ (WalletCategory *)allCategory;
+ (WalletCategory *)favoriteCategory;

@end
