//
//  A3CacheStoreManager.m
//  AppBox3
//
//  Created by A3 on 12/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CacheStoreManager.h"
#import "NSFileManager+A3Addtion.h"
#import "CurrencyRateItem.h"
#import "CurrencyFavorite.h"
#import "A3CurrencyDataManager.h"

@interface A3CacheStoreManager ()

@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation A3CacheStoreManager

- (id)init {
	self = [super init];
	if (self) {
		@try {
			_model = [NSManagedObjectModel mergedModelFromBundles:nil];
			_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
			NSURL *cacheStoreURL = [NSURL fileURLWithPath:[[NSFileManager defaultManager] cacheStorePath]];
			NSDictionary *cacheStoreOptions = @{
					NSMigratePersistentStoresAutomaticallyOption : @YES,
					NSInferMappingModelAutomaticallyOption       : @YES
			};
			NSError *error;
			[_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:cacheStoreURL options:cacheStoreOptions error:&error];
			_context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
			[_context setPersistentStoreCoordinator:_persistentStoreCoordinator];
		}
		@catch (id exception) {
			NSLog(@"%@", [(id<NSObject>)exception description]);
		}
	}

	return self;
}

- (void)save {
	NSError *error;
	if ([_context hasChanges] && ![_context save:&error]) {
		NSLog(@"%s, %@", __PRETTY_FUNCTION__, [error localizedDescription]);
	}
}

- (float)rateForCurrencyCode:(NSString *)currency {
	float rate;
	@autoreleasepool {
		CurrencyRateItem *currencyItem = [CurrencyRateItem MR_findFirstByAttribute:@"currencyCode" withValue:currency inContext:self.context];
		NSAssert(currencyItem, @"CurrencyRateItem: Currency data does not exist for '%@'", currency);
		rate = currencyItem.rateToUSD.floatValue;
	}
	return rate;
}

@end
