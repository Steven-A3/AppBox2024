//
//  NSUserDefaults+A3Addition.m
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSUserDefaults+A3Addition.h"
#import "A3AppDelegate+iCloud.h"

NSString *const A3SettingsUseiCloudSync = @"A3SettingsUseiCloudSync";
NSString *const A3SettingsUsePasscodeLock = @"A3SettingsUsePasscodeLock";
NSString *const A3SettingsNumberOfItemsRecentToKeep = @"A3SettingsNumberOfItemsRecentToKeep";
NSString *const A3SettingsUseLunarCalendar = @"A3SettingsUseLunarCalendar";
NSString *const A3SettingsUseKoreanCalendarForLunarConversion = @"A3SettingsUseKoreanCalendarForLunarConversion";

@implementation NSUserDefaults (A3Addition)

- (NSString *)stringForSyncMethod {
	return [[A3AppDelegate instance].ubiquityStoreManager cloudEnabled] ?
			NSLocalizedString(@"iCloud", @"Setgings > Sync, enable disable iCloud sync") : NSLocalizedString(@"None", @"Settings, not use iCloud sync");
}

- (NSString *)stringForPasscodeLock {
	return [[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsUsePasscodeLock] ?
			NSLocalizedString(@"On", @"Settings, Passcode Lock On") : NSLocalizedString(@"Off", @"Settings, Passcode Lock Off");
}

- (NSString *)stringForRecentToKeep {
	NSInteger numberOfItemsToKeep = [[NSUserDefaults standardUserDefaults] integerForKey:A3SettingsNumberOfItemsRecentToKeep];

	if (numberOfItemsToKeep == 0) {
		numberOfItemsToKeep = 3;
	}
	if (numberOfItemsToKeep > 1) {
		return [NSString stringWithFormat:NSLocalizedString(@"Last %d", @"Settings for main menu, in setting the number of items to show in recent list."), numberOfItemsToKeep];
	} else {
		return NSLocalizedString(@"Most Recent", @"Settings for Main menu, in setting the number of items to show recent list, most recent means that it will show only one last one.");
	}
}

- (NSString *)stringForLunarCalendarCountry {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsUseLunarCalendar]) {
		return NSLocalizedString(@"Off", @"Value for Use Lunar Calendar");
	}
	return [[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsUseKoreanCalendarForLunarConversion] ?
		NSLocalizedString(@"Korean", @"In Settings, selected lunar calendar name for Korean Lunar Calendar") : NSLocalizedString(@"Chinese", @"In Settings, selected lunar calendar name for Chinese Lunar Calendar");
}

@end
