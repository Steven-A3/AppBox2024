//
//  NSUserDefaults+A3Addition.m
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSUserDefaults+A3Addition.h"
#import "A3AppDelegate+iCloud.h"
#import "A3AppDelegate+mainMenu.h"

NSString *const A3SettingsUseLunarCalendar = @"A3SettingsUseLunarCalendar";
NSString *const A3SettingsUseKoreanCalendarForLunarConversion = @"A3SettingsUseKoreanCalendarForLunarConversion";

@implementation NSUserDefaults (A3Addition)

- (NSString *)stringForSyncMethod {
	return [[A3AppDelegate instance].ubiquityStoreManager cloudEnabled] ?
			NSLocalizedString(@"iCloud", @"Setgings > Sync, enable disable iCloud sync") : NSLocalizedString(@"None", @"Settings, not use iCloud sync");
}

- (NSString *)stringForRecentToKeep {
	NSInteger numberOfItemsToKeep = [[A3AppDelegate instance] maximumRecentlyUsedMenus];

	if (numberOfItemsToKeep > 1) {
		return [NSString stringWithFormat:NSLocalizedString(@"Last %ld", @"Settings for main menu, in setting the number of items to show in recent list."), (long)numberOfItemsToKeep];
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
