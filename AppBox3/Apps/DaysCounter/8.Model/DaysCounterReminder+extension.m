//
//  DaysCounterReminder+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "DaysCounterReminder+extension.h"
#import "DaysCounterEvent.h"

@implementation DaysCounterReminder (extension)

- (DaysCounterEvent *)event {
	return [DaysCounterEvent MR_findFirstByAttribute:@"uniqueID" withValue:self.eventID];
}

@end
