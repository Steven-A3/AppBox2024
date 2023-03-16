//
//  DaysCounterReminder+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "DaysCounterReminder+extension.h"
#import "DaysCounterEvent.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"

@implementation DaysCounterReminder (extension)

- (DaysCounterEvent *)event {
	return [DaysCounterEvent findFirstByAttribute:@"uniqueID" withValue:self.eventID];
}

@end
