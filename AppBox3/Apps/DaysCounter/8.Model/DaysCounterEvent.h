//
//  DaysCounterEvent.h
//  AppBox3
//
//  Created by A3 on 7/25/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DaysCounterEvent : NSManagedObject

@property (nonatomic, retain) NSDate * alertDatetime;
@property (nonatomic, retain) NSNumber * alertInterval;
@property (nonatomic, retain) NSNumber * alertType;
@property (nonatomic, retain) NSString * calendarID;
@property (nonatomic, retain) NSNumber * durationOption;
@property (nonatomic, retain) NSDate * effectiveStartDate;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSNumber * hasReminder;
@property (nonatomic, retain) NSNumber * isAllDay;
@property (nonatomic, retain) NSNumber * isLunar;
@property (nonatomic, retain) NSNumber * isPeriod;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * repeatEndDate;
@property (nonatomic, retain) NSNumber * repeatType;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * photoID;

@end
