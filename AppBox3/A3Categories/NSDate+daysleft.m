//
//  NSDate+daysleft.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSDate+daysleft.h"
#import "HolidayData.h"

@implementation NSDate (daysleft)

- (NSString *)daysLeft {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:[HolidayData justDateWithDate:[NSDate date]] toDate:self options:NSWrapCalendarComponents];

	return [NSString stringWithFormat:@"%ld Days Left", (long)components.day];
}

@end
