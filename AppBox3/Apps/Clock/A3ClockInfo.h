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

@property (nonatomic, strong) NSString* strTimeHour;
@property (nonatomic, strong) NSString* strTimeMinute;
@property (nonatomic, strong) NSString* strTimeSecond;
@property (nonatomic, strong) NSString* strTimeAMPM;
@property (nonatomic, strong) NSString* strDateDay;
@property (nonatomic, strong) NSString* strDateMaxDay;
@property (nonatomic, strong) NSString* strDateMonth;
@property (nonatomic, strong) NSString* strDateMonthShort;
@property (nonatomic, strong) NSString* strWeek;
@property (nonatomic, strong) NSString* strWeekShort;
@property (nonatomic, strong) NSString* strWeekStartShort;
@property (nonatomic, strong) NSString* strWeekEndShort;
@property (nonatomic, strong) A3Weather *currentWeather;

@end
