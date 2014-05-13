//
//  DaysCounterEvent.h
//  AppBox3
//
//  Created by A3 on 5/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DaysCounterCalendar, DaysCounterDateModel, DaysCounterEventLocation, DaysCounterFavorite, DaysCounterReminder;

@interface DaysCounterEvent : NSManagedObject

@property (nonatomic, retain) NSDate * alertDatetime;
@property (nonatomic, retain) NSNumber * alertInterval;
@property (nonatomic, retain) NSNumber * alertType;
@property (nonatomic, retain) NSString * calendarId;
@property (nonatomic, retain) NSNumber * durationOption;
@property (nonatomic, retain) NSDate * effectiveStartDate;
@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSString * eventKitId;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSNumber * hasReminder;
@property (nonatomic, retain) NSString * imageFilename;
@property (nonatomic, retain) NSNumber * isAllDay;
@property (nonatomic, retain) NSNumber * isLunar;
@property (nonatomic, retain) NSNumber * isPeriod;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * regDate;
@property (nonatomic, retain) NSDate * repeatEndDate;
@property (nonatomic, retain) NSNumber * repeatType;
@property (nonatomic, retain) NSNumber * useLeapMonth;
@property (nonatomic, retain) DaysCounterCalendar *calendar;
@property (nonatomic, retain) DaysCounterDateModel *endDate;
@property (nonatomic, retain) DaysCounterFavorite *favorite;
@property (nonatomic, retain) DaysCounterEventLocation *location;
@property (nonatomic, retain) DaysCounterReminder *reminder;
@property (nonatomic, retain) DaysCounterDateModel *startDate;

@end
