//
//  A3AppDelegate+iCloud.m
//  AppBox3
//
//  Created by A3 on 12/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate+iCloud.h"
#import "A3LadyCalendarModelManager.h"
#import "A3DaysCounterModelManager.h"
#import "NSDate-Utilities.h"
#import "A3SyncManager.h"
#import "A3UserDefaults.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "AppBox3-Swift.h"
#import "NSFileManager+A3Addition.h"
#import <Ensembles/Ensembles.h>
#import <BackgroundTasks/BackgroundTasks.h>

@implementation A3AppDelegate (iCloud)

- (void)persistentStoreActivityWillEndActivity:(NSNotification *)notification {
	FNLOG();
	
	CDEEnsembleActivity activity = (CDEEnsembleActivity) [[notification.userInfo objectForKey:CDEEnsembleActivityKey] unsignedIntegerValue];
	if (activity == CDEEnsembleActivityLeeching || activity == CDEEnsembleActivityDeleeching) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:CDEPersistentStoreEnsembleWillEndActivityNotification object:nil];
		[self.hud hideAnimated:YES];
	}
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register background refresh task
    [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:@"com.yourapp.refresh" usingQueue:nil launchHandler:^(__kindof BGTask *task) {
        [self handleAppRefreshTask:(BGAppRefreshTask *)task];
    }];
    
    // Schedule the first background refresh task
    [self scheduleAppRefresh];
    
    return YES;
}

- (void)scheduleAppRefresh {
    BGAppRefreshTaskRequest *request = [[BGAppRefreshTaskRequest alloc] initWithIdentifier:@"net.allaboutapps.AppBox.refresh"];
    request.earliestBeginDate = [NSDate dateWithTimeIntervalSinceNow:15 * 60]; // Schedule for 15 minutes from now (adjust as needed)
    
    NSError *error = nil;
    if (![[BGTaskScheduler sharedScheduler] submitTaskRequest:request error:&error]) {
        NSLog(@"Failed to schedule app refresh: %@", error);
    }
}

- (void)handleAppRefreshTask:(BGAppRefreshTask *)task {
    // Set the time of wake up to use for returning if we updated
    self.wakeUpTime = [NSDate date];
    FNLOG(@"%@", self.wakeUpTime);

    __weak BGAppRefreshTask *weakTask = task; // Capture task weakly
    task.expirationHandler = ^{
        // Use weakTask to avoid a retain cycle
        [weakTask setTaskCompletedWithSuccess:NO];
    };
    
    if (!self.isCoreDataReady) {
        [task setTaskCompletedWithSuccess:NO];
        return;
    }
    
    if ([[UIApplication sharedApplication] isProtectedDataAvailable]) {
        FNLOG(@"Protected Data is Available.");
        
        [A3DaysCounterModelManager reloadAlertDateListForLocalNotification];
        [A3LadyCalendarModelManager setupLocalNotification];
        
        [task setTaskCompletedWithSuccess:YES];
    } else {
        FNLOG(@"Protected Data is NOT Available.");
        [task setTaskCompletedWithSuccess:NO];
    }
    
    // Reschedule the background task
    [self scheduleAppRefresh];
}

#pragma mark - A3UserDefaults & NSUbiquitousKeyValueStore

- (void)mergeUserDefaultsDeleteCloud:(BOOL)deleteCloud {
	NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
	[keyValueStore synchronize];
	A3UserDefaults *userDefaults = [A3UserDefaults standardUserDefaults];

	for (NSString *key in [self syncKeys]) {
		NSDictionary *objectInCloud = [keyValueStore objectForKey:key];
		NSDictionary *objectInLocal = [userDefaults objectForKey:key];

		if (objectInCloud && ![self isValidSyncEnabledObject:objectInCloud]) {
			[keyValueStore removeObjectForKey:key];
			objectInCloud = nil;
		}
		if (objectInLocal && ![self isValidSyncEnabledObject:objectInLocal]) {
			[userDefaults removeObjectForKey:key];
			objectInLocal = nil;
		}

		if (!objectInCloud && [objectInLocal[A3KeyValueDBState] unsignedIntegerValue] == A3DataObjectStateInitialized)
			continue;

		if (objectInCloud && [objectInLocal[A3KeyValueDBState] unsignedIntegerValue] == A3DataObjectStateInitialized) {
			[userDefaults setObject:objectInCloud forKey:key];
			continue;
		}

		NSDate *cloudTimestamp = objectInCloud[A3KeyValueDBUpdateDate];
		NSDate *localTimestamp = objectInLocal[A3KeyValueDBUpdateDate];
		if ([localTimestamp isEarlierThanDate:cloudTimestamp]) {
			[userDefaults setObject:objectInCloud forKey:key];
		} else {
			[keyValueStore setObject:objectInLocal forKey:key];
		}
	}
	[userDefaults synchronize];
	[keyValueStore synchronize];
}

- (BOOL)isValidSyncEnabledObject:(NSDictionary *)object {
	if (![object isKindOfClass:[NSDictionary class]]) return NO;
	NSArray *allKeys = [object allKeys];
	return [allKeys count] == 3 &&
			[allKeys containsObject:A3KeyValueDBDataObject] &&
			[allKeys containsObject:A3KeyValueDBState] &&
	[allKeys containsObject:A3KeyValueDBUpdateDate];
}

- (NSArray *)syncKeys {
	return @[
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

			A3CalculatorUserDefaultsSavedLastExpression,

			A3CurrencyUserDefaultsLastInputValue,

			A3DaysCounterUserDefaultsSlideShowOptions,

			A3ExpenseListUserDefaultsCurrencyCode,
			A3ExpenseListIsAddBudgetCanceledByUser,
			A3ExpenseListIsAddBudgetInitiatedOnce,

			A3LadyCalendarCurrentAccountID,
			A3LadyCalendarUserDefaultsSettings,
			A3LadyCalendarLastViewMonth,

			A3LoanCalcUserDefaultShowDownPayment,
			A3LoanCalcUserDefaultShowExtraPayment,
			A3LoanCalcUserDefaultShowAdvanced,
			A3LoanCalcUserDefaultsLoanDataKey,
			A3LoanCalcUserDefaultsLoanDataKey_A,
			A3LoanCalcUserDefaultsLoanDataKey_B,
			A3LoanCalcUserDefaultsCustomCurrencyCode,

			A3LunarConverterLastInputDateComponents,
			A3LunarConverterLastInputDateIsLunar,

			A3PercentCalcUserDefaultsCalculationType,
			A3PercentCalcUserDefaultsSavedInputData,

			A3SalesCalcUserDefaultsSavedInputDataKey,
			A3SalesCalcUserDefaultsCurrencyCode,

			A3TipCalcUserDefaultsCurrencyCode,

			A3UnitConverterDefaultSelectedCategoryID,
			A3UnitConverterTableViewUnitValueKey,

			A3UnitPriceUserDefaultsCurrencyCode,

			A3MainMenuUserDefaultsMaxRecentlyUsed,
	];
}

/**
 *  Fetch every objects for every entities and check any of it has duplicated objects
 *
 *  @return YES if it founds entity which duplicated objects
 */
- (BOOL)deduplicateDatabaseWithModel:(NSManagedObjectModel *)model {
	BOOL dataHasDuplicatedRecords = NO;
	for (NSEntityDescription *entityDescription in model.entities) {
		@autoreleasepool {
			dataHasDuplicatedRecords |= [self deDupRecordsForEntity:entityDescription.name];
		}
	}
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
    [context saveIfNeeded];

	return dataHasDuplicatedRecords;
}

/**
 *  Find duplicated NSManagedObject for given entity name and delete duplicated objects
 *
 *  @param entityName Name of the entity to find and delete duplicated objects.
 *
 *  @return YES if it founds duplicated objects and deleted duplicated objects.
 */
- (BOOL)deDupRecordsForEntity:(NSString *)entityName {
	BOOL hasDuplicatedRecords = NO;
	
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];

	NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"uniqueID"]; // Does not really matter
	NSExpression *countExpression = [NSExpression expressionForFunction:@"count:"
															  arguments:@[keyPathExpression]];
	NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
	[expressionDescription setName: @"dupCount"];
	[expressionDescription setExpression: countExpression];
	[expressionDescription setExpressionResultType: NSInteger32AttributeType];

	NSMutableArray *propertiesToFetch = [NSMutableArray arrayWithArray:entityDescription.properties];
	[propertiesToFetch addObject:expressionDescription];

	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	fetchRequest.entity = entityDescription;
	fetchRequest.propertiesToFetch = propertiesToFetch;
	fetchRequest.propertiesToGroupBy = entityDescription.properties;
	fetchRequest.resultType = NSDictionaryResultType;

	NSError *error;
	NSArray *result = [context executeFetchRequest:fetchRequest error:&error];

	for (NSDictionary *unique in result) {
		if ([unique[@"dupCount"] integerValue] > 1) {
			hasDuplicatedRecords = YES;
			
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"uniqueID", unique[@"uniqueID"]];

			NSArray *duplicatedItems = [NSClassFromString(entityName) findAllWithPredicate:predicate];
			BOOL skipFirst = YES;
			for (NSManagedObject *targetRow in duplicatedItems) {
				if (skipFirst) {
					skipFirst = NO;
					continue;
				}
				FNLOG(@"Deleting: %@", targetRow);
                [context deleteObject:targetRow];
			}
		}
	}

	return hasDuplicatedRecords;
}

@end
