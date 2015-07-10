//
// Created by Byeong Kwon Kwak on 7/8/15.
// Copyright (c) 2015 ALLABOUTAPPS. All rights reserved.
//

#import "A3Application.h"
#import "A3AppDelegate.h"

@implementation A3Application

- (void)sendEvent:(UIEvent *)event {
	[super sendEvent:event];

	FNLOG(@"");
	[[A3AppDelegate instance] restartAdDisplayTimer];
}

@end