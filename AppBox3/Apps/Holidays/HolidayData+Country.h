//
//  HolidayData+Country.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "HolidayData.h"

extern NSString *const kHolidayCountryCode;
extern NSString *const kHolidayCapitalCityName;
extern NSString *const kHolidayTimeZone;
extern NSString *const kA3TimeZoneName;
extern NSString *const A3NotificationHolidaysCountryListChanged;

@interface HolidayData (Country)

+ (NSArray *)supportedCountries;
+ (void)resetFirstCountryWithLocale;
+ (NSArray *)userSelectedCountries;
- (NSMutableArray *)holidaysForCountry:(NSString *)countryCode year:(NSUInteger)year fullSet:(BOOL)fullSet;
- (NSDictionary *)firstUpcomingHolidaysForCountry:(NSString *)countryCode;
+ (id)keyForExcludedHolidaysForCountry:(NSString *)countryCode;
+ (BOOL)needToShowLunarDatesForCountryCode:(NSString *)countryCode;
+ (BOOL)needToShowLunarDatesOptionMenuForCountryCode:(NSString *)countryCode;
+ (void)addCountryToShowLunarDatesSet:(NSString *)countryCode;
+ (void)removeCountryFromShowLunarDatesSet:(NSString *)countryCode;
+ (NSTimeZone *)timeZoneForCountryCode:(NSString *)countryCode;
+ (void)setUserSelectedCountries:(NSArray *)newData;
+ (NSInteger)thisYear;

@end
