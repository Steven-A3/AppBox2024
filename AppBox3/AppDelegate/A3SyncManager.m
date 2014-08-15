//
//  A3SyncManager.m
//  AppBox3
//
//  Created by A3 on 7/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SyncManager.h"
#import "A3AppDelegate.h"
#import "DaysCounterEvent+extension.h"
#import "WalletFieldItem+initialize.h"
#import "NSString+conversion.h"
#import "NSManagedObject+extension.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3CurrencyDataManager.h"
#import "A3DaysCounterModelManager.h"
#import "WalletData.h"
#import "A3LadyCalendarModelManager.h"
#import "A3UnitDataManager.h"
#import "NSFileManager+A3Addtion.h"
#import "A3UserDefaults.h"

NSString * const A3SyncManagerCloudEnabled = @"A3SyncManagerCloudEnabled";
NSString * const A3SyncActivityDidBeginNotification = @"A3SyncActivityDidBegin";
NSString * const A3SyncActivityDidEndNotification = @"A3SyncActivityDidEnd";
NSString * const A3SyncDeviceSyncStartInfo = @"A3SyncDeviceSyncStartInfo";	// Dictionary. Time and device name.
NSString * const A3SyncStartTime = @"A3SyncStartTime";
NSString * const A3SyncStartDevice = @"A3SyncStartDevice";
NSString * const A3SyncStartDenyReason = @"A3SyncStartDenyReason";

typedef NS_ENUM(NSUInteger, A3SyncStartDenyReasonValue) {
	A3SyncStartDeniedBecauseOtherDeviceDidStartSyncWithin10Minutes,
	A3SyncStartDeniedBecauseCloudDeleteStartedWithin10Minutes
};

NSString * const A3DictionaryDBLogsDirectoryName = @"DictionaryTransactionLogs";
NSString * const A3DictionaryDBDownloadedFileList = @"downloadedFilesSet";
NSString * const A3DictionaryDBFirstHunkFilename = @"baseline";
NSString * const A3DictionaryDBDeviceID = @"deviceID";					// [UIDevice identifierForVendor]
NSString * const A3DictionaryDBTransactionID = @"transactionID";		// UUID
NSString * const A3DictionaryDBEntityKey = @"entityKey";				// userDefaultsKeyName
NSString * const A3DictionaryDBTransactionType = @"transactionType";	//
NSString * const A3DictionaryDBTimestamp = @"timestamp";				// NSDate date
NSString * const A3DictionaryDBUniqueID = @"uniqueID";
NSString * const A3DictionaryDBObject = @"transactionObject";			// object for each transaction
NSString * const A3DictionaryDBLastPlayedTransactionID = @"A3DictionaryDBLastPlayedTransactionByID";	// filename
NSString * const A3DictionaryDBInitialMergeObjects = @"A3DictionaryDBInitialMergeObjects";

@interface A3SyncManager () <CDEPersistentStoreEnsembleDelegate>
@end

@implementation A3SyncManager
{
	NSUInteger _activeMergeCount;
	NSFileManager *_fileManager;
	NSUInteger _leechFailCount;
	NSTimer *_syncTimer;
}

+ (instancetype)sharedSyncManager
{
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[A3SyncManager alloc] init];
	});
	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		_fileManager = [NSFileManager new];
		[_fileManager URLForUbiquityContainerIdentifier:nil];
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyValueStoreDidChangeExternally:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:store];
#ifdef DEBUG_ENSEMBLE_PROGRESS
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ensembleDidBeginActivity:) name:CDEPersistentStoreEnsembleDidBeginActivityNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ensembleDidMakeProgress:) name:CDEPersistentStoreEnsembleDidMakeProgressWithActivityNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ensembleWilEndActivity:) name:CDEPersistentStoreEnsembleWillEndActivityNotification object:nil];
#endif
	}

	return self;
}

#ifdef DEBUG_ENSEMBLE_PROGRESS
- (void)ensembleDidBeginActivity:(NSNotification *)notification {
	FNLOG(@"%@", notification.userInfo[CDEEnsembleActivityKey]);
}

- (void)ensembleDidMakeProgress:(NSNotification *)notification {
	FNLOG(@"%@", notification.userInfo[CDEEnsembleActivityKey]);
	FNLOG(@"%@", notification.userInfo[CDEProgressFractionKey]);
}

- (void)ensembleWilEndActivity:(NSNotification *)notification {
	id activity = notification.userInfo[CDEEnsembleActivityKey];
	FNLOG(@"%@", activity);
	switch ([activity unsignedIntegerValue]) {
		case CDEEnsembleActivityLeeching: {
			NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
			[keyValueStore removeObjectForKey:A3SyncDeviceSyncStartInfo];
			[keyValueStore synchronize];
			break;
		}
		case CDEEnsembleActivityDeleeching:
		default:
			break;
	}
}
#endif

- (BOOL)canSyncStart {
	NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
	NSDictionary *syncInfo = [keyValueStore objectForKey:A3SyncDeviceSyncStartInfo];
	if (!syncInfo) {
		return YES;
	}
	NSDate *lastSyncStartTime = syncInfo[A3SyncStartTime];
	NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastSyncStartTime];
	if (interval >= 60 * 5) {
		return YES;
	}

	A3SyncStartDenyReasonValue reason = (A3SyncStartDenyReasonValue) [syncInfo[A3SyncStartDenyReason] unsignedIntegerValue];

	NSString *message;
	if (reason == A3SyncStartDeniedBecauseOtherDeviceDidStartSyncWithin10Minutes) {
		message = [NSString stringWithFormat:NSLocalizedString(@"%@ syncing is in progress. Try after 10 minutes.", nil), syncInfo[A3SyncStartDevice]];
	} else {
		message = NSLocalizedString(@"iCloud delete is in progress. Try after 10 minutes.", nil);
	}
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
														message:message
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
	[alertView show];
	return NO;
}

- (BOOL)isCloudAvailable {
	return [[NSFileManager defaultManager] ubiquityIdentityToken] != nil;
}

- (NSString *)cloudStoreID {
	return @"AppBoxCloudStore";
}

- (NSString *)rootDirectoryName {
	return @"net.allaboutapps.AppBox";
}

- (CDEICloudFileSystem *)cloudFileSystem {
	if (!_cloudFileSystem) {
		_cloudFileSystem = [[CDEICloudFileSystem alloc] initWithUbiquityContainerIdentifier:nil relativePathToRootInContainer:[self rootDirectoryName]];
	}
	return _cloudFileSystem;
}

- (void)enableCloudSync {
	if ([self isCloudEnabled]) return;

	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3SyncManagerCloudEnabled];
	[[A3UserDefaults standardUserDefaults] synchronize];

	[self writeSyncInfoToKeyValueStore:A3SyncStartDeniedBecauseOtherDeviceDidStartSyncWithin10Minutes];

	[self createDirectories];
	[self setupEnsemble];
	[self synchronizeWithCompletion:^(NSError *error) {
		[self.ensemble mergeWithCompletion:NULL];
	}];

	[self mergeNonCoreDataEntities];
}

- (void)writeSyncInfoToKeyValueStore:(A3SyncStartDenyReasonValue)reason {
	NSDictionary *syncInfo = @{
			A3SyncStartTime : [NSDate date],
			A3SyncStartDevice : [[UIDevice currentDevice] name],
			A3SyncStartDenyReason : @(reason)
	};

	NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
	[keyValueStore setObject:syncInfo forKey:A3SyncDeviceSyncStartInfo];
	[keyValueStore synchronize];
}

- (void)setupEnsemble
{
	if (!self.isCloudEnabled || _ensemble) return;

	NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:[[A3AppDelegate instance] storeFileName]];
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AppBox3" withExtension:@"momd"];
	_ensemble = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:self.cloudStoreID persistentStoreURL:storeURL managedObjectModelURL:modelURL cloudFileSystem:self.cloudFileSystem];
	_ensemble.delegate = self;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localSaveOccurred:) name:CDEMonitoredManagedObjectContextDidSaveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDidDownload:) name:CDEICloudFileSystemDidDownloadFilesNotification object:nil];
}

- (void)disableCloudSync {
	[_ensemble deleechPersistentStoreWithCompletion:^(NSError *error) {
		[self deleteLogFiles];
		[self reset];
	}];
}

- (void)reset
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CDEMonitoredManagedObjectContextDidSaveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CDEICloudFileSystemDidDownloadFilesNotification object:nil];

	_ensemble.delegate = nil;
	_ensemble = nil;

	[[A3UserDefaults standardUserDefaults] removeObjectForKey:A3SyncManagerCloudEnabled];
	[[A3UserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Sync Methods

- (void)cloudDidDownload:(NSNotification *)notification
{
	FNLOG();
	if (!self.isCloudEnabled) return;
	
	[self synchronizeWithCompletion:NULL];
}

- (void)localSaveOccurred:(NSNotification *)notification
{
	FNLOG();
	if (!self.isCloudEnabled) return;
	
	[self synchronizeWithCompletion:NULL];
}

- (BOOL)isCloudEnabled {
	return [[NSFileManager defaultManager] ubiquityIdentityToken] &&
			[[A3UserDefaults standardUserDefaults] boolForKey:A3SyncManagerCloudEnabled];
}

- (void)synchronizeWithCompletion:(CDECompletionBlock)completion
{
	if (!self.isCloudEnabled) return;

	[self incrementMergeCount];
	if (!_ensemble.isLeeched) {
		[_ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
			[self uploadMediaFilesToCloud];
			[self downloadMediaFilesFromCloud];

			[self decrementMergeCount];
			if (error && !_ensemble.isLeeched) {
				NSLog(@"Could not leech to ensemble: %@", error);
				[self disableCloudSync];
			}
			else {
				_leechFailCount = 0;
				if (completion) completion(error);
			}
		}];
	}
	else {
		[_ensemble mergeWithCompletion:^(NSError *error) {
			[self uploadMediaFilesToCloud];
			[self downloadMediaFilesFromCloud];

			[self decrementMergeCount];
			if (error) NSLog(@"Error merging: %@", error);
			if (completion) completion(error);
		}];
	}

	[self downloadAndPlayTransactions];

	[_syncTimer invalidate];
	_syncTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(syncWithTimer) userInfo:nil repeats:NO];
}

- (void)syncWithTimer {
	[_syncTimer invalidate];
	_syncTimer = nil;

	if (![_ensemble isMerging]) {
		FNLOG(@"Sync initiated by timer.");
		[self synchronizeWithCompletion:NULL];
	}
}

- (void)decrementMergeCount
{
	_activeMergeCount--;
	if (_activeMergeCount == 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCloudCoreDataStoreDidImport object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:A3SyncActivityDidEndNotification object:nil];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

- (void)incrementMergeCount
{
	_activeMergeCount++;
	if (_activeMergeCount == 1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCloudCoreDataStoreDidImport object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:A3SyncActivityDidBeginNotification object:nil];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

#pragma mark - Persistent Store Ensemble Delegate


- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didSaveMergeChangesWithNotification:(NSNotification *)notification
{
	FNLOG();
	NSManagedObjectContext *rootContext = [NSManagedObjectContext MR_rootSavingContext];
	[rootContext performBlockAndWait:^{
		[rootContext mergeChangesFromContextDidSaveNotification:notification];
	}];

	NSManagedObjectContext *mainContext = [NSManagedObjectContext MR_defaultContext];
	[mainContext performBlockAndWait:^{
		[mainContext mergeChangesFromContextDidSaveNotification:notification];
	}];
}

- (NSArray *)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble globalIdentifiersForManagedObjects:(NSArray *)objects
{
	return [objects valueForKeyPath:@"uniqueID"];
}

- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didDeleechWithError:(NSError *)error {
	if (error) {
		if (self.isCloudAvailable && _leechFailCount < 4) {
			_leechFailCount++;
			[self enableCloudSync];
			return;
		}
	}
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
														message:NSLocalizedString(@"iCloud Disabled", nil)
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
	[alertView show];
	[self reset];
}

- (BOOL)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didFailToSaveMergedChangesInManagedObjectContext:(NSManagedObjectContext *)savingContext error:(NSError *)error reparationManagedObjectContext:(NSManagedObjectContext *)reparationContext {
	NSMutableArray *objectIDs = [NSMutableArray array];
	NSMutableArray *errors = [NSMutableArray array];
	FNLOG(@"%@", objectIDs);
	FNLOG(@"%@", errors);

	[savingContext performBlockAndWait:^{
		if (error.code != NSValidationMultipleErrorsError) {
			NSManagedObject *object = error.userInfo[@"NSValidationErrorObject"];
			[objectIDs addObject:object.objectID];
			[errors addObject:error];
		} else {
			NSArray *detailedErrors = error.userInfo[NSDetailedErrorsKey];
			for (NSError *error_ in detailedErrors) {
				NSDictionary *detailedInfo = error_.userInfo;
				NSManagedObject *object = detailedInfo[@"NSValidationErrorObject"];
				[objectIDs addObject:object.objectID];
				[errors addObject:error_];
			}
		}
	}];

	[reparationContext performBlockAndWait:^{
		[objectIDs enumerateObjectsWithOptions:0 usingBlock:^(NSManagedObjectID *objectID, NSUInteger idx, BOOL *stop) {
			NSError *error_;
			id object = [reparationContext existingObjectWithID:objectID error:&error_];
			if (!object) {
				FNLOG(@"Failed to retrieve invalid object: %@", error_);
				return;
			}
			[object repairWithError:errors[idx]];
		}];
	}];

	return YES;
}

#pragma mark - Upload Download Manager

- (void)uploadMediaFilesToCloud {
	[self uploadFilesToCloudInDirectory:A3DaysCounterImageDirectory];
	[self uploadFilesToCloudInDirectory:A3WalletImageDirectory];
	[self uploadFilesToCloudInDirectory:A3WalletVideoDirectory];
}

- (void)uploadFilesToCloudInDirectory:(NSString *)directory {
	[_cloudFileSystem connect:^(NSError *error) {
		[_cloudFileSystem fileExistsAtPath:directory completion:^(BOOL exists, BOOL isDirectory, NSError *error_) {
			void (^fileCopyBlock)(NSError *) = ^(NSError *error__){
				NSArray *files = [_fileManager contentsOfDirectoryAtPath:[directory pathInLibraryDirectory] error:NULL];
				NSString *localBasePath = [directory pathInLibraryDirectory];
				for (NSString *filename in files) {
					NSString *localPath = [localBasePath stringByAppendingPathComponent:filename];
					NSString *cloudPath = [directory stringByAppendingPathComponent:filename];

					[_cloudFileSystem fileExistsAtPath:cloudPath completion:^(BOOL exists_, BOOL isDirectory_, NSError *error___) {
						if (!exists_) {
							FNLOG(@"Filename: %@", filename);
							[_cloudFileSystem uploadLocalFile:localPath toPath:cloudPath completion:NULL];
						}
					}];
				}
			};
			if (!exists) {
				[_cloudFileSystem createDirectoryAtPath:directory completion:fileCopyBlock];
			} else {
				fileCopyBlock(nil);
			}
		}];
	}];
}

- (void)downloadMediaFilesFromCloud {
	[self downloadFilesFromCloudInDirectory:A3DaysCounterImageDirectory];
	[self downloadFilesFromCloudInDirectory:A3WalletImageDirectory];
	[self downloadFilesFromCloudInDirectory:A3WalletVideoDirectory];
}

- (void)downloadFilesFromCloudInDirectory:(NSString *)directory {
	[_cloudFileSystem connect:^(NSError *error) {
		[_cloudFileSystem contentsOfDirectoryAtPath:directory completion:^(NSArray *contents, NSError *error_) {
			for (CDECloudFile *file in contents) {
				NSString *filename = file.name;
				NSString *localFile = [[directory stringByAppendingPathComponent:filename] pathInLibraryDirectory];

				if (![_fileManager fileExistsAtPath:localFile]) {
					FNLOG(@"%@, %@", file.name, file.path);
					[_cloudFileSystem downloadFromPath:file.path toLocalFile:localFile completion:NULL];
				}
			}
		}];
	}];
}

#ifdef ENABLE_DELETE_CLOUD
#pragma mark - Delete iCloud Data

/*! iCloud Sync는 꺼져 있어야 한다. device의 iCloud는 켜져 있어야 지울 수 있다.
 *  ensemble을 셋업하고 지우고 닫는다.
 * \param
 * \returns
 */
- (void)deleteCloudData {
	if (![self isCloudEnabled] || _ensemble) return;

	[CDEPersistentStoreEnsemble removeEnsembleWithIdentifier:self.cloudStoreID inCloudFileSystem:self.cloudFileSystem completion:^(NSError *error) {
		[self writeSyncInfoToKeyValueStore:A3SyncStartDeniedBecauseCloudDeleteStartedWithin10Minutes];
		[self deleteKeyValueStore];
		[self deleteCloudFilesToResetCloud];
	}];
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
		[self.cloudFileSystem removeItemAtPath:[fileURL path] completion:NULL];
	}
}

- (void)deleteKeyValueStore {
	NSArray *keysToDelete = @[

	];
	NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
	for (NSString *key in keysToDelete) {
		[keyValueStore removeObjectForKey:key];
	}
	[keyValueStore synchronize];
}
#endif

#pragma mark --- DictionaryDB Transaction Management

- (NSString *)transactionLogDirectoryPath {
	return [A3DictionaryDBLogsDirectoryName pathInLibraryDirectory];
}

- (void)addTransaction:(NSString *)dataFilename type:(A3DictionaryDBTransactionTypeValue)typeValue object:(id)object {
	if (!self.isCloudEnabled) return;

	NSString *transactionID = [[NSUUID UUID] UUIDString];
	NSDictionary *transaction = @{
			A3DictionaryDBTransactionID : transactionID,
			A3DictionaryDBTransactionType : @(typeValue),
			A3DictionaryDBTimestamp : [NSDate date],
			A3DictionaryDBEntityKey : dataFilename,
			A3DictionaryDBDeviceID : [[[UIDevice currentDevice] identifierForVendor] UUIDString],
			A3DictionaryDBObject : object
	};
	NSString *logFilePath = [[self transactionLogDirectoryPath] stringByAppendingPathComponent:transactionID];
	// Each log file has array of transactions even if it has only one transaction.
	NSError *conversionError;
	NSData *data = [NSPropertyListSerialization dataWithPropertyList:@[transaction]
															  format:NSPropertyListBinaryFormat_v1_0
															 options:0
															   error:&conversionError];
	if ([data writeToFile:logFilePath atomically:YES]) {
		FNLOG(@"File write success for filename: %@", dataFilename);
	}

	[_cloudFileSystem connect:^(NSError *error) {
		NSString *cloudFilePath = [A3DictionaryDBLogsDirectoryName stringByAppendingPathComponent:transactionID];
		[_cloudFileSystem fileExistsAtPath:cloudFilePath completion:^(BOOL exists, BOOL isDirectory, NSError *error_1) {
			if (!exists) {
				[_cloudFileSystem uploadLocalFile:logFilePath toPath:cloudFilePath completion:^(NSError *error_2) {
					if (!error_2) {
						FNLOG(@"Transaction log uploaded: %@", transaction);
						NSString *listFilePath = [self downloadedFileListFilePath];
						NSMutableArray *downloadedFileList = nil;
						if ([_fileManager fileExistsAtPath:listFilePath]) {
							downloadedFileList = [NSMutableArray arrayWithArray:[NSArray arrayWithContentsOfFile:listFilePath]];
						} else {
							downloadedFileList = [NSMutableArray new];
						}
						[downloadedFileList addObject:transactionID];
						[downloadedFileList writeToFile:listFilePath atomically:YES];
						
						[self aggregateLogFiles];

						if (typeValue == A3DictionaryDBTransactionTypeSetBaseline) {
							[self removePreviousTransactionsBeforeBaselineForFilename:dataFilename lastTransactionFileName:transactionID ];
						}
					} else {
						FNLOG(@"Log upload faild with error: %@", error_2.localizedDescription);
					}
				}];
			}
		}];
	}];
}

- (void)removePreviousTransactionsBeforeBaselineForFilename:(NSString *)entityName lastTransactionFileName:(NSString *)lastTransactionFilename {
	NSError *error;
	NSString *directoryPath = [self transactionLogDirectoryPath];
	NSArray *logFiles = [_fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
	if (error) return;
	for (NSString *filename in logFiles) {
		if ([filename isEqualToString:lastTransactionFilename]) continue;

		NSString *filePath = [directoryPath stringByAppendingPathComponent:filename];
		NSData *rawData = [NSData dataWithContentsOfFile:filePath];
		if (!rawData) {
			continue;
		}
		NSArray *transactions = [NSPropertyListSerialization propertyListWithData:rawData
																		  options:0
																		   format:NULL
																			error:NULL];
		if ([transactions count] == 1) {
			NSDictionary *transaction = transactions[0];
			if (transaction && [transaction[A3DictionaryDBEntityKey] isEqualToString:entityName]) {
				[_fileManager removeItemAtPath:filePath error:NULL];
				[_cloudFileSystem removeItemAtPath:[A3DictionaryDBLogsDirectoryName stringByAppendingPathComponent:filename] completion:NULL];
			}
		} else {
			NSMutableArray *editingTransactions = [NSMutableArray arrayWithArray:transactions];
			NSMutableArray *willDeleteTransactions = [NSMutableArray new];
			for (NSDictionary *transaction in editingTransactions) {
				if ([transaction[A3DictionaryDBEntityKey] isEqualToString:filename]) {
					[willDeleteTransactions addObject:transaction];
				}
			}
			if ([willDeleteTransactions count]) {
				[editingTransactions removeObjectsInArray:willDeleteTransactions];
				if ([editingTransactions count]) {
					NSData *data = [NSPropertyListSerialization dataWithPropertyList:editingTransactions
																			  format:NSPropertyListBinaryFormat_v1_0
																			 options:0
																			   error:NULL];
					[data writeToFile:filePath atomically:YES];
				} else {
					[_fileManager removeItemAtPath:filePath error:NULL];
					[_cloudFileSystem removeItemAtPath:[A3DictionaryDBLogsDirectoryName stringByAppendingPathComponent:filename] completion:NULL];
				}
			}
		}
	}
}

- (NSString *)downloadedFileListFilePath {
	return [A3DictionaryDBDownloadedFileList pathInLibraryDirectory];
}

- (void)downloadAndPlayTransactions {
	[self uploadLogFiles];
	[self downloadLogFiles:^(NSError *error) {
		[self aggregateLogFiles];
	}];
}

- (void)downloadLogFiles:(CDECompletionBlock)completionBlock {
	NSString *localTransactionLogDirectoryPath = [self transactionLogDirectoryPath];
	NSMutableSet *downloadedFilesSet = [self downloadedFilesSet];
	[_cloudFileSystem connect:^(NSError *error) {
		[_cloudFileSystem fileExistsAtPath:A3DictionaryDBLogsDirectoryName completion:^(BOOL exists, BOOL isDirectory, NSError *error_1) {
			if (!exists) {
				FNLOG(@"Log Directory does not exist.");
				return;
			}
			[_cloudFileSystem contentsOfDirectoryAtPath:A3DictionaryDBLogsDirectoryName completion:^(NSArray *contents, NSError *error_2) {
				FNLOG();
				__block NSMutableArray *downloadFiles = [NSMutableArray new];
				for (CDECloudFile *cloudFile in contents) {
					NSString *localFilePath = [localTransactionLogDirectoryPath stringByAppendingPathComponent:cloudFile.name];
					if (![downloadedFilesSet containsObject:cloudFile.name] || ![_fileManager fileExistsAtPath:localFilePath]) {
						[downloadFiles addObject:cloudFile];
					} else {
						[self addFilenameToDownloadedFileList:cloudFile.name];
					}
				}
				FNLOG(@"Files to downlaod : %@", downloadFiles);

				for (CDECloudFile *cloudFile in downloadFiles) {
					NSString *localFilePath = [localTransactionLogDirectoryPath stringByAppendingPathComponent:cloudFile.name];
					FNLOG(@"Try downloading file : %@", cloudFile.name);
					[_cloudFileSystem downloadFromPath:cloudFile.path toLocalFile:localFilePath completion:^(NSError *error_3) {
						FNLOG();
						if (!error_3) {
							FNLOG(@"Transaction Log downloaded: %@", cloudFile.name);
							[self addFilenameToDownloadedFileList:cloudFile.name];

							if ([cloudFile isEqual:[downloadFiles lastObject]]) {
								[self playTransactions];

								NSDictionary *mergeObjects = [[A3UserDefaults standardUserDefaults] objectForKey:A3DictionaryDBInitialMergeObjects];
								if (mergeObjects) {
									for (NSString *key in [mergeObjects allKeys]) {
										[self mergeForKey:key withBackupData:mergeObjects[key]];
									}
									[[A3UserDefaults standardUserDefaults] removeObjectForKey:A3DictionaryDBInitialMergeObjects];
									[[A3UserDefaults standardUserDefaults] synchronize];
								}
								if (completionBlock) {
									completionBlock(nil);
								}
							}
						} else {
							FNLOG(@"Failed to download file : %@\n%@", cloudFile.name, error_3.localizedDescription);
							[self downloadLogFiles:completionBlock];
						}
					}];
				}
			}];
		}];
	}];
}

- (void)aggregateLogFiles {
	NSArray *logFiles = [_fileManager contentsOfDirectoryAtPath:[self transactionLogDirectoryPath] error:NULL];
	if ([logFiles count] < 32) return;

	FNLOG(@"Try to aggregate log files");
	NSString *aggregatedHunkFilePath = [[self transactionLogDirectoryPath] stringByAppendingPathComponent:A3DictionaryDBFirstHunkFilename];

	NSArray *oldAggregatedHunkContents;
	NSMutableSet *newAggregatedHunkContents = [NSMutableSet new];
	
	NSMutableArray *mutableLogFiles = [logFiles mutableCopy];
	if ([mutableLogFiles containsObject:A3DictionaryDBFirstHunkFilename]) {
		[mutableLogFiles removeObject:A3DictionaryDBFirstHunkFilename];

		NSData *aggregatedHunkFileData = [NSData dataWithContentsOfFile:aggregatedHunkFilePath];
		if (aggregatedHunkFileData) {
			oldAggregatedHunkContents = [NSPropertyListSerialization propertyListWithData:aggregatedHunkFileData
																				  options:0
																				   format:NULL
																					error:NULL];
			if (oldAggregatedHunkContents) {
				[newAggregatedHunkContents addObjectsFromArray:oldAggregatedHunkContents];
			}
		}
	}

	[_cloudFileSystem connect:^(NSError *error) {
		for (NSString *logFilename in mutableLogFiles) {
			NSString *logFilePath = [[self transactionLogDirectoryPath] stringByAppendingPathComponent:logFilename];
			NSData *transactionsData = [NSData dataWithContentsOfFile:logFilePath];
			NSArray *transactions = [NSPropertyListSerialization propertyListWithData:transactionsData
																			  options:0
																			   format:NULL
																				error:NULL];
			if (transactions) {
				[newAggregatedHunkContents addObjectsFromArray:transactions];
			}
			[_fileManager removeItemAtPath:logFilePath error:NULL];
			NSString *cloudPath = [A3DictionaryDBLogsDirectoryName stringByAppendingPathComponent:logFilename];
			[_cloudFileSystem removeItemAtPath:cloudPath completion:NULL];
		}
		NSData *newData = [NSPropertyListSerialization dataWithPropertyList:[newAggregatedHunkContents allObjects]
																	 format:NSPropertyListBinaryFormat_v1_0
																	options:0
																	  error:NULL];
		[newData writeToFile:aggregatedHunkFilePath atomically:YES];
		[_cloudFileSystem uploadLocalFile:aggregatedHunkFilePath toPath:[A3DictionaryDBLogsDirectoryName stringByAppendingPathComponent:A3DictionaryDBFirstHunkFilename] completion:NULL];
	}];
}

- (void)uploadLogFiles {
	[_cloudFileSystem connect:^(NSError *error) {
		[_cloudFileSystem fileExistsAtPath:A3DictionaryDBLogsDirectoryName completion:^(BOOL exists, BOOL isDirectory, NSError *error_1) {
			if (exists) {
				[self uploadLogFilesInLocalDirectoryToCloud];
			} else {
				FNLOG(@"Log directory does not exist. Trying create directory.");
				[_cloudFileSystem createDirectoryAtPath:A3DictionaryDBLogsDirectoryName completion:^(NSError *error_2) {
					if (!error_2) {
						[self uploadLogFilesInLocalDirectoryToCloud];
					}
				}];
			}
		}];
	}];
}

- (NSMutableSet *)downloadedFilesSet {
	NSArray *array = [NSArray arrayWithContentsOfFile:[self downloadedFileListFilePath]];
	if (array) {
		return [NSMutableSet setWithArray:array];
	}
	return [NSMutableSet new];
}

- (void)addFilenameToDownloadedFileList:(NSString *)filename {
	NSMutableSet *downloadedFileList = [self downloadedFilesSet];
	[downloadedFileList addObject:filename];
	[[downloadedFileList allObjects] writeToFile:[self downloadedFileListFilePath] atomically:YES];
}

- (void)uploadLogFilesInLocalDirectoryToCloud {
	NSArray *fileList = [_fileManager contentsOfDirectoryAtPath:[self transactionLogDirectoryPath] error:NULL];
	for (NSString *path in fileList) {
		NSString *cloudFilePath = [A3DictionaryDBLogsDirectoryName stringByAppendingPathComponent:path.lastPathComponent];
		[_cloudFileSystem fileExistsAtPath:cloudFilePath completion:^(BOOL exists, BOOL isDirectory, NSError *error_1) {
			if (!exists) {
				FNLOG(@"Try uploading : %@", path.lastPathComponent);
				[_cloudFileSystem uploadLocalFile:path toPath:cloudFilePath completion:^(NSError *error_2) {
					if (!error_2) {
						FNLOG(@"Successfully uploaded file : %@", cloudFilePath);
						[self addFilenameToDownloadedFileList:path.lastPathComponent];
					} else {
						FNLOG(@"Failed to uploading file : %@", cloudFilePath);
					}
				}];
			}
		}];
	}
}

- (void)playTransactions {
	FNLOG();
	NSMutableArray *allTransactions = [NSMutableArray new];
	NSString *baselineFilePath = [[self transactionLogDirectoryPath] stringByAppendingPathComponent:A3DictionaryDBFirstHunkFilename];
	if ([_fileManager fileExistsAtPath:baselineFilePath]) {
		NSData *data = [NSData dataWithContentsOfFile:baselineFilePath];
		if (data) {
			NSError *conversionError;
			NSArray *transactions = [NSPropertyListSerialization propertyListWithData:data
																			  options:NSPropertyListMutableContainersAndLeaves
																			   format:nil
																				error:&conversionError];
			if (!conversionError) {
				[allTransactions addObjectsFromArray:transactions];
			}
		} else {
			FNLOG(@"Failed to read log file: %@", baselineFilePath.lastPathComponent);
		}
	}

	NSArray *logFiles = [_fileManager contentsOfDirectoryAtPath:[self transactionLogDirectoryPath] error:NULL];
	FNLOG(@"%@", logFiles);
	for (NSString *logFile in logFiles) {
		if (![[logFile lastPathComponent] isEqualToString:A3DictionaryDBFirstHunkFilename]) {
			NSData *data = [NSData dataWithContentsOfFile:[[self transactionLogDirectoryPath] stringByAppendingPathComponent:logFile]];
			if (data) {
				NSError *error;
				NSArray *transactions = [NSPropertyListSerialization propertyListWithData:data
																				  options:NSPropertyListMutableContainersAndLeaves
																				   format:nil
																					error:&error];
				if (!error) {
					[allTransactions addObjectsFromArray:transactions];
				}
			} else {
				FNLOG(@"Failed to read log file: %@", logFile.lastPathComponent);
			}
		}
	}

	[allTransactions sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSDate *dateObj1 = obj1[A3DictionaryDBTimestamp];
		NSDate *dateObj2 = obj2[A3DictionaryDBTimestamp];
		return [dateObj1 compare:dateObj2];
	}];

	NSString *lastPlayedTransactionIDPath = [A3DictionaryDBLastPlayedTransactionID pathInLibraryDirectory];
	NSString *lastPlayedTransactionID = nil;
	if ([_fileManager fileExistsAtPath:lastPlayedTransactionIDPath]) {
		lastPlayedTransactionID = [NSString stringWithContentsOfFile:lastPlayedTransactionIDPath encoding:NSUTF8StringEncoding error:NULL];
	}
	NSUInteger indexOfTransaction = NSNotFound;
	if (lastPlayedTransactionID) {
		indexOfTransaction = [allTransactions indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
			return [obj[A3DictionaryDBTransactionID] isEqualToString:lastPlayedTransactionID];
		}];
	}

	NSString *currentDeviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	
	NSUInteger idx = indexOfTransaction == NSNotFound ? 0 : indexOfTransaction + 1;
	for (; idx < [allTransactions count]; idx++ ) {
		NSDictionary *transaction = allTransactions[idx];
		FNLOG(@"Total: %ld, current: %ld, %@:%@, %@", (long)[allTransactions count], (long)idx, transaction[A3DictionaryDBEntityKey], transaction[A3DictionaryDBTransactionType], transaction[A3DictionaryDBTimestamp]);
		if (![transaction[A3DictionaryDBDeviceID] isEqualToString:currentDeviceID]) {
			NSArray *targetObject = [self dataObjectForFilename:transaction[A3DictionaryDBEntityKey]];
			NSMutableArray *mutableTargetEntity = [NSMutableArray new];
			if (targetObject) {
				[mutableTargetEntity addObjectsFromArray:targetObject];
			}
			switch ((A3DictionaryDBTransactionTypeValue)[transaction[A3DictionaryDBTransactionType] unsignedIntegerValue]) {
				case A3DictionaryDBTransactionTypeSetBaseline:{
					NSArray *baselineObject = transaction[A3DictionaryDBObject];
					if ([baselineObject isEqual:A3SyncManagerEmptyObject]) {
						[mutableTargetEntity removeAllObjects];
					} else {
						mutableTargetEntity = [baselineObject mutableCopy];
					}
					break;
				}
				case A3DictionaryDBTransactionTypeInsertTop:
					[mutableTargetEntity insertObject:transaction[A3DictionaryDBObject] atIndex:0];
					break;
				case A3DictionaryDBTransactionTypeInsertBottom:
					[mutableTargetEntity addObject:transaction[A3DictionaryDBObject]];
					break;
				case A3DictionaryDBTransactionTypeDelete: {
					NSString *deletingID = transaction[A3DictionaryDBObject];
					NSUInteger indexOfObject = [mutableTargetEntity indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx2, BOOL *stop) {
						return [obj[A3DictionaryDBUniqueID] isEqualToString:deletingID];
					}];
					if (indexOfObject != NSNotFound) {
						[mutableTargetEntity removeObjectAtIndex:indexOfObject];
					}
					break;
				}
				case A3DictionaryDBTransactionTypeUpdate: {
					NSDictionary *updatingObject = transaction[A3DictionaryDBObject];
					NSUInteger indexOfObject = [mutableTargetEntity indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx2, BOOL *stop) {
						return [obj[A3DictionaryDBUniqueID] isEqualToString:updatingObject[A3DictionaryDBUniqueID]];
					}];
					if (indexOfObject != NSNotFound) {
						[mutableTargetEntity replaceObjectAtIndex:indexOfObject withObject:updatingObject];
					}
					break;
				}
				case A3DictionaryDBTransactionTypeReplace: {
					NSArray *updatingObject = transaction[A3DictionaryDBObject];
					NSDictionary *oldObject = updatingObject[0];
					NSDictionary *newObject = updatingObject[1];
					NSUInteger indexOfObject = [mutableTargetEntity indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx2, BOOL *stop) {
						return [obj[A3DictionaryDBUniqueID] isEqualToString:oldObject[A3DictionaryDBUniqueID]];
					}];
					if (indexOfObject != NSNotFound) {
						[mutableTargetEntity replaceObjectAtIndex:indexOfObject withObject:newObject];
					}
					break;
				}
				case A3DictionaryDBTransactionTypeReorder: {
					NSArray *newOrder = transaction[A3DictionaryDBObject];
					NSMutableArray *newListByOrder = [NSMutableArray new];
					for (NSString *objectID in newOrder) {
						NSUInteger indexOfObject = [mutableTargetEntity indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx2, BOOL *stop) {
							return [obj[A3DictionaryDBUniqueID] isEqualToString:objectID];
						}];
						if (indexOfObject != NSNotFound) {
							[newListByOrder addObject:mutableTargetEntity[indexOfObject]];
							[mutableTargetEntity removeObjectAtIndex:indexOfObject];
						}
					}
					if ([mutableTargetEntity count]) {
						[newListByOrder addObjectsFromArray:mutableTargetEntity];
					}
					mutableTargetEntity = newListByOrder;
					break;
				}
			}
			[self saveDataObject:mutableTargetEntity forFilename:transaction[A3DictionaryDBEntityKey] state:A3DataObjectStateModified];
//			FNLOG(@"Transaction Log played: %@", transaction);
		} else {
			FNLOG(@"Transaction from current device skipped to play.");
		}
	}

	lastPlayedTransactionID = [allTransactions lastObject][A3DictionaryDBTransactionID];
	[lastPlayedTransactionID writeToFile:lastPlayedTransactionIDPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

- (void)createDirectories {
	NSString *logDirectory = [A3DictionaryDBLogsDirectoryName pathInLibraryDirectory];
	if (![_fileManager fileExistsAtPath:logDirectory]) {
		[_fileManager createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	[_cloudFileSystem connect:^(NSError *error) {
		[_cloudFileSystem fileExistsAtPath:A3DictionaryDBLogsDirectoryName completion:^(BOOL exists, BOOL isDirectory, NSError *error_1) {
			if (!exists) {
				[_cloudFileSystem createDirectoryAtPath:A3DictionaryDBLogsDirectoryName completion:^(NSError *error_2) {
					if (error_2) {
						FNLOG(@"%@", error_2.localizedDescription);
					}
				}];
			}
		}];
	}];
}

- (void)mergeNonCoreDataEntities {
	[_cloudFileSystem connect:^(NSError *error) {
		[_cloudFileSystem fileExistsAtPath:A3DictionaryDBLogsDirectoryName completion:^(BOOL exists, BOOL isDirectory, NSError *error_1) {
			if (!exists) {
				[_cloudFileSystem createDirectoryAtPath:A3DictionaryDBLogsDirectoryName completion:^(NSError *error_2) {
					// code 516 means directory already exists. Any how directory is exist, we can upload files to that directory.
					if (!error_2 || error_2.code == 516) {
						[self uploadBaseline];
					}
				}];
			} else {
				[_cloudFileSystem contentsOfDirectoryAtPath:A3DictionaryDBLogsDirectoryName completion:^(NSArray *contents, NSError *error_3) {
					if ([contents count]) {
						NSArray *targetEntities = @[
								A3CurrencyDataEntityFavorites,
								A3DaysCounterDataEntityCalendars,
								A3LadyCalendarDataEntityAccounts,
								A3WalletDataEntityCategoryInfo,
								A3UnitConverterDataEntityConvertItems,
								A3UnitConverterDataEntityFavorites,
								A3UnitConverterDataEntityUnitCategories,
								A3UnitPriceUserDataEntityPriceFavorites,
								A3MainMenuDataEntityFavorites,
								A3MainMenuDataEntityRecentlyUsed,
								A3MainMenuDataEntityAllMenu
						];

						NSMutableDictionary *backupDataDictionary = [NSMutableDictionary new];
						A3UserDefaults *userDefaults = [A3UserDefaults standardUserDefaults];

						for (NSString *key in targetEntities) {
							id backup = [self backupObjectForKey:key];
							if (backup) {
								[backupDataDictionary setObject:backup forKey:key];
							}
							[userDefaults removeObjectForKey:key];
						}
						if ([[backupDataDictionary allKeys] count] > 0) {
							[[A3UserDefaults standardUserDefaults] setObject:backupDataDictionary forKey:A3DictionaryDBInitialMergeObjects];
							[[A3UserDefaults standardUserDefaults] synchronize];
						}
						
						// Reset data to inital state.
						[A3CurrencyDataManager setupFavorites];
						[A3DaysCounterModelManager calendars];
						[WalletData walletCategoriesFilterDoNotShow:NO];
						[self removeDataObjectForKey:A3MainMenuDataEntityAllMenu];
						[self removeDataObjectForKey:A3MainMenuDataEntityFavorites];
						[self removeDataObjectForKey:A3MainMenuDataEntityRecentlyUsed];
						[self removeDataObjectForKey:A3UnitConverterDataEntityUnitCategories];
						[self removeDataObjectForKey:A3UnitConverterDataEntityConvertItems];
						[self removeDataObjectForKey:A3UnitConverterDataEntityFavorites];
						[self removeDataObjectForKey:A3UnitPriceUserDataEntityPriceFavorites];
						[self removeDataObjectForKey:A3LadyCalendarDataEntityAccounts];

						[self downloadLogFiles:NULL];
					} else {
						[self uploadBaseline];
					}
				}];
			}
		}];
	}];
}

- (void)uploadBaseline {
	[A3CurrencyDataManager setupFavorites];
	NSArray *currencyFavorites = [self dataObjectForFilename:A3CurrencyDataEntityFavorites];
	[self addTransaction:A3CurrencyDataEntityFavorites
					type:A3DictionaryDBTransactionTypeSetBaseline
				  object:currencyFavorites];

	NSArray *daysCounterCalendars = [A3DaysCounterModelManager calendars];
	[self addTransaction:A3DaysCounterDataEntityCalendars
					type:A3DictionaryDBTransactionTypeSetBaseline
				  object:daysCounterCalendars];

	NSArray *walletCategories = [WalletData walletCategoriesFilterDoNotShow:NO];
	[self addTransaction:A3WalletDataEntityCategoryInfo
					type:A3DictionaryDBTransactionTypeSetBaseline
				  object:walletCategories];

	A3LadyCalendarModelManager *ladyCalendarModelManager = [A3LadyCalendarModelManager new];
	[ladyCalendarModelManager prepareAccount];
	NSArray *ladyCalendarAccounts = [ladyCalendarModelManager accountList];
	[self addTransaction:A3LadyCalendarDataEntityAccounts
					type:A3DictionaryDBTransactionTypeSetBaseline
				  object:ladyCalendarAccounts];

	A3UnitDataManager *unitDataManager = [A3UnitDataManager new];
	[self addTransaction:A3UnitConverterDataEntityFavorites
					type:A3DictionaryDBTransactionTypeSetBaseline
				  object:[unitDataManager allFavorites]];
	[self addTransaction:A3UnitConverterDataEntityUnitCategories
					type:A3DictionaryDBTransactionTypeSetBaseline
				  object:[unitDataManager allCategories]];
	[self addTransaction:A3UnitConverterDataEntityConvertItems
					type:A3DictionaryDBTransactionTypeSetBaseline
				  object:[unitDataManager unitConvertItems]];
	[self addTransaction:A3UnitPriceUserDataEntityPriceFavorites
					type:A3DictionaryDBTransactionTypeSetBaseline
				  object:[unitDataManager allUnitPriceFavorites]];

	A3AppDelegate *appDelegate = [A3AppDelegate instance];
	[self addTransaction:A3MainMenuDataEntityAllMenu
					type:A3DictionaryDBTransactionTypeSetBaseline
				  object:[appDelegate allMenuArrayFromStoredDataFile]];
	NSArray *favoriteItems = [self dataObjectForFilename:A3MainMenuDataEntityFavorites];
	[self addTransaction:A3MainMenuDataEntityFavorites
					type:A3DictionaryDBTransactionTypeSetBaseline
				  object:favoriteItems ? favoriteItems : A3SyncManagerEmptyObject];
	NSArray *recentMenus = [self dataObjectForFilename:A3MainMenuDataEntityRecentlyUsed];
	[self addTransaction:A3MainMenuDataEntityRecentlyUsed
					type:A3DictionaryDBTransactionTypeSetBaseline
				  object:recentMenus ? recentMenus : A3SyncManagerEmptyObject];
}

- (NSArray *)backupObjectForKey:(NSString *)key {
	NSDictionary *dictionary = [[A3UserDefaults standardUserDefaults] objectForKey:key];
	if (dictionary && [dictionary[A3KeyValueDBState] unsignedIntegerValue] == A3DataObjectStateModified) {
		return dictionary[A3KeyValueDBDataObject];
	}
	return nil;
}

- (void)mergeForKey:(NSString *)key withBackupData:(NSArray *)backup {
	if (!backup) return;

	NSMutableArray *array = [[self objectForKey:key] mutableCopy];
	for (NSDictionary *object in backup) {
		NSUInteger idx = [array indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx2, BOOL *stop) {
			return [obj[A3DictionaryDBUniqueID] isEqualToString:object[A3DictionaryDBUniqueID]];
		}];
		if (idx == NSNotFound) {
			[array addObject:object];
			[self addTransaction:key type:A3DictionaryDBTransactionTypeInsertBottom object:object];
		}
	}
	[self saveDataObject:array forFilename:key state:A3DataObjectStateModified];
}

/*! iCloud를 끄면 log File 들을 모두 지운다.
 * \param
 * \returns
 */
- (void)deleteLogFiles {
	[_fileManager removeItemAtPath:[self downloadedFileListFilePath] error:NULL];
	[_fileManager removeItemAtPath:[A3DictionaryDBLastPlayedTransactionID pathInLibraryDirectory] error:NULL];
	NSArray *logFiles = [_fileManager contentsOfDirectoryAtPath:[self transactionLogDirectoryPath] error:NULL];
	for (NSString *path in logFiles) {
		[_fileManager removeItemAtPath:path error:NULL];
	}
}

@end
