//
//  A3BackupRestoreManager.m
//  AppBox3
//
//  Created by A3 on 6/4/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>
#import "A3BackupRestoreManager.h"
#import "A3AppDelegate.h"
#import "NSString+conversion.h"
#import "DaysCounterEvent.h"
#import "DaysCounterEvent+extension.h"
#import "WalletFieldItem+initialize.h"
#import "AAAZip.h"
#import "HolidayData+Country.h"
#import "A3HolidaysFlickrDownloadManager.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "NSFileManager+A3Addition.h"
#import "A3UserDefaults.h"

NSString *const A3ZipFilename = @"name";
NSString *const A3ZipNewFilename = @"newname";
NSString *const A3BackupFileVersionKey = @"ApplicationVersion";
NSString *const A3BackupFileDateKey = @"BackupDate";
NSString *const A3BackupFileOSVersionKey = @"OSVersion";
NSString *const A3BackupFileSystemModelKey = @"Model";
NSString *const A3BackupFileUserDefaultsKey = @"UserDefaults";
NSString *const A3BackupInfoFilename = @"BackupInfo.plist";

@interface A3BackupRestoreManager () <AAAZipDelegate, DBRestClientDelegate, A3DataMigrationManagerDelegate>

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSNumberFormatter *percentFormatter;
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, copy) NSString *backupFilePath;
@property (nonatomic, copy) NSString *backupCoreDataStorePath;
@property (nonatomic, strong) A3DataMigrationManager *migrationManager;
@property (nonatomic, strong) NSMutableArray *deleteFilesAfterZip;

@end

@implementation A3BackupRestoreManager {
	BOOL _backupToDocumentDirectory;
}

#pragma mark - Backup Data

- (void)backupData {
	_backupToDocumentDirectory = NO;
	[self backupCoreDataStore];
}

- (void)backupToDocumentDirectory {
	_backupToDocumentDirectory = YES;
	[self backupCoreDataStore];
}

- (NSString *)storeFilePath {
	NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
	NSString *path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
	path = [path stringByAppendingPathComponent:bundleName];
	return [path stringByAppendingPathComponent:[[A3AppDelegate instance] storeFileName]];
}

- (void)backupCoreDataStore {
	NSMutableArray *fileList = [NSMutableArray new];
	_deleteFilesAfterZip = [NSMutableArray new];

	_backupCoreDataStorePath = [self storeFilePath];
	NSString *path;
	NSString *filename = [[A3AppDelegate instance] storeFileName];
	[fileList addObject:@{A3ZipFilename : _backupCoreDataStorePath, A3ZipNewFilename : filename}];

	path = [NSString stringWithFormat:@"%@%@", _backupCoreDataStorePath, @"-shm"];
	[fileList addObject:@{A3ZipFilename : path, A3ZipNewFilename : [NSString stringWithFormat:@"%@%@", filename, @"-shm"]}];

	path = [NSString stringWithFormat:@"%@%@", _backupCoreDataStorePath, @"-wal"];
	[fileList addObject:@{A3ZipFilename : path, A3ZipNewFilename : [NSString stringWithFormat:@"%@%@", filename, @"-wal"]}];

	// Backup data files
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[self addToFileList:fileList forDataFilename:A3CurrencyDataEntityFavorites fileManager:fileManager];
	[self addToFileList:fileList forDataFilename:A3DaysCounterDataEntityCalendars fileManager:fileManager];
	[self addToFileList:fileList forDataFilename:A3LadyCalendarDataEntityAccounts fileManager:fileManager];
	[self addToFileList:fileList forDataFilename:A3WalletDataEntityCategoryInfo fileManager:fileManager];
	[self addToFileList:fileList forDataFilename:A3UnitConverterDataEntityUnitCategories fileManager:fileManager];
	[self addToFileList:fileList forDataFilename:A3UnitConverterDataEntityConvertItems fileManager:fileManager];
	[self addToFileList:fileList forDataFilename:A3UnitConverterDataEntityFavorites fileManager:fileManager];
	[self addToFileList:fileList forDataFilename:A3UnitPriceUserDataEntityPriceFavorites fileManager:fileManager];
	[self addToFileList:fileList forDataFilename:A3MainMenuDataEntityRecentlyUsed fileManager:fileManager];
	[self addToFileList:fileList forDataFilename:A3MainMenuDataEntityAllMenu fileManager:fileManager];
	[self addToFileList:fileList forDataFilename:A3MainMenuDataEntityFavorites fileManager:fileManager];

	NSArray *daysCounterEvents = [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"photoID != NULL"]];
	for (DaysCounterEvent *event in daysCounterEvents) {
		[fileList addObject:
			@{
				A3ZipFilename : [[event photoURLInOriginalDirectory:YES] path],
				A3ZipNewFilename : [NSString stringWithFormat:@"%@/%@", A3DaysCounterImageDirectory, event.photoID]
			}];
	}

	NSArray *holidayCountries = [HolidayData userSelectedCountries];
	A3HolidaysFlickrDownloadManager *holidaysFlickrDownloadManager = [A3HolidaysFlickrDownloadManager sharedInstance];
	for (NSString *countryCode in holidayCountries) {
		if ([holidaysFlickrDownloadManager hasUserSuppliedImageForCountry:countryCode]) {
			NSString *holidayBackground = [[A3HolidaysFlickrDownloadManager sharedInstance] holidayImagePathForCountryCode:countryCode];
			if ([holidayBackground length]) {
				[fileList addObject:
						@{
								A3ZipFilename : holidayBackground,
								A3ZipNewFilename : [holidayBackground lastPathComponent]
						}
				];
			}
		}
	}

	NSArray *walletImages = [WalletFieldItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"hasImage == YES"]];
	for (WalletFieldItem *item in walletImages) {
		[fileList addObject:
			@{
				A3ZipFilename : [[item photoImageURLInOriginalDirectory:YES] path],
				A3ZipNewFilename : [NSString stringWithFormat:@"%@/%@", A3WalletImageDirectory, item.uniqueID]
			}];
	}

	NSArray *walletVideos = [WalletFieldItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"hasVideo == YES"]];
	for (WalletFieldItem *video in walletVideos) {
		[fileList addObject:
			@{
				A3ZipFilename : [[video videoFileURLInOriginal:YES] path],
				A3ZipNewFilename : [NSString stringWithFormat:@"%@/%@-video.%@", A3WalletVideoDirectory, video.uniqueID, video.videoExtension]
			}];
	}

	NSDictionary *backupInfoDictionary = @{
			A3BackupFileVersionKey : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
			A3BackupFileDateKey : [NSDate date],
			A3BackupFileOSVersionKey : [[UIDevice currentDevice] systemVersion],
			A3BackupFileSystemModelKey : [A3UIDevice platform],
			A3BackupFileUserDefaultsKey : [self userDefaultsDictionary]
	};

	FNLOG(@"%@", backupInfoDictionary);
	[backupInfoDictionary writeToFile:[A3BackupInfoFilename pathInDocumentDirectory] atomically:YES];
	[fileList addObject:@{
			A3ZipFilename : [A3BackupInfoFilename pathInDocumentDirectory],
			A3ZipNewFilename : A3BackupInfoFilename
	}];
	[_deleteFilesAfterZip addObject:[A3BackupInfoFilename pathInDocumentDirectory]];

	self.HUD.labelText = NSLocalizedString(@"Compressing", @"Compressing");
	self.HUD.progress = 0;
	[_hostingView addSubview:self.HUD];
	[self.HUD show:YES];

	AAAZip *zip = [AAAZip new];
	zip.delegate = self;
	_backupFilePath = [self uniqueBackupFilename];
	[zip createZipFile:_backupFilePath withArray:fileList];
}

- (void)addToFileList:(NSMutableArray *)fileList forDataFilename:(NSString *)filename fileManager:(NSFileManager *)fileManager {
	NSString *filePath = [[fileManager applicationSupportPath] stringByAppendingPathComponent:filename];
	[fileList addObject:@{A3ZipFilename : filePath, A3ZipNewFilename : filename}];
}

- (NSArray *)userDefaultsKeys {
	return @[
			A3SettingsUserDefaultsThemeColorIndex,
			A3SettingsUseKoreanCalendarForLunarConversion,

			A3MainMenuUserDefaultsMaxRecentlyUsed,

			A3LoanCalcUserDefaultShowDownPayment,
			A3LoanCalcUserDefaultShowExtraPayment,
			A3LoanCalcUserDefaultShowAdvanced,
			A3LoanCalcUserDefaultsLoanDataKey,
			A3LoanCalcUserDefaultsLoanDataKey_A,
			A3LoanCalcUserDefaultsLoanDataKey_B,
			A3LoanCalcUserDefaultsCustomCurrencyCode,

			A3ExpenseListUserDefaultsCurrencyCode,
			A3ExpenseListIsAddBudgetCanceledByUser,
			A3ExpenseListIsAddBudgetInitiatedOnce,

			A3CurrencyUserDefaultsAutoUpdate,
			A3CurrencyUserDefaultsUseCellularData,
			A3CurrencyUserDefaultsShowNationalFlag,
			A3CurrencyUserDefaultsLastInputValue,

			A3LunarConverterLastInputDateComponents,
			A3LunarConverterLastInputDateIsLunar,

			A3BatteryChosenThemeIndex,
			A3BatteryChosenTheme,
			A3BatteryAdjustedIndex,
			A3BatteryShowIndex,

			A3CalculatorUserDefaultsSavedLastExpression,
			A3CalculatorUserDefaultsRadianDegreeState,
			A3CalculatorUserDefaultsCalculatorMode,

			A3ClockTheTimeWithSeconds,
			A3ClockFlashTheTimeSeparators,
			A3ClockUse24hourClock,
			A3ClockShowAMPM,
			A3ClockShowTheDayOfTheWeek,
			A3ClockShowDate,
			A3ClockShowWeather,
			A3ClockUsesFahrenheit,
			A3ClockWaveClockColor,
			A3ClockWaveClockColorIndex,
			A3ClockWaveCircleLayout,
			A3ClockFlipDarkColor,
			A3ClockFlipDarkColorIndex,
			A3ClockFlipLightColor,
			A3ClockFlipLightColorIndex,
			A3ClockLEDColor,
			A3ClockLEDColorIndex,
			A3ClockUserDefaultsCurrentPage,

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

			A3DaysCounterUserDefaultsSlideShowOptions,
			A3DaysCounterLastOpenedMainIndex,

			A3LadyCalendarCurrentAccountID,
			A3LadyCalendarUserDefaultsSettings,
			A3LadyCalendarLastViewMonth,

			A3PercentCalcUserDefaultsCalculationType,
			A3PercentCalcUserDefaultsSavedInputData,

			A3SalesCalcUserDefaultsSavedInputDataKey,
			A3SalesCalcUserDefaultsCurrencyCode,

			A3TipCalcUserDefaultsCurrencyCode,

			A3UnitConverterDefaultSelectedCategoryID,
			A3UnitConverterTableViewUnitValueKey,

			A3UnitPriceUserDefaultsCurrencyCode,

			kHolidayCountriesForCurrentDevice,
			kHolidayCountryExcludedHolidays,
			kHolidayCountriesShowLunarDates,

			A3WalletUserDefaultsSelectedTab,
	];
}

- (NSDictionary *)userDefaultsDictionary {
	NSArray *defaultKeys = [self userDefaultsKeys];
	A3UserDefaults *userDefaults = [A3UserDefaults standardUserDefaults];
	NSMutableDictionary *keysAndValues = [NSMutableDictionary new];
	for (NSString *key in defaultKeys) {
		[self addKey:key ifHasValueTo:keysAndValues];
	}
	A3HolidaysFlickrDownloadManager *downloadManager = [A3HolidaysFlickrDownloadManager sharedInstance];
	for (NSString *countryCode in [userDefaults objectForKey:kHolidayCountriesForCurrentDevice]) {
		[self addKey:[downloadManager imageNameKeyForCountryCode:countryCode] ifHasValueTo:keysAndValues];
		[self addKey:[downloadManager ownerKeyForCountryCode:countryCode] ifHasValueTo:keysAndValues];
		[self addKey:[downloadManager urlKeyForCountryCode:countryCode] ifHasValueTo:keysAndValues];
		[self addKey:[downloadManager dateKeyForCountryCode:countryCode] ifHasValueTo:keysAndValues];
	}
	return keysAndValues;
}

- (void)addKey:(NSString *)key ifHasValueTo:(NSMutableDictionary *)target {
	id object = [[A3UserDefaults standardUserDefaults] objectForKey:key];
	if (object) {
		[target setObject:object forKey:key];
	}
}

- (MBProgressHUD *)HUD {
	if (!_HUD) {
		_HUD = [[MBProgressHUD alloc] initWithView:_hostingView];
		_HUD.mode = MBProgressHUDModeDeterminate;
		_HUD.removeFromSuperViewOnHide = YES;
	}
	return _HUD;
}

- (void)compressProgress:(float)currentByte total:(float)totalByte {
	_HUD.progress = (float) MIN(currentByte / totalByte, 1.0);
	_HUD.detailsLabelText = [self.percentFormatter stringFromNumber:@(_HUD.progress)];
}

- (void)decompressProgress:(float)currentByte total:(float)totalByte {
	_HUD.progress = currentByte / totalByte;
	_HUD.detailsLabelText = [self.percentFormatter stringFromNumber:@(_HUD.progress)];
}

- (void)completedZipProcess:(BOOL)bResult {
	if (_backupToDocumentDirectory) {
		[_HUD hide:YES];

		if ([_delegate respondsToSelector:@selector(backupRestoreManager:backupCompleteWithSuccess:)]) {
			[_delegate backupRestoreManager:self backupCompleteWithSuccess:YES];
		}

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
														message:NSLocalizedString(@"Backup file is ready.", nil)
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
		[alert show];
	} else {
		_HUD.labelText = NSLocalizedString(@"Uploading", @"Uploading");
		_HUD.detailsLabelText = @"";

		[self.restClient uploadFile:[_backupFilePath lastPathComponent] toPath:kDropboxDir withParentRev:nil fromPath:_backupFilePath];
	}
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	for (NSString *path in _deleteFilesAfterZip) {
		[fileManager removeItemAtPath:path error:NULL];
	}
	_deleteFilesAfterZip = nil;
}

- (NSString *)uniqueBackupFilename {
	NSDate *date = [NSDate date];
	NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	NSString *seedFilename = [NSString stringWithFormat:@"AppBoxBackup-%0ld-%02ld-%02ld-%02ld-%02ld", (long) components.year, (long) components.month, (long) components.day, (long) components.hour, (long) components.minute];
	NSString *filename = seedFilename;
	NSString *path = [[filename stringByAppendingPathExtension:@"backup"] pathInDocumentDirectory];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSInteger option = 1;
	while ([fileManager fileExistsAtPath:path]) {
		filename = [seedFilename stringByAppendingFormat:@"-%ld", (long)option++];
		path = [[filename stringByAppendingPathExtension:@"backup"] pathInDocumentDirectory];
	}
	return path;
}

- (NSNumberFormatter *)percentFormatter {
	if (!_percentFormatter) {
		_percentFormatter = [[NSNumberFormatter alloc] init];
		[_percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
	}
	return _percentFormatter;
}

#pragma mark - Dropbox Rest Client & Delegate

- (DBRestClient *)restClient {
	if (!_restClient) {
		_restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;
	}
	return _restClient;
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
	[_HUD hide:YES];
	_HUD = nil;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
													message:NSLocalizedString(@"Backup file has been uploaded to Dropbox successfully.", @"Backup file has been uploaded to Dropbox successfully.")
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
										  otherButtonTitles:nil];
	[alert show];

	[self deleteBackupFile];
}

- (void)restClient:(DBRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath {
	_HUD.progress = progress;
	_HUD.detailsLabelText = [self.percentFormatter stringFromNumber:@(progress)];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
	[_HUD hide:YES];
	_HUD = nil;

	UIAlertView *alertFail = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"Backup process failed to upload backup file to Dropbox.", @"Backup process failed to upload backup file to Dropbox.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertFail show];

	[self deleteBackupFile];
}

- (void)deleteBackupFile {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:_backupFilePath error:NULL];
}

#pragma mark - Restore data

- (void)restoreDataAt:(NSString *)backupFilePath toURL:(NSURL *)toURL {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	[MagicalRecord cleanUp];

	[self deleteCoreDataStoreFilesAt:toURL];
	[self removeMediaFiles];

	NSString *backupInfoFilePath = [backupFilePath stringByAppendingPathComponent:A3BackupInfoFilename];
	if ([fileManager fileExistsAtPath:backupInfoFilePath]) {
		// Backup file is made with Version 3.0 or above
		NSURL *sourceBaseURL = [NSURL fileURLWithPath:backupFilePath];
		NSURL *targetBaseURL = [toURL URLByDeletingLastPathComponent];

		NSString *filename = [[A3AppDelegate instance] storeFileName];
		[self moveComponent:filename fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:[NSString stringWithFormat:@"%@%@", filename, @"-wal"] fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:[NSString stringWithFormat:@"%@%@", filename, @"-shm"] fromURL:sourceBaseURL toURL:targetBaseURL];

		[self moveComponent:A3CurrencyDataEntityFavorites fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:A3DaysCounterDataEntityCalendars fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:A3LadyCalendarDataEntityAccounts fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:A3WalletDataEntityCategoryInfo fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:A3MainMenuDataEntityRecentlyUsed fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:A3MainMenuDataEntityFavorites fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:A3MainMenuDataEntityAllMenu fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:A3UnitConverterDataEntityUnitCategories fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:A3UnitConverterDataEntityConvertItems fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:A3UnitConverterDataEntityFavorites fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:A3UnitPriceUserDataEntityPriceFavorites fromURL:sourceBaseURL toURL:targetBaseURL];

		targetBaseURL = [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0]];

		[fileManager createDirectoryAtURL:[targetBaseURL URLByAppendingPathComponent:A3DaysCounterImageDirectory] withIntermediateDirectories:YES attributes:nil error:NULL];
		[fileManager createDirectoryAtURL:[targetBaseURL URLByAppendingPathComponent:A3WalletImageDirectory] withIntermediateDirectories:YES attributes:nil error:NULL];
		[fileManager createDirectoryAtURL:[targetBaseURL URLByAppendingPathComponent:A3WalletVideoDirectory] withIntermediateDirectories:YES attributes:nil error:NULL];

		[self moveFilesFromURL:[sourceBaseURL URLByAppendingPathComponent:A3DaysCounterImageDirectory]
						 toURL:[targetBaseURL URLByAppendingPathComponent:A3DaysCounterImageDirectory]];
		[self moveFilesFromURL:[sourceBaseURL URLByAppendingPathComponent:A3WalletImageDirectory]
						 toURL:[targetBaseURL URLByAppendingPathComponent:A3WalletImageDirectory]];
		[self moveFilesFromURL:[sourceBaseURL URLByAppendingPathComponent:A3WalletVideoDirectory]
						 toURL:[targetBaseURL URLByAppendingPathComponent:A3WalletVideoDirectory]];

		NSDictionary *backupInfo = [[NSDictionary alloc] initWithContentsOfFile:backupInfoFilePath];
		NSDictionary *userDefaults = backupInfo[A3BackupFileUserDefaultsKey];
		A3UserDefaults *standardUserDefaults = [A3UserDefaults standardUserDefaults];
		for (NSString *key in [self userDefaultsKeys]) {
			id object = [userDefaults objectForKey:key];
			if (object) {
				[standardUserDefaults setObject:object forKey:key];
			} else {
				[standardUserDefaults removeObjectForKey:key];
			}
		}
		[standardUserDefaults removeObjectForKey:A3SyncManagerCloudEnabled];
		[standardUserDefaults synchronize];

		NSNumber *selectedColor = [[A3SyncManager sharedSyncManager] objectForKey:A3SettingsUserDefaultsThemeColorIndex];
		if (selectedColor) {
			[A3AppDelegate instance].window.tintColor = [[A3AppDelegate instance] themeColor];
		}
		[fileManager removeItemAtPath:backupInfoFilePath error:NULL];
		[self moveFilesFromURL:sourceBaseURL toURL:targetBaseURL];

		[[A3AppDelegate instance] setupContext];

		if ([_delegate respondsToSelector:@selector(backupRestoreManager:restoreCompleteWithSuccess:)]) {
			[_delegate backupRestoreManager:self restoreCompleteWithSuccess:YES];
		}
	} else {
		[self extractV1DataFilesAt:backupFilePath];

		[[A3AppDelegate instance] setupContext];

		A3DataMigrationManager *migrationManager = [[A3DataMigrationManager alloc] init];
		migrationManager.migrationDirectory = backupFilePath;
		migrationManager.canCancelInEncryptionKeyView = YES;
		migrationManager.hostingViewController = self.hostingViewController;
		if ([migrationManager walletDataFileExists] && ![migrationManager walletDataWithPassword:nil]) {
			migrationManager.delegate = self;
			self.migrationManager = migrationManager;
			[self.migrationManager askWalletPassword];
		} else {
			[migrationManager migrateV1DataWithPassword:nil];
			if ([_delegate respondsToSelector:@selector(backupRestoreManager:restoreCompleteWithSuccess:)]) {
				[_delegate backupRestoreManager:self restoreCompleteWithSuccess:YES];
			}
		}
	}
}

/*! toURL 에 있는 파일을 지우고, 원본이 있으면 옮긴다.
 *  원본이 없더라도 대상 파일은 지워진다. 만약 원본이 없다면 대상도 없어야 하기 때문임
 *  복원을 목적으로 만들어진 것이므로 기타 용도로는 사용하면 안됨
 * \param
 * \returns
 */
- (void)moveComponent:(NSString *)component fromURL:(NSURL *)fromURL toURL:(NSURL *)toURL {
	NSURL *sourceURL = [fromURL URLByAppendingPathComponent:component];
	NSURL *targetURL = [toURL URLByAppendingPathComponent:component];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:[targetURL path]]) {
		[fileManager removeItemAtURL:targetURL error:NULL];
	}
	if (![fileManager fileExistsAtPath:[sourceURL path]]) {
		return;
	}
	[fileManager moveItemAtURL:[fromURL URLByAppendingPathComponent:component]
											toURL:targetURL
											error:NULL];
}

- (void)moveFilesFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *files = [fileManager contentsOfDirectoryAtPath:[fromURL path] error:NULL];
	for (NSString *filename in files) {
		[fileManager moveItemAtURL:[fromURL URLByAppendingPathComponent:filename]
							 toURL:[toURL URLByAppendingPathComponent:filename]
							 error:NULL];
	}
}

- (void)migrationManager:(A3DataMigrationManager *)manager didFinishMigration:(BOOL)success {
	self.migrationManager = nil;
	if ([_delegate respondsToSelector:@selector(backupRestoreManager:restoreCompleteWithSuccess:)]) {
		[_delegate backupRestoreManager:self restoreCompleteWithSuccess:YES];
	}
}

- (void)deleteCoreDataStoreFilesAt:(NSURL *)targetURL {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	// Delete existing Core Data Store
	NSString *storeFilename = [targetURL lastPathComponent];
	NSURL *baseURL = [targetURL URLByDeletingLastPathComponent];

	[fileManager removeItemAtURL:targetURL error:NULL];

	NSURL *walFileURL = [baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", storeFilename, @"-wal"]];
	[fileManager removeItemAtURL:walFileURL error:NULL];

	NSURL *shmFileURL = [baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", storeFilename, @"-shm"]];
	[fileManager removeItemAtURL:shmFileURL error:NULL];
}

- (void)removeMediaFiles {
	[self removeFilesAtDirectory:[A3DaysCounterImageDirectory pathInLibraryDirectory]];
	[self removeFilesAtDirectory:[A3DaysCounterImageThumbnailDirectory pathInLibraryDirectory]];
	[self removeFilesAtDirectory:[A3WalletImageDirectory pathInLibraryDirectory]];
	[self removeFilesAtDirectory:[A3WalletImageThumbnailDirectory pathInLibraryDirectory]];
	[self removeFilesAtDirectory:[A3WalletVideoDirectory pathInLibraryDirectory]];
	[self removeFilesAtDirectory:[A3WalletVideoThumbnailDirectory pathInLibraryDirectory]];
}

- (void)removeFilesAtDirectory:(NSString *)path {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *filesInDirectory = [fileManager contentsOfDirectoryAtPath:path error:NULL];
	for (NSString *filename in filesInDirectory) {
		[fileManager removeItemAtPath:[path stringByAppendingPathComponent:filename] error:NULL];
	}
}

NSString *const A3V1BackupDataFilename = @"fulldb";
NSString *const kBackupDataKeyDaysUntilList						= @"kBackupDataKeyDaysUntilList";
NSString *const kBackupDataKeyPCalendarDictionary				= @"kBackupDataKeyPCalendarDictionary";
NSString *const kBackupDataKeyTranslatorList					= @"kBackupDataKeyTranslatorList";
NSString *const kBackupDataKeyWalletList						= @"kBackupDataKeyWalletList";

extern NSString *const V1DaysUntilDataFilename;
extern NSString *const V1PCalendarDataFilename;
extern NSString *const V1TranslatorFavoritesFilename;
extern NSString *const V1WalletDataFilename;

- (void)extractV1DataFilesAt:(NSString *)path {
	NSString *fullDBPath = [path stringByAppendingPathComponent:A3V1BackupDataFilename];
	NSDictionary *fullDictionary = [[NSDictionary alloc] initWithContentsOfFile:fullDBPath];

	NSArray *daysUntilData = fullDictionary[kBackupDataKeyDaysUntilList];
	[daysUntilData writeToFile:[path stringByAppendingPathComponent:V1DaysUntilDataFilename] atomically:YES];

	NSDictionary *pCalendarData = fullDictionary[kBackupDataKeyPCalendarDictionary];
	[pCalendarData writeToFile:[path stringByAppendingPathComponent:V1PCalendarDataFilename] atomically:YES];

	NSData *translatorData = fullDictionary[kBackupDataKeyTranslatorList];
	[translatorData writeToFile:[path stringByAppendingPathComponent:V1TranslatorFavoritesFilename] atomically:YES];

	NSData *walletData = fullDictionary[kBackupDataKeyWalletList];
	[walletData writeToFile:[path stringByAppendingPathComponent:V1WalletDataFilename] atomically:YES];
}

@end
