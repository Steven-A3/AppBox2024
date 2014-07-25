//
//  A3SyncManager.m
//  AppBox3
//
//  Created by A3 on 7/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SyncManager.h"
#import "A3AppDelegate.h"

NSString * const A3SyncManagerCloudStoreID = @"A3SyncManagerCloudStoreID";
NSString * const A3SyncActivityDidBeginNotification = @"A3SyncActivityDidBegin";
NSString * const A3SyncActivityDidEndNotification = @"A3SyncActivityDidEnd";

@interface A3SyncManager () <CDEPersistentStoreEnsembleDelegate>
@end

@implementation A3SyncManager {
	CDEICloudFileSystem *cloudFileSystem;
	NSUInteger activeMergeCount;
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

- (BOOL)isCloudAvailable {
	return [[NSFileManager defaultManager] ubiquityIdentityToken] != nil;
}

- (NSString *)cloudStoreID {
	id ubiquityIdentityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
	if (!ubiquityIdentityToken) return nil;

	NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
	NSString *cloudStoreID = [keyValueStore objectForKey:A3SyncManagerCloudStoreID];
	return cloudStoreID;
}

- (NSString *)createCloudStoreID {
	NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
	NSString *cloudStoreID = [keyValueStore objectForKey:A3SyncManagerCloudStoreID];
	if (![cloudStoreID length]) {
		cloudStoreID = [[NSUUID UUID] UUIDString];
		[keyValueStore setObject:cloudStoreID forKey:A3SyncManagerCloudStoreID];
		[keyValueStore synchronize];
		FNLOG(@"New Store ID Created: %@", cloudStoreID);
	} else {
		FNLOG(@"Key Value Store already has Store ID: %@", cloudStoreID);
	}
	[[NSUserDefaults standardUserDefaults] setObject:cloudStoreID forKey:A3SyncManagerCloudStoreID];
	[[NSUserDefaults standardUserDefaults] synchronize];

	return cloudStoreID;
}

- (void)setupEnsemble
{
	if (!self.isCloudEnabled) return;

	cloudFileSystem = [[CDEICloudFileSystem alloc] initWithUbiquityContainerIdentifier:nil];
	if (!cloudFileSystem) return;

	NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:[[A3AppDelegate instance] storeFileName]];
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AppBox3" withExtension:@"momd"];
	_ensemble = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:self.cloudStoreID persistentStoreURL:storeURL managedObjectModelURL:modelURL cloudFileSystem:cloudFileSystem];
	_ensemble.delegate = self;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localSaveOccurred:) name:CDEMonitoredManagedObjectContextDidSaveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(icloudDidDownload:) name:CDEICloudFileSystemDidDownloadFilesNotification object:nil];
}

- (void)removeCloudStore {
	// Delete and forget
	NSString *storeID = [self cloudStoreID];
	if (![storeID length]) return;
	[CDEPersistentStoreEnsemble removeEnsembleWithIdentifier:self.cloudStoreID inCloudFileSystem:cloudFileSystem completion:^(NSError *error) {
		if (!error) {
			[[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:A3SyncManagerCloudStoreID];
			[[NSUbiquitousKeyValueStore defaultStore] synchronize];
		}
	}];
}

- (void)enableCloudSync {
	if ([self isCloudEnabled]) return;

	[self createCloudStoreID];
	[self setupEnsemble];
	[self synchronizeWithCompletion:^(NSError *error) {
		[self.ensemble mergeWithCompletion:NULL];
	}];
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

	[[NSUserDefaults standardUserDefaults] removeObjectForKey:A3SyncManagerCloudStoreID];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Sync Methods

- (void)icloudDidDownload:(NSNotification *)notif
{
	[self synchronizeWithCompletion:NULL];
}

- (void)localSaveOccurred:(NSNotification *)notif
{
	[self synchronizeWithCompletion:NULL];
}

- (BOOL)isCloudEnabled {
	FNLOG(@"Cloud Store ID : %@", [[NSUserDefaults standardUserDefaults] objectForKey:A3SyncManagerCloudStoreID]);
	return [[NSFileManager defaultManager] ubiquityIdentityToken] &&
			[[[NSUserDefaults standardUserDefaults] objectForKey:A3SyncManagerCloudStoreID] length];
}

- (void)synchronizeWithCompletion:(CDECompletionBlock)completion
{
	if (!self.isCloudEnabled) return;

	[self incrementMergeCount];
	if (!_ensemble.isLeeched) {
		[_ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
			[self decrementMergeCount];
			if (error && !_ensemble.isLeeched) {
				NSLog(@"Could not leech to ensemble: %@", error);
				[self disableCloudSync];
			}
			else {
				if (completion) completion(error);
			}
		}];
	}
	else {
		[_ensemble mergeWithCompletion:^(NSError *error) {
			[self decrementMergeCount];
			if (error) NSLog(@"Error merging: %@", error);
			if (completion) completion(error);
		}];
	}
}

- (void)decrementMergeCount
{
	activeMergeCount--;
	if (activeMergeCount == 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3SyncActivityDidEndNotification object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCloudCoreDataStoreDidImport object:nil];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

- (void)incrementMergeCount
{
	activeMergeCount++;
	if (activeMergeCount == 1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3SyncActivityDidBeginNotification object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCloudCoreDataStoreDidImport object:nil];
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

- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didDeleechWithError:(NSError *)error
{
	NSLog(@"Store did deleech with error: %@", error);
	[self reset];
}

@end
