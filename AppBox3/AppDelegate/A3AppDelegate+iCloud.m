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
#import "DaysCounterEvent+management.h"
#import "NSString+conversion.h"
#import "WalletFieldItem+initialize.h"
#import "WalletCategory.h"
#import "WalletCategory+extension.h"
#import "UnitConvertItem.h"
#import "UnitConvertItem+initialize.h"
#import "UnitFavorite.h"
#import "UnitFavorite+initialize.h"
#import "UnitItem+initialize.h"
#import "UnitType+initialize.h"
#import "UnitPriceFavorite+initialize.h"
#import "Calculation.h"
#import "CurrencyHistory.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterFavorite.h"
#import "DaysCounterReminder.h"
#import "ExpenseListHistory.h"
#import "ExpenseListBudget.h"
#import "ExpenseListCategories.h"
#import "LadyCalendarAccount.h"
#import "LadyCalendarPeriod+extension.h"
#import "LoanCalcComparisonHistory.h"
#import "LoanCalcHistory.h"
#import "PercentCalcHistory.h"
#import "SalesCalcHistory.h"
#import "TipCalcHistory.h"
#import "TranslatorFavorite.h"
#import "TranslatorGroup.h"
#import "UnitHistory.h"
#import "UnitPriceHistory.h"
#import "UnitPriceInfo.h"
#import "WalletFavorite.h"
#import "WalletItem+Favorite.h"

NSString *const A3UniqueIdentifier = @"uniqueID";
NSString *const A3iCloudLastDBImportKey = @"kA3iCloudLastDBImportKey";
NSString *const A3NotificationCoreDataReady = @"A3NotificationCoreDataReady";
NSString *const A3CloudHasData = @"A3CloudHasData";

@protocol UbiquityStoreManagerInternal <NSObject>

- (NSMutableDictionary *)optionsForLocalStore;
- (NSMutableDictionary *)optionsForCloudStoreURL:(NSURL *)cloudStoreURL;

@end

@protocol A3CloudCompatibleData <NSObject>

- (NSString *)uniqueID;
- (NSDate *)updateDate;
- (void)moveChildesFromObject:(id)object;

@end

@implementation A3AppDelegate (iCloud)

- (void)setupCloud {

	self.ubiquityStoreManager = [[UbiquityStoreManager alloc] initWithDelegate:self];
	self.ubiquityStoreManager.migrationStrategy = UbiquityStoreMigrationStrategyIOS;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDidImportChanges:) name:USMStoreDidImportChangesNotification object:nil];
}

- (void)setCloudEnabled:(BOOL)enable deleteCloud:(BOOL)deleteCloud {
	_needsDataMigrationBetweenLocalCloud = YES;

	if (enable) {
		if (deleteCloud) {
			[self deleteCloudFilesToResetCloud];
			[self.ubiquityStoreManager setCloudEnabledAndOverwriteCloudWithLocalIfConfirmed:^(void (^confirmationAnswer)(BOOL)) {
				confirmationAnswer(YES);
				return;
			}];
		} else {
			[self.ubiquityStoreManager setCloudEnabled:YES];
		}
	}
	else {
		[self.ubiquityStoreManager migrateCloudToLocal];
	}
	[self enableCloudForFiles:enable];

	UIView *targetViewForHud = [[self visibleViewController] view];
	self.hud = [MBProgressHUD showHUDAddedTo:targetViewForHud animated:YES];
	self.hud.labelText = enable ? NSLocalizedString(@"Enabling iCloud", @"Enabling iCloud") : NSLocalizedString(@"Disabling iCloud", @"Disableing iCloud");
	self.hud.minShowTime = 2;
	self.hud.removeFromSuperViewOnHide = YES;
	__typeof(self) __weak weakSelf = self;
	self.hud.completionBlock = ^{
		weakSelf.hud = nil;
	};
}

- (void)cloudDidImportChanges:(NSNotification *)note {
	FNLOG();
	NSSet *insertedObjects = [note.userInfo objectForKey:NSInsertedObjectsKey];

	NSMutableSet *candidates = [NSMutableSet new];
	for (id insertedObjectID in [insertedObjects allObjects]) {
		NSManagedObject *managedObject = [self.managedObjectContext objectWithID:insertedObjectID];
		[candidates addObject:NSStringFromClass([managedObject class])];
	}

	for (NSString *className in [candidates allObjects]) {
		if (
				[className isEqualToString:NSStringFromClass([Calculation class])] ||
				[className isEqualToString:NSStringFromClass([CurrencyFavorite class])] ||
				[className isEqualToString:NSStringFromClass([CurrencyHistory class])] ||
				[className isEqualToString:NSStringFromClass([DaysCounterCalendar class])] ||
				[className isEqualToString:NSStringFromClass([DaysCounterEvent class])] ||
				[className isEqualToString:NSStringFromClass([DaysCounterFavorite class])] ||
				[className isEqualToString:NSStringFromClass([DaysCounterReminder class])] ||
				[className isEqualToString:NSStringFromClass([ExpenseListHistory class])] ||
				[className isEqualToString:NSStringFromClass([ExpenseListBudget class])] ||
				[className isEqualToString:NSStringFromClass([ExpenseListCategories class])] ||
				[className isEqualToString:NSStringFromClass([LadyCalendarAccount class])] ||
				[className isEqualToString:NSStringFromClass([LadyCalendarPeriod class])] ||
				[className isEqualToString:NSStringFromClass([LoanCalcComparisonHistory class])] ||
				[className isEqualToString:NSStringFromClass([LoanCalcHistory class])] ||
				[className isEqualToString:NSStringFromClass([PercentCalcHistory class])] ||
				[className isEqualToString:NSStringFromClass([SalesCalcHistory class])] ||
				[className isEqualToString:NSStringFromClass([TipCalcHistory class])] ||
				[className isEqualToString:NSStringFromClass([TranslatorFavorite class])] ||
				[className isEqualToString:NSStringFromClass([TranslatorGroup class])] ||
				[className isEqualToString:NSStringFromClass([UnitItem class])] ||
				[className isEqualToString:NSStringFromClass([UnitConvertItem class])] ||
				[className isEqualToString:NSStringFromClass([UnitFavorite class])] ||
				[className isEqualToString:NSStringFromClass([UnitHistory class])] ||
				[className isEqualToString:NSStringFromClass([UnitPriceFavorite class])] ||
				[className isEqualToString:NSStringFromClass([UnitPriceHistory class])] ||
				[className isEqualToString:NSStringFromClass([UnitPriceInfo class])] ||
				[className isEqualToString:NSStringFromClass([UnitType class])] ||
				[className isEqualToString:NSStringFromClass([WalletCategory class])] ||
				[className isEqualToString:NSStringFromClass([WalletFavorite class])] ||
				[className isEqualToString:NSStringFromClass([WalletItem class])]
		)
		{
			[self deDupeForEntity:className];
		}
	}

	[self startDownloadAllFiles];

	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:A3iCloudLastDBImportKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	FNLOG();
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
				FNLOG(@"Unresolved error: %@\n%@", error, [error userInfo]);
			
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
	FNLOG();
	[self setPersistentStoreCoordinator:coordinator];
	[self setupMagicalRecordStackWithCoordinator:coordinator];

	self.coreDataReadyToUse = YES;

	if (isCloudStore) {
		NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
		[keyValueStore setBool:YES forKey:A3CloudHasData];
		[keyValueStore synchronize];

		[self startDownloadAllFiles];

		if (_needsDataMigrationBetweenLocalCloud) {
			// Cloud data exist and we need to migrate.
			// Delete seeding data before migrate because cloud already has seed data such as CurrencyFavorite

			[self migrateLocalDataToCloudContext];
		}

		// Initial de duplication of redundant data.
		[self deDupeForEntity:NSStringFromClass([Calculation class])];
		[self deDupeForEntity:NSStringFromClass([CurrencyFavorite class])];
		[self deDupeForEntity:NSStringFromClass([CurrencyHistory class])];
		[self deDupeForEntity:NSStringFromClass([DaysCounterCalendar class])];
		[self deDupeForEntity:NSStringFromClass([DaysCounterEvent class])];
		[self deDupeForEntity:NSStringFromClass([DaysCounterFavorite class])];
		[self deDupeForEntity:NSStringFromClass([DaysCounterReminder class])];
		[self deDupeForEntity:NSStringFromClass([ExpenseListHistory class])];
		[self deDupeForEntity:NSStringFromClass([ExpenseListBudget class])];
		[self deDupeForEntity:NSStringFromClass([ExpenseListCategories class])];
		[self deDupeForEntity:NSStringFromClass([LadyCalendarAccount class])];
		[self deDupeForEntity:NSStringFromClass([LadyCalendarPeriod class])];
		[self deDupeForEntity:NSStringFromClass([LoanCalcComparisonHistory class])];
		[self deDupeForEntity:NSStringFromClass([LoanCalcHistory class])];
		[self deDupeForEntity:NSStringFromClass([PercentCalcHistory class])];
		[self deDupeForEntity:NSStringFromClass([SalesCalcHistory class])];
		[self deDupeForEntity:NSStringFromClass([TipCalcHistory class])];
		[self deDupeForEntity:NSStringFromClass([TranslatorFavorite class])];
		[self deDupeForEntity:NSStringFromClass([TranslatorGroup class])];
		[self deDupeForEntity:NSStringFromClass([UnitItem class])];
		[self deDupeForEntity:NSStringFromClass([UnitConvertItem class])];
		[self deDupeForEntity:NSStringFromClass([UnitFavorite class])];
		[self deDupeForEntity:NSStringFromClass([UnitHistory class])];
		[self deDupeForEntity:NSStringFromClass([UnitPriceFavorite class])];
		[self deDupeForEntity:NSStringFromClass([UnitPriceHistory class])];
		[self deDupeForEntity:NSStringFromClass([UnitPriceInfo class])];
		[self deDupeForEntity:NSStringFromClass([UnitType class])];
		[self deDupeForEntity:NSStringFromClass([WalletCategory class])];
		[self deDupeForEntity:NSStringFromClass([WalletFavorite class])];
		[self deDupeForEntity:NSStringFromClass([WalletItem class])];

	} else {
		if (!_needsDataMigrationBetweenLocalCloud) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[A3CurrencyDataManager setupFavorites];

				A3DaysCounterModelManager *modelManager = [A3DaysCounterModelManager new];
				[modelManager prepareInContext:self.managedObjectContext];

				A3LadyCalendarModelManager *dataManager = [A3LadyCalendarModelManager new];
				[dataManager prepareAccountInContext:self.managedObjectContext];
				if ([WalletCategory MR_countOfEntities] == 0) {
					[WalletCategory resetWalletCategoriesInContext:self.managedObjectContext];
				}

				if ([UnitConvertItem MR_countOfEntities] == 0) {
					[UnitConvertItem reset];
				}
				if ([UnitFavorite MR_countOfEntities] == 0) {
					[UnitFavorite reset];
				}
				if (![UnitType MR_countOfEntities]) {
					[UnitType resetUnitTypeLists];
				}
				if ([UnitPriceFavorite MR_countOfEntities] == 0) {
					[UnitPriceFavorite reset];
				}
			});
		}
	}

	[self coreDataReady];

	FNLOG();
	[A3DaysCounterModelManager reloadAlertDateListForLocalNotification];
	[A3LadyCalendarModelManager setupLocalNotification];
	FNLOG();

	[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCoreDataReady object:nil];
	FNLOG();

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
				weakSelf.hud.labelText = NSLocalizedString(@"iCloud Enabled", @"iCloud Enabled");
				weakSelf.hud.detailsLabelText = NSLocalizedString(@"Syncing in background", @"Syncing in backgorund");
			} else {
				weakSelf.hud.labelText = NSLocalizedString(@"iCloud Disabled", @"iCloud Disabled");
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
			_handleLocalStoreAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Local Store Problem", @"Local Store Problem")
																message:NSLocalizedString(@"Your datastore got corrupted and needs to be recreated.", @"Your datastore got corrupted and needs to be recreated.")
															   delegate:self
													  cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Recreate", @"Recreate"), nil];
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

#pragma mark - Migrate Local Data

- (void)migrateLocalDataToCloudContext {
	NSURL *localStoreURL = self.ubiquityStoreManager.localStoreURL;
	if (![[NSFileManager defaultManager] fileExistsAtPath:[localStoreURL path]]) {
		return;
	}

	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

	NSError *error;
	NSPersistentStore *localStore = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:localStoreURL options:nil error:&error];
	NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[localContext setPersistentStoreCoordinator:psc];

	NSURL *targetURL = self.ubiquityStoreManager.URLForCloudStore;

	NSDictionary *cloudOptions = [(id<UbiquityStoreManagerInternal>)self.ubiquityStoreManager optionsForCloudStoreURL:targetURL];

	[psc lock];
	[psc migratePersistentStore:localStore toURL:targetURL options:cloudOptions withType:NSSQLiteStoreType error:nil];
	[psc unlock];

	if ([[NSFileManager defaultManager] fileExistsAtPath:[localStoreURL path]]) {
		[[NSFileManager defaultManager] removeItemAtURL:localStoreURL error:NULL];
		NSString *path = [localStoreURL path];
		[[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingString:@"-shm"] error:NULL];
		[[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingString:@"-wal"] error:NULL];
	}
}

- (BOOL)deDuplicateForEntity:(NSString *)entityName ignoreUpdateDate:(BOOL)ignoreUpdateDate localContext:(NSManagedObjectContext *)localContext cloudContext:(NSManagedObjectContext *)cloudContext {
	Class managedObject = NSClassFromString(entityName);
	NSArray *localData = [managedObject MR_findAllInContext:localContext];
	if (![localData count]) {
		return NO;
	}

	NSString *uniqueIdentifier = @"uniqueID";

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
	FNLOG();
	//if importNotification, scope dedupe by inserted records
	//else no search scope, prey for efficiency.
	NSError *error = nil;
	NSManagedObjectContext *moc = self.managedObjectContext;

	NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName:entityName];
	[fr setIncludesPendingChanges:NO]; //distinct has to go down to the db, not implemented for in memory filtering
	[fr setFetchBatchSize:1000]; //protect thy memory

	NSExpression *countExpr = [NSExpression expressionWithFormat:@"count:(uniqueID)"];
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

	FNLOG(@"uniqueIdentifiers with dupes: %@", uidWithDupes);
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
			if ([object.uniqueID isEqualToString:prevObject.uniqueID]) {
				if ([object.updateDate compare:prevObject.updateDate] == NSOrderedAscending) {
					if ([prevObject respondsToSelector:@selector(moveChildesFromObject:)]) {
						[prevObject moveChildesFromObject:object];
					}
					[moc deleteObject:object];
				} else {
					if ([object respondsToSelector:@selector(moveChildesFromObject:)]) {
						[object moveChildesFromObject:prevObject];
					}
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
				FNLOG(@"Saved successfully after uniquing");
			} else {
				FNLOG(@"Error saving unique results: %@", error);
			}
		}

		i++;
	}

	if ([moc save:&error]) {
		FNLOG(@"Saved successfully after uniquing");
	} else {
		FNLOG(@"Error saving unique results: %@", error);
	}
	FNLOG();
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// required or the app defaults to no background fetching
	[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
	return YES;
}

- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	// set the time of wake up to use for returning if we updated
	self.wakeUpTime = [NSDate date];
	FNLOG(@"%s %@", __PRETTY_FUNCTION__, self.wakeUpTime);
		
	// pass on the completion handler to another method with delay to allow any imports to occur
	// the API Allows 30 seconds so I only delay for 28 seconds just to be safe
	[self performSelector:@selector(sendBGFetchCompletionHandler:) withObject:completionHandler afterDelay:28];
}

- (void) sendBGFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	FNLOG(@"%s", __PRETTY_FUNCTION__);
	NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
	
	// get the time we were woke up to fetch
	NSDate *wakeUpCall = self.wakeUpTime;
	
	// the core data singleton saves the time of the last iCloud import into user defaults
	NSDate *iCloudImport = [userDefaults objectForKey:A3iCloudLastDBImportKey];
	
	// a bool to determine if changes were imported or not
	BOOL importedUpdates = NO;
	
	// compare the last import time against the wake up time to determine if we imported changes
	if (([wakeUpCall compare:iCloudImport] == NSOrderedAscending)) {
		//          FNLOG(@"We have New Changes");
		importedUpdates = YES;
		completionHandler(UIBackgroundFetchResultNewData);
	} else {
		//          FNLOG(@"We have NO New Changes");
		completionHandler(UIBackgroundFetchResultNoData);
	}
	
	// comment all the rest of this out for production builds
	
	// update the app icon badge & save results of fetch
	FNLOG(@"Saving Update Results");
	
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

	FNLOG(@"%s - EXIT", __PRETTY_FUNCTION__);
}

#pragma mark - Image and Video files

- (void)enableCloudForFiles:(BOOL)enable {
	if (enable) {
		[self moveFilesToCloud];
	} else {
		[self copyFilesFromCloud];
	}
}

- (void)moveFilesToCloud {
	[self moveFilesToCloudInDirectory:A3DaysCounterImageDirectory];
	[self moveFilesToCloudInDirectory:A3WalletImageDirectory];
	[self moveFilesToCloudInDirectory:A3WalletVideoDirectory];
}

- (void)moveFilesToCloudInDirectory:(NSString *)directory {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
		NSURL *ubiquityContainerURL = [fileManager URLForUbiquityContainerIdentifier:nil];
		NSURL *directoryURL = [ubiquityContainerURL URLByAppendingPathComponent:directory];
		NSError *error;
		if (![fileManager isUbiquitousItemAtURL:directoryURL]) {
			[fileCoordinator coordinateWritingItemAtURL:directoryURL
												options:NSFileCoordinatorWritingForReplacing
												  error:&error
											 byAccessor:^(NSURL *newURL) {
												 [fileManager createDirectoryAtURL:newURL withIntermediateDirectories:YES attributes:nil error:NULL];
											 }];
		}

		NSArray *files = [fileManager contentsOfDirectoryAtPath:[directory pathInLibraryDirectory] error:NULL];
		FNLOG(@"%@", files);
		for (NSString *filename in files) {
			NSString *filePath = [directory stringByAppendingPathComponent:filename];
			NSURL *localURL = [NSURL fileURLWithPath:[filePath pathInLibraryDirectory] ];
			NSURL *cloudURL = [ubiquityContainerURL URLByAppendingPathComponent:filePath];

			FNLOG(@"%@, %@", localURL, cloudURL);
			[fileManager setUbiquitous:YES
							 itemAtURL:localURL
						destinationURL:cloudURL
								 error:&error];
			if (error) {
				FNLOG(@"%@, %@", error.localizedDescription, error.localizedFailureReason);
			}
		}
	});
}

- (void)copyFilesFromCloud {
	[self copyFilesFromCloudInDirectory:A3DaysCounterImageDirectory];
	[self copyFilesFromCloudInDirectory:A3WalletImageDirectory];
	[self copyFilesFromCloudInDirectory:A3WalletVideoDirectory];
}

- (void)copyFilesFromCloudInDirectory:(NSString *)directory {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		NSURL *ubiquityContainerURL = [fileManager URLForUbiquityContainerIdentifier:nil];

		NSArray *files = [fileManager contentsOfDirectoryAtURL:[ubiquityContainerURL URLByAppendingPathComponent:directory]
									includingPropertiesForKeys:nil
													   options:0
														 error:NULL];

		for (NSURL *cloudURL in files) {
			NSString *filename = [cloudURL lastPathComponent];

			NSURL *localURL = [NSURL fileURLWithPath:[[directory stringByAppendingPathComponent:filename] pathInLibraryDirectory] ];

			NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
			NSError *error;
			[fileCoordinator coordinateReadingItemAtURL:cloudURL
												options:NSFileCoordinatorReadingWithoutChanges
									   writingItemAtURL:localURL
												options:NSFileCoordinatorWritingForReplacing
												  error:&error
											 byAccessor:^(NSURL *newReadingURL, NSURL *newWritingURL) {
												 [fileManager removeItemAtURL:newWritingURL error:NULL];
												 [fileManager copyItemAtURL:newReadingURL toURL:newWritingURL error:NULL];
											 }];
			if (error) {
				FNLOG(@"%@", error.localizedDescription);
			}
		}
	});
}

#pragma mark - NSMetadataQuery

- (void)startCloudFileQuery {
	FNLOG();
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudFileChanged) name:NSMetadataQueryDidUpdateNotification object:self.metadataQuery];

	[self.metadataQuery startQuery];
}

- (void)cloudFileChanged {
	FNLOG();
	[self.metadataQuery disableUpdates];

	for (NSMetadataItem *metaData in [self.metadataQuery results]) {
		FNLOG(@"%@", [metaData valueForAttribute:NSMetadataItemFSNameKey]);
		if (![[metaData valueForAttribute:NSMetadataUbiquitousItemDownloadingStatusKey] isEqualToString:NSMetadataUbiquitousItemDownloadingStatusDownloaded]) {
			NSURL *fileURL = [metaData valueForKey:NSMetadataItemURLKey];
			[[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:fileURL error:NULL];
		}
	}

	[self.metadataQuery enableUpdates];
}

- (void)stopCloudFileQuery {
	if (self.metadataQuery) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:self.metadataQuery];
		[self.metadataQuery stopQuery];
		self.metadataQuery = nil;
	}
}

- (void)startDownloadAllFiles {
	FNLOG();
	[self startDownloadInDirectory:A3DaysCounterImageDirectory];
	[self startDownloadInDirectory:A3WalletImageDirectory];
	[self startDownloadInDirectory:A3WalletVideoDirectory];
}

- (void)startDownloadInDirectory:(NSString *)directory {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *ubiquityContainerURL = [fileManager URLForUbiquityContainerIdentifier:nil];
	NSArray *files = [fileManager contentsOfDirectoryAtURL:[ubiquityContainerURL URLByAppendingPathComponent:directory] includingPropertiesForKeys:nil options:0 error:NULL];
	for (NSURL *fileURL in files) {
		[fileManager startDownloadingUbiquitousItemAtURL:fileURL error:NULL];
	}
}

- (void)deleteCloudFilesToResetCloud {
	// iCloud 데이터를 초기화 하는 경우에, 이미지 파일들도 함께 지워야 한다.
	// DaysCounter image, Wallet 사진, 비디오 이미지를 함께 삭제한다.
	[self deleteCloudFilesToResetCloudInDirectory:A3DaysCounterImageDirectory];
	[self deleteCloudFilesToResetCloudInDirectory:A3WalletImageDirectory];
	[self deleteCloudFilesToResetCloudInDirectory:A3WalletVideoDirectory];
}

- (void)deleteCloudFilesToResetCloudInDirectory:(NSString *)directory {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *ubiquityContainerURL = [fileManager URLForUbiquityContainerIdentifier:nil];
	NSArray *files = [fileManager contentsOfDirectoryAtURL:[ubiquityContainerURL URLByAppendingPathComponent:directory] includingPropertiesForKeys:nil options:0 error:NULL];
	for (NSURL *fileURL in files) {
		[fileManager removeItemAtURL:fileURL error:NULL];
	}
}

@end
