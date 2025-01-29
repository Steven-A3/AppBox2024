//
//  A3SyncManager(NSUbiquitousKeyValueStore)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/3/14 6:14 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "NSDate-Utilities.h"
#import "NSFileManager+A3Addition.h"
#import "A3UserDefaults.h"
#import "AppBoxKit/AppBoxKit-Swift.h"

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
        
        if ([changedKeys containsObject:kUserDefaultsKeyForSystemInitiatesDataReset]) {
            if (!self.ignoreDataReset) {
                CoreDataStack *stack = [CoreDataStack shared];
                [stack resetLocalContainer];
                abort();
            } else {
                // This effective once and reset the flag to respond additional reset.
                self.ignoreDataReset = NO;
            }
            return;
        }
        
		NSUbiquitousKeyValueStore* store = [NSUbiquitousKeyValueStore defaultStore];
		A3UserDefaults* userDefaults = [A3UserDefaults standardUserDefaults];

		// This loop assumes you are using the same key names in both
		// the user defaults database and the iCloud key-value store
		for (NSString* key in changedKeys) {
            FNLOG(@"%@", key);
			NSDictionary *objectInCloud = [store objectForKey:key];
			NSDictionary *objectInLocal = [userDefaults objectForKey:key];

            FNLOG(@"%@, %@", objectInCloud, objectInLocal);

            if (![objectInCloud isKindOfClass:[NSDictionary class]] || ((objectInLocal != nil) && ![objectInLocal isKindOfClass:[NSDictionary class]])) {
                continue;
            }
			if (!objectInLocal || [objectInLocal[A3KeyValueDBState] unsignedIntegerValue] == A3DataObjectStateInitialized) {
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

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCloudKeyValueStoreDidImport object:nil];
        });
	}
}

- (NSInteger)integerForKey:(NSString *)key {
	return [[self objectForKey:key] integerValue];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key state:(A3DataObjectStateValue)state {
	[self setObject:@(value) forKey:key state:state];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key state:(A3DataObjectStateValue)state {
	[self setObject:@(value) forKey:key state:state];
}

- (BOOL)boolForKey:(NSString *)key {
	return [[self objectForKey:key] boolValue];
}

/**
 * Retrieves the value associated with the specified key from local user defaults.
 * If the value is not found locally, it attempts to retrieve the value from
 * the iCloud key-value store (NSUbiquitousKeyValueStore).
 *
 * The method ensures data consistency by checking for a valid dictionary structure
 * and handles placeholders for removed or empty objects.
 *
 * @param key The key whose value you want to retrieve.
 * @return The value associated with the specified key, or `nil` if the key does not exist
 *         or the value is marked as empty.
 *
 * Behavior:
 * - First checks the local user defaults (A3UserDefaults).
 * - If the key exists locally, validates and returns the stored value.
 * - If the key does not exist locally, queries the NSUbiquitousKeyValueStore for the value.
 * - Ensures the object is a valid dictionary and checks for special placeholders
 *   indicating removed or empty values.
 */
- (id)objectForKey:(NSString *)key {
#ifdef DEBUG
    if ([key isEqualToString:A3LadyCalendarUserDefaultsSettings]) {
        FNLOG(@"Accessing A3LadyCalendarUserDefaultsSettings");
    }
#endif
    NSDictionary *object = [[A3UserDefaults standardUserDefaults] objectForKey:key];
    if ([object isKindOfClass:[NSDictionary class]]) {
        id dataObject = object[A3KeyValueDBDataObject];
        if ([dataObject isEqual:A3SyncManagerEmptyObject]) {
            return nil;
        }
        return dataObject;
    }
    
    // If the object is not available locally, check the iCloud key-value store
    NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
    NSDictionary *cloudObject = [keyValueStore objectForKey:key];
    if ([cloudObject isKindOfClass:[NSDictionary class]]) {
        id dataObject = cloudObject[A3KeyValueDBDataObject];
        if ([dataObject isEqual:A3SyncManagerEmptyObject]) {
            return nil;
        }
        return dataObject;
    }
    
    return nil;
}

- (void)setObject:(id)object forKey:(NSString *)key state:(A3DataObjectStateValue)state {
#ifdef DEBUG
    if ([key isEqualToString:A3LadyCalendarUserDefaultsSettings]) {
        FNLOG(@"Setting A3LadyCalendarUserDefaultsSettings");
    }
#endif
	FNLOG(@"%@", key);
	if (object == nil)
		return;
	
	NSDictionary *userDefaultsFormat = @{
			A3KeyValueDBDataObject : object,
			A3KeyValueDBState : @(state),
			A3KeyValueDBUpdateDate : [NSDate date]
	};
	[[A3UserDefaults standardUserDefaults] setObject:userDefaultsFormat forKey:key];
	[[A3UserDefaults standardUserDefaults] synchronize];

	if ([key isEqualToString:A3MainMenuDataEntityAllMenu] ||
		[key isEqualToString:A3MainMenuDataEntityFavorites]) {
		return;
	}
	
	if (state == A3DataObjectStateModified && [self isCloudEnabled]) {
		NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
		[keyValueStore setObject:userDefaultsFormat forKey:key];
		[keyValueStore synchronize];
	}
}

- (void)setDateComponents:(NSDateComponents *)dateComponents forKey:(NSString *)key state:(A3DataObjectStateValue)state {
    NSError *error;
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dateComponents requiringSecureCoding:YES error:&error];
    if (error) {
        FNLOG(@"%@", error.localizedDescription);
    }
	[self setObject:data forKey:key state:state];
}

- (NSDateComponents *)dateComponentsForKey:(NSString *)key {
	NSData *data = [self objectForKey:key];
	if (data) {
        NSError *error;
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
        NSDateComponents *decodedObject = nil;
        if (error) {
            FNLOG(@"Error unarchiving NSDateComponents data: %@", error.localizedDescription);
        } else {
            unarchiver.requiresSecureCoding = NO; // Set this to YES if your object conforms to NSSecureCoding
            decodedObject = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
            [unarchiver finishDecoding];
        }
        return decodedObject;
	}
	return nil;
}

@end
