//
//  DaysCounterEvent.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 5..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DaysCounterCalendar, DaysCounterEventLocation;

@interface DaysCounterEvent : NSManagedObject

@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSString * eventKitId;
@property (nonatomic, retain) NSString * calendarId;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSNumber * isLunar;
@property (nonatomic, retain) NSString * imageFilename;
@property (nonatomic, retain) NSNumber * isAllDay;
@property (nonatomic, retain) NSNumber * isPeriod;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * repeatType;
@property (nonatomic, retain) NSDate * repeatEndDate;
@property (nonatomic, retain) NSDate * alertDatetime;
@property (nonatomic, retain) NSNumber * durationOption;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSDate * regDate;
@property (nonatomic, retain) DaysCounterEventLocation *location;
@property (nonatomic, retain) DaysCounterCalendar *calendar;

@end
