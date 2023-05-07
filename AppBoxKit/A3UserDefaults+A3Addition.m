//
//  A3UserDefaults+A3Addition.m
//  AppBox3
//
//  Created by A3 on 12/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3UserDefaults+A3Addition.h"
#import "A3SyncManager.h"
#import "A3SyncManager+mainmenu.h"

@implementation A3UserDefaults (A3Addition)

- (NSString *)stringForRecentToKeep {
	NSInteger numberOfItemsToKeep = [[A3SyncManager sharedSyncManager] maximumRecentlyUsedMenus];

	return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld Most Recent", @"StringsDict", nil), (long)numberOfItemsToKeep];
}

@end
