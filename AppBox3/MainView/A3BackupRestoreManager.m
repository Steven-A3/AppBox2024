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
#import "WalletFieldItemImage.h"
#import "WalletFieldItem+initialize.h"
#import "AAAZip.h"
#import "A3UserDefaults.h"
#import "WalletFieldItemVideo.h"

NSString *const A3ZipFilename = @"name";
NSString *const A3ZipNewFilename = @"newname";
NSString *const A3BackupFileVersionKey = @"ApplicationVersion";
NSString *const A3BackupFileDateKey = @"BackupDate";
NSString *const A3BackupFileOSVersionKey = @"OSVersion";
NSString *const A3BackupFileSystemModelKey = @"Model";
NSString *const A3BackupFileUserDefaultsKey = @"UserDefaults";
NSString *const A3BackupInfoFilename = @"BackupInfo.plist";

extern NSString *const USMCloudContentName;

@interface UbiquityStoreManager (extension)
- (NSMutableDictionary *)optionsForLocalStore;
- (NSMutableDictionary *)optionsForCloudStoreURL:(NSURL *)cloudStoreURL;
@end

@interface A3BackupRestoreManager () <AAAZipDelegate, DBRestClientDelegate, A3DataMigrationManagerDelegate>
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSNumberFormatter *percentFormatter;
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, copy) NSString *backupFilePath;
@property (nonatomic, copy) NSString *backupCoreDataStorePath;
@property (nonatomic, strong) A3DataMigrationManager *migrationManager;
@property (nonatomic, strong) NSMutableArray *deleteFilesAfterZip;
@end

@implementation A3BackupRestoreManager

#pragma mark - Backup Data

- (void)backupData {
	[self backupCoreDataStore];
}

- (void)backupCoreDataStore {
	A3AppDelegate *appDelegate = [A3AppDelegate instance];

	self.backupCoreDataStorePath = [self uniquePathInDocumentDirectory];
	NSDictionary *migrationOptions = nil;
	if (appDelegate.ubiquityStoreManager.cloudEnabled) {
		migrationOptions = @{NSPersistentStoreRemoveUbiquitousMetadataOption:@YES};
	}
	NSURL *backupStoreURL = [NSURL fileURLWithPath:_backupCoreDataStorePath];
	
	NSError *error;
	NSPersistentStoreCoordinator *appPSC = [[A3AppDelegate instance] persistentStoreCoordinator];
	[appPSC lock];
	[appPSC migratePersistentStore:appPSC.persistentStores[0]
							 toURL:backupStoreURL
						   options:migrationOptions
						  withType:NSSQLiteStoreType
							 error:&error];
	[appPSC unlock];

	NSMutableArray *fileList = [NSMutableArray new];
	_deleteFilesAfterZip = [NSMutableArray new];

	NSString *path;
	[fileList addObject:@{A3ZipFilename : _backupCoreDataStorePath, A3ZipNewFilename : [NSString stringWithFormat:@"%@%@", USMCloudContentName, @".sqlite"]}];
	[_deleteFilesAfterZip addObject:_backupCoreDataStorePath];

	path = [NSString stringWithFormat:@"%@%@", _backupCoreDataStorePath, @"-shm"];
	[fileList addObject:@{A3ZipFilename : path, A3ZipNewFilename : [NSString stringWithFormat:@"%@%@", USMCloudContentName, @".sqlite-shm"]}];
	[_deleteFilesAfterZip addObject:path];

	path = [NSString stringWithFormat:@"%@%@", _backupCoreDataStorePath, @"-wal"];
	[fileList addObject:@{A3ZipFilename : path, A3ZipNewFilename : [NSString stringWithFormat:@"%@%@", USMCloudContentName, @".sqlite-wal"]}];
	[_deleteFilesAfterZip addObject:path];

	NSArray *daysCounterEvents = [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"hasPhoto == YES"]];
	for (DaysCounterEvent *event in daysCounterEvents) {
		[fileList addObject:
			@{
				A3ZipFilename : [[event photoURLInOriginalDirectory:YES] path],
				A3ZipNewFilename : [NSString stringWithFormat:@"%@/%@", A3DaysCounterImageDirectory, event.uniqueID]
			}];
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
			A3BackupFileUserDefaultsKey : [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]
	};

	[backupInfoDictionary writeToFile:[A3BackupInfoFilename pathInDocumentDirectory] atomically:YES];
	[fileList addObject:@{
			A3ZipFilename : [A3BackupInfoFilename pathInDocumentDirectory],
			A3ZipNewFilename : A3BackupInfoFilename
	}];
	[_deleteFilesAfterZip addObject:[A3BackupInfoFilename pathInDocumentDirectory]];

	self.HUD.labelText = NSLocalizedString(@"Compressing", @"Compressing");
	[_hostingView addSubview:self.HUD];
	[self.HUD show:YES];

	AAAZip *zip = [AAAZip new];
	zip.delegate = self;
	_backupFilePath = [self uniqueBackupFilename];
	[zip createZipFile:_backupFilePath withArray:fileList];
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
	_HUD.detailsLabelText = [self.percentFormatter stringFromNumber:@(_HUD.progress)];
}

- (void)decompressProgress:(float)currentByte total:(float)totalByte {
	_HUD.progress = currentByte / totalByte;
	_HUD.detailsLabelText = [self.percentFormatter stringFromNumber:@(_HUD.progress)];
}

- (void)completedZipProcess:(BOOL)bResult {
	_HUD.labelText = NSLocalizedString(@"Uploading", @"Uploading");
	_HUD.detailsLabelText = @"";

	[self.restClient uploadFile:[_backupFilePath lastPathComponent] toPath:kDropboxDir withParentRev:nil fromPath:_backupFilePath];

	NSFileManager *fileManager = [[NSFileManager alloc] init];
	for (NSString *path in _deleteFilesAfterZip) {
		[fileManager removeItemAtPath:path error:NULL];
	}
	_deleteFilesAfterZip = nil;
}

- (NSString *)uniquePathInDocumentDirectory {
	NSDate *date = [NSDate date];
	NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	NSString *seedFilename = [NSString stringWithFormat:@"storeBackupFile-%ld-%ld-%ld-%ld-%ld-%ld", (long) components.year, (long) components.month, (long) components.day, (long) components.hour, (long) components.minute, (long) components.second];
	NSString *filename = seedFilename;
	NSString *path = [[filename stringByAppendingPathExtension:@"sqlite"] pathInDocumentDirectory];
	NSFileManager *fileManager = [NSFileManager new];
	NSInteger option = 1;
	while ([fileManager fileExistsAtPath:path]) {
		filename = [seedFilename stringByAppendingFormat:@"-%ld", (long)option++];
		path = [[filename stringByAppendingPathExtension:@"sqlite"] pathInDocumentDirectory];
	}
	return path;
}

- (NSString *)uniqueBackupFilename {
	NSDate *date = [NSDate date];
	NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	NSString *seedFilename = [NSString stringWithFormat:@"AppBoxBackup-%0ld-%02ld-%02ld-%02ld-%02ld", (long) components.year, (long) components.month, (long) components.day, (long) components.hour, (long) components.minute];
	NSString *filename = seedFilename;
	NSString *path = [[filename stringByAppendingPathExtension:@"backup"] pathInDocumentDirectory];
	NSFileManager *fileManager = [NSFileManager new];
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
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info") message:NSLocalizedString(@"Backup file has been uploaded to Dropbox successfully.", @"Backup file has been uploaded to Dropbox successfully.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
	NSFileManager *fileManager = [NSFileManager new];
	[fileManager removeItemAtPath:_backupFilePath error:NULL];
}

#pragma mark - Restore data

// targetURL : .../UbiquityStore.sqlite

- (void)restoreDataAt:(NSString *)backupFilePath toURL:(NSURL *)toURL {
	NSFileManager *fileManager = [NSFileManager new];
	[self deleteCoreDataStoreFilesAt:toURL];
	[self removeMediaFiles];

	NSString *backupInfoFilePath = [backupFilePath stringByAppendingPathComponent:A3BackupInfoFilename];
	if ([fileManager fileExistsAtPath:backupInfoFilePath]) {
		// Backup file is made with Version 3.0 or above
		NSURL *sourceBaseURL = [NSURL fileURLWithPath:backupFilePath];
		NSURL *targetBaseURL = [toURL URLByDeletingLastPathComponent];

		[self moveComponent:[NSString stringWithFormat:@"%@%@", USMCloudContentName, @".sqlite"] fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:[NSString stringWithFormat:@"%@%@", USMCloudContentName, @".sqlite-wal"] fromURL:sourceBaseURL toURL:targetBaseURL];
		[self moveComponent:[NSString stringWithFormat:@"%@%@", USMCloudContentName, @".sqlite-shm"] fromURL:sourceBaseURL toURL:targetBaseURL];

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
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		for (NSString *key in userDefaults.allKeys) {
			[standardUserDefaults setObject:userDefaults[key] forKey:key];
		}
		[standardUserDefaults synchronize];

		if ([_delegate respondsToSelector:@selector(backupRestoreManager:restoreCompleteWithSuccess:)]) {
			[_delegate backupRestoreManager:self restoreCompleteWithSuccess:YES];
		}
		[fileManager removeItemAtPath:backupInfoFilePath error:NULL];
	} else {
		[self extractV1DataFilesAt:backupFilePath];

		SQLiteMagicalRecordStack *sqLiteMagicalRecordStack = [[SQLiteMagicalRecordStack alloc] initWithStoreAtURL:toURL];
		A3DataMigrationManager *migrationManager = [[A3DataMigrationManager alloc] initWithPersistentStoreCoordinator:sqLiteMagicalRecordStack.coordinator];
		migrationManager.migrationDirectory = backupFilePath;
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

- (void)moveComponent:(NSString *)component fromURL:(NSURL *)fromURL toURL:(NSURL *)toURL {
	[[NSFileManager new] moveItemAtURL:[fromURL URLByAppendingPathComponent:component]
											toURL:[toURL URLByAppendingPathComponent:component]
											error:NULL];
}

- (void)moveFilesFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL {
	NSFileManager *fileManager = [NSFileManager new];
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
	NSFileManager *fileManager = [NSFileManager new];

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
	NSFileManager *fileManager = [NSFileManager new];
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
