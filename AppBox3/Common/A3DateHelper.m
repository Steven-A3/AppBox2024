//
//  A3DateHelper.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateHelper.h"

@implementation A3DateHelper

+ (NSString*)dateStringFromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy. MM. dd. EEE"];
	return [df stringFromDate:date];
}

+ (NSString*)dateStringFromDate:(NSDate*)date withFormat:(NSString*)format
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:format];
	return [df stringFromDate:date];
}

+ (NSDate*)dateFromString:(NSString*)dateStr withFormat:(NSString *)format
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:format];
	
	return [df dateFromString:dateStr];
}

+ (BOOL)isAMDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"a"];
	NSString *str = [df stringFromDate:date];
	
	return [str isEqualToString:@"AM"];
}

+ (NSInteger)hour24FromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"HH"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)hour12FromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"hh"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)minuteFromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"mm"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)secondFromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"ss"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)yearFromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)monthFromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"MM"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)dayFromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"dd"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)weekdayFromDate:(NSDate*)date
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    
    return [comp weekday];
}

+ (NSInteger)getDaysFromTodayToDate:(NSDate*)goalDate
{
	if( goalDate == nil )
		return 0;
	NSDate* today = [NSDate date];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *todayComponent = [[NSDateComponents alloc] init];
	[todayComponent setDay:[A3DateHelper dayFromDate:today]];
	[todayComponent setMonth:[A3DateHelper monthFromDate:today]];
	[todayComponent setYear:[A3DateHelper yearFromDate:today]];
	NSDateComponents *diffComponent = [calendar components:NSDayCalendarUnit
												  fromDate:[calendar dateFromComponents:todayComponent]
													toDate:goalDate options:0];
	
	return [diffComponent day];
}

+ (NSInteger)diffDaysFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
	if( toDate == nil || fromDate == nil || [fromDate isKindOfClass:[NSNull class]] || [toDate isKindOfClass:[NSNull class]])
		return 0;
    
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *diffComponent = [calendar components:NSDayCalendarUnit
												  fromDate:fromDate
													toDate:toDate options:0];

	return [diffComponent day];
}

// KJH
+ (NSString *)untilSinceStringByFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate allDayOption:(BOOL)isAllDay repeat:(BOOL)isRepeat
{
    if (isAllDay) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *fromComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:fromDate];
        NSDateComponents *toComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:toDate];
        
        if (isRepeat && [fromComp month] == [toComp month] && [fromComp day] == [toComp day]) {
            return @"today";
        }
        
        fromComp.hour = 0;
        fromComp.minute = 0;
        fromComp.second = 0;
        toComp.hour = 0;
        toComp.minute = 0;
        toComp.second = 0;
        
        NSDateComponents *daysGapComp = [calendar components:NSDayCalendarUnit
                                                    fromDate:[calendar dateFromComponents:fromComp]
                                                      toDate:[calendar dateFromComponents:toComp]
                                                     options:0];
        if ([daysGapComp day] == 0) {
            return @"today";
        }
        else {
            if ([daysGapComp day] > 0) {
                return @"until";
            }
            else {
                return @"since";
            }
        }
    }
    else {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *fromComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:fromDate];
        NSDateComponents *toComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:toDate];
        
        if (isRepeat && [fromComp month] == [toComp month] && [fromComp day] == [toComp day] &&
            [fromComp hour] == [toComp hour] && [fromComp minute] == [toComp minute]) {
            return @"now";
        }
        else if (!isRepeat && [fromComp year] == [toComp year] && [fromComp month] == [toComp month] && [fromComp day] == [toComp day] &&
                 [fromComp hour] == [toComp hour] && [fromComp minute] == [toComp minute]) {
            return @"now";
        }
        
        if (isRepeat && [fromComp month] == [toComp month] && [fromComp day] == [toComp day]) {
            return @"today";
        }
        else if (!isRepeat && [fromComp year] == [toComp year] && [fromComp month] == [toComp month] && [fromComp day] == [toComp day]) {
            return @"today";
        }

        if ([toDate timeIntervalSince1970] > [fromDate timeIntervalSince1970]) {
            return @"until";
        }
        else {
            return @"since";
        }
    }
}

// KJH
+ (NSInteger)diffDaysFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate isAllDay:(BOOL)isAllDay
{
	if ( toDate == nil || fromDate == nil) {
		return 0;
    }
    
	NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *fromComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:fromDate];
    NSDateComponents *toComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:toDate];
    
    fromComp.hour = 0;
    fromComp.minute = 0;
    fromComp.second = 0;
    toComp.hour = 0;
    toComp.minute = 0;
    toComp.second = 0;
    
    NSDateComponents *diffComponent = [calendar components:NSDayCalendarUnit
                                                  fromDate:[calendar dateFromComponents:fromComp]
                                                    toDate:[calendar dateFromComponents:toComp]
                                                   options:0];
	
	return [diffComponent day];
}

+ (NSInteger)diffWeeksFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    if( toDate == nil || fromDate == nil)
		return 0;
    
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *diffComponent = [calendar components:NSWeekCalendarUnit
												  fromDate:fromDate
													toDate:toDate options:0];
	
	return [diffComponent week];
}

+ (NSInteger)diffMonthsFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    if( toDate == nil || fromDate == nil)
		return 0;
    
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *diffComponent = [calendar components:NSMonthCalendarUnit
												  fromDate:fromDate
													toDate:toDate options:0];
	
	return [diffComponent month];
}

+ (NSInteger)diffYearsFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    if( toDate == nil || fromDate == nil)
		return 0;
    
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *diffComponent = [calendar components:NSYearCalendarUnit
												  fromDate:fromDate
													toDate:toDate options:0];
	
	return [diffComponent year];
}

+ (NSInteger)diffSecondsFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
	if( toDate == nil || fromDate == nil)
		return 0;
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *diffComponent = [calendar components:NSSecondCalendarUnit
												  fromDate:fromDate
													toDate:toDate options:0];
	
	return [diffComponent second];
}

+ (NSDate*)dateFromTodayByDays:(NSInteger)days
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setDay:days];
	return [calendar dateByAddingComponents:addComponent toDate:[NSDate date] options:0];
}

+ (NSDate*)dateFromTodayAndHour:(NSInteger)hour minute:(NSInteger)minute
{
	NSDate* today = [NSDate date];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *todayComponent = [[NSDateComponents alloc] init];
	[todayComponent setDay:[A3DateHelper dayFromDate:today]];
	[todayComponent setMonth:[A3DateHelper monthFromDate:today]];
	[todayComponent setYear:[A3DateHelper yearFromDate:today]];
	[todayComponent setHour:hour];
	[todayComponent setMinute:minute];
	[todayComponent setSecond:0];
	
	return [calendar dateFromComponents:todayComponent];
}

+ (NSDate*)dateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
	[dateComponent setDay:day];
	[dateComponent setMonth:month];
	[dateComponent setYear:year];
	[dateComponent setHour:hour];
	[dateComponent setMinute:minute];
	[dateComponent setSecond:second];
	
	return [calendar dateFromComponents:dateComponent];
}

+ (NSDate*)dateByAddingDays:(NSInteger)days fromDate:(NSDate*)date
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setDay:days];
	return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

+ (NSDate*)dateByAddingYears:(NSInteger)years fromDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setYear:years];
	return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

+ (NSDate*)dateByAddingMonth:(NSInteger)month fromDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setMonth:month];
	return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

+ (NSDate*)dateByAddingWeeks:(NSInteger)weeks fromDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setWeek:weeks];
	return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

+ (NSDate*)dateByDiffMonth:(NSInteger)diff atMonth:(NSDate*)month
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setMonth:diff];
	return [calendar dateByAddingComponents:addComponent toDate:month options:0];
}

+ (NSInteger)firstDayPositionOfMonth:(NSDate*)month
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *component = [[NSDateComponents alloc] init];
	[component setYear:[A3DateHelper yearFromDate:month]];
	[component setMonth:[A3DateHelper monthFromDate:month]];
	[component setDay:1];
	NSDate* date = [calendar dateFromComponents:component];
	component = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit fromDate:date];
	
	return ([component weekday]-1);
}

+ (NSInteger)numberOfWeeksOfMonth:(NSDate*)month
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *startDate = [A3DateHelper dateFromYear:[A3DateHelper yearFromDate:month] month:[A3DateHelper monthFromDate:month] day:1 hour:12 minute:0 second:0];
	NSRange range = [calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:startDate];
	
	return range.length;
}

+ (NSInteger)lastDaysOfMonth:(NSDate*)month
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *startDate = [A3DateHelper dateFromYear:[A3DateHelper yearFromDate:month] month:[A3DateHelper monthFromDate:month] day:1 hour:12 minute:0 second:0];
	NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:startDate];
	
	return range.length;
}

+ (NSDate*)dateMake12PM:(NSDate*)date
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    
    return [A3DateHelper dateFromYear:[comps year] month:[comps month] day:[comps day] hour:12 minute:0 second:0];
}

+ (NSDate*)dateMakeSecondZero:(NSDate*)date
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    
    return [A3DateHelper dateFromYear:[comps year] month:[comps month] day:[comps day] hour:[comps hour] minute:[comps minute] second:0];
}

+ (NSDate*)dateMakeMonthFirstDayAtDate:(NSDate*)date
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    
    return [A3DateHelper dateFromYear:[comps year] month:[comps month] day:1 hour:12 minute:0 second:0];
}

+ (NSDate*)dateMakeDate:(NSDate*)date Hour:(NSInteger)hour minute:(NSInteger)minute
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    
    return [A3DateHelper dateFromYear:[comps year] month:[comps month] day:[comps day] hour:hour minute:minute second:0];
}

+ (NSDateComponents*)dateComponentsFromDate:(NSDate*)date unitFlags:(NSUInteger)unitFlags
{
    return [[NSCalendar currentCalendar] components:unitFlags fromDate:date];
}

+ (BOOL)isCurrentLocaleIsKorea
{
    return [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]	isEqualToString:@"KR"];
}

@end
