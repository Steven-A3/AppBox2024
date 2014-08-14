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

- (NSDictionary *)favoriteMenuDictionary;
- (NSArray *)favoriteItems;

- (NSUInteger)maximumRecentlyUsedMenus;
- (void)storeMaximumNumberRecentlyUsedMenus:(NSUInteger)maxNumber;
- (void)clearRecentlyUsedMenus;

@end
