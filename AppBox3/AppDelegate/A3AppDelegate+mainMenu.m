//
//  A3AppDelegate+mainMenu.m
//  AppBox3
//
//  Created by A3 on 1/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3MainMenuTableViewController.h"
#import "A3SettingsFavoritesViewController.h"
#import "A3AppDelegate+mainMenu.h"

@implementation A3AppDelegate (mainMenu)

NSString *const kA3AppsMenuName = @"kA3AppsMenuName";
NSString *const kA3AppsMenuCollapsed = @"kA3AppsMenuCollapsed";
NSString *const kA3AppsMenuImageName = @"kA3AppsMenuImageName";
NSString *const kA3AppsExpandableChildren = @"kA3AppsExpandableChildren";
NSString *const kA3AppsClassName = @"kA3AppsClassName";
NSString *const kA3AppsNibName = @"kA3AppsNibName";
NSString *const kA3AppsStoryboardName = @"kA3AppsStoryboardName";
NSString *const kA3AppsMenuExpandable = @"kA3AppsMenuExpandable";
NSString *const kA3AppsMenuNeedSecurityCheck = @"kA3AppsMenuNeedSecurityCheck";

NSString *const kA3ThemeColorIndex = @"kA3ThemeColorIndex";

NSString *const kA3AppsMenuArray = @"kA3AppsMenuArray";
NSString *const kA3AppsDataUpdateDate = @"kA3AppsDataUpdateDate";


- (NSArray *)allMenu {
	return @[
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @YES,
				 kA3AppsMenuName : @"Calculator",
				 kA3AppsExpandableChildren :	@[
						 @{kA3AppsMenuName : @"Date Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"DateCalculator"},
						 @{kA3AppsMenuName : @"Loan Calculator", kA3AppsClassName : @"A3LoanCalc2ViewController", kA3AppsMenuImageName : @"LoanCalculator"},
						 @{kA3AppsMenuName : @"Sales Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"SalesCalculator"},
						 @{kA3AppsMenuName : @"Tip Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"TipCalculator"},
						 @{kA3AppsMenuName : @"Unit Price", kA3AppsClassName : @"", kA3AppsMenuImageName : @"UnitPrice"},
						 @{kA3AppsMenuName : @"Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Calculator"},
						 @{kA3AppsMenuName : @"Percent Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"PercentCalculator"}
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @YES,
				 kA3AppsMenuName : @"Converter",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : @"Currency", kA3AppsClassName : @"A3CurrencyViewController", kA3AppsMenuImageName : @"Currency"},
						 @{kA3AppsMenuName : @"Lunar Converter", kA3AppsClassName : @"", kA3AppsMenuImageName : @"LunarConverter"},
						 @{kA3AppsMenuName : @"Translator", kA3AppsClassName : @"A3TranslatorViewController", kA3AppsMenuImageName : @"Translator"},
						 @{kA3AppsMenuName : @"Unit Converter", kA3AppsClassName : @"", kA3AppsMenuImageName : @"UnitConverter"},
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @YES,
				 kA3AppsMenuName : @"Productivity",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : @"Days Counter", kA3AppsClassName : @"", kA3AppsMenuImageName : @"DaysCounter", kA3AppsMenuNeedSecurityCheck : @YES},
						 @{kA3AppsMenuName : @"Lady Calendar", kA3AppsClassName : @"", kA3AppsMenuImageName : @"LadyCalendar", kA3AppsMenuNeedSecurityCheck : @YES},
						 @{kA3AppsMenuName : @"Wallet", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Wallet", kA3AppsMenuNeedSecurityCheck : @YES},
						 @{kA3AppsMenuName : @"Expense List", kA3AppsClassName : @"", kA3AppsMenuImageName : @"ExpenseList"},
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @YES,
				 kA3AppsMenuName : @"Reference",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : @"Holidays", kA3AppsClassName : @"A3HolidaysPageViewController", kA3AppsMenuImageName : @"Holidays"},
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @YES,
				 kA3AppsMenuName : @"Utility",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : @"Clock", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Clock"},
						 @{kA3AppsMenuName : @"Battery Status", kA3AppsClassName : @"", kA3AppsMenuImageName : @"BatteryStatus"},
						 @{kA3AppsMenuName : @"Mirror", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Mirror"},
						 @{kA3AppsMenuName : @"Magnifier", kA3AppsClassName : @"", kA3AppsMenuImageName : @"Magnifier"},
						 ]
				 },
			 ];
}

- (NSArray *)allMenuItems {
	NSMutableArray *tempArray = [NSMutableArray new];
	NSArray *groups = [self allMenu];
	for (NSDictionary *group in groups) {
		[tempArray addObjectsFromArray:group[kA3AppsExpandableChildren]];
	}
	return tempArray;
}

- (NSArray *)allMenuArrayFromUserDefaults {
	NSMutableDictionary *allMenusDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kA3MainMenuAllMenu];

	NSArray *allMenuArray;
	if (allMenusDictionary) {
		allMenuArray = allMenusDictionary[kA3AppsMenuArray];
	} else {
		allMenuArray = [self allMenu];
	}
	return allMenuArray;
}

- (void)storeAllMenu:(NSArray *)menuArray withDate:(NSDate *)date {
	NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
	mutableDictionary[kA3AppsMenuArray] = menuArray;
	mutableDictionary[kA3AppsDataUpdateDate] = date;
	[self storeMenuDictionary:mutableDictionary forKey:kA3MainMenuAllMenu];
}

- (NSDictionary *)favoriteMenuDictionary {
	NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kA3MainMenuFavorites];
	if (!dictionary) {
		dictionary = @{
				kA3AppsMenuName : @"Favorites",
				kA3AppsMenuCollapsed : @YES,
				kA3AppsMenuExpandable : @YES,
				kA3AppsExpandableChildren :
				@[
						@{kA3AppsMenuName : @"Currency", kA3AppsClassName : @"A3CurrencyViewController", kA3AppsMenuImageName : @"Currency"},
						@{kA3AppsMenuName : @"Date Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"DateCalculator"},
						@{kA3AppsMenuName : @"Sales Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"SalesCalculator"},
						@{kA3AppsMenuName : @"Tip Calculator", kA3AppsClassName : @"", kA3AppsMenuImageName : @"TipCalculator"},
				]
		};
		[self storeFavoriteMenuDictionary:[dictionary mutableCopy] withDate:[NSDate distantPast]];
	}
	return dictionary;
}

- (NSArray *)favoriteItems {
	NSDictionary *favoriteObject = [[NSUserDefaults standardUserDefaults] objectForKey:kA3MainMenuFavorites];
	return favoriteObject[kA3AppsExpandableChildren];
}

- (void)storeFavorites:(NSArray *)newFavorites {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *favoriteObject = [[userDefaults objectForKey:kA3MainMenuFavorites] mutableCopy];

	favoriteObject[kA3AppsExpandableChildren] = newFavorites;

	[self storeFavoriteMenuDictionary:favoriteObject withDate:[NSDate date]];
}

- (void)storeFavoriteMenuDictionary:(NSMutableDictionary *)mutableDictionary withDate:(NSDate *)updateDate {
	mutableDictionary[kA3AppsDataUpdateDate] = updateDate;
	[self storeMenuDictionary:mutableDictionary forKey:kA3MainMenuFavorites];
}

- (void)storeRecentlyUsedMenuDictionary:(NSMutableDictionary *)mutableDictionary withDate:(NSDate *)updateDate {
	mutableDictionary[kA3AppsDataUpdateDate] = updateDate;
	[self storeMenuDictionary:mutableDictionary forKey:kA3MainMenuRecentlyUsed];

	[[NSNotificationCenter defaultCenter] postNotificationName:kA3AppsMainMenuContentsChangedNotification object:nil];
}

- (void)storeMenuDictionary:(NSMutableDictionary *)mutableDictionary forKey:(NSString *)key {
	[[NSUserDefaults standardUserDefaults] setObject:mutableDictionary forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([self.ubiquityStoreManager cloudEnabled]) {
		[[NSUbiquitousKeyValueStore defaultStore] setDictionary:mutableDictionary forKey:key];
	}
}

- (NSUInteger)maximumRecentlyUsedMenus {
	NSUInteger maximum = (NSUInteger) [[NSUserDefaults standardUserDefaults] integerForKey:kA3MainMenuMaxRecentlyUsed];
	maximum = !maximum ? 3 : maximum;
	return maximum;
}

- (void)storeMaximumNumberRecentlyUsedMenus:(NSUInteger)maxNumber {
	[[NSUserDefaults standardUserDefaults] setInteger:maxNumber forKey:kA3MainMenuMaxRecentlyUsed];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if ([self.ubiquityStoreManager cloudEnabled]) {
		[[NSUbiquitousKeyValueStore defaultStore] setObject:@(maxNumber) forKey:kA3MainMenuMaxRecentlyUsed];
	}
}

- (void)clearRecentlyUsedMenus {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kA3MainMenuRecentlyUsed];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([self.ubiquityStoreManager cloudEnabled]) {
		[[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:kA3MainMenuRecentlyUsed];
	}
}

@end
