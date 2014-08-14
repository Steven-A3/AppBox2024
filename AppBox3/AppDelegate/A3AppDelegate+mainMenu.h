//
//  A3AppDelegate+mainMenu.h
//  AppBox3
//
//  Created by A3 on 1/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate.h"
#import "A3UserDefaults.h"

@interface A3AppDelegate (mainMenu)

- (NSArray *)allMenu;
- (NSArray *)allMenuItems;
- (NSArray *)allMenuArrayFromStoredDataFile;

- (void)storeAllMenu:(NSArray *)menuArray withDate:(NSDate *)date state:(A3DataObjectStateValue)state;
- (NSDictionary *)favoriteMenuDictionary;
- (NSArray *)favoriteItems;
- (void)storeFavorites:(NSArray *)newFavorites;

- (void)saveToFileFavoriteMenuDictionary:(NSMutableDictionary *)dictionary withDate:(NSDate *)updateDate state:(A3DataObjectStateValue)state;
- (void)saveToFileRecentlyUsedMenuDictionary:(NSMutableDictionary *)mutableDictionary withDate:(NSDate *)updateDate;
- (NSUInteger)maximumRecentlyUsedMenus;
- (void)storeMaximumNumberRecentlyUsedMenus:(NSUInteger)maxNumber;
- (void)clearRecentlyUsedMenus;

@end
