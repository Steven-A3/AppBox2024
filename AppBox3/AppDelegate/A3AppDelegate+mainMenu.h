//
//  A3AppDelegate+mainMenu.h
//  AppBox3
//
//  Created by A3 on 1/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate.h"
#import "A3UserDefaultsKeys.h"

@interface A3AppDelegate (mainMenu)

- (NSDictionary *)groupColors;
- (NSDictionary *)appInfoDictionary;
- (NSString *)imageNameForApp:(NSString *)appName;
- (NSArray *)allMenu;
- (NSArray *)allMenuItems;
- (NSArray *)allMenuArrayFromStoredDataFile;
- (NSDictionary *)favoriteMenuDictionary;
- (NSArray *)favoriteItems;
- (NSUInteger)maximumRecentlyUsedMenus;
- (void)storeMaximumNumberRecentlyUsedMenus:(NSUInteger)maxNumber;
- (void)clearRecentlyUsedMenus;
- (NSArray *)availableMenuTypes;
- (void)reloadRootViewController;
- (void)setupMainMenuViewController;
- (BOOL)launchAppNamed:(NSString *)appName verifyPasscode:(BOOL)verifyPasscode animated:(BOOL)animated;
- (UIViewController *)getViewControllerForAppNamed:(NSString *)appName;
- (void)startRemoveAds;
- (void)startRestorePurchase;

@end
