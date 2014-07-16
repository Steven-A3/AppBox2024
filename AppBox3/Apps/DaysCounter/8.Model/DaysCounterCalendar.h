//
//  DaysCounterCalendar.h
//  AppBox3
//
//  Created by A3 on 7/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DaysCounterCalendar : NSManagedObject

@property (nonatomic, retain) NSData * calendarColor;
@property (nonatomic, retain) NSString * calendarColorID;
@property (nonatomic, retain) NSString * calendarName;
@property (nonatomic, retain) NSNumber * calendarType;
@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSNumber * isShow;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;

@end
