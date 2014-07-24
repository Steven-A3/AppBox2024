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
#import "A3UserDefaults.h"
#import "A3SyncManager.h"

@implementation A3AppDelegate (keyValueStore)

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
			if ([key isEqualToString:A3SyncManagerCloudStoreID]) {
				// Cloud Store ID 는 동기화에서 제외
				continue;
			}
			id objectInCloud = [store objectForKey:key];
			id objectInLocal = [userDefaults objectForKey:key];
			if ([key isEqualToString:A3MainMenuUserDefaultsAllMenu]) {
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

		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCloudKeyValueStoreDidImport object:nil];
	}
}

@end
