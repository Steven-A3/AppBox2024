//
//  DaysCounterReminder+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/AppBoxKit.h>
#import "DaysCounterReminder+extension.h"

@implementation DaysCounterReminder_ (extension)

- (DaysCounterEvent_ *)event {
	return [DaysCounterEvent_ findFirstByAttribute:@"uniqueID" withValue:self.eventID];
}

@end
