//
//  A3AppDelegate+iCloud.m
//  AppBox3
//
//  Created by A3 on 12/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate+iCloud.h"
#import "A3LadyCalendarModelManager.h"
#import "A3DaysCounterModelManager.h"
#import "NSDate-Utilities.h"
#import "A3SyncManager.h"
#import "A3UserDefaults.h"

@implementation A3AppDelegate (iCloud)

- (void)setCloudEnabled:(BOOL)enable {
	A3SyncManager *sharedSyncManager = [A3SyncManager sharedSyncManager];
	if (enable) {
		sharedSyncManager.storePath = [self.storeURL path];
		[sharedSyncManager enableCloudSync];
		[self mergeUserDefaultsDeleteCloud:NO];
	}
	else {
		[sharedSyncManager disableCloudSync];

		[[A3UserDefaults standardUserDefaults] removeObjectForKey:A3SyncManagerCloudEnabled];
		[[A3UserDefaults standardUserDefaults] synchronize];
	}
	[self enableCloudForFiles:enable];

	self.hud.labelText = enable ? NSLocalizedString(@"Enabling iCloud", @"Enabling iCloud") : NSLocalizedString(@"Disabling iCloud", @"Disableing iCloud");
	[self.hud show:YES];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persistentStoreActivityWillEndActivity:) name:CDEPersistentStoreEnsembleWillEndActivityNotification object:nil];
}

- (void)persistentStoreActivityWillEndActivity:(NSNotification *)notification {
	FNLOG();
	
	CDEEnsembleActivity activity = (CDEEnsembleActivity) [[notification.userInfo objectForKey:CDEEnsembleActivityKey] unsignedIntegerValue];
	if (activity == CDEEnsembleActivityLeeching || activity == CDEEnsembleActivityDeleeching) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:CDEPersistentStoreEnsembleWillEndActivityNotification object:nil];
		[self.hud hide:YES];
	}
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// required or the app defaults to no background fetching
	[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
	return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	// set the time of wake up to use for returning if we updated
	self.wakeUpTime = [NSDate date];
	FNLOG(@"%@", self.wakeUpTime);

	if (!self.isCoreDataReady) {
		completionHandler(UIBackgroundFetchResultNoData);
		return;
	}
	if ([[UIApplication sharedApplication] isProtectedDataAvailable]) {
		FNLOG(@"Protected Data is Available.");
		
		[A3DaysCounterModelManager reloadAlertDateListForLocalNotification:[NSManagedObjectContext MR_rootSavingContext] ];
		[A3LadyCalendarModelManager setupLocalNotification];
		
		completionHandler(UIBackgroundFetchResultNewData);
	} else {
		FNLOG(@"Protected Data is NOT Available.");
		completionHandler(UIBackgroundFetchResultNoData);
	}
}

#pragma mark - Image and Video files

- (void)enableCloudForFiles:(BOOL)enable {
	if (enable) {
		[[A3SyncManager sharedSyncManager] uploadMediaFilesToCloud];
	}
	[[A3SyncManager sharedSyncManager] downloadMediaFilesFromCloud];
}

#pragma mark - A3UserDefaults & NSUbiquitousKeyValueStore

- (void)mergeUserDefaultsDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
	[keyValueStore synchronize];
	A3UserDefaults *userDefaults = [A3UserDefaults standardUserDefaults];

	for (NSString *key in [self syncKeys]) {
		NSDictionary *objectInCloud = [keyValueStore objectForKey:key];
		NSDictionary *objectInLocal = [userDefaults objectForKey:key];

		if (objectInCloud && ![self isValidSyncEnabledObject:objectInCloud]) {
			[keyValueStore removeObjectForKey:key];
			objectInCloud = nil;
		}
		if (objectInLocal && ![self isValidSyncEnabledObject:objectInLocal]) {
			[userDefaults removeObjectForKey:key];
			objectInLocal = nil;
		}

		if (!objectInCloud && [objectInLocal[A3KeyValueDBState] unsignedIntegerValue] == A3DataObjectStateInitialized)
			continue;

		if (objectInCloud && [objectInLocal[A3KeyValueDBState] unsignedIntegerValue] == A3DataObjectStateInitialized) {
			[userDefaults setObject:objectInCloud forKey:key];
			continue;
		}

		NSDate *cloudTimestamp = objectInCloud[A3KeyValueDBUpdateDate];
		NSDate *localTimestamp = objectInLocal[A3KeyValueDBUpdateDate];
		if ([localTimestamp isEarlierThanDate:cloudTimestamp]) {
			[userDefaults setObject:objectInCloud forKey:key];
		} else {
			[keyValueStore setObject:objectInLocal forKey:key];
		}
	}
	[userDefaults synchronize];
	[keyValueStore synchronize];
}

- (BOOL)isValidSyncEnabledObject:(NSDictionary *)object {
	if (![object isKindOfClass:[NSDictionary class]]) return NO;
	NSArray *allKeys = [object allKeys];
	return [allKeys count] == 3 &&
			[allKeys containsObject:A3KeyValueDBDataObject] &&
			[allKeys containsObject:A3KeyValueDBState] &&
	[allKeys containsObject:A3KeyValueDBUpdateDate];
}

- (NSArray *)syncKeys {
	return @[
			A3DateCalcDefaultsIsAddSubMode,
			A3DateCalcDefaultsFromDate,
			A3DateCalcDefaultsToDate,
			A3DateCalcDefaultsOffsetDate,
			A3DateCalcDefaultsDidSelectMinus,
			A3DateCalcDefaultsSavedYear,
			A3DateCalcDefaultsSavedMonth,
			A3DateCalcDefaultsSavedDay,
			A3DateCalcDefaultsDurationType,
			A3DateCalcDefaultsExcludeOptions,

			A3CalculatorUserDefaultsSavedLastExpression,

			A3CurrencyUserDefaultsLastInputValue,

			A3DaysCounterUserDefaultsSlideShowOptions,

			A3ExpenseListUserDefaultsCurrencyCode,
			A3ExpenseListIsAddBudgetCanceledByUser,
			A3ExpenseListIsAddBudgetInitiatedOnce,

			A3LadyCalendarCurrentAccountID,
			A3LadyCalendarUserDefaultsSettings,
			A3LadyCalendarLastViewMonth,

			A3LoanCalcUserDefaultShowDownPayment,
			A3LoanCalcUserDefaultShowExtraPayment,
			A3LoanCalcUserDefaultShowAdvanced,
			A3LoanCalcUserDefaultsLoanDataKey,
			A3LoanCalcUserDefaultsLoanDataKey_A,
			A3LoanCalcUserDefaultsLoanDataKey_B,
			A3LoanCalcUserDefaultsCustomCurrencyCode,

			A3LunarConverterLastInputDateComponents,
			A3LunarConverterLastInputDateIsLunar,

			A3PercentCalcUserDefaultsCalculationType,
			A3PercentCalcUserDefaultsSavedInputData,

			A3SalesCalcUserDefaultsSavedInputDataKey,
			A3SalesCalcUserDefaultsCurrencyCode,

			A3TipCalcUserDefaultsCurrencyCode,

			A3UnitConverterDefaultSelectedCategoryID,
			A3UnitConverterTableViewUnitValueKey,

			A3UnitPriceUserDefaultsCurrencyCode,

			A3MainMenuUserDefaultsMaxRecentlyUsed,
	];
}

@end
