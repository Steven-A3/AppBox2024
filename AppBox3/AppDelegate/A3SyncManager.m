//
//  A3SyncManager.m
//  AppBox3
//
//  Created by A3 on 7/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3SyncManager.h"
#import "A3AppDelegate.h"

NSString * const A3SyncManagerCloudEnabled = @"A3SyncManagerCloudEnabled";
NSString * const A3SyncActivityDidBeginNotification = @"A3SyncActivityDidBegin";
NSString * const A3SyncActivityDidEndNotification = @"A3SyncActivityDidEnd";

@interface A3SyncManager () <CDEPersistentStoreEnsembleDelegate>
@end

@implementation A3SyncManager
{
	NSUInteger _activeMergeCount;
	NSFileManager *fileManager;
	NSURL *rootDirectoryURL;
	NSOperationQueue *operationQueue;
	dispatch_queue_t timeOutQueue;
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

- (id)init {
	self = [super init];
	if (self) {
		operationQueue = [[NSOperationQueue alloc] init];
		operationQueue.maxConcurrentOperationCount = 1;
		timeOutQueue = dispatch_queue_create("com.mentalfaculty.ensembles.queue.icloudtimeout", DISPATCH_QUEUE_SERIAL);
		rootDirectoryURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
		[rootDirectoryURL URLByAppendingPathComponent:@"net.allaboutapps.appbox"];
	}

	return self;
}

- (BOOL)isCloudAvailable {
	return [[NSFileManager defaultManager] ubiquityIdentityToken] != nil;
}

- (NSString *)cloudStoreID {
	return @"AppBoxCloudStore";
}

- (void)setupEnsemble
{
	if (!self.isCloudEnabled) return;

	NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:[[A3AppDelegate instance] storeFileName]];
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AppBox3" withExtension:@"momd"];
	_ensemble = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:self.cloudStoreID persistentStoreURL:storeURL managedObjectModelURL:modelURL cloudFileSystem:self.cloudFileSystem];
	_ensemble.delegate = self;
	rootDirectoryURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
	[rootDirectoryURL URLByAppendingPathComponent:@"net.allaboutapps.appbox"];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localSaveOccurred:) name:CDEMonitoredManagedObjectContextDidSaveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(icloudDidDownload:) name:CDEICloudFileSystemDidDownloadFilesNotification object:nil];
}

- (CDEICloudFileSystem *)cloudFileSystem {
	if (!_cloudFileSystem) {
		_cloudFileSystem = [[CDEICloudFileSystem alloc] initWithUbiquityContainerIdentifier:nil relativePathToRootInContainer:@"net.allaboutapps.appbox"];
	}
	return _cloudFileSystem;
}

- (void)enableCloudSync {
	if ([self isCloudEnabled]) return;

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

	[[NSUserDefaults standardUserDefaults] removeObjectForKey:A3SyncManagerCloudEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Sync Methods

- (void)icloudDidDownload:(NSNotification *)notif
{
	if (!self.isCloudEnabled) return;
	
	[self synchronizeWithCompletion:NULL];
	[[A3AppDelegate instance] uploadFilesToCloud];
	[[A3AppDelegate instance] downloadFilesFromCloud];
}

- (void)localSaveOccurred:(NSNotification *)notif
{
	if (!self.isCloudEnabled) return;
	
	[self synchronizeWithCompletion:NULL];
	[[A3AppDelegate instance] uploadFilesToCloud];
	[[A3AppDelegate instance] downloadFilesFromCloud];
}

- (BOOL)isCloudEnabled {
	return [[NSFileManager defaultManager] ubiquityIdentityToken] &&
			[[NSUserDefaults standardUserDefaults] boolForKey:A3SyncManagerCloudEnabled];
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
	_activeMergeCount--;
	if (_activeMergeCount == 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3SyncActivityDidEndNotification object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCloudCoreDataStoreDidImport object:nil];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

- (void)incrementMergeCount
{
	_activeMergeCount++;
	if (_activeMergeCount == 1) {
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

#pragma mark - Upload Download Manager

static const NSTimeInterval CDEFileCoordinatorTimeOut = 10.0;

- (void)fileExistsAtPath:(NSString *)path completion:(void(^)(BOOL exists, BOOL isDirectory, NSError *error))block
{
	[operationQueue addOperationWithBlock:^{
		NSError *fileCoordinatorError = nil;
		__block NSError *timeoutError = nil;
		__block BOOL coordinatorExecuted = NO;
		__block BOOL isDirectory = NO;
		__block BOOL exists = NO;

		NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];

		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, CDEFileCoordinatorTimeOut * NSEC_PER_SEC);
		dispatch_after(popTime, timeOutQueue, ^{
			if (!coordinatorExecuted) {
				[coordinator cancel];
				timeoutError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeFileCoordinatorTimedOut userInfo:nil];
			}
		});

		NSURL *url = [NSURL fileURLWithPath:[self fullPathForPath:path]];
		[coordinator coordinateReadingItemAtURL:url options:0 error:&fileCoordinatorError byAccessor:^(NSURL *newURL) {
			dispatch_sync(timeOutQueue, ^{ coordinatorExecuted = YES; });
			if (timeoutError) return;
			exists = [fileManager fileExistsAtPath:newURL.path isDirectory:&isDirectory];
		}];

		NSError *error = fileCoordinatorError ? : timeoutError ? : nil;
		dispatch_async(dispatch_get_main_queue(), ^{
			if (block) block(exists, isDirectory, error);
		});
	}];
}

- (void)contentsOfDirectoryAtPath:(NSString *)path completion:(void(^)(NSArray *contents, NSError *error))block
{
	[operationQueue addOperationWithBlock:^{
		NSError *fileCoordinatorError = nil;
		__block NSError *timeoutError = nil;
		__block NSError *fileManagerError = nil;
		__block BOOL coordinatorExecuted = NO;

		NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];

		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, CDEFileCoordinatorTimeOut * NSEC_PER_SEC);
		dispatch_after(popTime, timeOutQueue, ^{
			if (!coordinatorExecuted) {
				[coordinator cancel];
				timeoutError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeFileCoordinatorTimedOut userInfo:nil];
			}
		});

		__block NSArray *contents = nil;
		NSURL *url = [NSURL fileURLWithPath:[self fullPathForPath:path]];
		[coordinator coordinateReadingItemAtURL:url options:0 error:&fileCoordinatorError byAccessor:^(NSURL *newURL) {
			dispatch_sync(timeOutQueue, ^{ coordinatorExecuted = YES; });
			if (timeoutError) return;

			NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:[self fullPathForPath:path]];
			NSDictionary *info = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Couldn't create directory enumerator for path: %@", path]};
			if (!dirEnum) fileManagerError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeFileAccessFailed userInfo:info];

			NSString *filename;
			NSMutableArray *mutableContents = [[NSMutableArray alloc] init];
			while ((filename = [dirEnum nextObject])) {
				if ([filename hasPrefix:@"."]) continue; // Skip .DS_Store and other system files
				NSString *filePath = [path stringByAppendingPathComponent:filename];
				if ([dirEnum.fileAttributes.fileType isEqualToString:NSFileTypeDirectory]) {
					[dirEnum skipDescendants];

					CDECloudDirectory *dir = [[CDECloudDirectory alloc] init];
					dir.name = filename;
					dir.path = filePath;
					[mutableContents addObject:dir];
				}
				else {
					CDECloudFile *file = [CDECloudFile new];
					file.name = filename;
					file.path = filePath;
					file.size = dirEnum.fileAttributes.fileSize;
					[mutableContents addObject:file];
				}
			}

			if (!fileManagerError) contents = mutableContents;
		}];

		NSError *error = fileCoordinatorError ? : timeoutError ? : fileManagerError ? : nil;
		dispatch_async(dispatch_get_main_queue(), ^{
			if (block) block(contents, error);
		});
	}];

}

- (void)createDirectoryAtPath:(NSString *)path completion:(CDECompletionBlock)block
{
	[operationQueue addOperationWithBlock:^{
		NSError *fileCoordinatorError = nil;
		__block NSError *timeoutError = nil;
		__block NSError *fileManagerError = nil;
		__block BOOL coordinatorExecuted = NO;

		NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];

		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, CDEFileCoordinatorTimeOut * NSEC_PER_SEC);
		dispatch_after(popTime, timeOutQueue, ^{
			if (!coordinatorExecuted) {
				[coordinator cancel];
				timeoutError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeFileCoordinatorTimedOut userInfo:nil];
			}
		});

		NSURL *url = [NSURL fileURLWithPath:[self fullPathForPath:path]];
		[coordinator coordinateWritingItemAtURL:url options:0 error:&fileCoordinatorError byAccessor:^(NSURL *newURL) {
			dispatch_sync(timeOutQueue, ^{ coordinatorExecuted = YES; });
			if (timeoutError) return;
			[fileManager createDirectoryAtPath:newURL.path withIntermediateDirectories:NO attributes:nil error:&fileManagerError];
		}];

		NSError *error = fileCoordinatorError ? : timeoutError ? : fileManagerError ? : nil;
		dispatch_async(dispatch_get_main_queue(), ^{
			if (block) block(error);
		});
	}];
}

- (void)removeItemAtPath:(NSString *)path completion:(CDECompletionBlock)block
{
	[operationQueue addOperationWithBlock:^{
		NSError *fileCoordinatorError = nil;
		__block NSError *timeoutError = nil;
		__block NSError *fileManagerError = nil;
		__block BOOL coordinatorExecuted = NO;

		NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];

		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, CDEFileCoordinatorTimeOut * NSEC_PER_SEC);
		dispatch_after(popTime, timeOutQueue, ^{
			if (!coordinatorExecuted) {
				[coordinator cancel];
				timeoutError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeFileCoordinatorTimedOut userInfo:nil];
			}
		});

		NSURL *url = [NSURL fileURLWithPath:[self fullPathForPath:path]];
		[coordinator coordinateWritingItemAtURL:url options:NSFileCoordinatorWritingForDeleting error:&fileCoordinatorError byAccessor:^(NSURL *newURL) {
			dispatch_sync(timeOutQueue, ^{ coordinatorExecuted = YES; });
			if (timeoutError) return;
			[fileManager removeItemAtPath:newURL.path error:&fileManagerError];
		}];

		NSError *error = fileCoordinatorError ? : timeoutError ? : fileManagerError ? : nil;
		dispatch_async(dispatch_get_main_queue(), ^{
			if (block) block(error);
		});
	}];
}

- (void)uploadLocalFile:(NSString *)fromPath toPath:(NSString *)toPath completion:(CDECompletionBlock)block
{
	[operationQueue addOperationWithBlock:^{
		NSError *fileCoordinatorError = nil;
		__block NSError *timeoutError = nil;
		__block NSError *fileManagerError = nil;
		__block BOOL coordinatorExecuted = NO;

		NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];

		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, CDEFileCoordinatorTimeOut * NSEC_PER_SEC);
		dispatch_after(popTime, timeOutQueue, ^{
			if (!coordinatorExecuted) {
				[coordinator cancel];
				timeoutError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeFileCoordinatorTimedOut userInfo:nil];
			}
		});

		NSURL *fromURL = [NSURL fileURLWithPath:fromPath];
		NSURL *toURL = [NSURL fileURLWithPath:[self fullPathForPath:toPath]];
		[coordinator coordinateReadingItemAtURL:fromURL options:0 writingItemAtURL:toURL options:NSFileCoordinatorWritingForReplacing error:&fileCoordinatorError byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
			dispatch_sync(timeOutQueue, ^{ coordinatorExecuted = YES; });
			if (timeoutError) return;
			[fileManager removeItemAtPath:newWritingURL.path error:NULL];
			[fileManager copyItemAtPath:newReadingURL.path toPath:newWritingURL.path error:&fileManagerError];
		}];

		NSError *error = fileCoordinatorError ? : timeoutError ? : fileManagerError ? : nil;
		dispatch_async(dispatch_get_main_queue(), ^{
			if (block) block(error);
		});
	}];
}

- (void)downloadFromPath:(NSString *)fromPath toLocalFile:(NSString *)toPath completion:(CDECompletionBlock)block
{
	[operationQueue addOperationWithBlock:^{
		NSError *fileCoordinatorError = nil;
		__block NSError *timeoutError = nil;
		__block NSError *fileManagerError = nil;
		__block BOOL coordinatorExecuted = NO;

		NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];

		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, CDEFileCoordinatorTimeOut * NSEC_PER_SEC);
		dispatch_after(popTime, timeOutQueue, ^{
			if (!coordinatorExecuted) {
				[coordinator cancel];
				timeoutError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeFileCoordinatorTimedOut userInfo:nil];
			}
		});

		NSURL *fromURL = [NSURL fileURLWithPath:[self fullPathForPath:fromPath]];
		NSURL *toURL = [NSURL fileURLWithPath:toPath];
		[coordinator coordinateReadingItemAtURL:fromURL options:0 writingItemAtURL:toURL options:NSFileCoordinatorWritingForReplacing error:&fileCoordinatorError byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
			dispatch_sync(timeOutQueue, ^{ coordinatorExecuted = YES; });
			if (timeoutError) return;
			[fileManager removeItemAtPath:newWritingURL.path error:NULL];
			[fileManager copyItemAtPath:newReadingURL.path toPath:newWritingURL.path error:&fileManagerError];
		}];

		NSError *error = fileCoordinatorError ? : timeoutError ? : fileManagerError ? : nil;
		dispatch_async(dispatch_get_main_queue(), ^{
			if (block) block(error);
		});
	}];
}

- (NSString *)fullPathForPath:(NSString *)path {
	return [[rootDirectoryURL path] stringByAppendingPathComponent:path];
}

@end
