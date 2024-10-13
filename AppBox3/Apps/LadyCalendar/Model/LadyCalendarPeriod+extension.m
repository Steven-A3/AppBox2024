//
//  LadyCalendarPeriod(extension)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/3/14 5:14 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "LadyCalendarPeriod+extension.h"
#import "A3AppDelegate.h"

@implementation LadyCalendarPeriod_ (extension)

- (void)awakeFromFetch {
	[super awakeFromFetch];

	NSDateComponents *components = [NSDateComponents new];
	components.day = [self.cycleLength integerValue];
	self.periodEnds = [[A3AppDelegate instance].calendar dateByAddingComponents:components toDate:self.startDate options:0];
}

- (void)reassignUniqueIDWithStartDate {
	NSDateComponents *components = [[A3AppDelegate instance].calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.startDate];
	self.uniqueID = [NSString stringWithFormat:@"%ld-%02ld-%02ld", (long)components.year, (long)components.month, (long)components.day];
}

@end
