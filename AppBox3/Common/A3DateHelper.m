//
//  A3DateHelper.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateHelper.h"
#import "NSDateFormatter+LunarDate.h"
#import "A3AppDelegate.h"

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

+ (NSInteger)weekdayFromDate:(NSDate*)date
{
    NSDateComponents *comp = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitWeekday fromDate:date];
    
    return [comp weekday];
}

+ (NSInteger)diffDaysFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
	if( toDate == nil || fromDate == nil || [fromDate isKindOfClass:[NSNull class]] || [toDate isKindOfClass:[NSNull class]])
		return 0;
    
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *diffComponent = [calendar components:NSCalendarUnitDay
												  fromDate:fromDate
													toDate:toDate options:0];

	return [diffComponent day];
}

+ (NSDateComponents *)diffCompFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate calendarUnit:(NSCalendarUnit)calendarUnit
{
	if( toDate == nil || fromDate == nil || [fromDate isKindOfClass:[NSNull class]] || [toDate isKindOfClass:[NSNull class]])
		return 0;
    
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *diffComponent = [calendar components:calendarUnit
												  fromDate:fromDate
													toDate:toDate options:0];
    
	return diffComponent;
}

// KJH
+ (NSString *)untilSinceStringByFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate allDayOption:(BOOL)isAllDay repeat:(BOOL)isRepeat strict:(BOOL)isStrict
{
    if (isAllDay) {
        NSCalendar *calendar = [[A3AppDelegate instance] calendar];
        NSDateComponents *fromComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:fromDate];
        NSDateComponents *toComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:toDate];
        
        if (isRepeat && [fromComp month] == [toComp month] && [fromComp day] == [toComp day]) {
            return NSLocalizedString(@"Today", @"Today");
        }
        
        fromComp.hour = 0;
        fromComp.minute = 0;
        fromComp.second = 0;
        toComp.hour = 0;
        toComp.minute = 0;
        toComp.second = 0;
        
        NSDateComponents *daysGapComp = [calendar components:NSCalendarUnitDay
                                                    fromDate:[calendar dateFromComponents:fromComp]
                                                      toDate:[calendar dateFromComponents:toComp]
                                                     options:0];
        if ([daysGapComp day] == 0) {
            return NSLocalizedString(@"Today", @"Today");
        }
        else {
            if ([daysGapComp day] > 0) {
                return NSLocalizedString(@"until", @"until");
            }
            else {
                return NSLocalizedString(@"since", @"since");
            }
        }
    }
    else {
        NSCalendar *calendar = [[A3AppDelegate instance] calendar];
        NSDateComponents *fromComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:fromDate];
        NSDateComponents *toComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:toDate];
        
        if (isRepeat && [fromComp month] == [toComp month] && [fromComp day] == [toComp day] &&
            [fromComp hour] == [toComp hour] && [fromComp minute] == [toComp minute]) {
            return NSLocalizedString(@"Now", nil);
        }
        else if (!isRepeat && [fromComp year] == [toComp year] && [fromComp month] == [toComp month] && [fromComp day] == [toComp day] &&
                 [fromComp hour] == [toComp hour] && [fromComp minute] == [toComp minute]) {
            return NSLocalizedString(@"Now", nil);
        }
        
        if (isStrict) {
            if ([toDate timeIntervalSince1970] > [fromDate timeIntervalSince1970]) {
                return NSLocalizedString(@"until", @"until");
            }
            else {
                if ([fromDate timeIntervalSince1970] > [toDate timeIntervalSince1970]) {
                    if (isRepeat && [fromComp month] == [toComp month] && [fromComp day] == [toComp day]) {
                        return NSLocalizedString(@"Today", @"Today");
                    }
                    else if (!isRepeat && [fromComp year] == [toComp year] && [fromComp month] == [toComp month] && [fromComp day] == [toComp day]) {
                        return NSLocalizedString(@"Today", @"Today");
                    }
                }
                return NSLocalizedString(@"since", @"since");
            }
        }
        else {
            if (isRepeat && [fromComp month] == [toComp month] && [fromComp day] == [toComp day]) {
                return NSLocalizedString(@"Today", @"Today");
            }
            else if (!isRepeat && [fromComp year] == [toComp year] && [fromComp month] == [toComp month] && [fromComp day] == [toComp day]) {
                return NSLocalizedString(@"Today", @"Today");
            }
            
            if ([toDate timeIntervalSince1970] > [fromDate timeIntervalSince1970]) {
                return NSLocalizedString(@"until", @"until");
            }
            else {
                return NSLocalizedString(@"since", @"since");
            }
        }
    }
}

// KJH
+ (NSInteger)diffDaysFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate isAllDay:(BOOL)isAllDay
{
	if ( toDate == nil || fromDate == nil) {
		return 0;
    }
    
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
    NSDateComponents *fromComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:fromDate];
    NSDateComponents *toComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:toDate];
    
    fromComp.hour = 0;
    fromComp.minute = 0;
    fromComp.second = 0;
    toComp.hour = 0;
    toComp.minute = 0;
    toComp.second = 0;
    
    NSDateComponents *diffComponent = [calendar components:NSCalendarUnitDay
                                                  fromDate:[calendar dateFromComponents:fromComp]
                                                    toDate:[calendar dateFromComponents:toComp]
                                                   options:0];
	
	return [diffComponent day];
}

+ (NSInteger)diffWeeksFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    if( toDate == nil || fromDate == nil)
		return 0;
    
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *diffComponent = [calendar components:NSWeekOfYearCalendarUnit
												  fromDate:fromDate
													toDate:toDate options:0];
	
	return [diffComponent weekOfYear];
}

+ (NSInteger)diffMonthsFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    if( toDate == nil || fromDate == nil)
		return 0;
    
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *diffComponent = [calendar components:NSCalendarUnitMonth
												  fromDate:fromDate
													toDate:toDate options:0];
	
	return [diffComponent month];
}

+ (NSInteger)diffYearsFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    if( toDate == nil || fromDate == nil)
		return 0;
    
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *diffComponent = [calendar components:NSCalendarUnitYear
												  fromDate:fromDate
													toDate:toDate options:0];
	
	return [diffComponent year];
}

+ (NSDate*)dateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
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
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setDay:days];
	return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

+ (NSDate*)dateByAddingYears:(NSInteger)years fromDate:(NSDate*)date
{
    NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setYear:years];
	return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

+ (NSDate*)dateByAddingMonth:(NSInteger)month fromDate:(NSDate*)date
{
    NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setMonth:month];
	return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

+ (NSDate*)dateByAddingWeeks:(NSInteger)weeks fromDate:(NSDate*)date
{
    NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setWeekOfYear:weeks];
	return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

#pragma mark Specific Date

+ (NSInteger)numberOfWeeksOfMonth:(NSDate*)month
{
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:month];
	NSDate *startDate = [A3DateHelper dateFromYear:components.year month:components.month day:1 hour:12 minute:0 second:0];
	NSRange range = [calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSCalendarUnitMonth forDate:startDate];
	
	return range.length;
}

+ (NSInteger)lastDaysOfMonth:(NSDate*)month
{
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:month];
	NSDate *startDate = [A3DateHelper dateFromYear:components.year month:components.month day:1 hour:12 minute:0 second:0];
	NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:startDate];
	
	return range.length;
}

+ (NSDate*)dateMake12PM:(NSDate*)date
{
    NSDateComponents *comps = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    
    return [A3DateHelper dateFromYear:[comps year] month:[comps month] day:[comps day] hour:12 minute:0 second:0];
}

+ (NSDate*)dateMakeMonthFirstDayAtDate:(NSDate*)date
{
    NSDateComponents *comps = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    
    return [A3DateHelper dateFromYear:[comps year] month:[comps month] day:1 hour:12 minute:0 second:0];
}

+ (NSDate *)midnightForDate:(NSDate *)date
{
    NSDateComponents *comp = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                                             fromDate:date];
    comp.hour = 0;
    comp.minute = 0;
    comp.second = 0;
    date = [[[A3AppDelegate instance] calendar] dateFromComponents:comp];
    return date;
}

#pragma mark Lunar

+ (NSString *)dateStringFromDateComponents:(NSDateComponents *)dateComp withFormat:(NSString *)format
{ 
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    if (format) {
        [dateFormatter setDateFormat:format];
    }
    else {
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    
    return [dateFormatter stringFromDateComponents:dateComp];
}

@end
