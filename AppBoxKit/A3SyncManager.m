//
//  A3SyncManager.m
//  AppBox3
//
//  Created by A3 on 7/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SyncManager.h"
#import <Ensembles/Ensembles.h>
#import "common.h"
#import "NSString+conversion.h"
#import "NSManagedObject+extension.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3UserDefaults.h"
#import "NSFileManager+A3Addition.h"

NSString * const A3SyncManagerCloudEnabled = @"A3SyncManagerCloudEnabled";
NSString * const A3SyncActivityDidBeginNotification = @"A3SyncActivityDidBegin";
NSString * const A3SyncActivityDidEndNotification = @"A3SyncActivityDidEnd";
NSString * const A3SyncDeviceSyncStartInfo = @"A3SyncDeviceSyncStartInfo";	// Dictionary. Time and device name.
NSString * const A3SyncStartTime = @"A3SyncStartTime";
NSString * const A3SyncStartDevice = @"A3SyncStartDevice";
NSString * const A3SyncStartDenyReason = @"A3SyncStartDenyReason";
NSString *const A3NotificationCloudCoreDataStoreDidImport = @"A3CloudCoreDataStoreDidImport";
NSString *const A3NotificationCloudKeyValueStoreDidImport = @"A3CloudKeyValueStoreDidImport";

NSString *const A3DaysCounterImageDirectory = @"DaysCounterImages";
NSString *const A3DaysCounterImageThumbnailDirectory = @"DaysCounterPhotoThumbnail";
NSString *const A3WalletImageDirectory = @"WalletImages";        // in Library Directory
NSString *const A3WalletVideoDirectory = @"WalletVideos";        // in Library Directory
NSString *const A3WalletImageThumbnailDirectory = @"WalletImageThumbnails";    // in Caches Directory
NSString *const A3WalletVideoThumbnailDirectory = @"WalletVideoThumbnails"; // in Caches Directory

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
NSString *const A3AppName_QRCode = @"QR Code";
NSString *const A3AppName_Pedometer = @"Pedometer";
NSString *const A3AppName_Abbreviation = @"Abbreviation";
NSString *const A3AppName_Kaomoji = @"Kaomoji";

NSString *const A3AppName_Settings = @"Settings";
NSString *const A3AppName_About = @"About";
NSString *const A3AppName_RemoveAds = @"Remove Ads";
NSString *const A3AppName_RestorePurchase = @"Restore Purchase";
NSString *const A3AppName_None = @"None";

NSString *const kA3AdsUserDidSelectPersonalizedAds = @"kA3AdsUserDidSelectPersonalizedAds";

typedef NS_ENUM(NSUInteger, A3SyncStartDenyReasonValue) {
	A3SyncStartDeniedBecauseOtherDeviceDidStartSyncWithin10Minutes,
	A3SyncStartDeniedBecauseCloudDeleteStartedWithin10Minutes
};

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
	if (interval >= 60 * 1) {
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

	[self setupEnsemble];
	[self synchronizeWithCompletion:^(NSError *error) {
		[self.ensemble mergeWithCompletion:NULL];
	}];
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

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *storeURL = [fileManager storeURL];
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AppBox3" withExtension:@"momd"];
	_ensemble = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:self.cloudStoreID persistentStoreURL:storeURL managedObjectModelURL:modelURL cloudFileSystem:self.cloudFileSystem];
	_ensemble.delegate = self;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localSaveOccurred:) name:CDEMonitoredManagedObjectContextDidSaveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDidDownload:) name:CDEICloudFileSystemDidDownloadFilesNotification object:nil];
}

- (void)disableCloudSync {
	[_ensemble deleechPersistentStoreWithCompletion:^(NSError *error) {
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
            if (error && !self->_ensemble.isLeeched) {
				NSLog(@"Could not leech to ensemble: %@", error);
				[self disableCloudSync];
			}
			else {
                self->_leechFailCount = 0;
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
    NSManagedObjectContext *rootContext = self.persistentContainer.viewContext;
	[rootContext performBlockAndWait:^{
		[rootContext mergeChangesFromContextDidSaveNotification:notification];
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
		[self->_cloudFileSystem fileExistsAtPath:directory completion:^(BOOL exists, BOOL isDirectory, NSError *error_) {
			void (^fileCopyBlock)(NSError *) = ^(NSError *error__){
				NSArray *files = [self->_fileManager contentsOfDirectoryAtPath:[directory pathInLibraryDirectory] error:NULL];
				NSString *localBasePath = [directory pathInLibraryDirectory];
				for (NSString *filename in files) {
					NSString *localPath = [localBasePath stringByAppendingPathComponent:filename];
					NSString *cloudPath = [directory stringByAppendingPathComponent:filename];

					[self->_cloudFileSystem fileExistsAtPath:cloudPath completion:^(BOOL exists_, BOOL isDirectory_, NSError *error___) {
						if (!exists_) {
							FNLOG(@"Filename: %@", filename);
							[self->_cloudFileSystem uploadLocalFile:localPath toPath:cloudPath completion:NULL];
						}
					}];
				}
			};
			if (!exists) {
				[self->_cloudFileSystem createDirectoryAtPath:directory completion:fileCopyBlock];
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
        [self->_cloudFileSystem contentsOfDirectoryAtPath:directory completion:^(NSArray *contents, NSError *error_) {
			for (CDECloudFile *file in contents) {
				NSString *filename = file.name;
				NSString *localFile = [[directory stringByAppendingPathComponent:filename] pathInLibraryDirectory];

				if (![self->_fileManager fileExistsAtPath:localFile]) {
					FNLOG(@"%@, %@", file.name, file.path);
					[self->_cloudFileSystem downloadFromPath:file.path toLocalFile:localFile completion:NULL];
				}
			}
		}];
	}];
}

@end
