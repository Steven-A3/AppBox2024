//
//  A3DateCalcStateManager.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 16..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcStateManager.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"
#import "A3AppDelegate.h"
#import "A3DateMainTableViewController.h"
#import "A3SyncManager.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

@implementation A3DateCalcStateManager

static DurationType g_currentDurationType;

#pragma mark -
+ (void)setDurationType:(DurationType)options
{
//    DurationType result = DurationType_Year;
    DurationType result = DurationType_Day;
    DurationType oldOptions = (DurationType) [[A3SyncManager sharedSyncManager] integerForKey:A3DateCalcDefaultsDurationType];
    
    if (oldOptions == options) {
        // 선택 항목이 마지막 하나 남은 경우.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(A3AppName_DateCalculator, nil)
                                                            message:NSLocalizedString(@"To show results, need one option.", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (options == DurationType_None) {
        //result = DurationType_Year;
        result = DurationType_Day;
    }
    else {
        if (oldOptions & options) {
            result = oldOptions & ~options;
        } else {
            result = oldOptions|options;
        }
    }
    
    if (result==DurationType_None) {
        //result = DurationType_Year;
        result = DurationType_Day;
    }

	[[A3SyncManager sharedSyncManager] setObject:@(result) forKey:A3DateCalcDefaultsDurationType state:A3DataObjectStateModified];
}

+ (DurationType)durationType
{
    return (DurationType) [[A3SyncManager sharedSyncManager] integerForKey:A3DateCalcDefaultsDurationType];
}

+ (NSCalendarUnit)calendarUnitByDurationType
{
    NSCalendarUnit calUnit = 0;
    DurationType durationType = (DurationType) [[A3SyncManager sharedSyncManager] integerForKey:A3DateCalcDefaultsDurationType];
 
    if (durationType & DurationType_Year) {
        calUnit |= NSCalendarUnitYear;
    }
    if (durationType & DurationType_Month) {
        calUnit |= NSCalendarUnitMonth;
    }
    if (durationType & DurationType_Week) {
        calUnit |=NSCalendarUnitWeekOfYear;
    }
    if (durationType & DurationType_Day) {
        calUnit |=NSCalendarUnitDay;
    }
    
    return calUnit;
}

+ (NSString *)durationTypeString
{
    DurationType type = (DurationType) [[A3SyncManager sharedSyncManager] integerForKey:A3DateCalcDefaultsDurationType];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (type & DurationType_None || type & DurationType_Year) {
        [result addObject:NSLocalizedString(@"Years", @"Years")];
    }
    if (type & DurationType_Month) {
        [result addObject:NSLocalizedString(@"Months", @"Months")];
    }
    if (type & DurationType_Week) {
        [result addObject:NSLocalizedString(@"Weeks", @"Weeks")];
    }
    if (type & DurationType_Day) {
        [result addObject:NSLocalizedString(@"Days", @"Days")];
    }
    
    return [result componentsJoinedByString:@", "];
}

+ (void)setCurrentDurationType:(DurationType)type {
    g_currentDurationType = type;
}

+ (DurationType)currentDurationType {
    return g_currentDurationType;
}

+ (DurationType)addSubDurationType {
    return DurationType_Year | DurationType_Month | DurationType_Day;
}

#pragma mark - 
+ (void)setExcludeOptions:(ExcludeOptions)options
{
    ExcludeOptions result = ExcludeOptions_None;
    ExcludeOptions oldOptions = (ExcludeOptions) [[A3SyncManager sharedSyncManager] integerForKey:A3DateCalcDefaultsExcludeOptions];
    
    if (oldOptions == options) {
        return;
    }
    
    if (options == ExcludeOptions_None) {
        result = ExcludeOptions_None;
        
    } else {
        if (oldOptions & options) {
            result = oldOptions & ~options;
        } else {
            result = oldOptions|options;
        }
    }

	[[A3SyncManager sharedSyncManager] setObject:@(result) forKey:A3DateCalcDefaultsExcludeOptions state:A3DataObjectStateModified];
}

+ (ExcludeOptions)excludeOptions
{
    return (ExcludeOptions) [[A3SyncManager sharedSyncManager] integerForKey:A3DateCalcDefaultsExcludeOptions];
}

+ (NSString *)excludeOptionsString
{
    ExcludeOptions options = (ExcludeOptions) [[A3SyncManager sharedSyncManager] integerForKey:A3DateCalcDefaultsExcludeOptions];
    if (ExcludeOptions_None == options) {
        return NSLocalizedString(@"DateCalcExclude_None", nil);
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];

    if (ExcludeOptions_Saturday & options && ExcludeOptions_Sunday & options) {
        [result addObject:NSLocalizedString(@"Weekends", @"Weekends")];
    } else {
        if (ExcludeOptions_Saturday & options) {
            [result addObject:IS_IPHONE ? NSLocalizedString(@"Sat", @"Sat") : NSLocalizedString(@"Saturday", @"Saturday")];
        }
        if (ExcludeOptions_Sunday & options) {
            [result addObject:IS_IPHONE ? NSLocalizedString(@"Sun", @"Sun") : NSLocalizedString(@"Sunday", @"Sunday")];
        }
    }
    
    if (ExcludeOptions_PublicHoliday & options) {
        [result addObject:NSLocalizedString(@"Public Holidays", @"Public Holidays")];
    }
    
    return [result componentsJoinedByString:@", "];
}

#pragma mark - DateCalculation

+ (NSCalendar *)currentCalendar
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return calendar;
}

+ (NSDateComponents *)dateComponentByAddingDay:(NSInteger)aDay toDate:(NSDate *)fromDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [NSDateComponents new];
    comp.day = aDay;
    // 날짜 더하기
    NSDate *toDate = [calendar dateByAddingComponents:comp toDate:fromDate options:0];
    
    return [A3DateCalcStateManager dateComponentFromDate:fromDate toDate:toDate];
}

+ (NSDateComponents *)dateComponentBySubtractingDay:(NSInteger)aDay toDate:(NSDate *)fromDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [NSDateComponents new];
    comp.day = -aDay;
    // 날짜 더하기
    NSDate *toDate = [calendar dateByAddingComponents:comp toDate:fromDate options:0];
    
    return [A3DateCalcStateManager dateComponentFromDate:toDate toDate:fromDate];
}

+ (NSDate *)dateByAddingDay:(NSInteger)aDay toDate:(NSDate *)fromDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [NSDateComponents new];
    comp.day = aDay;
    // 날짜 더하기
    NSDate *toDate = [calendar dateByAddingComponents:comp toDate:fromDate options:0];
    return toDate;
}

+ (NSDate *)dateBySubtractingDay:(NSInteger)aDay toDate:(NSDate *)fromDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [NSDateComponents new];
    comp.day = -aDay;
    // 날짜 더하기
    NSDate *toDate = [calendar dateByAddingComponents:comp toDate:fromDate options:0];
    return toDate;
}

/**
 - 제외날짜, 기간 적용하여 날짜 계산.

 **/
+ (NSDateComponents *)dateComponentFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    FNLOG(@"\nfromDate: %@ \ntoDate: %@", fromDate, toDate);
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // 제외 날짜 계산. 일요일, 토요일
    ExcludeOptions exclude = [A3DateCalcStateManager excludeOptions];
    NSInteger excludeOffset = 0;
    NSInteger resultDays = 0;
    
    NSDateComponents *rangeDayComp = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    NSDateComponents *weeks = [calendar components:NSWeekOfYearCalendarUnit fromDate:fromDate toDate:toDate options:0];
    NSDateComponents *fromWeekDay = [calendar components:NSCalendarUnitWeekday fromDate:fromDate];
    NSDateComponents *toWeekDay = [calendar components:NSCalendarUnitWeekday fromDate:toDate];
    NSInteger totalWeeks = 0;

    if ( (rangeDayComp.day % 7 == 0) || (fromWeekDay.weekday < toWeekDay.weekday) ) {
        if (exclude & ExcludeOptions_Sunday) {
            totalWeeks += weeks.weekOfYear;
        }
        if (exclude & ExcludeOptions_Saturday) {
            totalWeeks += weeks.weekOfYear;
        }
    } else {
        // from > to
        if (toWeekDay.weekday==[calendar firstWeekday]+6 || toWeekDay.weekday==[calendar firstWeekday]) {
            // toDate가 주말인 경우
            if (exclude & ExcludeOptions_Sunday) {
                if (fromWeekDay.weekday > toWeekDay.weekday && toWeekDay.weekday == [calendar firstWeekday]+6) {
                    totalWeeks += weeks.weekOfYear + 1;
                } else {
                    totalWeeks += weeks.weekOfYear;
                }
            }
            if (exclude & ExcludeOptions_Saturday) {
                if (fromWeekDay.weekday > toWeekDay.weekday && toWeekDay.weekday == [calendar firstWeekday]) {
                    totalWeeks += weeks.weekOfYear + 1;
                } else {
                    totalWeeks += weeks.weekOfYear;
                }
            }
        } else {
            // toDate가 주중인 경우
            if (exclude & ExcludeOptions_Sunday) {
                if (fromWeekDay.weekday > toWeekDay.weekday) {
                    totalWeeks += weeks.weekOfYear + 1;
                } else {
                    totalWeeks += weeks.weekOfYear;
                }
            }
            if (exclude & ExcludeOptions_Saturday) {
                if (fromWeekDay.weekday > toWeekDay.weekday) {
                    totalWeeks += weeks.weekOfYear + 1;
                } else {
                    totalWeeks += weeks.weekOfYear;
                }
            }
        }
    }
    
    excludeOffset = totalWeeks;
    resultDays = rangeDayComp.day - excludeOffset;
    
    // 계산 결과, 기간타입 반영 반환
    NSDateComponents *daysComp = [NSDateComponents new];
    NSDate *resultDate;
    DurationType durationType = [A3DateCalcStateManager durationType];
    g_currentDurationType = durationType;
    NSCalendarUnit calUnit = [A3DateCalcStateManager calendarUnitByDurationType];
    daysComp.day = resultDays;
    
    if (durationType == DurationType_Day) {
        return daysComp;
    }

    resultDate = [calendar dateByAddingComponents:daysComp toDate:fromDate options:0];
    //resultComp = [calendar components:calUnit fromDate:fromDate toDate:toDate options:0];
    FNLOG(@"fromDate: %@, toDate: %@ \nresultDate: %@", fromDate, toDate, resultDate);
    FNLOG(@"betweenDays: %ld", (long)daysComp.day);
    NSDateComponents *resultComp = [calendar components:calUnit fromDate:fromDate toDate:resultDate options:0];
    
    // 기간이 충분치 않아, durationType 에 맞게 표현할 수 없는 경우.
    if ( (durationType==DurationType_Year && resultComp.year==0) ||
         (durationType==DurationType_Month && resultComp.month==0) ) {
        calUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        g_currentDurationType = DurationType_Year | DurationType_Month | DurationType_Day;
        resultDate = [calendar dateByAddingComponents:daysComp toDate:fromDate options:0];
        resultComp = [calendar components:calUnit fromDate:fromDate toDate:resultDate options:0];
        FNLOG(@"resultComp 2: %@", resultComp);
        return resultComp;
    }
    
    FNLOG(@"resultComp 1: %@", resultComp);

    return resultComp;
}

+ (NSInteger)dayCountToDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *result = [calendar components:NSCalendarUnitDay fromDate:date];
    return result.day;
}

+ (NSInteger)dayCountToDate:(NSDate *)date from:(NSDate *)from
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *result = [calendar components:NSCalendarUnitDay fromDate:from toDate:date options:0];
    return result.day;
}


+ (NSString *)fullStyleDateStringFromDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp1 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    comp1.hour = 0;
    comp1.minute = 0;
    NSDate *today = [calendar dateFromComponents:comp1];
    comp1 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
    NSDateComponents *comp2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    if (comp1.year==comp2.year && comp1.month==comp2.month && comp1.day==comp2.day) {
        return NSLocalizedString(@"Today  ", @"Today  ");
    }
    
    return [date a3FullStyleString];
}

+ (NSString *)fullCustomStyleDateStringFromDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp1 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    comp1.hour = 0;
    comp1.minute = 0;
    NSDate *today = [calendar dateFromComponents:comp1];
    comp1 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
    NSDateComponents *comp2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    if (comp1.year==comp2.year && comp1.month==comp2.month && comp1.day==comp2.day) {
        return NSLocalizedString(@"Today  ", @"Today  ");
    }
    
    return [date a3FullCustomStyleString];
}

@end
