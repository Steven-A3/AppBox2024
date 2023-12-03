//
//  A3BackupRestoreManager.m
//  AppBox3
//
//  Created by A3 on 6/4/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

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
#import "TJDropbox.h"
#import "ACSimpleKeychain.h"
#import "WalletField.h"
#import "WalletItem.h"
#import "WalletCategory.h"
#import "UIViewController+A3Addition.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3UserDefaults+A3Addition.h"

NSString *const A3ZipFilename = @"name";
NSString *const A3ZipNewFilename = @"newname";
NSString *const A3BackupFileVersionKey = @"ApplicationVersion";
NSString *const A3BackupFileDateKey = @"BackupDate";
NSString *const A3BackupFileOSVersionKey = @"OSVersion";
NSString *const A3BackupFileSystemModelKey = @"Model";
/**
 *  UserDefaultsKey는 A3UserDefaults로 저장되는 내역을 백업합니다.
 *  A3UserDefaults에 저장되는 내용은 iCloud를 사용하는 경우, 
 *  동기화에 적용이 됩니다.
 *  Device 동기화를 지원하지 않는 설정의 경우에는 NSUserDefaults에 저장되는데,
 *  이는 A3BackupFileDeviceUserDefaultsKey로 저장합니다.
 */
NSString *const A3BackupFileUserDefaultsKey = @"UserDefaults";
/**
 *  NSUserDefaults에 저장하는 값 중에서 백업이 필요한 Data를 보관하는 키 입니다.
 */
NSString *const A3BackupFileDeviceUserDefaultsKey = @"DeviceUserDefaults";
NSString *const A3BackupInfoFilename = @"BackupInfo.plist";

@interface A3BackupRestoreManager () <AAAZipDelegate, A3DataMigrationManagerDelegate, UIDocumentPickerDelegate>

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSNumberFormatter *percentFormatter;
@property (nonatomic, copy) NSString *backupFilePath;
@property (nonatomic, copy) NSURL *backupFileURL;
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
    NSFileManager *fileManager = [NSFileManager defaultManager];
	return [path stringByAppendingPathComponent:[fileManager storeFileName]];
}

- (void)addDaysCounterPhotosWith:(NSFileManager *)fileManager fileList:(NSMutableArray *)fileList forBackup:(BOOL)forBackup {
    NSArray *daysCounterEvents = [DaysCounterEvent findAllWithPredicate:[NSPredicate predicateWithFormat:@"photoID != NULL"]];
    [daysCounterEvents enumerateObjectsUsingBlock:^(DaysCounterEvent * _Nonnull event, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *photoPath = [[event photoURLInOriginalDirectory:YES] path];
        if (![fileManager fileExistsAtPath:photoPath]) return;
        NSString *filename = forBackup ?
        [NSString stringWithFormat:@"%@/%@", A3DaysCounterImageDirectory, event.photoID]
        : [NSString stringWithFormat:@"%@/DaysCounterPhoto-%ld.jpg", A3DaysCounterImageDirectory, (long)idx + 1]
        ;
        [fileList addObject:
         @{
           A3ZipFilename : photoPath,
           A3ZipNewFilename : filename
           }];
    }];
}

- (void)addWalletPhotosVideosWith:(NSFileManager *)fileManager fileList:(NSMutableArray *)fileList forBackup:(BOOL)forBackup {
    NSArray *walletImages = [WalletFieldItem findAllWithPredicate:[NSPredicate predicateWithFormat:@"hasImage == YES"]];
    [walletImages enumerateObjectsUsingBlock:^(WalletFieldItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *photoPath = [[item photoImageURLInOriginalDirectory:YES] path];
        if (![fileManager fileExistsAtPath:photoPath]) return;
        NSString *filename = forBackup ?
            [NSString stringWithFormat:@"%@/%@", A3WalletImageDirectory, item.uniqueID] :
            [NSString stringWithFormat:@"%@/WalletPhoto-%ld.jpg", A3WalletImageDirectory, (long)idx + 1];
        [fileList addObject:
         @{
           A3ZipFilename : photoPath,
           A3ZipNewFilename : filename
           }];
    }];

    NSArray *walletVideos = [WalletFieldItem findAllWithPredicate:[NSPredicate predicateWithFormat:@"hasVideo == YES"]];
    [walletVideos enumerateObjectsUsingBlock:^(WalletFieldItem * _Nonnull video, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *items = [WalletItem findByAttribute:@"uniqueID" withValue:video.walletItemID];
        if ([items count] == 0) return;
        
        NSString *videoFilePath = [[video videoFileURLInOriginal:YES] path];
        if (![fileManager fileExistsAtPath:videoFilePath]) return;
        NSString *filename = forBackup ?
            [NSString stringWithFormat:@"%@/%@-video.%@", A3WalletVideoDirectory, video.uniqueID, video.videoExtension] :
            [NSString stringWithFormat:@"%@/WalletVideo-%ld.%@", A3WalletVideoDirectory, (long)idx + 1, video.videoExtension];
        [fileList addObject:
         @{
           A3ZipFilename : videoFilePath,
           A3ZipNewFilename : filename
           }];
    }];
}

- (void)exportPhotosVideos {
    // 압축이 완료되면 UIActivityViewController를 통해 압축 파일을 전달한다.
    _backupToDocumentDirectory = YES;
    
    NSMutableArray *fileList = [NSMutableArray new];
    _deleteFilesAfterZip = [NSMutableArray new];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    [self addDaysCounterPhotosWith:fileManager fileList:fileList forBackup:NO];
    [self addWalletPhotosVideosWith:fileManager fileList:fileList forBackup:NO];

    self.HUD.label.text = NSLocalizedString(@"Compressing", @"Compressing");
    self.HUD.progress = 0;
    [_hostingView addSubview:self.HUD];
    [self.HUD showAnimated:YES];
    
    AAAZip *zip = [AAAZip new];
    zip.delegate = self;
    zip.encryptZip = NO;
    _backupFilePath = [self uniqueBackupFilenameWithPostfix:@"PhotosVideos" extension:@"zip"];
    [zip createZipFile:_backupFilePath withArray:fileList];
}

- (void)removeFileIfexists:(NSFileManager *)fileManager tempCoreDataPath:(NSString *)tempCoreDataPath {
    if ([fileManager fileExistsAtPath:tempCoreDataPath]) {
        [fileManager removeItemAtPath:tempCoreDataPath error:NULL];
    }
}

- (void)removeExistingTempFile:(NSFileManager *)fileManager path:(NSString *)tempCoreDataPath {
    [self removeFileIfexists:fileManager tempCoreDataPath:tempCoreDataPath];
    [self removeFileIfexists:fileManager tempCoreDataPath:[NSString stringWithFormat:@"%@%@", tempCoreDataPath, @"-shm"]];
    [self removeFileIfexists:fileManager tempCoreDataPath:[NSString stringWithFormat:@"%@%@", tempCoreDataPath, @"-wal"]];
}

- (NSString *)migrateCoreDataStoreToTemp {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *tempCoreDataPath = [[fileManager storeFileName] pathInTemporaryDirectory];
    // Temporary directory
    [self removeExistingTempFile:fileManager path:tempCoreDataPath];
    
    NSPersistentContainer *persistentContainer = A3SyncManager.sharedSyncManager.persistentContainer;
    for (NSPersistentStoreDescription *description in persistentContainer.persistentStoreDescriptions) {
        if ([description.type isEqualToString:NSInMemoryStoreType]) {
            continue;
        }
        if (nil == description.URL) {
            continue;
        }
        NSPersistentStoreCoordinator *tempPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:persistentContainer.managedObjectModel];
        NSURL *destinationURL = [NSURL fileURLWithPath:tempCoreDataPath];
        NSError *addStoreError = nil;
        NSPersistentStore *newStore = [tempPSC addPersistentStoreWithType:description.type configuration:description.configuration URL:description.URL options:description.options error:&addStoreError];
        NSError *migrateError = nil;
        [tempPSC migratePersistentStore:newStore toURL:destinationURL options:description.options withType:description.type error:&migrateError];
        if (migrateError) {
            FNLOG(@"%@", migrateError);
        }
    }
    
    return tempCoreDataPath;
}

- (void)backupCoreDataStore {
    [A3SyncManager.sharedSyncManager.persistentContainer.viewContext reset];

    _backupCoreDataStorePath = [self migrateCoreDataStoreToTemp];

    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSMutableArray *fileList = [NSMutableArray new];
	_deleteFilesAfterZip = [NSMutableArray new];

	NSString *path;
	NSString *filename = [fileManager storeFileName];

	if ([fileManager isDeletableFileAtPath:_backupCoreDataStorePath]) {
		[fileList addObject:@{A3ZipFilename : _backupCoreDataStorePath, A3ZipNewFilename : filename}];
	}

	path = [NSString stringWithFormat:@"%@%@", _backupCoreDataStorePath, @"-shm"];
	if ([fileManager fileExistsAtPath:path]) {
		[fileList addObject:@{A3ZipFilename : path, A3ZipNewFilename : [NSString stringWithFormat:@"%@%@", filename, @"-shm"]}];
	}

	path = [NSString stringWithFormat:@"%@%@", _backupCoreDataStorePath, @"-wal"];
	if ([fileManager fileExistsAtPath:path]) {
		[fileList addObject:@{A3ZipFilename : path, A3ZipNewFilename : [NSString stringWithFormat:@"%@%@", filename, @"-wal"]}];
	}

	// Backup data files
    [self addDaysCounterPhotosWith:fileManager fileList:fileList forBackup:YES];
    
	NSArray *holidayCountries = [HolidayData userSelectedCountries];
	A3HolidaysFlickrDownloadManager *holidaysFlickrDownloadManager = [A3HolidaysFlickrDownloadManager sharedInstance];
	for (NSString *countryCode in holidayCountries) {
		if ([holidaysFlickrDownloadManager hasUserSuppliedImageForCountry:countryCode]) {
			NSString *holidayBackground = [[A3HolidaysFlickrDownloadManager sharedInstance] holidayImagePathForCountryCode:countryCode];
			if ([holidayBackground length]) {
				if (![fileManager fileExistsAtPath:holidayBackground]) continue;
				[fileList addObject:
						@{
							A3ZipFilename : holidayBackground,
							A3ZipNewFilename : [holidayBackground lastPathComponent]
						}
				];
			}
		}
	}

    [self addWalletPhotosVideosWith:fileManager fileList:fileList forBackup:YES];

	NSDictionary *backupInfoDictionary = @{
			A3BackupFileVersionKey : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
			A3BackupFileDateKey : [NSDate date],
			A3BackupFileOSVersionKey : [[UIDevice currentDevice] systemVersion],
			A3BackupFileSystemModelKey : [A3UIDevice platform],
			A3BackupFileUserDefaultsKey : [self userDefaultsDictionary],
			A3BackupFileDeviceUserDefaultsKey : [self deviceUserDefaultsDictionary],
	};

	FNLOG(@"%@", backupInfoDictionary);
	[backupInfoDictionary writeToFile:[A3BackupInfoFilename pathInDocumentDirectory] atomically:YES];
	[fileList addObject:@{
			A3ZipFilename : [A3BackupInfoFilename pathInDocumentDirectory],
			A3ZipNewFilename : A3BackupInfoFilename
	}];
	[_deleteFilesAfterZip addObject:[A3BackupInfoFilename pathInDocumentDirectory]];

	self.HUD.label.text = NSLocalizedString(@"Compressing", @"Compressing");
	self.HUD.progress = 0;
	[_hostingView addSubview:self.HUD];
	[self.HUD showAnimated:YES];

	AAAZip *zip = [AAAZip new];
	zip.delegate = self;
    _backupFilePath = [self uniqueBackupFilenameWithPostfix:nil extension:nil];
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

- (NSDictionary *)deviceUserDefaultsDictionary {
	NSMutableDictionary *dictionary = [NSMutableDictionary new];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray *targetKeyArray = @[A3MainMenuHexagonMenuItems, A3MainMenuGridMenuItems];
	for (NSString *key in targetKeyArray) {
		id value = [userDefaults objectForKey:key];
		if (value) {
			[dictionary setObject:value forKey:key];
		}
	}
	return dictionary;
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
	_HUD.progress = currentByte / totalByte;
	_HUD.detailsLabel.text = [self.percentFormatter stringFromNumber:@(_HUD.progress)];
}

- (void)decompressProgress:(float)currentByte total:(float)totalByte {
	_HUD.progress = currentByte / totalByte;
	_HUD.detailsLabel.text = [self.percentFormatter stringFromNumber:@(_HUD.progress)];
}

- (void)completedZipProcess:(BOOL)bResult {
	if (_backupToDocumentDirectory) {
		[_HUD hideAnimated:YES];

		if ([_delegate respondsToSelector:@selector(backupRestoreManager:backupCompleteWithSuccess:)]) {
			[_delegate backupRestoreManager:self backupCompleteWithSuccess:YES];
		}

        if (@available(iOS 14.0, *)) {
            self.backupFileURL = [NSURL fileURLWithPath:self.backupFilePath];
            
            UIDocumentPickerViewController *documentPickerViewController = [[UIDocumentPickerViewController alloc] initForExportingURLs:@[self.backupFileURL] asCopy:YES];
            documentPickerViewController.delegate = self;
            [self.hostingViewController presentViewController:documentPickerViewController animated:YES completion:NULL];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                            message:NSLocalizedString(@"Backup file is ready.", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
        }
	} else {
		_HUD.label.text = NSLocalizedString(@"Uploading", @"Uploading");
		_HUD.detailsLabel.text = @"";

		ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
		NSDictionary *dropboxLinkInfo = [keychain credentialsForUsername:@"dropboxUser" service:@"Dropbox"];
		if (dropboxLinkInfo) {
			NSString *accessToken = [dropboxLinkInfo valueForKey:ACKeychainPassword];
			
            NSFileManager *fileManager = [NSFileManager defaultManager];
            unsigned long long filesize = [[fileManager attributesOfItemAtPath:_backupFilePath error:nil] fileSize];
            
            __weak __typeof__(self) weakSelf = self;
            void (^progressBlock)(CGFloat) = ^(CGFloat progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    FNLOG(@"%f", progress);
                    __typeof__(self) strongSelf = weakSelf;
                    strongSelf.HUD.progress = progress;
                    strongSelf.HUD.detailsLabel.text = [strongSelf.percentFormatter stringFromNumber:@(progress)];
                });
            };
            __weak __typeof__(self) weakSelfCompletion = self;
            void (^completionBlock)(NSDictionary * _Nullable parsedResponse, NSError * _Nullable error) = ^(NSDictionary * _Nullable parsedResponse, NSError * _Nullable error) {
                FNLOG(@"%@", parsedResponse);
                FNLOG(@"%@", error);
                FNLOG(@"%@", error.description);
                FNLOG(@"%@", error.debugDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    __typeof__(self) strongSelf = weakSelfCompletion;
                    if (error == nil) {
                        [strongSelf.HUD hideAnimated:YES];
                        strongSelf.HUD = nil;
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                                        message:NSLocalizedString(@"Backup file has been uploaded to Dropbox successfully.", @"Backup file has been uploaded to Dropbox successfully.")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                              otherButtonTitles:nil];
                        [alert show];
                        
                        [strongSelf deleteBackupFile];
                        
                        if ([strongSelf.delegate respondsToSelector:@selector(backupRestoreManager:backupCompleteWithSuccess:)]) {
                            [strongSelf.delegate backupRestoreManager:strongSelf backupCompleteWithSuccess:YES];
                        }
                    } else {
                        [strongSelf.HUD hideAnimated:YES];
                        strongSelf.HUD = nil;
                        
                        UIAlertView *alertFail = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"Backup process failed to upload backup file to Dropbox.", @"Backup process failed to upload backup file to Dropbox.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertFail show];
                        
                        [strongSelf deleteBackupFile];
                        FNLOG(@"%@", error.description);
                    }
                });
            };
            
            NSString *toPath = [NSString stringWithFormat:@"%@/%@", kDropboxDir, [_backupFilePath lastPathComponent]];
            if (filesize > 1500000) {
                [TJDropbox uploadLargeFileAtPath:_backupFilePath
                                          toPath:toPath
                               overwriteExisting:NO
                        muteDesktopNotifications:YES
                                     accessToken:accessToken
                                   progressBlock:progressBlock
                                      completion:completionBlock];
            } else {
                [TJDropbox uploadFileAtPath:_backupFilePath
                                     toPath:toPath
                          overwriteExisting:NO
                   muteDesktopNotifications:YES
                                accessToken:accessToken
                              progressBlock:progressBlock
                                 completion:completionBlock];
            }
		}
	}
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	for (NSString *path in _deleteFilesAfterZip) {
		[fileManager removeItemAtPath:path error:NULL];
	}
	_deleteFilesAfterZip = nil;
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [self deleteBackupFile];
    [_hostingViewController presentAlertWithTitle:NSLocalizedString(@"Info", @"Info")
                                          message:NSLocalizedString(@"The backup process has been canceled.", @"")];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    [self deleteBackupFile];
    
    [_hostingViewController presentAlertWithTitle:NSLocalizedString(@"Info", @"Info")
                                          message:NSLocalizedString(@"The backup file has been stored successfully.", @"")];
}

- (NSString *)uniqueBackupFilenameWithPostfix:(NSString *)postfix extension:(NSString *)extension {
	NSDate *date = [NSDate date];
	NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSString *seedFilename = [NSString stringWithFormat:@"BK%0ld-%02ld-%02ld-%02ld-%02ld-%@", (long) components.year, (long) components.month, (long) components.day, (long) components.hour, (long) components.minute, postfix ?: @"AppBoxBackup"];
	NSString *filename = seedFilename;
    NSString *path = [[filename stringByAppendingPathExtension:extension ?:@"backup"] pathInDocumentDirectory];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSInteger option = 1;
	while ([fileManager fileExistsAtPath:path]) {
		filename = [seedFilename stringByAppendingFormat:@"-%ld", (long)option++];
        path = [[filename stringByAppendingPathExtension:extension ?: @"backup"] pathInDocumentDirectory];
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

- (void)deleteBackupFile {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:_backupFilePath error:NULL];
}

#pragma mark - Restore data

- (void)restoreDataAt:(NSString *)backupFilePath toURL:(NSURL *)toURL {
	NSFileManager *fileManager = [NSFileManager defaultManager];

    NSPersistentContainer *persistentContainer = A3SyncManager.sharedSyncManager.persistentContainer;
    NSManagedObjectContext *context = persistentContainer.viewContext;
    [context reset];
    
    NSError *error = nil;
    NSPersistentStoreCoordinator *psc = persistentContainer.persistentStoreCoordinator;
	for (NSPersistentStore *store in [psc persistentStores]) {
		BOOL removed = [psc removePersistentStore:store error:&error];
		
		if (!removed) {
			NSLog(@"Couldn't remove persistent store: %@", error);
		}
        NSError *destroyError = nil;
        [psc destroyPersistentStoreAtURL:store.URL
                                withType:store.type
                                 options:store.options
                                   error:&destroyError];
        if (destroyError) {
            FNLOG(@"%@", destroyError);
        }
	}
    
    A3SyncManager.sharedSyncManager.persistentContainer = nil;

	[self deleteCoreDataStoreFilesAt:toURL];
	[self removeMediaFiles];

	NSString *backupInfoFilePath = [backupFilePath stringByAppendingPathComponent:A3BackupInfoFilename];
	if ([fileManager fileExistsAtPath:backupInfoFilePath]) {
		// Backup file is made with Version 3.0 or above
		NSURL *sourceBaseURL = [NSURL fileURLWithPath:backupFilePath];
		NSURL *targetBaseURL = [toURL URLByDeletingLastPathComponent];

		NSString *filename = [fileManager storeFileName];
		[self moveComponent:filename fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:[NSString stringWithFormat:@"%@%@", filename, @"-wal"] fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:[NSString stringWithFormat:@"%@%@", filename, @"-shm"] fromURL:sourceBaseURL toURL:targetBaseURL];

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

		NSDictionary *deviceUserDefaultsBackup = backupInfo[A3BackupFileDeviceUserDefaultsKey];
		NSUserDefaults *deviceUserDefaults = [NSUserDefaults standardUserDefaults];
		for (id key in [deviceUserDefaultsBackup allKeys]) {
			[deviceUserDefaults setObject:deviceUserDefaultsBackup[key] forKey:key];
		}
		float version = [backupInfo[A3BackupFileVersionKey] floatValue];
		if (version == 4.0) {
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuHexagonShouldAddQRCodeMenu];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuGridShouldAddQRCodeMenu];
		}
		// Hexagon, Grid 스타일 메뉴는 4.0에 추가 되었다.
		// 백업 파일이 4.0 이전에 만들어 졌다면, Hexagon, Grid 메뉴가 아예 없기 때문에 별도 메뉴 추가를 고려할 필요가 없다.
		if (version >= 4.0 && version < 4.2) {
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuHexagonShouldAddPedometerMenu];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuGridShouldAddPedometerMenu];
		}
		if (version >= 4.0 && version <= 4.2) {
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuHexagonShouldAddAbbreviationMenu];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:A3SettingsMainMenuGridShouldAddAbbreviationMenu];
		}

		NSNumber *selectedColor = [[A3SyncManager sharedSyncManager] objectForKey:A3SettingsUserDefaultsThemeColorIndex];
		if (selectedColor) {
            [A3AppDelegate instance].window.tintColor = [[A3UserDefaults standardUserDefaults] themeColor];
		}
		[fileManager removeItemAtPath:backupInfoFilePath error:NULL];
		[self moveFilesFromURL:sourceBaseURL toURL:targetBaseURL];

        // Cleanup restore source directory
        [fileManager removeItemAtPath:backupFilePath error:NULL];
        
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
