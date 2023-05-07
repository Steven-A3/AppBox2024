//
//  A3AppDelegate+appearance.m
//  AppBox3
//
//  Created by A3 on 1/16/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate+appearance.h"

@implementation A3AppDelegate (appearance)

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
