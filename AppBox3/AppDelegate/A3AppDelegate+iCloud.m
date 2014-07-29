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
#import "DaysCounterEvent+extension.h"
#import "NSString+conversion.h"
#import "WalletFieldItem+initialize.h"
#import "A3DateMainTableViewController.h"
#import "NSDate-Utilities.h"
#import "A3Calculator.h"
#import "A3UserDefaults.h"
#import "A3SyncManager.h"

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

		[[NSUserDefaults standardUserDefaults] removeObjectForKey:A3SyncManagerCloudEnabled];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[self enableCloudForFiles:enable];

	self.hud.labelText = enable ? NSLocalizedString(@"Enabling iCloud", @"Enabling iCloud") : NSLocalizedString(@"Disabling iCloud", @"Disableing iCloud");
	[self.hud show:YES];
	[self.hud hide:YES afterDelay:3];
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

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		[[A3SyncManager sharedSyncManager] synchronizeWithCompletion:^(NSError *error) {
			[A3DaysCounterModelManager reloadAlertDateListForLocalNotification];
			[A3LadyCalendarModelManager setupLocalNotification];
		}];
	}

	// pass on the completion handler to another method with delay to allow any imports to occur
	// the API Allows 30 seconds so I only delay for 28 seconds just to be safe
	[self performSelector:@selector(sendBGFetchCompletionHandler:) withObject:completionHandler afterDelay:28];
}

- (void)sendBGFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		completionHandler(UIBackgroundFetchResultNewData);
	} else {
		completionHandler(UIBackgroundFetchResultNoData);
	}
}

#pragma mark - Image and Video files

- (void)enableCloudForFiles:(BOOL)enable {
	if (enable) {
		[[A3SyncManager sharedSyncManager] uploadFilesToCloud];
	}
	[[A3SyncManager sharedSyncManager] downloadFilesFromCloud];
}

#pragma mark - NSMetadataQuery

- (void)startCloudFileQuery {
	FNLOG();
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudFileChanged) name:NSMetadataQueryDidUpdateNotification object:self.metadataQuery];

	[self.metadataQuery startQuery];
}

- (void)cloudFileChanged {
	FNLOG();
	[self.metadataQuery disableUpdates];

	for (NSMetadataItem *metaData in [self.metadataQuery results]) {
		FNLOG(@"%@", [metaData valueForAttribute:NSMetadataItemFSNameKey]);
		if (![[metaData valueForAttribute:NSMetadataUbiquitousItemDownloadingStatusKey] isEqualToString:NSMetadataUbiquitousItemDownloadingStatusDownloaded]) {
			NSURL *fileURL = [metaData valueForKey:NSMetadataItemURLKey];
			[[NSFileManager new] startDownloadingUbiquitousItemAtURL:fileURL error:NULL];
		}
	}

	[self.metadataQuery enableUpdates];
}

- (void)stopCloudFileQuery {
	if (self.metadataQuery) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:self.metadataQuery];
		[self.metadataQuery stopQuery];
		self.metadataQuery = nil;
	}
}

- (void)deleteCloudFilesToResetCloud {
	// iCloud 데이터를 초기화 하는 경우에, 이미지 파일들도 함께 지워야 한다.
	// DaysCounter image, Wallet 사진, 비디오 이미지를 함께 삭제한다.
	[self deleteCloudFilesToResetCloudInDirectory:A3DaysCounterImageDirectory];
	[self deleteCloudFilesToResetCloudInDirectory:A3WalletImageDirectory];
	[self deleteCloudFilesToResetCloudInDirectory:A3WalletVideoDirectory];
}

- (void)deleteCloudFilesToResetCloudInDirectory:(NSString *)directory {
	NSFileManager *fileManager = [NSFileManager new];
	NSURL *ubiquityContainerURL = [fileManager URLForUbiquityContainerIdentifier:nil];
	if (!ubiquityContainerURL || !directory) return;
	NSArray *files = [fileManager contentsOfDirectoryAtURL:[ubiquityContainerURL URLByAppendingPathComponent:directory] includingPropertiesForKeys:nil options:0 error:NULL];
	CDEICloudFileSystem *fileSystem = [[A3SyncManager sharedSyncManager] cloudFileSystem];
	for (NSURL *fileURL in files) {
		[fileSystem removeItemAtPath:[fileURL path] completion:NULL];
	}
}

- (BOOL)isLocalLaterForLocal:(NSDate *)local cloud:(NSDate *)cloud {
	if (!cloud) return YES;
	if (!local) return NO;
	return [cloud isEarlierThanDate:local];
}

#pragma mark - NSUserDefaults & NSUbiquitousKeyValueStore

- (void)migrateDefaultsToStoreForKeys:(NSArray *)keys {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	for (id key in keys) {
		id object = [userDefaults objectForKey:key];
		if (object) {
			[store setObject:object forKey:key];
		} else {
			[store removeObjectForKey:key];
		}
	}
}

- (void)migrateDefaultsFromStoreForKeys:(NSArray *)keys {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	for (id key in keys) {
		id object = [store objectForKey:key];
		if (object) {
			[userDefaults setObject:object forKey:key];
		} else {
			[userDefaults removeObjectForKey:key];
		}
	}
}

- (void)mergeUserDefaultsDeleteCloud:(BOOL)deleteCloud {
	[[NSUbiquitousKeyValueStore defaultStore] synchronize];

	if (deleteCloud) {
		[self mergeMainMenuDeleteCloud:deleteCloud];
	} else {
		[self migrateMainMenuFromCloud];
	}
	[self mergeCalculatorDeleteCloud:deleteCloud];
	[self mergeCurrencyDeleteCloud:deleteCloud];
	[self mergeDateCalcDeleteCloud:deleteCloud];
	[self mergeDaysCounterDeleteCloud:deleteCloud];
	[self mergeExpenseListDeleteCloud:deleteCloud];
	[self mergeLadyCalendarDeleteCloud:deleteCloud];
	[self mergeLoanCalcDeleteCloud:deleteCloud];
	[self mergeLunarConverterDeleteCloud:deleteCloud];
	[self mergePercentCalcDeleteCloud:deleteCloud];
	[self mergeSalesCalcDeleteCloud:deleteCloud];
	[self mergeTipCalcDeleteCloud:deleteCloud];
	[self mergeUnitConverterDeleteCloud:deleteCloud];
	[self mergeUnitPriceDeleteCloud:deleteCloud];
}

- (void)mergeDateCalcDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3DateCalcDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3DateCalcDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3DateCalcDefaultsIsAddSubMode,
			A3DateCalcDefaultsFromDate,
			A3DateCalcDefaultsToDate,
			A3DateCalcDefaultsOffsetDate,
			A3DateCalcDefaultsDidSelectMinus,
			A3DateCalcDefaultsSavedYear,
			A3DateCalcDefaultsSavedMonth,
			A3DateCalcDefaultsSavedDay,
			A3DateCalcDefaultsDurationType,
			A3DateCalcDefaultsExcludeOptions
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3DateCalcDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3DateCalcDefaultsUpdateDate];
	}
}

- (void)mergeCalculatorDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3CalculatorUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3CalculatorUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3CalculatorUserDefaultsSavedLastExpression
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3CalculatorUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3CalculatorUserDefaultsUpdateDate];
	}
}

- (void)mergeCurrencyDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3CurrencyUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3CurrencyUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3CurrencyUserDefaultsLastInputValue
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3CurrencyUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3CurrencyUserDefaultsUpdateDate];
	}
}

- (void)mergeDaysCounterDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3DaysCounterUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3DaysCounterUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3DaysCounterUserDefaultsSlideShowOptions
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3DaysCounterUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3DaysCounterUserDefaultsUpdateDate];
	}
}

- (void)mergeExpenseListDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3ExpenseListUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3ExpenseListUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3ExpenseListUserDefaultsCurrencyCode,
			A3ExpenseListIsAddBudgetCanceledByUser
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3ExpenseListUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3ExpenseListUserDefaultsUpdateDate];
	}
}

- (void)mergeLadyCalendarDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3LadyCalendarUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3LadyCalendarUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3LadyCalendarCurrentAccountID,
			A3LadyCalendarUserDefaultsSettings,
			A3LadyCalendarLastViewMonth
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3LadyCalendarUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3LadyCalendarUserDefaultsUpdateDate];
	}
}

- (void)mergeLoanCalcDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3LoanCalcUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3LoanCalcUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3LoanCalcUserDefaultShowDownPayment,
			A3LoanCalcUserDefaultShowExtraPayment,
			A3LoanCalcUserDefaultShowAdvanced,
			A3LoanCalcUserDefaultsLoanDataKey,
			A3LoanCalcUserDefaultsLoanDataKey_A,
			A3LoanCalcUserDefaultsLoanDataKey_B,
			A3LoanCalcUserDefaultsCustomCurrencyCode
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3LoanCalcUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3LoanCalcUserDefaultsUpdateDate];
	}
}

- (void)mergeLunarConverterDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3LunarConverterUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3LunarConverterUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3LunarConverterLastInputDateComponents,
			A3LunarConverterLastInputDateIsLunar
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3LunarConverterUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3LunarConverterUserDefaultsUpdateDate];
	}
}

- (void)mergePercentCalcDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3PercentCalcUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3PercentCalcUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3PercentCalcUserDefaultsCalculationType,
			A3PercentCalcUserDefaultsSavedInputData
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3PercentCalcUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3PercentCalcUserDefaultsUpdateDate];
	}
}

- (void)mergeSalesCalcDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3SalesCalcUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3SalesCalcUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3SalesCalcUserDefaultsSavedInputDataKey,
			A3SalesCalcUserDefaultsCurrencyCode
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3SalesCalcUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3SalesCalcUserDefaultsUpdateDate];
	}
}

- (void)mergeTipCalcDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3TipCalcUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3TipCalcUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3TipCalcUserDefaultsCurrencyCode
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3TipCalcUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3TipCalcUserDefaultsUpdateDate];
	}
}

- (void)mergeUnitConverterDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3UnitConverterUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3UnitConverterUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3UnitConverterDefaultSelectedCategoryID,
			A3UnitConverterTableViewUnitValueKey
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3UnitConverterUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3UnitConverterUserDefaultsUpdateDate];
	}
}

- (void)mergeUnitPriceDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3UnitPriceUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3UnitPriceUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3UnitPriceUserDefaultsCurrencyCode
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3UnitPriceUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3UnitPriceUserDefaultsUpdateDate];
	}
}

- (void)mergeMainMenuDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3MainMenuUserDefaultsCloudUpdateDate];
	NSDate *localUpdateDate = [userDefaults objectForKey:A3MainMenuUserDefaultsUpdateDate];

	NSArray *migratingKeys = @[
			A3MainMenuUserDefaultsFavorites,
			A3MainMenuUserDefaultsRecentlyUsed,
			A3MainMenuUserDefaultsAllMenu,
			A3MainMenuUserDefaultsMaxRecentlyUsed
	];
	if (deleteCloud || [self isLocalLaterForLocal:localUpdateDate cloud:cloudUpdateDate]) {
		[self migrateDefaultsToStoreForKeys:migratingKeys];
		[store setObject:localUpdateDate forKey:A3MainMenuUserDefaultsCloudUpdateDate];
	} else {
		[self migrateDefaultsFromStoreForKeys:migratingKeys];
		[userDefaults setObject:cloudUpdateDate forKey:A3MainMenuUserDefaultsUpdateDate];
	}
}

- (void)migrateMainMenuFromCloud {
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSDate *cloudUpdateDate = [store objectForKey:A3MainMenuUserDefaultsCloudUpdateDate];
	[userDefaults setObject:cloudUpdateDate forKey:A3MainMenuUserDefaultsUpdateDate];
	NSArray *migratingKeys = @[
			A3MainMenuUserDefaultsFavorites,
			A3MainMenuUserDefaultsRecentlyUsed,
			A3MainMenuUserDefaultsAllMenu,
			A3MainMenuUserDefaultsMaxRecentlyUsed
	];
	for (NSString *key in migratingKeys) {
		id object = [store objectForKey:key];
		if (object) {
			[userDefaults setObject:object forKey:key];
		}
	}
}

@end
