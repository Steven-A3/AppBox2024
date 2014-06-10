//
//  A3AppDelegate+mainMenu.m
//  AppBox3
//
//  Created by A3 on 1/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate+mainMenu.h"

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

NSString *const kA3ThemeColorIndex = @"kA3ThemeColorIndex";

NSString *const kA3AppsMenuArray = @"kA3AppsMenuArray";
NSString *const kA3AppsDataUpdateDate = @"kA3AppsDataUpdateDate";


- (NSArray *)allMenu {
	return @[
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @YES,
				 kA3AppsMenuName : NSLocalizedString(@"Calculator", @"Main menu group name"),
				 kA3AppsExpandableChildren :	@[
						 @{kA3AppsMenuName : NSLocalizedString(@"Date Calculator", @"Main menu group name"), kA3AppsClassName_iPhone : @"A3DateMainTableViewController", kA3AppsMenuImageName : @"DateCalculator"},
						 @{kA3AppsMenuName : NSLocalizedString(@"Loan Calculator", @"Loan Calculator"), kA3AppsStoryboard_iPhone:@"LoanCalculatorPhoneStoryBoard", kA3AppsStoryboard_iPad:@"LoanCalculatorPadStoryBoard",kA3AppsMenuImageName : @"LoanCalculator"},
						 @{kA3AppsMenuName : NSLocalizedString(@"Sales Calculator", @"Sales Calculator"), kA3AppsClassName_iPhone : @"A3SalesCalcMainViewController", kA3AppsMenuImageName : @"SalesCalculator"},
						 @{kA3AppsMenuName : NSLocalizedString(@"Tip Calculator", @"Tip Calculator"), kA3AppsClassName_iPhone : @"A3TipCalcMainTableViewController", kA3AppsMenuImageName : @"TipCalculator"},
						 @{kA3AppsMenuName : NSLocalizedString(@"Unit Price", @"Unit Price"), kA3AppsStoryboard_iPhone:@"UnitPriceStoryboard", kA3AppsStoryboard_iPad:@"UnitPriceStoryboard_iPad", kA3AppsMenuImageName : @"UnitPrice"},
						 @{kA3AppsMenuName : NSLocalizedString(@"Calculator", @"Calculator"), kA3AppsClassName_iPhone : @"A3CalculatorViewController_iPhone", kA3AppsClassName_iPad:@"A3CalculatorViewController_iPad",  kA3AppsMenuImageName : @"Calculator"},
						 @{kA3AppsMenuName : NSLocalizedString(@"Percent Calculator", @"Percent Calculator"), kA3AppsClassName_iPhone : @"A3PercentCalcMainViewController", kA3AppsMenuImageName : @"PercentCalculator"}
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @YES,
				 kA3AppsMenuName : @"Converter",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : NSLocalizedString(@"Currency Converter", @"Currency Converter"), kA3AppsClassName_iPhone : @"A3CurrencyViewController", kA3AppsMenuImageName : @"Currency"},
						 @{kA3AppsMenuName : NSLocalizedString(@"Lunar Converter", @"Lunar Converter"), kA3AppsClassName_iPhone : @"A3LunarConverterViewController", kA3AppsNibName_iPhone : @"A3LunarConverterViewController", kA3AppsMenuImageName : @"LunarConverter"},
						 @{kA3AppsMenuName : NSLocalizedString(@"Translator", @"Translator"), kA3AppsClassName_iPhone : @"A3TranslatorViewController", kA3AppsMenuImageName : @"Translator"},
						 @{kA3AppsMenuName : NSLocalizedString(@"Unit Converter", @"Unit Converter"), kA3AppsStoryboard_iPhone:@"UnitConverterPhoneStoryboard", kA3AppsStoryboard_iPad:@"UnitConverterPhoneStoryboard", kA3AppsMenuImageName : @"UnitConverter"},
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @YES,
				 kA3AppsMenuName : @"Productivity",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : NSLocalizedString(@"Days Counter", @"Days Counter"), kA3AppsClassName_iPhone : @"", kA3AppsMenuImageName : @"DaysCounter", kA3AppsMenuNeedSecurityCheck : @YES},
						 @{kA3AppsMenuName : NSLocalizedString(@"Lady Calendar", @"Lady Calendar"), kA3AppsClassName_iPhone : @"A3LadyCalendarViewController", kA3AppsNibName_iPhone:@"A3LadyCalendarViewController", kA3AppsMenuImageName : @"LadyCalendar", kA3AppsMenuNeedSecurityCheck : @YES},
						 @{kA3AppsMenuName : NSLocalizedString(@"Wallet", @"Wallet"), kA3AppsClassName_iPhone : @"A3WalletMainTabBarController", kA3AppsMenuImageName : @"Wallet", kA3AppsMenuNeedSecurityCheck : @YES},
						 @{kA3AppsMenuName : NSLocalizedString(@"Expense List", @"Expense List"), kA3AppsClassName_iPhone : @"A3ExpenseListMainViewController", kA3AppsMenuImageName : @"ExpenseList"},
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @YES,
				 kA3AppsMenuName : @"Reference",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : NSLocalizedString(@"Holidays", @"Holidays"), kA3AppsClassName_iPhone : @"A3HolidaysPageViewController", kA3AppsMenuImageName : @"Holidays"},
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @YES,
				 kA3AppsMenuName : @"Utility",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : NSLocalizedString(@"Clock", @"Clock"), kA3AppsClassName_iPhone : @"A3ClockMainViewController", kA3AppsMenuImageName : @"Clock"},
						 @{kA3AppsMenuName : NSLocalizedString(@"Battery Status", @"Battery Status"), kA3AppsClassName_iPhone : @"A3BatteryStatusMainViewController", kA3AppsMenuImageName : @"BatteryStatus"},
						 @{kA3AppsMenuName : NSLocalizedString(@"Mirror", @"Mirror"), kA3AppsClassName_iPhone : @"A3MirrorViewController", kA3AppsNibName_iPhone :@"A3MirrorViewController", kA3AppsMenuImageName : @"Mirror"},
						 @{kA3AppsMenuName : NSLocalizedString(@"Magnifier", @"Magnifier"), kA3AppsClassName_iPhone : @"A3MagnifierViewController", kA3AppsNibName_iPhone:@"A3MagnifierViewController", kA3AppsMenuImageName : @"Magnifier"},
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
	NSMutableArray *sortedMenuArray = [NSMutableArray new];
	for (NSDictionary *section in allMenuArray) {
		@autoreleasepool {
			NSMutableDictionary *modifiedSection = 	[section mutableCopy];
			NSMutableArray *originalMenus = [modifiedSection[kA3AppsExpandableChildren] mutableCopy];
			NSMutableArray *localizedMenus = [NSMutableArray new];
			for (NSDictionary *menuItem in originalMenus) {
				NSMutableDictionary *localizedItem = [menuItem mutableCopy];
				localizedItem[kA3AppsMenuName] = NSLocalizedString(menuItem[kA3AppsMenuName], nil);
				[localizedMenus addObject:localizedItem];
			}
			[localizedMenus sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				return [obj1[kA3AppsMenuName] compare:obj2[kA3AppsMenuName]];
			}];
			modifiedSection[kA3AppsExpandableChildren] = localizedMenus;
			[sortedMenuArray addObject:modifiedSection];
		}
	}
	return sortedMenuArray;
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
				kA3AppsMenuName : NSLocalizedString(@"Favorites", @"Favorites"),
				kA3AppsMenuCollapsed : @YES,
				kA3AppsMenuExpandable : @YES,
				kA3AppsExpandableChildren :
				@[
						@{kA3AppsMenuName : NSLocalizedString(@"Currency Converter", @"Currency Converter"), kA3AppsClassName_iPhone : @"A3CurrencyViewController", kA3AppsMenuImageName : @"Currency"},
						@{kA3AppsMenuName : NSLocalizedString(@"Date Calculator", @"Date Calculator"), kA3AppsClassName_iPhone : @"A3DateMainTableViewController", kA3AppsMenuImageName : @"DateCalculator"},
						@{kA3AppsMenuName : NSLocalizedString(@"Sales Calculator", @"Sales Calculator"), kA3AppsClassName_iPhone : @"A3SalesCalcMainViewController", kA3AppsMenuImageName : @"SalesCalculator"},
						@{kA3AppsMenuName : NSLocalizedString(@"Tip Calculator", @"Tip Calculator"), kA3AppsClassName_iPhone : @"A3TipCalcMainTableViewController", kA3AppsMenuImageName : @"TipCalculator"},
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

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationAppsMainMenuContentsChanged object:nil];
}

- (void)storeMenuDictionary:(NSMutableDictionary *)mutableDictionary forKey:(NSString *)key {
	FNLOG(@"%@, %@", key, mutableDictionary);

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
	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationAppsMainMenuContentsChanged object:nil];
}

@end
