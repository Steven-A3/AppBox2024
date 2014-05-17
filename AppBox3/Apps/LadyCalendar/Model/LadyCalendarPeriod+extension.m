//
//  LadyCalendarPeriod(extension)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/3/14 5:14 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "LadyCalendarPeriod+extension.h"
#import "A3AppDelegate.h"


@implementation LadyCalendarPeriod (extension)

- (void)awakeFromFetch {
	[super awakeFromFetch];

	NSDateComponents *components = [NSDateComponents new];
	components.day = [self.cycleLength integerValue];
	self.periodEnds = [[A3AppDelegate instance].calendar dateByAddingComponents:components toDate:self.startDate options:0];
}

@end
