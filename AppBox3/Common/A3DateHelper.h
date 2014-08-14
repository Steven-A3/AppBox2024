//
//  A3DateHelper.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A3DateHelper : NSObject

+ (NSString*)dateStringFromDate:(NSDate*)date;
+ (NSString*)dateStringFromDate:(NSDate*)date withFormat:(NSString*)format;

+ (NSInteger)yearFromDate:(NSDate*)date;
+ (NSInteger)monthFromDate:(NSDate*)date;
+ (NSInteger)dayFromDate:(NSDate*)date;
+ (NSInteger)weekdayFromDate:(NSDate*)date;

+ (NSInteger)diffDaysFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;
+ (NSDateComponents *)diffCompFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate calendarUnit:(NSCalendarUnit)calendarUnit;
+ (NSString *)untilSinceStringByFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate allDayOption:(BOOL)isAllDay repeat:(BOOL)isRepeat strict:(BOOL)isStrict;      // KJH
+ (NSInteger)diffDaysFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate isAllDay:(BOOL)isAllDay;     // KJH
+ (NSInteger)diffWeeksFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;
+ (NSInteger)diffMonthsFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;
+ (NSInteger)diffYearsFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;

+ (NSDate*)dateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;
+ (NSDate*)dateByAddingDays:(NSInteger)days fromDate:(NSDate*)date;
+ (NSDate*)dateByAddingYears:(NSInteger)years fromDate:(NSDate*)date;
+ (NSDate*)dateByAddingMonth:(NSInteger)month fromDate:(NSDate*)date;
+ (NSDate*)dateByAddingWeeks:(NSInteger)weeks fromDate:(NSDate*)date;
#pragma mark Specific Date
+ (NSInteger)numberOfWeeksOfMonth:(NSDate*)month;
+ (NSInteger)lastDaysOfMonth:(NSDate*)month;
+ (NSDate*)dateMake12PM:(NSDate*)date;

+ (NSDate*)dateMakeMonthFirstDayAtDate:(NSDate*)date;

+ (NSDate *)midnightForDate:(NSDate *)date;
#pragma mark Lunar
+ (NSString *)dateStringFromDateComponents:(NSDateComponents *)dateComp withFormat:(NSString *)format;
@end
