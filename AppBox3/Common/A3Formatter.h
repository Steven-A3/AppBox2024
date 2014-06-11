//
//  A3Formatter.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/2/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//


@interface A3Formatter : NSObject

+ (NSString *)shortStyleDateTimeStringFromDate:(NSDate *)date;

+ (NSString *)mediumStyleDateStringFromDate:(NSDate *)date;
+ (NSString *)fullStyleMonthSymbolFromDate:(NSDate *)date;
+ (NSString *)fullStyleYearMonthStringFromDate:(NSDate *)date;
+ (NSString *)stringWithCurrencyFormatFromNumber:(NSNumber *)number;

+ (NSString *)stringWithPercentFormatFromNumber:(NSNumber *)number;
// 오영택 add
+ (NSString *)fullStyleDateStringFromDate:(NSDate *)date;
+ (NSString *)customFullStyleStringFromDate:(NSDate *)date;

@end
