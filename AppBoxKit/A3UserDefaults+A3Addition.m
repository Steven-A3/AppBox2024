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
#import "A3UserDefaultsKeys.h"

@implementation A3UserDefaults (A3Addition)

- (NSString *)stringForRecentToKeep {
	NSInteger numberOfItemsToKeep = [[A3SyncManager sharedSyncManager] maximumRecentlyUsedMenus];

	return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld Most Recent", @"StringsDict", nil), (long)numberOfItemsToKeep];
}

- (NSArray *)themeColors {
    return @[
            [UIColor colorWithRed:252.0 / 255.0 green:49.0 / 255.0 blue:89.0 / 255.0 alpha:1.0],
            [UIColor colorWithRed:252.0 / 255.0 green:61.0 / 255.0 blue:57.0 / 255.0 alpha:1.0],
            [UIColor colorWithRed:27.0 / 255.0 green:169.0 / 255.0 blue:77.0 / 255.0 alpha:1.0],
            [UIColor colorWithRed:60.0 / 255.0 green:171.0 / 255.0 blue:218.0 / 255.0 alpha:1.0],
            [UIColor colorWithRed:21.0 / 255.0 green:126.0 / 255.0 blue:251.0 / 255.0 alpha:1.0],
            [UIColor colorWithRed:11.0 / 255.0 green:54.0 / 255.0 blue:117.0 / 255.0 alpha:1.0],
            [UIColor colorWithRed:113.0 / 255.0 green:58.0 / 255.0 blue:209.0 / 255.0 alpha:1.0],
            [UIColor colorWithRed:201.0 / 255.0 green:120.0 / 255.0 blue:38.0 / 255.0 alpha:1.0]
    ];
}

- (UIColor *)themeColor {
    NSNumber *selectedIndex = [self objectForKey:A3SettingsUserDefaultsThemeColorIndex];
    if (selectedIndex) {
        return self.themeColors[[selectedIndex unsignedIntegerValue]];
    }
    return self.themeColors[4];
}

@end
