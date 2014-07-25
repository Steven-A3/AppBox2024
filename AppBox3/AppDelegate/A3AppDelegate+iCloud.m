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

- (void)setCloudEnabled:(BOOL)enable deleteCloud:(BOOL)deleteCloud {
	A3SyncManager *sharedSyncManager = [A3SyncManager sharedSyncManager];
	if (enable) {
		if (deleteCloud) {
			[sharedSyncManager removeCloudStore];
			[self deleteCloudFilesToResetCloud];
		}
		sharedSyncManager.storePath = [self.storeURL path];

		[sharedSyncManager enableCloudSync];

		[self mergeUserDefaultsDeleteCloud:(BOOL)deleteCloud];
		[self startDownloadAllFiles];
	}
	else {
		[sharedSyncManager disableCloudSync];
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

- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	// set the time of wake up to use for returning if we updated
	self.wakeUpTime = [NSDate date];
	FNLOG(@"%@", self.wakeUpTime);
		
	// pass on the completion handler to another method with delay to allow any imports to occur
	// the API Allows 30 seconds so I only delay for 28 seconds just to be safe
	[self performSelector:@selector(sendBGFetchCompletionHandler:) withObject:completionHandler afterDelay:28];
}

- (void)sendBGFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	[A3DaysCounterModelManager reloadAlertDateListForLocalNotification];
	[A3LadyCalendarModelManager setupLocalNotification];

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		completionHandler(UIBackgroundFetchResultNewData);
	} else {
		completionHandler(UIBackgroundFetchResultNoData);
	}
}

#pragma mark - Image and Video files

- (void)enableCloudForFiles:(BOOL)enable {
	if (enable) {
		[self moveFilesToCloud];
	} else {
		[self copyFilesFromCloud];
	}
}

- (void)moveFilesToCloud {
	[self moveFilesToCloudInDirectory:A3DaysCounterImageDirectory];
	[self moveFilesToCloudInDirectory:A3WalletImageDirectory];
	[self moveFilesToCloudInDirectory:A3WalletVideoDirectory];
}

- (void)moveFilesToCloudInDirectory:(NSString *)directory {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
		NSURL *ubiquityContainerURL = [fileManager URLForUbiquityContainerIdentifier:nil];
		NSURL *directoryURL = [ubiquityContainerURL URLByAppendingPathComponent:directory];
		NSError *error;
		if (![fileManager isUbiquitousItemAtURL:directoryURL]) {
			[fileCoordinator coordinateWritingItemAtURL:directoryURL
												options:NSFileCoordinatorWritingForReplacing
												  error:&error
											 byAccessor:^(NSURL *newURL) {
												 [fileManager createDirectoryAtURL:newURL withIntermediateDirectories:YES attributes:nil error:NULL];
											 }];
		}

		NSArray *files = [fileManager contentsOfDirectoryAtPath:[directory pathInLibraryDirectory] error:NULL];
		FNLOG(@"%@", files);
		for (NSString *filename in files) {
			NSString *filePath = [directory stringByAppendingPathComponent:filename];
			NSURL *localURL = [NSURL fileURLWithPath:[filePath pathInLibraryDirectory] ];
			NSURL *cloudURL = [ubiquityContainerURL URLByAppendingPathComponent:filePath];

			FNLOG(@"%@, %@", localURL, cloudURL);
			[fileManager setUbiquitous:YES
							 itemAtURL:localURL
						destinationURL:cloudURL
								 error:&error];
			if (error) {
				FNLOG(@"%@, %@", error.localizedDescription, error.localizedFailureReason);
			}
		}
	});
}

- (void)copyFilesFromCloud {
	[self copyFilesFromCloudInDirectory:A3DaysCounterImageDirectory];
	[self copyFilesFromCloudInDirectory:A3WalletImageDirectory];
	[self copyFilesFromCloudInDirectory:A3WalletVideoDirectory];
}

- (void)copyFilesFromCloudInDirectory:(NSString *)directory {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		NSURL *ubiquityContainerURL = [fileManager URLForUbiquityContainerIdentifier:nil];

		if (!ubiquityContainerURL || !directory) {
			return;
		}
		NSArray *files = [fileManager contentsOfDirectoryAtURL:[ubiquityContainerURL URLByAppendingPathComponent:directory]
									includingPropertiesForKeys:nil
													   options:0
														 error:NULL];

		for (NSURL *cloudURL in files) {
			NSString *filename = [cloudURL lastPathComponent];

			NSURL *localURL = [NSURL fileURLWithPath:[[directory stringByAppendingPathComponent:filename] pathInLibraryDirectory] ];

			NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
			NSError *error;
			[fileCoordinator coordinateReadingItemAtURL:cloudURL
												options:NSFileCoordinatorReadingWithoutChanges
									   writingItemAtURL:localURL
												options:NSFileCoordinatorWritingForReplacing
												  error:&error
											 byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
												 [fileManager removeItemAtURL:newWritingURL error:NULL];
												 [fileManager copyItemAtURL:newReadingURL toURL:newWritingURL error:NULL];
											 }];
			if (error) {
				FNLOG(@"%@", error.localizedDescription);
			}
		}
	});
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

- (void)startDownloadAllFiles {
	FNLOG();
	[self startDownloadInDirectory:A3DaysCounterImageDirectory];
	[self startDownloadInDirectory:A3WalletImageDirectory];
	[self startDownloadInDirectory:A3WalletVideoDirectory];
}

- (void)startDownloadInDirectory:(NSString *)directory {
	NSFileManager *fileManager = [NSFileManager new];
	NSURL *ubiquityContainerURL = [fileManager URLForUbiquityContainerIdentifier:nil];
	if (!ubiquityContainerURL || !directory) return;

	NSArray *files = [fileManager contentsOfDirectoryAtURL:[ubiquityContainerURL URLByAppendingPathComponent:directory] includingPropertiesForKeys:nil options:0 error:NULL];
	for (NSURL *fileURL in files) {
		[fileManager startDownloadingUbiquitousItemAtURL:fileURL error:NULL];
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
	for (NSURL *fileURL in files) {
		[fileManager removeItemAtURL:fileURL error:NULL];
	}
}

- (BOOL)isLocalLaterForLocal:(NSDate *)local cloud:(NSDate *)cloud {
	if (!cloud) return YES;
	if (!local) return NO;
	return [cloud isEarlierThanDate:local];
}

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
			A3LadyCalendarSetting,
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
			A3LoanCalcUserDefaultCalculationFor,
			A3LoanCalcUserDefaultShowDownPayment,
			A3LoanCalcUserDefaultShowExtraPayment,
			A3LoanCalcUserDefaultShowAdvanced,
			A3LoanCalcUserDefaultUseSimpleInterest,
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
			A3UnitConverterDefaultCurrentUnitTap,
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
