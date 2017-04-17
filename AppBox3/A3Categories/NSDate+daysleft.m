//
//  NSDate+daysleft.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSDate+daysleft.h"
#import "HolidayData.h"
#import "A3AppDelegate.h"

@implementation NSDate (daysleft)

- (NSString *)daysLeft {
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	NSDateComponents *components = [gregorian components:NSCalendarUnitDay fromDate:[HolidayData justDateWithDate:[NSDate date]] toDate:self options:NSWrapCalendarComponents];

	return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld Days Left", @"StringsDict", nil), (long)components.day];
}

@end
