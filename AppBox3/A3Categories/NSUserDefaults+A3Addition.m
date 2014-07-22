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
#import "A3UserDefaults.h"

NSString *const A3SettingsUseKoreanCalendarForLunarConversion = @"A3SettingsUseKoreanCalendarForLunarConversion";

@implementation NSUserDefaults (A3Addition)

- (NSString *)stringForSyncMethod {
	return [[A3AppDelegate instance].ubiquityStoreManager cloudEnabled] ?
			NSLocalizedString(@"iCloud", @"Setgings > Sync, enable disable iCloud sync") : NSLocalizedString(@"None", @"Settings, not use iCloud sync");
}

- (NSString *)stringForRecentToKeep {
	NSInteger numberOfItemsToKeep = [[A3AppDelegate instance] maximumRecentlyUsedMenus];

	if (numberOfItemsToKeep > 1) {
		return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld Most Recent", @"StringsDict", nil), (long)numberOfItemsToKeep];
	} else {
		return NSLocalizedString(@"Most Recent", @"Settings for Main menu, in setting the number of items to show recent list, most recent means that it will show only one last one.");
	}
}

- (BOOL)useKoreanLunarCalendarForConversion {
	NSNumber *obj = [self objectForKey:A3SettingsUseKoreanCalendarForLunarConversion];
	if (obj) {
		return [obj boolValue];
	}
	return [A3UIDevice useKoreanLunarCalendar];
}

- (void)setDateComponents:(NSDateComponents *)dateComponents forKey:(NSString *)key {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dateComponents];
	NSDate *updateDate;
	[self setObject:updateDate forKey:A3LunarConverterUserDefaultsUpdateDate];
	[self setObject:data forKey:key];
	[self synchronize];

	if ([[A3AppDelegate instance].ubiquityStoreManager cloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setObject:data forKey:key];
		[store setObject:updateDate forKey:A3LunarConverterUserDefaultsCloudUpdateDate];
		[store synchronize];
	}
}

- (NSDateComponents *)dateComponentsForKey:(NSString *)key {
	NSData *data = [self objectForKey:key];
	if (data) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	}
	return nil;
}

@end
