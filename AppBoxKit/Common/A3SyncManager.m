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
#import "AppBoxKit/AppBoxKit-Swift.h"

NSString * const A3SyncManagerCloudEnabled = @"A3SyncManagerCloudEnabled";
NSString * const A3SyncActivityDidBeginNotification = @"A3SyncActivityDidBegin";
NSString * const A3SyncActivityDidEndNotification = @"A3SyncActivityDidEnd";
NSString * const A3SyncDeviceSyncStartInfo = @"A3SyncDeviceSyncStartInfo";	// Dictionary. Time and device name.
NSString * const A3SyncStartTime = @"A3SyncStartTime";
NSString * const A3SyncStartDevice = @"A3SyncStartDevice";
NSString * const A3SyncStartDenyReason = @"A3SyncStartDenyReason";
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
	}

	return self;
}

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
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Info", @"Info")
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];

    // Add the "OK" action to the alert
    [alertController addAction:okAction];

    // Present the alert
    UIViewController *rootViewController = [UIApplication sharedApplication].myKeyWindow.rootViewController;
    [rootViewController presentViewController:alertController animated:YES completion:nil];
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

//- (CDEICloudFileSystem *)cloudFileSystem {
//	if (!_cloudFileSystem) {
//		_cloudFileSystem = [[CDEICloudFileSystem alloc] initWithUbiquityContainerIdentifier:@"iCloud.net.allaboutapps.AppBox"
//                                                              relativePathToRootInContainer:[self rootDirectoryName]];
//	}
//	return _cloudFileSystem;
//}

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

//- (void)disableCloudSync {
//	[_ensemble deleechPersistentStoreWithCompletion:^(NSError *error) {
//		[self reset];
//	}];
//}

- (void)reset
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CDEMonitoredManagedObjectContextDidSaveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CDEICloudFileSystemDidDownloadFilesNotification object:nil];

//	_ensemble.delegate = nil;
//	_ensemble = nil;

	[[A3UserDefaults standardUserDefaults] removeObjectForKey:A3SyncManagerCloudEnabled];
	[[A3UserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Sync Methods

- (BOOL)isCloudEnabled {
    return [[NSFileManager defaultManager] ubiquityIdentityToken];
}

@end
