//
//  A3AppDelegate+keyValueStore.m
//  AppBox3
//
//  Created by A3 on 1/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate+keyValueStore.h"
#import "A3MainMenuTableViewController.h"
#import "NSDate-Utilities.h"
#import "A3AppDelegate+mainMenu.h"

@implementation A3AppDelegate (keyValueStore)

- (void)keyValueStoreDidChangeExternally:(NSNotification *)notification {
	FNLOG(@"keyValueStoreDidChangeExternally");
	if (![self.ubiquityStoreManager cloudEnabled]) return;

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
			id objectInCloud = [store objectForKey:key];
			id objectInLocal = [userDefaults objectForKey:key];
			if ([key isEqualToString:kA3MainMenuAllMenu]) {
				if ([objectInCloud[kA3AppsDataUpdateDate] isLaterThanDate:objectInLocal[kA3AppsDataUpdateDate]]) {
					[userDefaults setObject:objectInCloud forKey:key];
				} else {
					[store setObject:objectInLocal forKey:key];
				}
			} else {
				[userDefaults setObject:objectInCloud forKey:key];
			}
		}
		[userDefaults synchronize];
	}
}

- (void)migrateToKeyValueStore {
	NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];

	[self migrateObjectToKeyValueStore:kA3MainMenuFavorites];
	[self migrateObjectToKeyValueStore:kA3MainMenuRecentlyUsed];
	[self migrateObjectToKeyValueStore:kA3MainMenuAllMenu];
	[self migrateObjectToKeyValueStore:kA3MainMenuMaxRecentlyUsed];

	[keyValueStore synchronize];
}

- (void)migrateObjectToKeyValueStore:(NSString *)key {
	NSUbiquitousKeyValueStore *keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
	id object = [keyValueStore objectForKey:key];
	if (object) {
		[[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
	} else {
		object = [[NSUserDefaults standardUserDefaults] objectForKey:key];
		if (object) {
			[keyValueStore setObject:object forKey:key];
		}
	}
}

@end
