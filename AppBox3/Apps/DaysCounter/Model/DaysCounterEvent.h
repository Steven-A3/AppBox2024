//
//  DaysCounterEvent.h
//  AppBox3
//
//  Created by dotnetguy83 on 4/12/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DaysCounterCalendar, DaysCounterEventLocation;

@interface DaysCounterEvent : NSManagedObject

@property (nonatomic, retain) NSDate * alertDatetime;
@property (nonatomic, retain) NSNumber * alertInterval;
@property (nonatomic, retain) NSString * calendarId;
@property (nonatomic, retain) NSNumber * durationOption;
@property (nonatomic, retain) NSDate * effectiveStartDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSString * eventKitId;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSString * imageFilename;
@property (nonatomic, retain) NSNumber * isAllDay;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSNumber * isLunar;
@property (nonatomic, retain) NSNumber * isPeriod;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * regDate;
@property (nonatomic, retain) NSDate * repeatEndDate;
@property (nonatomic, retain) NSNumber * repeatType;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * alertType;
@property (nonatomic, retain) DaysCounterCalendar *calendar;
@property (nonatomic, retain) DaysCounterEventLocation *location;

@end
