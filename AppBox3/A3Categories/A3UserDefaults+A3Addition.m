//
//  A3UserDefaults+A3Addition.m
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3UserDefaults+A3Addition.h"
#import "A3AppDelegate+iCloud.h"
#import "A3AppDelegate+mainMenu.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"

@implementation A3UserDefaults (A3Addition)

- (NSString *)stringForRecentToKeep {
	NSInteger numberOfItemsToKeep = [[A3AppDelegate instance] maximumRecentlyUsedMenus];

	if (numberOfItemsToKeep > 1) {
		return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld Most Recent", @"StringsDict", nil), (long)numberOfItemsToKeep];
	} else {
		return NSLocalizedString(@"Most Recent", @"Settings for Main menu, in setting the number of items to show recent list, most recent means that it will show only one last one.");
	}
}

@end
