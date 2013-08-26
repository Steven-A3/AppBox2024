//
//  A3HolidaysData.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

extern NSString *const kHolidayName;
extern NSString *const kHolidayType;
extern NSString *const kHolidayDuration;
extern NSString *const kHolidayIsPublic;
extern NSString *const kHolidayMonth;
extern NSString *const kHolidayDay;
extern NSString *const kHolidayWeekday;
extern NSString *const kHolidayOrdinal;

typedef NS_ENUM(NSUInteger, HolidayItemType) {
	HolidayItemDate,
	HolidayItemWeekdayOrdinalInMonth,
	HolidayItemEasterDay,
};

typedef NS_ENUM(NSUInteger, A3DaysOfTheWeek) {
	A3Sunday = 1,
	A3Monday,
	A3Tuesday,
	A3Wednesday,
	A3Thursday,
	A3Friday,
	A3Saturday
};

@interface A3HolidaysData : NSObject

@end
