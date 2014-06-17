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
+ (BOOL)isLunarLeapMonthAtDateComponents:(NSDateComponents *)dateComponents isKorean:(BOOL)isKorean;
+ (NSInteger)lastMonthDayForLunarYear:(NSInteger)year month:(NSInteger)month isKorean:(BOOL)isKorean;
+ (BOOL)isLunarDateComponents:(NSDateComponents *)dateComp isKorean:(BOOL)isKorean;
@end
