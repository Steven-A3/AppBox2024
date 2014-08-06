//
//  A3AppDelegate+mainMenu.m
//  AppBox3
//
//  Created by A3 on 1/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate+mainMenu.h"
#import "A3UserDefaults.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

@implementation A3AppDelegate (mainMenu)

NSString *const kA3ApplicationLastRunVersion = @"kLastRunVersion";
NSString *const kA3AppsMenuName = @"kA3AppsMenuName";
NSString *const kA3AppsMenuCollapsed = @"kA3AppsMenuCollapsed";
NSString *const kA3AppsMenuImageName = @"kA3AppsMenuImageName";
NSString *const kA3AppsExpandableChildren = @"kA3AppsExpandableChildren";
NSString *const kA3AppsClassName_iPhone = @"kA3AppsClassName_iPhone";
NSString *const kA3AppsClassName_iPad = @"kA3AppsClassName_iPad";
NSString *const kA3AppsNibName_iPhone = @"kA3AppsNibName_iPhone";
NSString *const kA3AppsNibName_iPad = @"kA3AppsNibName_iPad";
NSString *const kA3AppsStoryboard_iPhone = @"kA3AppsStoryboard_iPhone";
NSString *const kA3AppsStoryboard_iPad = @"kA3AppsStoryboard_iPad";
NSString *const kA3AppsMenuExpandable = @"kA3AppsMenuExpandable";
NSString *const kA3AppsMenuNeedSecurityCheck = @"kA3AppsMenuNeedSecurityCheck";

NSString *const kA3AppsMenuArray = @"kA3AppsMenuArray";
NSString *const kA3AppsDataUpdateDate = @"kA3AppsDataUpdateDate";

- (NSArray *)allMenu {
	return @[
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"CalculatorGroup",
				 kA3AppsExpandableChildren :	@[
						 @{kA3AppsMenuName : @"Date Calculator", kA3AppsClassName_iPhone : @"A3DateMainTableViewController", kA3AppsMenuImageName : @"DateCalculator"},
						 @{kA3AppsMenuName : @"Loan Calculator", kA3AppsStoryboard_iPhone:@"LoanCalculatorPhoneStoryBoard", kA3AppsStoryboard_iPad:@"LoanCalculatorPadStoryBoard",kA3AppsMenuImageName : @"LoanCalculator"},
						 @{kA3AppsMenuName : @"Sales Calculator", kA3AppsClassName_iPhone : @"A3SalesCalcMainViewController", kA3AppsMenuImageName : @"SalesCalculator"},
						 @{kA3AppsMenuName : @"Tip Calculator", kA3AppsClassName_iPhone : @"A3TipCalcMainTableViewController", kA3AppsMenuImageName : @"TipCalculator"},
						 @{kA3AppsMenuName : @"Unit Price", kA3AppsStoryboard_iPhone:@"UnitPriceStoryboard", kA3AppsStoryboard_iPad:@"UnitPriceStoryboard_iPad", kA3AppsMenuImageName : @"UnitPrice"},
						 @{kA3AppsMenuName : @"Calculator", kA3AppsClassName_iPhone : @"A3CalculatorViewController_iPhone", kA3AppsClassName_iPad:@"A3CalculatorViewController_iPad",  kA3AppsMenuImageName : @"Calculator"},
						 @{kA3AppsMenuName : @"Percent Calculator", kA3AppsClassName_iPhone : @"A3PercentCalcMainViewController", kA3AppsMenuImageName : @"PercentCalculator"}
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"Converter",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : @"Currency Converter", kA3AppsClassName_iPhone : @"A3CurrencyViewController", kA3AppsMenuImageName : @"Currency"},
						 @{kA3AppsMenuName : @"Lunar Converter", kA3AppsClassName_iPhone : @"A3LunarConverterViewController", kA3AppsNibName_iPhone : @"A3LunarConverterViewController", kA3AppsMenuImageName : @"LunarConverter"},
						 @{kA3AppsMenuName : @"Translator", kA3AppsClassName_iPhone : @"A3TranslatorViewController", kA3AppsMenuImageName : @"Translator"},
						 @{kA3AppsMenuName : @"Unit Converter", kA3AppsStoryboard_iPhone:@"UnitConverterPhoneStoryboard", kA3AppsStoryboard_iPad:@"UnitConverterPhoneStoryboard", kA3AppsMenuImageName : @"UnitConverter"},
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"Productivity",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : @"Days Counter", kA3AppsClassName_iPhone : @"", kA3AppsMenuImageName : @"DaysCounter", kA3AppsMenuNeedSecurityCheck : @YES},
						 @{kA3AppsMenuName : @"Ladies Calendar", kA3AppsClassName_iPhone : @"A3LadyCalendarViewController", kA3AppsNibName_iPhone:@"A3LadyCalendarViewController", kA3AppsMenuImageName : @"LadyCalendar", kA3AppsMenuNeedSecurityCheck : @YES},
						 @{kA3AppsMenuName : @"Wallet", kA3AppsClassName_iPhone : @"A3WalletMainTabBarController", kA3AppsMenuImageName : @"Wallet", kA3AppsMenuNeedSecurityCheck : @YES},
						 @{kA3AppsMenuName : @"Expense List", kA3AppsClassName_iPhone : @"A3ExpenseListMainViewController", kA3AppsMenuImageName : @"ExpenseList"},
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"Reference",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : @"Holidays", kA3AppsClassName_iPhone : @"A3HolidaysPageViewController", kA3AppsMenuImageName : @"Holidays"},
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"Utility",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : @"Clock", kA3AppsClassName_iPhone : @"A3ClockMainViewController", kA3AppsMenuImageName : @"Clock"},
						 @{kA3AppsMenuName : @"Battery Status", kA3AppsClassName_iPhone : @"A3BatteryStatusMainViewController", kA3AppsMenuImageName : @"BatteryStatus"},
						 @{kA3AppsMenuName : @"Mirror", kA3AppsClassName_iPhone : @"A3MirrorViewController", kA3AppsNibName_iPhone :@"A3MirrorViewController", kA3AppsMenuImageName : @"Mirror"},
						 @{kA3AppsMenuName : @"Magnifier", kA3AppsClassName_iPhone : @"A3MagnifierViewController", kA3AppsNibName_iPhone:@"A3MagnifierViewController", kA3AppsMenuImageName : @"Magnifier"},
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
	NSMutableDictionary *allMenusDictionary = [[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuUserDefaultsAllMenu];
	
	NSArray *allMenuArray;
	if (allMenusDictionary) {
		allMenuArray = allMenusDictionary[kA3AppsMenuArray];
	} else {
		allMenuArray = [self allMenu];
	}
	NSMutableArray *sortedMenuArray = [NSMutableArray new];
	for (NSDictionary *section in allMenuArray) {
		@autoreleasepool {
			NSMutableDictionary *modifiedSection = 	[section mutableCopy];
			NSMutableArray *originalMenus = [modifiedSection[kA3AppsExpandableChildren] mutableCopy];
			[originalMenus sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				return [NSLocalizedString(obj1[kA3AppsMenuName], nil) compare:NSLocalizedString(obj2[kA3AppsMenuName], nil)];
			}];
			if (![A3UIDevice shouldSupportLunarCalendar]) {
				NSUInteger indexOfLunarConverter = [originalMenus indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
					return [obj[kA3AppsMenuName] isEqualToString:@"Lunar Converter"];
				}];
				if (indexOfLunarConverter != NSNotFound) {
					[originalMenus removeObjectAtIndex:indexOfLunarConverter];
				}
			}
			modifiedSection[kA3AppsExpandableChildren] = originalMenus;
			[sortedMenuArray addObject:modifiedSection];
		}
	}
	return sortedMenuArray;
}

- (void)storeAllMenu:(NSArray *)menuArray withDate:(NSDate *)date state:(A3KeyValueDBStateValue)state {
	NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
	mutableDictionary[kA3AppsMenuArray] = menuArray;
	mutableDictionary[kA3AppsDataUpdateDate] = date;
	[self storeMenuDictionary:mutableDictionary forKey:A3MainMenuUserDefaultsAllMenu state:state];
}

- (NSDictionary *)favoriteMenuDictionary {
	NSDictionary *dictionary = [[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuUserDefaultsFavorites];
	if (!dictionary) {
		dictionary = @{
				kA3AppsMenuName : @"Favorites",
				kA3AppsMenuCollapsed : @NO,
				kA3AppsMenuExpandable : @YES,
				kA3AppsExpandableChildren :
				@[
						@{kA3AppsMenuName : @"Calculator", kA3AppsClassName_iPhone : @"A3CalculatorViewController_iPhone", kA3AppsClassName_iPad:@"A3CalculatorViewController_iPad",  kA3AppsMenuImageName : @"Calculator"},
						@{kA3AppsMenuName : @"Clock", kA3AppsClassName_iPhone : @"A3ClockMainViewController", kA3AppsMenuImageName : @"Clock"},
						@{kA3AppsMenuName : @"Currency Converter", kA3AppsClassName_iPhone : @"A3CurrencyViewController", kA3AppsMenuImageName : @"Currency"},
						@{kA3AppsMenuName : @"Days Counter", kA3AppsClassName_iPhone : @"", kA3AppsMenuImageName : @"DaysCounter", kA3AppsMenuNeedSecurityCheck : @YES},
						@{kA3AppsMenuName : @"Holidays", kA3AppsClassName_iPhone : @"A3HolidaysPageViewController", kA3AppsMenuImageName : @"Holidays"},
						@{kA3AppsMenuName : @"Wallet", kA3AppsClassName_iPhone : @"A3WalletMainTabBarController", kA3AppsMenuImageName : @"Wallet", kA3AppsMenuNeedSecurityCheck : @YES},
				]
		};
		[self storeFavoriteMenuDictionary:[dictionary mutableCopy] withDate:[NSDate distantPast] state:A3KeyValueDBStateInitialized];
	}
	return dictionary;
}

- (NSArray *)favoriteItems {
	NSDictionary *favoriteObject = [[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuUserDefaultsFavorites];
	return favoriteObject[kA3AppsExpandableChildren];
}

- (void)storeFavorites:(NSArray *)newFavorites {
	NSMutableDictionary *favoriteObject = [[[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuUserDefaultsFavorites] mutableCopy];

	favoriteObject[kA3AppsExpandableChildren] = newFavorites;

	[self storeFavoriteMenuDictionary:favoriteObject withDate:[NSDate date] state:A3KeyValueDBStateModified];
}

- (void)storeFavoriteMenuDictionary:(NSMutableDictionary *)mutableDictionary withDate:(NSDate *)updateDate state:(A3KeyValueDBStateValue)state {
	mutableDictionary[kA3AppsDataUpdateDate] = updateDate;
	[self storeMenuDictionary:mutableDictionary forKey:A3MainMenuUserDefaultsFavorites state:state];
}

- (void)storeRecentlyUsedMenuDictionary:(NSMutableDictionary *)mutableDictionary withDate:(NSDate *)updateDate {
	mutableDictionary[kA3AppsDataUpdateDate] = updateDate;
	[self storeMenuDictionary:mutableDictionary forKey:A3MainMenuUserDefaultsRecentlyUsed state:A3KeyValueDBStateModified];

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationAppsMainMenuContentsChanged object:nil];
}

- (void)storeMenuDictionary:(NSMutableDictionary *)mutableDictionary forKey:(NSString *)key state:(A3KeyValueDBStateValue)state {
	[[A3SyncManager sharedSyncManager] setObject:mutableDictionary forKey:key state:state];
}

- (NSUInteger)maximumRecentlyUsedMenus {
	NSUInteger maximum = (NSUInteger) [[A3SyncManager sharedSyncManager] integerForKey:A3MainMenuUserDefaultsMaxRecentlyUsed];
	maximum = !maximum ? 3 : maximum;
	return maximum;
}

- (void)storeMaximumNumberRecentlyUsedMenus:(NSUInteger)maxNumber {
	[[A3SyncManager sharedSyncManager] setInteger:maxNumber forKey:A3MainMenuUserDefaultsMaxRecentlyUsed state:A3KeyValueDBStateModified];
}

- (void)clearRecentlyUsedMenus {
	[[A3SyncManager sharedSyncManager] setObject:A3SyncManagerEmptyObject forKey:A3MainMenuUserDefaultsRecentlyUsed state:A3KeyValueDBStateModified];

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationAppsMainMenuContentsChanged object:nil];
}

@end
