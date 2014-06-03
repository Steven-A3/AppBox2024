//
//  A3AppDelegate+iCloud.m
//  AppBox3
//
//  Created by A3 on 12/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate+iCloud.h"
#import "A3CurrencyDataManager.h"
#import "CurrencyFavorite.h"
#import "SFKImage.h"
#import "A3LadyCalendarModelManager.h"
#import "A3DaysCounterModelManager.h"
#import "A3DataMigrationManager.h"

NSString *const A3UniqueIdentifier = @"uniqueIdentifier";
NSString *const A3iCloudLastDBImportKey = @"kA3iCloudLastDBImportKey";
NSString *const A3NotificationCoreDataReady = @"A3NotificationCoreDataReady";

@protocol UbiquityStoreManagerInternal <NSObject>

- (NSMutableDictionary *)optionsForCloudStoreURL:(NSURL *)cloudStoreURL;

@end

@protocol A3CloudCompatibleData <NSObject>

- (NSString *)uniqueIdentifier;
- (NSDate *)updateDate;

@end

@implementation A3AppDelegate (iCloud)

- (void)setupCloud {

	self.ubiquityStoreManager = [[UbiquityStoreManager alloc] initWithDelegate:self];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDidImportChanges:) name:USMStoreDidImportChangesNotification object:nil];
}

- (void)setCloudEnabled:(BOOL)enable {
	_needMigrateLocalDataToCloud = YES;

	[self.ubiquityStoreManager setCloudEnabled:enable];

	UIView *targetViewForHud = [[self visibleViewController] view];
	self.hud = [MBProgressHUD showHUDAddedTo:targetViewForHud animated:YES];
	self.hud.labelText = enable ? @"Enabling iCloud" : @"Disableing iCloud";
	self.hud.minShowTime = 2;
	self.hud.removeFromSuperViewOnHide = YES;
	__typeof(self) __weak weakSelf = self;
	self.hud.completionBlock = ^{
		weakSelf.hud = nil;
	};
}

- (void)cloudDidImportChanges:(NSNotification *)note {
#ifdef DEBUG
	NSArray *insertedObjects = [note.userInfo objectForKey:NSInsertedObjectsKey];
	NSArray *updatedObjects = [note.userInfo objectForKey:NSUpdatedObjectsKey];
	NSArray *deletedObjects = [note.userInfo objectForKey:NSDeletedObjectsKey];

	FNLOG(@"\n-----------------------------------------\n%@\n%@\n%@\n-----------------------------------------", insertedObjects, updatedObjects, deletedObjects);
#endif
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:A3iCloudLastDBImportKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSManagedObjectContext *)ubiquityStoreManager:(UbiquityStoreManager *)manager
		  managedObjectContextForUbiquityChanges:(NSNotification *)note {

	return self.managedObjectContext;
}

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager willLoadStoreIsCloud:(BOOL)isCloudStore {
	if (self.managedObjectContext) {
		NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
		[managedObjectContext performBlockAndWait:^{
			NSError *error = nil;
			if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
				NSLog(@"Unresolved error: %@\n%@", error, [error userInfo]);
			
			[managedObjectContext reset];
		}];

		[self setManagedObjectContext:nil];
		[self setPersistentStoreCoordinator:nil];
		
		[[MagicalRecordStack defaultStack] reset];

		self.coreDataReadyToUse = NO;
	}
}

- (void)resetCoreDataStack {
	[self setupMagicalRecordStackWithCoordinator:self.persistentStoreCoordinator];
}

- (void)setupMagicalRecordStackWithCoordinator:(NSPersistentStoreCoordinator *)coordinator {
	SQLiteMagicalRecordStack *magicalRecordStack = [SQLiteMagicalRecordStack new];
	magicalRecordStack.coordinator = coordinator;
	magicalRecordStack.store = coordinator.persistentStores[0];

	self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	magicalRecordStack.context = self.managedObjectContext;
	magicalRecordStack.context.persistentStoreCoordinator = coordinator;
	magicalRecordStack.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

	[MagicalRecordStack setDefaultStack:magicalRecordStack];
}

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager didLoadStoreForCoordinator:(NSPersistentStoreCoordinator *)coordinator
					 isCloud:(BOOL)isCloudStore {

	[self setPersistentStoreCoordinator:coordinator];
	[self setupMagicalRecordStackWithCoordinator:coordinator];

	self.coreDataReadyToUse = YES;

	if (isCloudStore) {
		if (_needMigrateLocalDataToCloud) {
			// Cloud data exist and we need to migrate.
			// Delete seeding data before migrate because cloud already has seed data such as CurrencyFavorite

			[self migrateLocalDataToCloudContext:self.managedObjectContext];
		}
	} else {
		[A3CurrencyDataManager setupFavorites];
		[A3DaysCounterModelManager reloadAlertDateListForLocalNotification];
		[A3LadyCalendarModelManager setupLocalNotification];
	}

	[self coreDataReady];
	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCoreDataReady object:nil];

	if (self.hud) {
		__typeof(self) __weak weakSelf = self;
		dispatch_async(dispatch_get_main_queue(), ^{
			UIImageView *imageView = [UIImageView new];
			[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:37]];
			[SFKImage setDefaultColor:[UIColor whiteColor]];
			imageView.image = [SFKImage imageNamed:@"u"];
			[imageView sizeToFit];
			weakSelf.hud.mode = MBProgressHUDModeCustomView;
			weakSelf.hud.customView = imageView;
			if (isCloudStore) {
				weakSelf.hud.labelText = @"iCloud Enabled";
				weakSelf.hud.detailsLabelText = @"Synging in backgorund";
			} else {
				weakSelf.hud.labelText = @"iCloud Disabled";
			}

			double delayInSeconds = 2.0;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[weakSelf.hud hide:YES];
			});
		});
	}
}

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager failedLoadingStoreWithCause:(UbiquityStoreErrorCause)cause context:(id)context
					wasCloud:(BOOL)wasCloudStore {

	dispatch_async( dispatch_get_main_queue(), ^{

		if (!wasCloudStore && ![_handleLocalStoreAlert isVisible]) {
			_handleLocalStoreAlert = [[UIAlertView alloc] initWithTitle:@"Local Store Problem"
															   message:@"Your datastore got corrupted and needs to be recreated."
															  delegate:self
													 cancelButtonTitle:nil otherButtonTitles:@"Recreate", nil];
			[_handleLocalStoreAlert show];
		}
	} );
}

- (BOOL)ubiquityStoreManager:(UbiquityStoreManager *)manager handleCloudContentCorruptionWithHealthyStore:(BOOL)storeHealthy {

	if (storeHealthy) {
		dispatch_async( dispatch_get_main_queue(), ^{
			if ([_cloudContentHealingAlert isVisible])
				return;

			_cloudContentHealingAlert = [[UIAlertView alloc]
					initWithTitle:@"iCloud Store Corruption"
						  message:@"\n\n\n\nRebuilding cloud store to resolve corruption."
						 delegate:self cancelButtonTitle:nil otherButtonTitles:@"Disable iCloud", nil];

			UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
					initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			activityIndicator.center = CGPointMake( 142, 90 );
			[activityIndicator startAnimating];
			[_cloudContentHealingAlert addSubview:activityIndicator];
			[_cloudContentHealingAlert show];
		} );

		return YES;
	}
	else {
		dispatch_async( dispatch_get_main_queue(), ^{
			if ([_cloudContentHealingAlert isVisible] || [_handleCloudContentWarningAlert isVisible])
				return;

			_cloudContentCorruptedAlert = [[UIAlertView alloc]
					initWithTitle:@"iCloud Store Corruption"
						  message:@"\n\n\n\nWaiting for another device to auto-correct the problem..."
						 delegate:self cancelButtonTitle:nil otherButtonTitles:@"Disable iCloud", @"Fix Now", nil];

			UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
					initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			activityIndicator.center = CGPointMake( 142, 90 );
			[activityIndicator startAnimating];
			[_cloudContentCorruptedAlert addSubview:activityIndicator];
			[_cloudContentCorruptedAlert show];
		} );

		return NO;
	}
}

- (BOOL)ubiquityStoreManager:(UbiquityStoreManager *)manager shouldMigrateFromStoreURL:(NSURL *)migrationStoreURL
				  toStoreURL:(NSURL *)destinationStoreURL isCloud:(BOOL)isCloudStore {
	// If it asks to migrate local data, it means we don't need to migrate data local data.
	_needMigrateLocalDataToCloud = NO;
	return isCloudStore;
}

#pragma mark - Migrate Local Data and remvoe duplication

- (void)migrateLocalDataToCloudContext:(NSManagedObjectContext *)cloudContext {
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
	NSURL *localStoreURL = self.ubiquityStoreManager.localStoreURL;

	NSError *error;
	NSPersistentStore *localStore = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:localStoreURL options:nil error:&error];
	NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[localContext setPersistentStoreCoordinator:psc];

	BOOL needMigration = NO;

	[CurrencyFavorite MR_truncateAllInContext:localContext];

	[localContext save:&error];
	[localContext reset];

	[cloudContext save:&error];
	[cloudContext reset];

	if (needMigration) {
		NSURL *targetURL = self.ubiquityStoreManager.URLForCloudStore;

		NSDictionary *cloudOptions = [(id<UbiquityStoreManagerInternal>)self.ubiquityStoreManager optionsForCloudStoreURL:targetURL];

		[psc lock];
		[psc migratePersistentStore:localStore toURL:targetURL options:cloudOptions withType:NSSQLiteStoreType error:nil];
		[psc unlock];
	}
}

- (BOOL)deDuplicateForEntity:(NSString *)entityName ignoreUpdateDate:(BOOL)ignoreUpdateDate localContext:(NSManagedObjectContext *)localContext cloudContext:(NSManagedObjectContext *)cloudContext {
	Class managedObject = NSClassFromString(entityName);
	NSArray *localData = [managedObject MR_findAllInContext:localContext];
	if (![localData count]) {
		return NO;
	}

	NSString *uniqueIdentifier = @"uniqueIdentifier";

	NSArray *uniqueIdentifiers = [localData valueForKeyPath:uniqueIdentifier];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN (%@)", uniqueIdentifier, uniqueIdentifiers];
	NSArray *duplicatesInCloud = [managedObject MR_findAllSortedBy:uniqueIdentifier
														 ascending:YES
													 withPredicate:predicate
														 inContext:cloudContext];

	NSArray *uuidsDuplicated = [duplicatesInCloud valueForKeyPath:uniqueIdentifier];

	predicate = [NSPredicate predicateWithFormat:@"%K IN (%@)", uniqueIdentifier, uuidsDuplicated];
	NSArray *duplicatedObjectsInLocal = [managedObject MR_findAllSortedBy:uniqueIdentifier
																ascending:YES
															withPredicate:predicate
																inContext:localContext];

	NSString *updateDate = @"updateDate";
	[duplicatedObjectsInLocal enumerateObjectsUsingBlock:^(NSManagedObject *objInLocal, NSUInteger idx, BOOL *stop) {
		NSManagedObject *objectInCloud = duplicatesInCloud[idx];
		if (ignoreUpdateDate) {
			[localContext deleteObject:objInLocal];
		} else {
			NSDate *dateInLocal = [objInLocal valueForKeyPath:updateDate];
			NSDate *dateInCloud = [objectInCloud valueForKeyPath:updateDate];
			NSComparisonResult result = [dateInLocal compare:dateInCloud];
			if (result == NSOrderedAscending || result == NSOrderedSame) {
				[localContext deleteObject:objInLocal];
			} else {
				[cloudContext deleteObject:objectInCloud];
			}
		}
	}];

	return [managedObject MR_countOfEntitiesWithContext:localContext] > 0;
}

- (void)deDupeForEntity:(NSString *)entityName {
	//if importNotification, scope dedupe by inserted records
	//else no search scope, prey for efficiency.
	NSError *error = nil;
	NSManagedObjectContext *moc = self.managedObjectContext;

	NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName:entityName];
	[fr setIncludesPendingChanges:NO]; //distinct has to go down to the db, not implemented for in memory filtering
	[fr setFetchBatchSize:1000]; //protect thy memory

	NSExpression *countExpr = [NSExpression expressionWithFormat:@"count:(uniqueIdentifier)"];
	NSExpressionDescription *countExprDesc = [[NSExpressionDescription alloc] init];
	[countExprDesc setName:@"count"];
	[countExprDesc setExpression:countExpr];
	[countExprDesc setExpressionResultType:NSInteger64AttributeType];

	NSAttributeDescription *uniqueIdentifierAttr = [[[NSEntityDescription entityForName:entityName inManagedObjectContext:moc] propertiesByName] objectForKey:A3UniqueIdentifier];
	[fr setPropertiesToFetch:[NSArray arrayWithObjects:uniqueIdentifierAttr, countExprDesc, nil]];
	[fr setPropertiesToGroupBy:[NSArray arrayWithObject:uniqueIdentifierAttr]];

	[fr setResultType:NSDictionaryResultType];

	NSArray *countDictionaries = [moc executeFetchRequest:fr error:&error];
	NSMutableArray *uidWithDupes = [[NSMutableArray alloc] init];
	for (NSDictionary *dict in countDictionaries) {
		NSNumber *count = [dict objectForKey:@"count"];
		if ([count integerValue] > 1) {
			[uidWithDupes addObject:[dict objectForKey:A3UniqueIdentifier]];
		}
	}

	NSLog(@"uniqueIdentifiers with dupes: %@", uidWithDupes);
	if (![uidWithDupes count]) {
		return;
	}

	//fetch out all the duplicate records
	fr = [NSFetchRequest fetchRequestWithEntityName:entityName];
	[fr setIncludesPendingChanges:NO];

	NSPredicate *p = [NSPredicate predicateWithFormat:@"%K IN (%@)", A3UniqueIdentifier, uidWithDupes];
	[fr setPredicate:p];

	NSSortDescriptor *uniqueIdentifierSort = [NSSortDescriptor sortDescriptorWithKey:A3UniqueIdentifier ascending:YES];
	[fr setSortDescriptors:[NSArray arrayWithObject:uniqueIdentifierSort]];

	NSUInteger batchSize = 500; //can be set 100-10000 objects depending on individual object size and available device memory
	[fr setFetchBatchSize:batchSize];
	NSArray *dupes = [moc executeFetchRequest:fr error:&error];

	NSManagedObject<A3CloudCompatibleData> *prevObject = nil;

	NSUInteger i = 1;
	for (NSManagedObject<A3CloudCompatibleData> *object in dupes) {
		if (prevObject) {
			if ([object.uniqueIdentifier isEqualToString:prevObject.uniqueIdentifier]) {
				if ([object.updateDate compare:prevObject.updateDate] == NSOrderedAscending) {
					[moc deleteObject:object];
				} else {
					[moc deleteObject:prevObject];
					prevObject = object;
				}
			} else {
				prevObject = object;
			}
		} else {
			prevObject = object;
		}

		if (0 == (i % batchSize)) {
			//save the changes after each batch, this helps control memory pressure by turning previously examined objects back in to faults
			if ([moc save:&error]) {
				NSLog(@"Saved successfully after uniquing");
			} else {
				NSLog(@"Error saving unique results: %@", error);
			}
		}

		i++;
	}

	if ([moc save:&error]) {
		NSLog(@"Saved successfully after uniquing");
	} else {
		NSLog(@"Error saving unique results: %@", error);
	}
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// required or the app defaults to no background fetching
	[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
	return YES;
}

- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	// set the time of wake up to use for returning if we updated
	self.wakeUpTime = [NSDate date];
	NSLog(@"%s %@", __PRETTY_FUNCTION__, self.wakeUpTime);
		
	// pass on the completion handler to another method with delay to allow any imports to occur
	// the API Allows 30 seconds so I only delay for 28 seconds just to be safe
	[self performSelector:@selector(sendBGFetchCompletionHandler:) withObject:completionHandler afterDelay:28];
}

- (void) sendBGFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
	
	// get the time we were woke up to fetch
	NSDate *wakeUpCall = self.wakeUpTime;
	
	// the core data singleton saves the time of the last iCloud import into user defaults
	NSDate *iCloudImport = [userDefaults objectForKey:A3iCloudLastDBImportKey];
	
	// a bool to determine if changes were imported or not
	BOOL importedUpdates = NO;
	
	// compare the last import time against the wake up time to determine if we imported changes
	if (([wakeUpCall compare:iCloudImport] == NSOrderedAscending)) {
		//          NSLog(@"We have New Changes");
		importedUpdates = YES;
		completionHandler(UIBackgroundFetchResultNewData);
	} else {
		//          NSLog(@"We have NO New Changes");
		completionHandler(UIBackgroundFetchResultNoData);
	}
	
	// comment all the rest of this out for production builds
	
	// update the app icon badge & save results of fetch
	NSLog(@"Saving Update Results");
	
	// Saving the results into an array in user defaults for a tableview
	// that is only visible in debug builds to show these results
	
	// format the fetch timestamp
	NSString *fetchTime = [NSDateFormatter localizedStringFromDate:wakeUpCall dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
	
	// determine if changes were brought in
	NSString *resultString = importedUpdates ? @"YES" : @"NO";
	
	// build the string
	NSString *newString = [NSString stringWithFormat:@"%@ - Updates Imported: %@", fetchTime, resultString];
	
	// get or create the array from user defaults
	NSMutableArray *fetchDates = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"BackgroundFetchUpDates"]];
	if (!fetchDates) {
		fetchDates = [NSMutableArray arrayWithArray:@[newString]];
	}else{
		[fetchDates insertObject:newString atIndex:0];
	}
	
	// save the array back to user defaults
	[userDefaults setObject:fetchDates forKey:@"BackgroundFetchUpDates"];
	[userDefaults synchronize];

	[A3DaysCounterModelManager reloadAlertDateListForLocalNotification];
	[A3LadyCalendarModelManager setupLocalNotification];

	NSLog(@"%s - EXIT", __PRETTY_FUNCTION__);
}

@end
