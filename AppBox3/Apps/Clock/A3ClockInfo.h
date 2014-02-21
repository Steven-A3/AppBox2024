//
//  A3ClockInfo.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3Weather.h"

@interface A3ClockInfo : NSObject

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDateComponents *dateComponents;

@property (nonatomic, strong) NSString *AMPM;
@property (nonatomic, strong) NSString *day;
@property (nonatomic, strong) NSString *maxDay;
@property (nonatomic, strong) NSString *month;
@property (nonatomic, strong) NSString *shortMonth;
@property (nonatomic, strong) NSString *weekday;
@property (nonatomic, strong) NSString *shortWeekday;
@property (nonatomic, strong) A3Weather *currentWeather;
@property (nonatomic, strong) NSString *fullStyleFormatWithoutYear;
@property (nonatomic, strong) NSString *mediumStyleFormatWithoutYear;

- (NSString *)fullStyleDateStringWithoutYear;

- (NSString *)mediumStyleDateStringWithoutYear;

- (NSString *)dateStringConsideringOptions;

- (long)hour;
@end
