//
//  A3AppDelegate+mainMenu.m
//  AppBox3
//
//  Created by A3 on 1/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate+mainMenu.h"
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
NSString *const kA3AppsStartingAppName = @"kA3AppsStartingAppName";

NSString *const A3AppName_DateCalculator = @"Date Calculator";
NSString *const A3AppName_LoanCalculator = @"Loan Calculator";
NSString *const A3AppName_SalesCalculator = @"Sales Calculator";
NSString *const A3AppName_TipCalculator = @"Tip Calculator";
NSString *const A3AppName_UnitPrice = @"Unit Price";
NSString *const A3AppName_Calculator = @"Calculator";
NSString *const A3AppName_PercentCalculator = @"Percent Calculator";
NSString *const A3AppName_CurrencyConverter = @"Currency Converter";
NSString *const A3AppName_LunarConverter = @"Lunar Converter";
NSString *const A3AppName_Translator = @"Translator";
NSString *const A3AppName_UnitConverter = @"Unit Converter";
NSString *const A3AppName_DaysCounter = @"Days Counter";
NSString *const A3AppName_LadiesCalendar = @"Ladies Calendar";
NSString *const A3AppName_Wallet = @"Wallet";
NSString *const A3AppName_ExpenseList = @"Expense List";
NSString *const A3AppName_Holidays = @"Holidays";
NSString *const A3AppName_Clock = @"Clock";
NSString *const A3AppName_BatteryStatus = @"Battery Status";
NSString *const A3AppName_Mirror = @"Mirror";
NSString *const A3AppName_Magnifier = @"Magnifier";
NSString *const A3AppName_Flashlight = @"Flashlight";
NSString *const A3AppName_Random = @"Random";
NSString *const A3AppName_Settings = @"Settings";

- (NSArray *)allMenu {
	return @[
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"CalculatorGroup",
				 kA3AppsExpandableChildren :	@[
						 @{kA3AppsMenuName : A3AppName_DateCalculator, kA3AppsClassName_iPhone : @"A3DateMainTableViewController", kA3AppsMenuImageName : @"DateCalculator"},
						 @{kA3AppsMenuName : A3AppName_LoanCalculator, kA3AppsStoryboard_iPhone:@"LoanCalculatorPhoneStoryBoard", kA3AppsStoryboard_iPad:@"LoanCalculatorPadStoryBoard",kA3AppsMenuImageName : @"LoanCalculator"},
						 @{kA3AppsMenuName : A3AppName_SalesCalculator, kA3AppsClassName_iPhone : @"A3SalesCalcMainViewController", kA3AppsMenuImageName : @"SalesCalculator"},
						 @{kA3AppsMenuName : A3AppName_TipCalculator, kA3AppsClassName_iPhone : @"A3TipCalcMainTableViewController", kA3AppsMenuImageName : @"TipCalculator"},
						 @{kA3AppsMenuName : A3AppName_UnitPrice, kA3AppsStoryboard_iPhone:@"UnitPriceStoryboard", kA3AppsStoryboard_iPad:@"UnitPriceStoryboard_iPad", kA3AppsMenuImageName : @"UnitPrice"},
						 @{kA3AppsMenuName : A3AppName_Calculator, kA3AppsClassName_iPhone : @"A3CalculatorViewController_iPhone", kA3AppsClassName_iPad:@"A3CalculatorViewController_iPad",  kA3AppsMenuImageName : @"Calculator"},
						 @{kA3AppsMenuName : A3AppName_PercentCalculator, kA3AppsClassName_iPhone : @"A3PercentCalcMainViewController", kA3AppsMenuImageName : @"PercentCalculator"}
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"Converter",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : A3AppName_CurrencyConverter, kA3AppsClassName_iPhone : @"A3CurrencyViewController", kA3AppsMenuImageName : @"Currency"},
						 @{kA3AppsMenuName : A3AppName_LunarConverter, kA3AppsClassName_iPhone : @"A3LunarConverterViewController", kA3AppsNibName_iPhone : @"A3LunarConverterViewController", kA3AppsMenuImageName : @"LunarConverter"},
						 @{kA3AppsMenuName : A3AppName_Translator, kA3AppsClassName_iPhone : @"A3TranslatorViewController", kA3AppsMenuImageName : @"Translator"},
						 @{kA3AppsMenuName : A3AppName_UnitConverter, kA3AppsStoryboard_iPhone:@"UnitConverterPhoneStoryboard", kA3AppsStoryboard_iPad:@"UnitConverterPhoneStoryboard", kA3AppsMenuImageName : @"UnitConverter"},
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"Productivity",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : A3AppName_DaysCounter, kA3AppsClassName_iPhone : @"", kA3AppsMenuImageName : @"DaysCounter", kA3AppsMenuNeedSecurityCheck : @YES},
						 @{kA3AppsMenuName : A3AppName_LadiesCalendar, kA3AppsClassName_iPhone : @"A3LadyCalendarViewController", kA3AppsNibName_iPhone:@"A3LadyCalendarViewController", kA3AppsMenuImageName : @"LadyCalendar", kA3AppsMenuNeedSecurityCheck : @YES},
						 @{kA3AppsMenuName : A3AppName_Wallet, kA3AppsClassName_iPhone : @"A3WalletMainTabBarController", kA3AppsMenuImageName : @"Wallet", kA3AppsMenuNeedSecurityCheck : @YES},
						 @{kA3AppsMenuName : A3AppName_ExpenseList, kA3AppsClassName_iPhone : @"A3ExpenseListMainViewController", kA3AppsMenuImageName : @"ExpenseList"},
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"Reference",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : A3AppName_Holidays, kA3AppsClassName_iPhone : @"A3HolidaysPageViewController", kA3AppsMenuImageName : @"Holidays"},
						 ]
				 },
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"Utility",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : A3AppName_Clock, kA3AppsClassName_iPhone : @"A3ClockMainViewController", kA3AppsMenuImageName : @"Clock"},
						 @{kA3AppsMenuName : A3AppName_BatteryStatus, kA3AppsClassName_iPhone : @"A3BatteryStatusMainViewController", kA3AppsMenuImageName : @"BatteryStatus"},
						 @{kA3AppsMenuName : A3AppName_Mirror, kA3AppsClassName_iPhone : @"A3MirrorViewController", kA3AppsNibName_iPhone :@"A3MirrorViewController", kA3AppsMenuImageName : @"Mirror"},
						 @{kA3AppsMenuName : A3AppName_Magnifier, kA3AppsClassName_iPhone : @"A3MagnifierViewController", kA3AppsNibName_iPhone:@"A3MagnifierViewController", kA3AppsMenuImageName : @"Magnifier"},
						 @{kA3AppsMenuName : A3AppName_Flashlight, kA3AppsClassName_iPhone : @"A3FlashViewController", kA3AppsNibName_iPhone:@"A3FlashViewController", kA3AppsMenuImageName : @"Flashlight"},
						 @{kA3AppsMenuName : A3AppName_Random, kA3AppsClassName_iPhone : @"A3RandomViewController", kA3AppsNibName_iPhone:@"A3RandomViewController", kA3AppsMenuImageName : @"Random"},
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

- (NSArray *)allMenuArrayFromStoredDataFile {
	NSArray *allMenuArray = [[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuDataEntityAllMenu];
	if (!allMenuArray) {
		allMenuArray = [self allMenu];
	}

	{
		for (NSDictionary *section in allMenuArray) {
			if ([section[kA3AppsMenuName] isEqualToString:@"Utility"]) {
				BOOL hasFlashlight = NO;
				for (NSDictionary *menus in section[kA3AppsExpandableChildren]) {
					if ([menus[kA3AppsMenuName] isEqualToString:A3AppName_Flashlight]) {
						hasFlashlight = YES;
						break;
					}
				}
				if (!hasFlashlight) {
					NSMutableArray *newMenus = [section[kA3AppsExpandableChildren] mutableCopy];
					NSArray *newItems = @[
							@{kA3AppsMenuName : A3AppName_Flashlight, kA3AppsClassName_iPhone : @"A3FlashViewController", kA3AppsNibName_iPhone:@"A3FlashViewController", kA3AppsMenuImageName : @"Flashlight"},
							@{kA3AppsMenuName : A3AppName_Random, kA3AppsClassName_iPhone : @"A3RandomViewController", kA3AppsNibName_iPhone:@"A3RandomViewController", kA3AppsMenuImageName : @"Random"},
					];
					[newMenus addObjectsFromArray:newItems];

					NSMutableDictionary *newSection = [section mutableCopy];
					newSection[kA3AppsExpandableChildren] = newMenus;

					NSMutableArray *newAllMenu = [allMenuArray mutableCopy];
					[newAllMenu removeObject:section];
					[newAllMenu addObject:newSection];
					allMenuArray = newAllMenu;

					[[A3SyncManager sharedSyncManager] setObject:allMenuArray forKey:A3MainMenuDataEntityAllMenu state:A3DataObjectStateModified];
				}
			}
		}
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
					return [obj[kA3AppsMenuName] isEqualToString:A3AppName_LunarConverter];
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

- (NSDictionary *)favoriteMenuDictionary {
	NSDictionary *dictionary = [[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuDataEntityFavorites];
	if (!dictionary) {
		dictionary = @{
				kA3AppsMenuName : @"Favorites",
				kA3AppsMenuCollapsed : @NO,
				kA3AppsMenuExpandable : @YES,
				kA3AppsExpandableChildren :
				@[
						@{kA3AppsMenuName : A3AppName_Calculator, kA3AppsClassName_iPhone : @"A3CalculatorViewController_iPhone", kA3AppsClassName_iPad:@"A3CalculatorViewController_iPad",  kA3AppsMenuImageName : @"Calculator"},
						@{kA3AppsMenuName : A3AppName_Clock, kA3AppsClassName_iPhone : @"A3ClockMainViewController", kA3AppsMenuImageName : @"Clock"},
						@{kA3AppsMenuName : A3AppName_CurrencyConverter, kA3AppsClassName_iPhone : @"A3CurrencyViewController", kA3AppsMenuImageName : @"Currency"},
						@{kA3AppsMenuName : A3AppName_DaysCounter, kA3AppsClassName_iPhone : @"", kA3AppsMenuImageName : @"DaysCounter", kA3AppsMenuNeedSecurityCheck : @YES},
						@{kA3AppsMenuName : A3AppName_Holidays, kA3AppsClassName_iPhone : @"A3HolidaysPageViewController", kA3AppsMenuImageName : @"Holidays"},
						@{kA3AppsMenuName : A3AppName_Wallet, kA3AppsClassName_iPhone : @"A3WalletMainTabBarController", kA3AppsMenuImageName : @"Wallet", kA3AppsMenuNeedSecurityCheck : @YES},
				]
		};
		[[A3SyncManager sharedSyncManager] setObject:dictionary forKey:A3MainMenuDataEntityFavorites state:A3DataObjectStateInitialized];
	}
	return dictionary;
}

- (NSArray *)favoriteItems {
	NSDictionary *favoriteObject = [[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuDataEntityFavorites];
	return favoriteObject[kA3AppsExpandableChildren];
}

- (NSUInteger)maximumRecentlyUsedMenus {
	id value = [[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuUserDefaultsMaxRecentlyUsed];
	return value ? [value unsignedIntegerValue] : 3;
}

- (void)storeMaximumNumberRecentlyUsedMenus:(NSUInteger)maxNumber {
	[[A3SyncManager sharedSyncManager] setInteger:maxNumber forKey:A3MainMenuUserDefaultsMaxRecentlyUsed state:A3DataObjectStateModified];
}

- (void)clearRecentlyUsedMenus {
	[[A3SyncManager sharedSyncManager] setObject:A3SyncManagerEmptyObject forKey:A3MainMenuDataEntityRecentlyUsed state:A3DataObjectStateModified];

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationAppsMainMenuContentsChanged object:nil];
}

@end
