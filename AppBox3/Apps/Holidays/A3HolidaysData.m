//
//  A3HolidaysData.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysData.h"
#import "common.h"

NSString *const kHolidayName = @"name";
NSString *const kHolidayType = @"type";
NSString *const kHolidayDuration = @"duration";
NSString *const kHolidayIsPublic = @"public";
NSString *const kHolidayMonth = @"month";
NSString *const kHolidayDay = @"day";
NSString *const kHolidayWeekday = @"weekday";
NSString *const kHolidayOrdinal = @"ordinal";

@implementation A3HolidaysData

- (NSArray *)holidayTemplate_us {
	FNLOG(@"%@", NSStringFromSelector(@selector(holidayTemplate_us)) );

	NSArray *holidays = @[
			@{kHolidayName : @"New Year's Day", kHolidayType:@(HolidayItemDate), kHolidayIsPublic:@(YES),
					kHolidayMonth:@1, kHolidayDay:@1, kHolidayDuration:@1},
			@{kHolidayName : @"Martin Luther King Day", kHolidayType:@(HolidayItemWeekdayOrdinalInMonth), kHolidayIsPublic:@(YES),
	kHolidayWeekday:@(A3Monday), kHolidayMonth:@1, kHolidayOrdinal:@3, kHolidayDuration:@1},
			@{kHolidayName : @"Groundhog Day", kHolidayType:@(HolidayItemDate), kHolidayIsPublic:@(YES),
					kHolidayMonth:@2, kHolidayDay:@2, kHolidayDuration:@1},
			@{kHolidayName : @"Lincoln's Birthday", kHolidayType:@(HolidayItemDate), kHolidayIsPublic:@(YES),
					kHolidayMonth:@2, kHolidayDay:@2, kHolidayDuration:@1},
			@{kHolidayName : @"Lincoln's Birthday", kHolidayType:@(HolidayItemDate), kHolidayIsPublic:@(YES),
					kHolidayMonth:@2, kHolidayDay:@12, kHolidayDuration:@1},
			@{kHolidayName : @"Valentine's Day", kHolidayType:@(HolidayItemDate), kHolidayIsPublic:@(YES),
					kHolidayMonth:@2, kHolidayDay:@14, kHolidayDuration:@1},
			@{kHolidayName : @"Washington's Birthday", kHolidayType:@(HolidayItemWeekdayOrdinalInMonth), kHolidayIsPublic:@(YES),
					kHolidayWeekday:@(A3Monday), kHolidayMonth:@2, kHolidayOrdinal:@3, kHolidayDuration:@1},
			@{kHolidayName : @"Daylight Saving Time Begins", kHolidayType:@(HolidayItemWeekdayOrdinalInMonth), kHolidayIsPublic:@(YES),
					kHolidayWeekday:@(A3Sunday), kHolidayMonth:@3, kHolidayOrdinal:@2, kHolidayDuration:@1},
	];

	return holidays;
}

@end
