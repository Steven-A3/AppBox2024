//
//  A3SyncManager(NSUbiquitousKeyValueStore)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/3/14 6:14 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "NSDate-Utilities.h"
#import "A3AppDelegate.h"

NSString *const A3SyncManagerEmptyObject = @"(!_^_!Empty!_^_!_#+129)";

@implementation A3SyncManager (NSUbiquitousKeyValueStore)

- (void)keyValueStoreDidChangeExternally:(NSNotification *)notification {
	FNLOG(@"keyValueStoreDidChangeExternally");
	if (![[A3SyncManager sharedSyncManager] isCloudEnabled]) return;

	FNLOG(@"keyValueStoreDidChangeExternally, data download and merged.");

	// Get the list of keys that changed.
	NSDictionary* userInfo = [notification userInfo];
	NSNumber* reasonForChange = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
	NSInteger reason = -1;

	// If a reason could not be determined, do not update anything.
	if (!reasonForChange)
		return;

	// Update only for changes from the server.
	reason = [reasonForChange integerValue];
	if ((reason == NSUbiquitousKeyValueStoreServerChange) ||
			(reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
		// If something is changing externally, get the changes
		// and update the corresponding keys locally.
		NSArray* changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
		NSUbiquitousKeyValueStore* store = [NSUbiquitousKeyValueStore defaultStore];
		NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];

		// This loop assumes you are using the same key names in both
		// the user defaults database and the iCloud key-value store
		for (NSString* key in changedKeys) {
			NSDictionary *objectInCloud = [store objectForKey:key];
			NSDictionary *objectInLocal = [userDefaults objectForKey:key];

			if (!objectInLocal || [objectInLocal[A3KeyValueDBState] unsignedIntegerValue] == A3KeyValueDBStateInitialized) {
				[userDefaults setObject:objectInCloud forKey:key];
			} else {
				if (![objectInCloud isKindOfClass:[NSDictionary class]]) {
					FNLOG(@"Object from cloud is invalid for key: %@", key);
					continue;
				}
				NSArray *allKeys = [objectInCloud allKeys];
				if ([allKeys count] != 3 || ![allKeys containsObject:A3KeyValueDBDataObject] || ![allKeys containsObject:A3KeyValueDBState] || ![allKeys containsObject:A3KeyValueDBUpdateDate]) {
					FNLOG(@"Object from cloud is invalid for key: %@", key);
				} else {
					NSDate *cloudTimestamp = objectInCloud[A3KeyValueDBUpdateDate];
					NSDate *localTimestamp = objectInLocal[A3KeyValueDBUpdateDate];
					if ([localTimestamp isEarlierThanDate:cloudTimestamp]) {
						if ([objectInCloud[A3KeyValueDBDataObject] isEqual:A3SyncManagerEmptyObject]) {
							[userDefaults removeObjectForKey:key];
						} else {
							[userDefaults setObject:objectInCloud forKey:key];
						}
					}
				}
			}
		}
		[userDefaults synchronize];

		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCloudKeyValueStoreDidImport object:nil];
	}
}

- (NSInteger)integerForKey:(NSString *)key {
	return [[self objectForKey:key] integerValue];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key state:(A3KeyValueDBStateValue)state {
	[self setObject:@(value) forKey:key state:state];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key state:(A3KeyValueDBStateValue)state {
	[self setObject:@(value) forKey:key state:state];
}

- (BOOL)boolForKey:(NSString *)key {
	return [[self objectForKey:key] boolValue];
}

- (id)objectForKey:(NSString *)key {
	NSDictionary *object = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	if ([object isKindOfClass:[NSDictionary class]]) {
		id dataObject = object[A3KeyValueDBDataObject];
		if ([dataObject isEqual:A3SyncManagerEmptyObject])
			return nil;
		return dataObject;
	}
	return nil;
}

- (void)setSyncObject:(id)object forKey:(NSString *)key state:(A3KeyValueDBStateValue)state {
	FNLOG(@"%@", key);
	NSDictionary *userDefaultsFormat = @{
			A3KeyValueDBDataObject : object,
			A3KeyValueDBState : @(state),
			A3KeyValueDBUpdateDate : [NSDate date]
	};
	[[NSUserDefaults standardUserDefaults] setObject:userDefaultsFormat forKey:key];
}

- (void)setObject:(id)object forKey:(NSString *)key state:(A3KeyValueDBStateValue)state {
	FNLOG(@"%@", key);
	NSDictionary *userDefaultsFormat = @{
			A3KeyValueDBDataObject : object,
			A3KeyValueDBState : @(state),
			A3KeyValueDBUpdateDate : [NSDate date]
	};
	[[NSUserDefaults standardUserDefaults] setObject:userDefaultsFormat forKey:key];

	if (state == A3KeyValueDBStateModified && [self isCloudEnabled]) {
		NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
		[keyValueStore setObject:userDefaultsFormat forKey:key];
		[keyValueStore synchronize];
	}
}

- (void)setDateComponents:(NSDateComponents *)dateComponents forKey:(NSString *)key state:(A3KeyValueDBStateValue)state {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dateComponents];
	[self setObject:data forKey:key state:state];
}

- (NSDateComponents *)dateComponentsForKey:(NSString *)key {
	NSData *data = [self objectForKey:key];
	if (data) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	}
	return nil;
}

@end