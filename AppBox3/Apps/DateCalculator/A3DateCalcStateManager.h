//
//  A3DateCalcStateManager.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 16..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef NS_ENUM(NSInteger, DurationType) {
//    DurationType_Year = 0,
//    DurationType_Month,
//    DurationType_Week,
//    DurationType_Day
//};

typedef NS_OPTIONS(NSInteger, DurationType) {
    DurationType_None = 0,
    DurationType_Year = 1 << 1,
    DurationType_Month = 1 << 2,
    DurationType_Week = 1 << 3,
    DurationType_Day = 1 << 4
};

typedef NS_OPTIONS(NSInteger, ExcludeOptions) {
    ExcludeOptions_None = 0,
    ExcludeOptions_Saturday = 1 << 1,
    ExcludeOptions_Sunday = 1 << 2,
    ExcludeOptions_PublicHoliday = 1 << 3
};

@interface A3DateCalcStateManager : NSObject
#pragma mark - Duration
+(void)setDurationType:(DurationType)durationType;
+(DurationType)durationType;
+(NSCalendarUnit)calendarUnitByDurationType;
+(NSString *)durationTypeString;
#pragma mark - Exclude
+(void)setExcludeOptions:(ExcludeOptions)options;
+(ExcludeOptions)excludeOptions;
+(NSString *)excludeOptionsString;
#pragma mark - DateCalculation
+(NSCalendar *)currentCalendar;
+(NSDate *)dateByAddingDay:(NSInteger)aDay toDate:(NSDate *)fromDate;
+(NSDate *)dateBySubtractingDay:(NSInteger)aDay toDate:(NSDate *)fromDate;
+(NSDateComponents *)dateComponentByAddingDay:(NSInteger)aDay toDate:(NSDate *)fromDate;
+(NSDateComponents *)dateComponentBySubtractingDay:(NSInteger)aDay toDate:(NSDate *)fromDate;
+(NSDateComponents *)dateComponentFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
+(NSInteger)dayCountToDate:(NSDate *)date;
+(NSInteger)dayCountToDate:(NSDate *)date from:(NSDate *)from;

+(NSString *)formattedStringDate:(NSDate *)date;
+(void)setCurrentDurationType:(DurationType)type;
+(DurationType)currentDurationType;
+(DurationType)addSubDurationType;
@end
