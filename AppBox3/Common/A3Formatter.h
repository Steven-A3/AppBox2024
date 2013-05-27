//
//  A3Formatter.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/2/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A3Formatter : NSObject

+ (NSString *)shortStyleDateTimeStringFromDate:(NSDate *)date;

+ (NSString *)mediumStyleDateStringFromDate:(NSDate *)date;
+ (NSString *)fullStyleMonthSymbolFromDate:(NSDate *)date;
+ (NSString *)fullStyleYearMonthStringFromDate:(NSDate *)date;
+ (NSString *)stringWithCurrencyFormatFromNumber:(NSNumber *)number;

+ (NSString *)stringWithPercentFormatFromNumber:(NSNumber *)number;
@end
