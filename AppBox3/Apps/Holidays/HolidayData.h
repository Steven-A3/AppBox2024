//
//  HolidayUtil.h
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import <Foundation/Foundation.h>

enum weekdays {
	Sunday = 1,
	Monday,
	Tuesday,
	Wednesday,
	Thursday,
	Friday,
	Saturday,
};

extern NSString *const A3HolidaysDoesNotNeedsShowDisclaimer;
extern NSString *const A3HolidaysDoesNotNeedsShowAcknowledgement;

extern NSString *const kHolidayName;
extern NSString *const kHolidayIsPublic;
extern NSString *const kHolidayDate;
extern NSString *const kHolidayDuration;

@interface HolidayData : NSObject

@property (nonatomic, assign)	NSUInteger year;

+ (NSDate *)adjustDate:(NSDate *)date calendar:(NSCalendar *)calendar option:(int)option;
+ (NSDate *)dateWithDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger) year withCalendar:(NSCalendar *)calendar option:(int)option;
+ (NSDate *)dateWithWeekday:(NSUInteger)weekday ordinal:(NSUInteger)ordinal month:(NSUInteger)month year:(NSUInteger)year withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getEasterDayOfYear:(NSUInteger)y withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getOrthodoxEaster:(NSUInteger)y withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getShamElNessim:(NSUInteger)y withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getMaundiThursday:(NSUInteger)y withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getGoodFriday:(NSUInteger)y western:(BOOL)western withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getHolySaturday:(NSUInteger)y withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getEasterMonday:(NSUInteger)y western:(BOOL)western withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getAshWednesday:(NSUInteger)y withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getAscensionDay:(NSUInteger)y western:(BOOL)western withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getPentecost:(NSUInteger)y western:(BOOL)western withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getWhitMonday:(NSUInteger)y western:(BOOL)western withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getSacredHeart:(NSUInteger)y withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getCorpusChristi:(NSUInteger)y withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getIslamicNewYear:(NSUInteger)year withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getRamadanFeast:(NSUInteger)year withCalendar:(NSCalendar *)calendar option:(int)option;
+ (NSDate *)getLaylat_al_Qadr:(NSUInteger)y withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getSacrificeFeast:(NSUInteger)year withCalendar:(NSCalendar *)calendar;

+ (NSArray *)getMohamedBirthday:(NSUInteger)year;

+ (NSDate *)getIsraAndMiraj:(NSUInteger)year withCalendar:(NSCalendar *)calendar;
+ (NSDate *)getVesakDay:(NSUInteger)year forCountryCode:(NSString *)countryCode withCalendar:(NSCalendar *)calendar;

+ (NSDate *)getDeepavaliForYear:(NSInteger)year;

+ (NSDate *)koreaLunarDateWithSolarDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year;

+ (NSDate *)chinaLunarDateWithSolarDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year;

+ (NSDate *)lunarDateWithSolarDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year;
+ (NSDate *)getLastWeekday:(NSUInteger)weekday OfMonth:(NSUInteger)month forYear:(NSUInteger)year withCalendar:(NSCalendar *)calendar;

+ (NSDate *)lunarCalcWithComponents:(NSDateComponents *)components gregorianToLunar:(BOOL)isGregorianToLunar leapMonth:(BOOL)isLeapMonth korean:(BOOL)isKorean;

+ (NSDate *)koreaLunarDateWithGregorianDate:(NSDate *)date;
+ (NSDate *)lunarDateWithGregorianDate:(NSDate *)date;
+ (NSDate *)justDateWithDate:(NSDate *)date;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSDate *)dateFrom:(NSDate *)from withOffset:(NSInteger)offset;

@end

void setDateStyleMedium(NSDateFormatter *df);
