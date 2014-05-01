//
//  NSDate+LunarConverter.h
//  A3TeamWork
//
//  Created by Byeong Kwon Kwak on 10/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (LunarConverter)

+ (NSDateComponents *)lunarCalcWithComponents:(NSDateComponents *)components gregorianToLunar:(BOOL)isGregorianToLunar leapMonth:(BOOL)isLeapMonth korean:(BOOL)isKorean resultLeapMonth:(BOOL*)resultLeapMonth;
+ (BOOL)isLunarLeapMonthAtDate:(NSDateComponents *)dateComponents isKorean:(BOOL)isKorean;
+ (NSInteger)lastMonthDayForLunarYear:(NSInteger)year month:(NSInteger)month isKorean:(BOOL)isKorean;
+ (NSDate *)dateOfLunarFromSolarDate:(NSDate *)date leapMonth:(BOOL)isLeapMonth korean:(BOOL)isKorean resultLeapMonth:(BOOL*)resultLeapMonth;
+ (NSDate *)dateOfSolarFromLunarDate:(NSDate *)date leapMonth:(BOOL)isLeapMonth korean:(BOOL)isKorean resultLeapMonth:(BOOL*)resultLeapMonth;
+ (BOOL)isLunarDate:(NSDate *)date isKorean:(BOOL)isKorean;
+ (BOOL)isLunarDateComponents:(NSDateComponents *)dateComp isKorean:(BOOL)isKorean;
+ (BOOL)isLunarLeapMonthDate:(NSDate *)date isKorean:(BOOL)isKorean;
@end
