//
//  A3AppDelegate+appearance.m
//  AppBox3
//
//  Created by A3 on 1/16/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3LaunchSceneViewController.h"
#import "A3AppDelegate+appearance.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

@implementation A3AppDelegate (appearance)

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
	NSNumber *selectedIndex = [[A3SyncManager sharedSyncManager] objectForKey:A3SettingsUserDefaultsThemeColorIndex];
	if (selectedIndex) {
		return self.themeColors[[selectedIndex unsignedIntegerValue]];
	}
	return self.themeColors[4];
}

- (NSString *)getLaunchImageName {
	NSString *imageName;
	if (IS_IPHONE) {
		if (IS_IPHONE35) {
			imageName = @"LaunchImage-700@2x.png";
		} else {
			imageName = @"LaunchImage-700-568h@2x.png";
		}

	} else {
		if (IS_LANDSCAPE) {
			if (IS_RETINA) {
				imageName = @"LaunchImage-700-Landscape@2x~ipad.png";
			} else {
				imageName = @"LaunchImage-700-Landscape~ipad.png";
			}
		} else {
			if (IS_RETINA) {
				imageName = @"LaunchImage-700-Portrait@2x~ipad.png";
			} else {
				imageName = @"LaunchImage-700-Portrait~ipad.png";
			}
		}
	}
	FNLOG(@"%@", imageName);
	return imageName;
}

@end
