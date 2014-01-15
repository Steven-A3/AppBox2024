//
//  A3AppDelegate+mainMenu.h
//  AppBox3
//
//  Created by A3 on 1/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate.h"

@interface A3AppDelegate (mainMenu)

- (NSArray *)allMenu;

- (NSArray *)allMenuItems;

- (NSArray *)allMenuArrayFromUserDefaults;

- (void)storeAllMenu:(NSArray *)menuArray withDate:(NSDate *)date;

- (NSDictionary *)favoriteMenuDictionary;

- (NSArray *)favoriteItems;

- (void)storeFavorites:(NSArray *)newFavorites;

- (void)storeFavoriteMenuDictionary:(NSMutableDictionary *)dictionary withDate:(NSDate *)updateDate;

- (void)storeRecentlyUsedMenuDictionary:(NSMutableDictionary *)mutableDictionary withDate:(NSDate *)updateDate;

- (NSUInteger)maximumRecentlyUsedMenus;

- (void)storeMaximumNumberRecentlyUsedMenus:(NSUInteger)maxNumber;

- (void)clearRecentlyUsedMenus;
@end
