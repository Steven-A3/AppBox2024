//
//  A3AppDelegate+mainMenu.m
//  AppBox3
//
//  Created by A3 on 1/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>
#import "A3AppDelegate+mainMenu.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3UserDefaults.h"
#import "A3MainMenuTableViewController.h"
#import "A3MainViewController.h"
#import "MMDrawerController.h"
#import "A3HexagonMenuViewController.h"
#import "A3KeychainUtils.h"
#import "A3DaysCounterModelManager.h"
#import "A3DaysCounterSlideShowMainViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "A3DaysCounterFavoriteListViewController.h"
#import "A3DaysCounterCalendarListMainViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3GridMenuViewController.h"
#import "RMAppReceipt.h"

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
NSString *const kA3AppsDoNotKeepAsRecent = @"DoNotKeepAsRecent";

NSString *const kA3AppsMenuArray = @"kA3AppsMenuArray";
NSString *const kA3AppsDataUpdateDate = @"kA3AppsDataUpdateDate";
NSString *const kA3AppsStartingAppName = @"kA3AppsStartingAppName";
NSString *const kA3AppsOriginalStartingAppName = @"kA3AppsOriginalStartingAppName";

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
NSString *const A3AppName_Ruler = @"Ruler";
NSString *const A3AppName_Level = @"Level";
NSString *const A3AppName_Settings = @"Settings";
NSString *const A3AppName_About = @"About";
NSString *const A3AppName_RemoveAds = @"Remove Ads";
NSString *const A3AppName_RestorePurchase = @"Restore Purchase";

// 아래 줄 이하는 새로 정의한 상수
NSString *const A3AppName_None = @"None";

NSString *const kA3AppsGroupName = @"kA3AppsGroupName";

NSString *const A3AppGroupNameUtility = @"A3AppGroupNameUtility";
NSString *const A3AppGroupNameCalculator = @"A3AppGroupNameCalculator";
NSString *const A3AppGroupNameConverter = @"A3AppGroupNameConverter";
NSString *const A3AppGroupNameReference = @"A3AppGroupNameReference";
NSString *const A3AppGroupNameProductivity = @"A3AppGroupNameProductivity";
NSString *const A3AppGroupNameNone = @"A3AppGroupNameNone";

@implementation A3AppDelegate (mainMenu)

- (NSDictionary *)appInfoDictionary {
	return @{
			 A3AppName_DateCalculator : @{kA3AppsClassName_iPhone : @"A3DateMainTableViewController", kA3AppsMenuImageName : @"DateCalculator"},
			 A3AppName_LoanCalculator : @{kA3AppsStoryboard_iPhone:@"LoanCalculatorPhoneStoryBoard", kA3AppsStoryboard_iPad:@"LoanCalculatorPadStoryBoard",kA3AppsMenuImageName : @"LoanCalculator"},
			 A3AppName_SalesCalculator : @{kA3AppsClassName_iPhone : @"A3SalesCalcMainViewController", kA3AppsMenuImageName : @"SalesCalculator"},
			 A3AppName_TipCalculator : @{kA3AppsClassName_iPhone : @"A3TipCalcMainTableViewController", kA3AppsMenuImageName : @"TipCalculator"},
			 A3AppName_UnitPrice : @{kA3AppsStoryboard_iPhone:@"UnitPriceStoryboard", kA3AppsStoryboard_iPad:@"UnitPriceStoryboard_iPad", kA3AppsMenuImageName : @"UnitPrice"},
			 A3AppName_Calculator : @{kA3AppsClassName_iPhone : @"A3CalculatorViewController_iPhone", kA3AppsClassName_iPad:@"A3CalculatorViewController_iPad",  kA3AppsMenuImageName : @"Calculator"},
			 A3AppName_PercentCalculator : @{kA3AppsClassName_iPhone : @"A3PercentCalcMainViewController", kA3AppsMenuImageName : @"PercentCalculator"},
			 A3AppName_CurrencyConverter : @{kA3AppsClassName_iPhone : @"A3CurrencyViewController", kA3AppsMenuImageName : @"Currency"},
			 A3AppName_LunarConverter : @{kA3AppsClassName_iPhone : @"A3LunarConverterViewController", kA3AppsNibName_iPhone : @"A3LunarConverterViewController", kA3AppsMenuImageName : @"LunarConverter"},
			 A3AppName_Translator : @{kA3AppsClassName_iPhone : @"A3TranslatorViewController", kA3AppsMenuImageName : @"Translator"},
			 A3AppName_UnitConverter : @{kA3AppsStoryboard_iPhone:@"UnitConverterPhoneStoryboard", kA3AppsStoryboard_iPad:@"UnitConverterPhoneStoryboard", kA3AppsMenuImageName : @"UnitConverter"},
			 A3AppName_DaysCounter : @{kA3AppsClassName_iPhone : @"", kA3AppsMenuImageName : @"DaysCounter", kA3AppsMenuNeedSecurityCheck : @YES},
			 A3AppName_LadiesCalendar : @{kA3AppsClassName_iPhone : @"A3LadyCalendarViewController", kA3AppsNibName_iPhone:@"A3LadyCalendarViewController", kA3AppsMenuImageName : @"LadyCalendar", kA3AppsMenuNeedSecurityCheck : @YES},
			 A3AppName_Wallet : @{kA3AppsClassName_iPhone : @"A3WalletMainTabBarController", kA3AppsMenuImageName : @"Wallet", kA3AppsMenuNeedSecurityCheck : @YES},
			 A3AppName_ExpenseList : @{kA3AppsClassName_iPhone : @"A3ExpenseListMainViewController", kA3AppsMenuImageName : @"ExpenseList"},
			 A3AppName_Holidays : @{kA3AppsClassName_iPhone : @"A3HolidaysPageViewController", kA3AppsMenuImageName : @"Holidays"},
			 A3AppName_Clock : @{kA3AppsClassName_iPhone : @"A3ClockMainViewController", kA3AppsMenuImageName : @"Clock"},
			 A3AppName_BatteryStatus : @{kA3AppsClassName_iPhone : @"A3BatteryStatusMainViewController", kA3AppsMenuImageName : @"BatteryStatus"},
			 A3AppName_Mirror : @{kA3AppsClassName_iPhone : @"A3MirrorViewController", kA3AppsNibName_iPhone :@"A3MirrorViewController", kA3AppsMenuImageName : @"Mirror"},
			 A3AppName_Magnifier : @{kA3AppsClassName_iPhone : @"A3MagnifierViewController", kA3AppsNibName_iPhone:@"A3MagnifierViewController", kA3AppsMenuImageName : @"Magnifier"},
			 A3AppName_Flashlight : @{kA3AppsClassName_iPhone : @"A3FlashViewController", kA3AppsNibName_iPhone:@"A3FlashViewController", kA3AppsMenuImageName : @"Flashlight"},
			 A3AppName_Random : @{kA3AppsClassName_iPhone : @"A3RandomViewController", kA3AppsNibName_iPhone:@"A3RandomViewController", kA3AppsMenuImageName : @"Random"},
			 A3AppName_Ruler : @{kA3AppsClassName_iPhone : @"A3RulerViewController", kA3AppsMenuImageName : @"Ruler"},
			 A3AppName_Level : @{kA3AppsClassName_iPhone : @"InclinometerViewController", kA3AppsMenuImageName : @"Level"},
			 A3AppName_Settings : @{kA3AppsStoryboard_iPhone : @"A3Settings", kA3AppsStoryboard_iPad:@"A3Settings", kA3AppsMenuNeedSecurityCheck : @YES, kA3AppsDoNotKeepAsRecent : @YES},
			 A3AppName_About : @{kA3AppsStoryboard_iPhone : @"about", kA3AppsStoryboard_iPad:@"about", kA3AppsDoNotKeepAsRecent:@YES},
			 A3AppName_RemoveAds : @{kA3AppsMenuNeedSecurityCheck : @NO, kA3AppsDoNotKeepAsRecent : @YES},
			 A3AppName_RestorePurchase : @{kA3AppsMenuNeedSecurityCheck : @NO, kA3AppsDoNotKeepAsRecent : @YES},
			 };
}

- (NSString *)imageNameForApp:(NSString *)appName {
	return [self appInfoDictionary][appName][kA3AppsMenuImageName];
}

- (NSArray *)allMenu {
	NSDictionary *calcGroup =
	@{
	  kA3AppsMenuExpandable : @YES,
	  kA3AppsMenuCollapsed : @NO,
	  kA3AppsMenuName : @"CalculatorGroup",
	  kA3AppsExpandableChildren :	@[
			  @{kA3AppsMenuName : A3AppName_DateCalculator},
			  @{kA3AppsMenuName : A3AppName_LoanCalculator},
			  @{kA3AppsMenuName : A3AppName_SalesCalculator},
			  @{kA3AppsMenuName : A3AppName_TipCalculator},
			  @{kA3AppsMenuName : A3AppName_UnitPrice},
			  @{kA3AppsMenuName : A3AppName_Calculator},
			  @{kA3AppsMenuName : A3AppName_PercentCalculator}
			  ]
	  };
	NSDictionary *converterGroup =
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"Converter",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : A3AppName_CurrencyConverter},
						 @{kA3AppsMenuName : A3AppName_LunarConverter},
						 @{kA3AppsMenuName : A3AppName_Translator},
						 @{kA3AppsMenuName : A3AppName_UnitConverter},
						 ]
				 };
	NSDictionary *productivityGroup =
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"Productivity",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : A3AppName_DaysCounter},
						 @{kA3AppsMenuName : A3AppName_LadiesCalendar},
						 @{kA3AppsMenuName : A3AppName_Wallet},
						 @{kA3AppsMenuName : A3AppName_ExpenseList},
						 ]
				 };
	NSDictionary *ReferenceGroup =
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"Reference",
				 kA3AppsExpandableChildren : @[
						 @{kA3AppsMenuName : A3AppName_Holidays},
						 ]
				 };
	NSMutableArray *utilityApps = [@[
			@{kA3AppsMenuName : A3AppName_Clock},
			@{kA3AppsMenuName : A3AppName_BatteryStatus},
			@{kA3AppsMenuName : A3AppName_Mirror},
			@{kA3AppsMenuName : A3AppName_Magnifier},
			@{kA3AppsMenuName : A3AppName_Flashlight},
			@{kA3AppsMenuName : A3AppName_Random},
			@{kA3AppsMenuName : A3AppName_Ruler},
			@{kA3AppsMenuName : A3AppName_Level},
	] mutableCopy];
	if (IS_IPAD) {
		[self removeMenu:@"Level" inMenus:utilityApps];
	}
	NSDictionary *utilityGroup =
			 @{
				 kA3AppsMenuExpandable : @YES,
				 kA3AppsMenuCollapsed : @NO,
				 kA3AppsMenuName : @"Utility",
				 kA3AppsExpandableChildren : utilityApps,
				 };
	
	return @[calcGroup, converterGroup, productivityGroup, ReferenceGroup, utilityGroup];
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
				BOOL hasRuler = NO;
				BOOL hasLevel = NO;
				for (NSDictionary *menus in section[kA3AppsExpandableChildren]) {
					if ([menus[kA3AppsMenuName] isEqualToString:A3AppName_Flashlight]) {
						hasFlashlight = YES;
					}
					else if ([menus[kA3AppsMenuName] isEqualToString:A3AppName_Ruler]) {
						hasRuler = YES;
					}
					else if ([menus[kA3AppsMenuName] isEqualToString:A3AppName_Level]) {
						hasLevel = YES;
					}
					if (hasFlashlight && hasRuler && hasLevel) break;
				}

				NSMutableArray *newMenus = [section[kA3AppsExpandableChildren] mutableCopy];
				if (!hasFlashlight) {
					NSArray *newItems = @[
							@{kA3AppsMenuName : A3AppName_Flashlight},
							@{kA3AppsMenuName : A3AppName_Random},
					];
					[newMenus addObjectsFromArray:newItems];
				}
				if (!hasRuler) {
					NSArray *newItems = @[
							@{kA3AppsMenuName : A3AppName_Ruler},
					];
					[newMenus addObjectsFromArray:newItems];
				}
				if (IS_IPHONE && !hasLevel) {
					NSDictionary *levelItem = @{kA3AppsMenuName: A3AppName_Level};
					[newMenus addObject:levelItem];
				}
				if (IS_IPAD && hasLevel) {
					NSInteger indexOfLevelItem = [section[kA3AppsExpandableChildren] indexOfObjectPassingTest:^BOOL(NSDictionary  * _Nonnull menuItem, NSUInteger idx, BOOL * _Nonnull stop) {
						return [menuItem[kA3AppsMenuName] isEqualToString:A3AppName_Level];
					}];
					if (indexOfLevelItem != NSNotFound) {
						[newMenus removeObjectAtIndex:indexOfLevelItem];
					}
				}

				NSMutableDictionary *newSection = [section mutableCopy];
				newSection[kA3AppsExpandableChildren] = newMenus;

				NSMutableArray *newAllMenu = [allMenuArray mutableCopy];
				[newAllMenu removeObject:section];
				[newAllMenu addObject:newSection];
				allMenuArray = newAllMenu;

				[[A3SyncManager sharedSyncManager] setObject:allMenuArray forKey:A3MainMenuDataEntityAllMenu state:A3DataObjectStateModified];
				break;
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
				[self removeMenu:A3AppName_LunarConverter inMenus:originalMenus];
			}
			modifiedSection[kA3AppsExpandableChildren] = originalMenus;
			[sortedMenuArray addObject:modifiedSection];
		}
	}
	return sortedMenuArray;
}

- (void)removeMenu:(NSString *)name inMenus:(NSMutableArray *)menus {
	NSUInteger indexOfMenu = [menus indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [obj[kA3AppsMenuName] isEqualToString:name];
	}];
	if (indexOfMenu != NSNotFound) {
		[menus removeObjectAtIndex:indexOfMenu];
	}
}

- (NSDictionary *)favoriteMenuDictionary {
	NSDictionary *dictionary = [[A3SyncManager sharedSyncManager] objectForKey:A3MainMenuDataEntityFavorites];
	if (!dictionary) {
		NSArray *menus;
		if (IS_IPHONE) {
			menus =
			@[@{kA3AppsMenuName : A3AppName_CurrencyConverter},
			  @{kA3AppsMenuName : A3AppName_Level},
			  @{kA3AppsMenuName : A3AppName_UnitConverter},
			  @{kA3AppsMenuName : A3AppName_Wallet},
			  ];
		} else {
			menus =
			@[@{kA3AppsMenuName : A3AppName_CurrencyConverter},
			@{kA3AppsMenuName : A3AppName_LoanCalculator},
			@{kA3AppsMenuName : A3AppName_UnitConverter},
			@{kA3AppsMenuName : A3AppName_Wallet},
			];
		}
		dictionary = @{
				kA3AppsMenuName : @"Favorites",
				kA3AppsMenuCollapsed : @NO,
				kA3AppsMenuExpandable : @YES,
				kA3AppsExpandableChildren : menus,
		};
		[[A3SyncManager sharedSyncManager] setObject:dictionary forKey:A3MainMenuDataEntityFavorites state:A3DataObjectStateInitialized];
	}
	if (IS_IPAD) {
		NSMutableArray *newArray = [NSMutableArray new];
		BOOL dataModified;
		for (NSDictionary *menu in dictionary[kA3AppsExpandableChildren]) {
			if (![menu[kA3AppsMenuName] isEqualToString:@"Level"]) {
				[newArray addObject:menu];
				dataModified = YES;
			}
		}
		if (dataModified) {
			NSMutableDictionary *modifiedDictionary = [dictionary mutableCopy];
			modifiedDictionary[kA3AppsExpandableChildren] = newArray;
			dictionary = modifiedDictionary;

			[[A3SyncManager sharedSyncManager] setObject:dictionary forKey:A3MainMenuDataEntityFavorites state:A3DataObjectStateInitialized];
		}
	}
    [self updateApplicationShortcutItems];
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

// TODO: 3D Touch 장비 입수후 테스트 필요
- (void)updateApplicationShortcutItems {
    if (![[UIApplication sharedApplication] respondsToSelector:NSSelectorFromString(@"shortcutItems")])
        return;
    NSArray *favoriteMenus = [self favoriteItems];
    NSMutableArray *newShortcutItems = [NSMutableArray new];

	NSDictionary *appInfoDictionary = [self appInfoDictionary];
    for (NSDictionary *favoriteItem in favoriteMenus) {
		NSString *iconName = appInfoDictionary[kA3AppsMenuImageName];
        UIApplicationShortcutItem *shortcutItem = [[UIApplicationShortcutItem alloc] initWithType:[NSString stringWithFormat:@"net.allaboutapps.%@", favoriteItem[kA3AppsMenuName]]
                                                                                   localizedTitle:NSLocalizedString(favoriteItem[kA3AppsMenuName], nil)
                                                                                localizedSubtitle:Nil
                                                                                             icon:[UIApplicationShortcutIcon iconWithTemplateImageName:iconName]
                                                                                         userInfo:favoriteItem
                                                   ];
		[newShortcutItems addObject:shortcutItem];
    }
    [[UIApplication sharedApplication] setShortcutItems:newShortcutItems];
}

- (NSArray *)availableMenuTypes {
	return @[A3SettingsMainMenuStyleTable, A3SettingsMainMenuStyleHexagon, A3SettingsMainMenuStyleIconGrid];
}

- (void)reloadRootViewController {
	[self setupMainMenuViewController];
}

- (void)setupMainMenuViewController {
	NSArray *menuTypes = [self availableMenuTypes];
	NSString *userSetting = [[NSUserDefaults standardUserDefaults] objectForKey:kA3SettingsMainMenuStyle];
	NSInteger idx = [menuTypes indexOfObject:userSetting];
	switch (idx) {
		case 0:
			[self setupTableStyleMainMenuViewController];
			break;
		case 1:
			[self setupHexagonStyleMainViewController];
			break;
		case 2:
			[self setupGridStyleMainViewController];
			break;
		default:
			[self setupHexagonStyleMainViewController];
			break;
	}
}

- (void)setupGridStyleMainViewController {
	if (IS_IPHONE) {
		A3GridMenuViewController *gridMenuViewController;

		gridMenuViewController = [A3GridMenuViewController new];
		A3NavigationController *navigationController = [[A3NavigationController alloc] initWithRootViewController:gridMenuViewController];
		self.window.rootViewController = navigationController;
		self.currentMainNavigationController = navigationController;
		self.rootViewController_iPhone = navigationController;
	}
}

- (void)setupHexagonStyleMainViewController {
	if (IS_IPHONE) {
		A3HexagonMenuViewController *hexagonMenuViewController;

		hexagonMenuViewController = [A3HexagonMenuViewController new];
		A3NavigationController *navigationController = [[A3NavigationController alloc] initWithRootViewController:hexagonMenuViewController];
		self.window.rootViewController = navigationController;
		self.currentMainNavigationController = navigationController;
		self.rootViewController_iPhone = navigationController;
	}
}

- (void)setupTableStyleMainMenuViewController {
	UIViewController *rootViewController;
	if (IS_IPAD) {
		A3RootViewController_iPad *rootViewController_iPad = [[A3RootViewController_iPad alloc] initWithNibName:nil bundle:nil];
		[rootViewController view];
		rootViewController = rootViewController_iPad;
		self.rootViewController_iPad = rootViewController_iPad;
		self.mainMenuViewController = rootViewController_iPad.mainMenuViewController;
		self.currentMainNavigationController = rootViewController_iPad.centerNavigationController;
	} else {
		self.mainMenuViewController = [[A3MainMenuTableViewController alloc] init];
		UINavigationController *menuNavigationController = [[UINavigationController alloc] initWithRootViewController:self.mainMenuViewController];

		UIViewController *viewController = [A3MainViewController new];
		A3NavigationController *navigationController = [[A3NavigationController alloc] initWithRootViewController:viewController];
		self.currentMainNavigationController = navigationController;

		MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:navigationController leftDrawerViewController:menuNavigationController];
		self.drawerController = drawerController;
		self.rootViewController_iPhone = self.drawerController;

		[drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
		[drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
		[drawerController setDrawerVisualStateBlock:[self slideAndScaleVisualStateBlock]];
		[drawerController setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeFull];
		[drawerController setGestureCompletionBlock:^(MMDrawerController *drawerController, UIGestureRecognizer *gesture) {
			[[NSNotificationCenter defaultCenter] postNotificationName:A3DrawerStateChanged object:nil];
			if (drawerController.openSide != MMDrawerSideLeft) {
				[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationMainMenuDidHide object:nil];
			}
		}];

		CGRect screenBounds = [[UIScreen mainScreen] bounds];
		[drawerController setMaximumLeftDrawerWidth:screenBounds.size.width];
		[drawerController setShowsShadow:NO];

		drawerController.view.frame = screenBounds;

		rootViewController = drawerController;
	}
	self.window.rootViewController = rootViewController;
}

- (MMDrawerControllerDrawerVisualStateBlock)slideAndScaleVisualStateBlock{
	MMDrawerControllerDrawerVisualStateBlock visualStateBlock =
			^(MMDrawerController * drawerController, MMDrawerSide drawerSide, CGFloat percentVisible){
				CGFloat minScale = .95;
				CGFloat scale = minScale + (percentVisible*(1.0-minScale));
				CATransform3D scaleTransform =  CATransform3DMakeScale(scale, scale, scale);

				CGFloat maxDistance = 10;
				CGFloat distance = maxDistance * percentVisible;
				CATransform3D translateTransform;
				UIViewController * sideDrawerViewController;
				if(drawerSide == MMDrawerSideLeft) {
					sideDrawerViewController = drawerController.leftDrawerViewController;
					translateTransform = CATransform3DMakeTranslation((maxDistance-distance), 0.0, 0.0);
				}
				else if(drawerSide == MMDrawerSideRight){
					sideDrawerViewController = drawerController.rightDrawerViewController;
					translateTransform = CATransform3DMakeTranslation(-(maxDistance-distance), 0.0, 0.0);
				}

				[sideDrawerViewController.view.layer setTransform:CATransform3DConcat(scaleTransform, translateTransform)];
				[sideDrawerViewController.view setAlpha:percentVisible];
			};
	return visualStateBlock;
}

- (BOOL)launchAppNamed:(NSString *)appName verifyPasscode:(BOOL)verifyPasscode animated:(BOOL)animated {
	BOOL appLaunched = NO;
	BOOL proceedPasscodeCheck = NO;

	NSDictionary *appInfo = [self appInfoDictionary][appName];
	if (   verifyPasscode
		&& [A3KeychainUtils getPassword]
		&& [self securitySettingIsOnForAppNamed:appName]
		&& [[A3AppDelegate instance] didPasscodeTimerEnd]
		)
	{
		proceedPasscodeCheck = YES;
		
		if ([appInfo[kA3AppsStoryboard_iPhone] isEqualToString:@"A3Settings"]) {
			proceedPasscodeCheck &= [[A3UserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForAskPasscodeForSettings];
		}
	}
	if (proceedPasscodeCheck) {
		[self presentLockScreen];
	} else {
		UIViewController *targetViewController= [self getViewControllerForAppNamed:appName];
		[targetViewController callPrepareCloseOnActiveMainAppViewController];
		[targetViewController popToRootAndPushViewController:targetViewController animated:animated];
		appLaunched = YES;
	}
	return appLaunched;
}

- (UIViewController *)getViewControllerForAppNamed:(NSString *)appName {
	UIViewController *targetViewController;

	NSDictionary *appInfo = [self appInfoDictionary][appName];
	if ([appInfo[kA3AppsMenuImageName] isEqualToString:@"DaysCounter"]) {
		A3DaysCounterModelManager *sharedManager = [[A3DaysCounterModelManager alloc] init];
		[sharedManager prepareInContext:[A3AppDelegate instance].managedObjectContext];

		NSInteger lastOpenedMainIndex = [[A3UserDefaults standardUserDefaults] integerForKey:A3DaysCounterLastOpenedMainIndex];
		switch (lastOpenedMainIndex) {
			case 1:
				targetViewController = [[A3DaysCounterSlideShowMainViewController alloc] initWithNibName:@"A3DaysCounterSlideShowMainViewController" bundle:nil];
				((A3DaysCounterSlideShowMainViewController *)targetViewController).sharedManager = sharedManager;
				break;
			case 3:
				targetViewController = [[A3DaysCounterReminderListViewController alloc] initWithNibName:@"A3DaysCounterReminderListViewController" bundle:nil];
				((A3DaysCounterReminderListViewController *)targetViewController).sharedManager = sharedManager;
				break;
			case 4:
				targetViewController = [[A3DaysCounterFavoriteListViewController alloc] initWithNibName:@"A3DaysCounterFavoriteListViewController" bundle:nil];
				((A3DaysCounterFavoriteListViewController *)targetViewController).sharedManager = sharedManager;
				break;

			default:
				targetViewController = [[A3DaysCounterCalendarListMainViewController alloc] initWithNibName:@"A3DaysCounterCalendarListMainViewController" bundle:nil];
				((A3DaysCounterCalendarListMainViewController *)targetViewController).sharedManager = sharedManager;
				break;
		}

		return targetViewController;
	}

	if ([appInfo[kA3AppsClassName_iPhone] length]) {
		Class class;
		NSString *nibName;
		if (IS_IPAD) {
			class = NSClassFromString(appInfo[kA3AppsClassName_iPad] ? appInfo[kA3AppsClassName_iPad] : appInfo[kA3AppsClassName_iPhone]);
			nibName = appInfo[kA3AppsNibName_iPad] ? appInfo[kA3AppsNibName_iPad] : appInfo[kA3AppsNibName_iPhone];
		} else {
			class = NSClassFromString(appInfo[kA3AppsClassName_iPhone]);
			nibName = appInfo[kA3AppsNibName_iPhone];
		}

		if (nibName) {
			targetViewController = [[class alloc] initWithNibName:nibName bundle:nil];
		} else {
			targetViewController = [[class alloc] init];
		}
	} else if ([appInfo[kA3AppsStoryboard_iPhone] length]) {
		NSString *storyboardName;
		if (IS_IPAD) {
			storyboardName = appInfo[kA3AppsStoryboard_iPad] ? appInfo[kA3AppsStoryboard_iPad] : appInfo[kA3AppsStoryboard_iPhone];
		} else {
			storyboardName = appInfo[kA3AppsStoryboard_iPhone];
		}
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
		targetViewController = [storyboard instantiateInitialViewController];
	}
	return targetViewController;
}

- (BOOL)securitySettingIsOnForAppNamed:(NSString *)appName {
	NSDictionary *appInfo = [self appInfoDictionary][appName];

	if (![appInfo[kA3AppsMenuNeedSecurityCheck] boolValue]) return NO;
	if ([appName isEqualToString:A3AppName_DaysCounter]) {
		return [[A3AppDelegate instance] shouldAskPasscodeForDaysCounter];
	} else if ([appName isEqualToString:A3AppName_LadiesCalendar]) {
		return [[A3AppDelegate instance] shouldAskPasscodeForLadyCalendar];
	} else if ([appName isEqualToString:A3AppName_Wallet]) {
		return [[A3AppDelegate instance] shouldAskPasscodeForWallet];
	} else if ([appName isEqualToString:A3AppName_Settings]) {
		return [[A3AppDelegate instance] shouldAskPasscodeForSettings];
	}
	return NO;
}

#pragma mark In App Purchase

- (void)startRemoveAds {
	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	appDelegate.inAppPurchaseInProgress = YES;

	[self showProcessingHUD];

	if ([appDelegate.receiptVerificator verifyAppReceipt]) {
		// 영수증을 다시 확인을 한다.
		// 영수증이 정상인데, 이 멤버가 호출이 되었다는 것은,
		// 사용자가 3.6 이후 버전을 구매했다는 의미 이므로 인앱 구매를 진행한다.
		// App Store에서 구매한 실 사용자라면 이 흐름으로 진행이 된다.

		[self executePurchaseRemoveAds];
	} else {
		// App Review 상황이거나, 앱을 App Store를 통해서 설치하지 않은 경우,
		// iTunes를 통해서 설치한 경우, 영수증이 없는 경우가 있다.

		// 앱 심사 과정의 Reject된 상황을 고려할 때 refreshReceipt가 App Review과정에서 실패하는 것으로
		// 추정이 된다.
		[[RMStore defaultStore] refreshReceiptOnSuccess:^{
			RMAppReceipt *appReceipt = [RMAppReceipt bundleReceipt];
			if ([appDelegate isPaidAppVersionCustomer:appReceipt]) {
				[self hideProcessingHUD];
				[self finishRemoveAds];
				appDelegate.inAppPurchaseInProgress = NO;
				[self alertPaidAppCustomer];
			} else if ([appDelegate isIAPPurchasedCustomer:appReceipt]) {
				[self hideProcessingHUD];
				[self finishRemoveAds];
				appDelegate.inAppPurchaseInProgress = NO;
				[self alertAlreadyPurchased];
			} else {
				[self executePurchaseRemoveAds];
			}
			[appDelegate makeReceiptBackup];
		} failure:^(NSError *error) {
			// 탈옥폰이라면 다음에 진행될 인앱 구매 진행이 실패할 것이다.
			// 앱 리뷰시 영수증 리프레시에 실패하여 이 코드가 실행이 된다.
			[self executePurchaseRemoveAds];
		}];
		return;
	}
}

- (void)executePurchaseRemoveAds {
	A3AppDelegate *appDelegate = [A3AppDelegate instance];

	[[RMStore defaultStore] addPayment:A3InAppPurchaseRemoveAdsProductIdentifier success:^(SKPaymentTransaction *transaction) {
		[self hideProcessingHUD];

		[self finishRemoveAds];
		appDelegate.inAppPurchaseInProgress = NO;
		[[A3AppDelegate instance] makeReceiptBackup];
	} failure:^(SKPaymentTransaction *transaction, NSError *error) {
		[self hideProcessingHUD];

		[self alertTransactionFailed];
		appDelegate.inAppPurchaseInProgress = NO;
	}];
}

- (void)startRestorePurchase {
	// App Receipt가 정상적으로 Validate가 되었는지 확인한다.
	self.inAppPurchaseInProgress = YES;

	[self showProcessingHUD];

	if (![self.receiptVerificator verifyAppReceipt]) {
		[[RMStore defaultStore] refreshReceiptOnSuccess:^{
			[self hideProcessingHUD];

			RMAppReceipt *appReceipt = [RMAppReceipt bundleReceipt];
			if ([self isPaidAppVersionCustomer:appReceipt]) {
				[self finishRemoveAds];
				[self alertPaidAppCustomer];
				self.inAppPurchaseInProgress = NO;
			} else if ([self isIAPPurchasedCustomer:appReceipt]) {
				[self finishRemoveAds];
				[self alertAlreadyPurchased];
				self.inAppPurchaseInProgress = NO;
			} else {
				[self executeRestoreTransaction];
			}
			[self makeReceiptBackup];
		} failure:^(NSError *error) {
			[self executeRestoreTransaction];
		}];
		return;
	} else {
		[self executeRestoreTransaction];
	}
}

- (void)executeRestoreTransaction {
	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	[[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
		[self hideProcessingHUD];

		BOOL isTransactionRestored = NO;
		for (SKPaymentTransaction *transaction in transactions) {
			SKPayment *payment = transaction.payment;
			if ([payment.productIdentifier isEqualToString:A3InAppPurchaseRemoveAdsProductIdentifier]) {
				isTransactionRestored = YES;
				break;
			}
		}

		if (isTransactionRestored) {
			[self finishRemoveAds];
			[self alertRestoreSuccess];
		} else {
			[self alertRestoreFailed];
		}
		appDelegate.inAppPurchaseInProgress = NO;
	} failure:^(NSError *error) {
		[self hideProcessingHUD];

		appDelegate.inAppPurchaseInProgress = NO;
	}];
}

- (void)finishRemoveAds {
	self.shouldPresentAd = NO;
	self.isIAPRemoveAdsAvailable = NO;

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationAppsMainMenuContentsChanged object:nil];
}

- (void)alertPaidAppCustomer {
	UIAlertView *alertAlreadyPurchased = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank You", nil)
																	message:NSLocalizedString(@"Your paid app receipt has been validated. Thank you very much.", nil)
																   delegate:nil
														  cancelButtonTitle:NSLocalizedString(@"OK", nil)
														  otherButtonTitles:nil];
	[alertAlreadyPurchased show];
}

- (void)alertAlreadyPurchased {
	UIAlertView *alertAlreadyPurchased = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank You", nil)
																	message:NSLocalizedString(@"You've already purchased this. Your purchases has been restored.", nil)
																   delegate:nil
														  cancelButtonTitle:NSLocalizedString(@"OK", nil)
														  otherButtonTitles:nil];
	[alertAlreadyPurchased show];
}

- (void)alertRestoreSuccess {
	UIAlertView *thanksAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thanks", @"Thanks")
															  message:NSLocalizedString(@"Thank you very much for purchasing the AppBox Pro.", @"Thank you very much for purchasing the AppBox Pro.")
															 delegate:nil
													cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
													otherButtonTitles:nil];
	[thanksAlertView show];
}

- (void)alertRestoreFailed {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", nil)
														message:NSLocalizedString(@"No Transactions to Restore", @"No Transactions to Restore")
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
	[alertView show];
}

- (void)alertTransactionFailed {
	UIAlertView *purchaseFailed = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
															 message:NSLocalizedString(@"Transaction failed. Try again later.", @"Transaction failed. Try again later.")
															delegate:nil
												   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												   otherButtonTitles:nil];
	[purchaseFailed show];
}

- (void)showProcessingHUD {
	if (IS_IPHONE) {
		self.hudView.labelText = NSLocalizedString(@"Processing", @"Processing");
		[self.hudView show:YES];
	} else {
		A3AppDelegate *appDelegate = [A3AppDelegate instance];
		appDelegate.hud.labelText = NSLocalizedString(@"Processing", @"Processing");
		[appDelegate.hud show:YES];
	}
}

- (void)hideProcessingHUD {
	if (IS_IPHONE) {
		[self.hudView hide:NO];
	} else {
		A3AppDelegate *appDelegate = [A3AppDelegate instance];
		[appDelegate.hud hide:NO];
	}
}

@end
