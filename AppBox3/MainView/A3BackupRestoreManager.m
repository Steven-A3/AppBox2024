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
#import "DaysCounterEvent+management.h"
#import "WalletFieldItemImage.h"
#import "WalletFieldItem+initialize.h"
#import "AAAZip.h"

@interface UbiquityStoreManager (extension)
- (NSMutableDictionary *)optionsForLocalStore;
- (NSMutableDictionary *)optionsForCloudStoreURL:(NSURL *)cloudStoreURL;
@end

@interface A3BackupRestoreManager () <AAAZipDelegate, DBRestClientDelegate>
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSNumberFormatter *percentFormatter;
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, copy) NSString *backupFilePath;
@end

@implementation A3BackupRestoreManager

- (void)backupData {
	[self backupCoreDataStore];
}

NSString *const A3ZipFilename = @"name";
NSString *const A3ZipNewFilename = @"newname";

- (void)backupCoreDataStore {
	// Copy core data store file to backup file
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	NSPersistentStoreCoordinator *applicationStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
	NSURL *applicationStoreURL;
	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	NSMutableDictionary *storeOptions;
	if (appDelegate.ubiquityStoreManager.cloudEnabled) {
		applicationStoreURL = [appDelegate.ubiquityStoreManager URLForCloudStore];
		storeOptions = [appDelegate.ubiquityStoreManager optionsForCloudStoreURL:applicationStoreURL];
		[storeOptions setObject:@YES forKey:NSPersistentStoreRemoveUbiquitousMetadataOption];
	} else {
		applicationStoreURL = [appDelegate.ubiquityStoreManager localStoreURL];
		storeOptions = [appDelegate.ubiquityStoreManager optionsForLocalStore];
	}

	NSError *error;
	id sourceStore = [applicationStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
											  configuration:nil
														URL:applicationStoreURL
													options:storeOptions
													  error:&error];

	NSString *backupStorePath = [self uniquePathInDocumentDirectory];
	if (sourceStore) {
		NSDictionary *migrationOptions = nil;
		if (appDelegate.ubiquityStoreManager.cloudEnabled) {
			migrationOptions = @{NSPersistentStoreRemoveUbiquitousMetadataOption:@YES};
		}
		NSURL *backupStoreURL = [NSURL fileURLWithPath:backupStorePath];
		[applicationStoreCoordinator migratePersistentStore:sourceStore toURL:backupStoreURL
													options:migrationOptions
												   withType:NSSQLiteStoreType
													  error:&error];
	}

	NSMutableArray *fileList = [NSMutableArray new];

	NSString *path;
	[fileList addObject:@{A3ZipFilename : backupStorePath, A3ZipNewFilename : [backupStorePath lastPathComponent]}];
	path = [NSString stringWithFormat:@"%@%@", backupStorePath, @"-shm"];
	[fileList addObject:@{A3ZipFilename : path, A3ZipNewFilename : [path lastPathComponent]}];
	path = [NSString stringWithFormat:@"%@%@", backupStorePath, @"-wal"];
	[fileList addObject:@{A3ZipFilename : path, A3ZipNewFilename : [path lastPathComponent]}];

	NSArray *daysCounterEvents = [DaysCounterEvent MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"hasPhoto == YES"]];
	for (DaysCounterEvent *event in daysCounterEvents) {
		[fileList addObject:
			@{
				A3ZipFilename : [event photoPathInOriginalDirectory:YES],
				A3ZipNewFilename : [NSString stringWithFormat:@"%@/%@", A3DaysCounterImageDirectory, event.uniqueID]
			}];
	}

	NSArray *walletImages = [WalletFieldItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"image != NULL"]];
	for (WalletFieldItem *item in walletImages) {
		[fileList addObject:
			@{
				A3ZipFilename : [item photoImagePathInOriginalDirectory:YES],
				A3ZipNewFilename : [NSString stringWithFormat:@"%@/%@", A3WalletImageDirectory, item.uniqueID]
			}];
	}

	NSArray *walletVideos = [WalletFieldItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"video != NULL"]];
	for (WalletFieldItem *video in walletVideos) {
		[fileList addObject:
			@{
				A3ZipFilename : [video videoFilePathInOriginal:YES],
				A3ZipNewFilename : [NSString stringWithFormat:@"%@/%@", A3WalletVideoDirectory, video.uniqueID]
			}];
	}

	self.HUD.labelText = @"Compressing";
	[_hostingView addSubview:self.HUD];
	[self.HUD show:YES];

	FNLOG(@"%@", fileList);

	AAAZip *zip = [AAAZip new];
	zip.delegate = self;
	_backupFilePath = [self uniqueBackupFilename];
	[zip CreateZipFileWithList:_backupFilePath SoureList:fileList];
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

- (void)completedProcess:(BOOL)bResult {
	_HUD.labelText = @"Uploading";
	_HUD.detailsLabelText = @"";
	[self.restClient uploadFile:[_backupFilePath lastPathComponent] toPath:kDropboxDir withParentRev:nil fromPath:_backupFilePath];
}

- (NSString *)uniquePathInDocumentDirectory {
	NSDate *date = [NSDate date];
	NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	NSString *seedFilename = [NSString stringWithFormat:@"storeBackupFile-%ld-%ld-%ld-%ld-%ld-%ld", (long) components.year, (long) components.month, (long) components.day, (long) components.hour, (long) components.minute, (long) components.second];
	NSString *filename = seedFilename;
	NSString *path = [[filename stringByAppendingPathExtension:@"sqlite"] pathInDocumentDirectory];
	NSFileManager *fileManager = [NSFileManager defaultManager];
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
	NSString *seedFilename = [NSString stringWithFormat:@"AppBoxBackup-%ld-%ld-%ld-%ld-%ld-%ld", (long) components.year, (long) components.month, (long) components.day, (long) components.hour, (long) components.minute, (long) components.second];
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
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Backup file has been uploaded to Dropbox successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)restClient:(DBRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath {
	_HUD.progress = progress;
	_HUD.detailsLabelText = [self.percentFormatter stringFromNumber:@(progress)];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
	[_HUD hide:YES];
	_HUD = nil;

	UIAlertView *alertFail = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Backup process failed to upload backup file to Dropbox." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertFail show];
}


@end
