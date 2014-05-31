//
//  DaysCounterDate.h
//  AppBox3
//
//  Created by A3 on 5/30/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DaysCounterEvent;

@interface DaysCounterDate : NSManagedObject

@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * hour;
@property (nonatomic, retain) NSNumber * isLeapMonth;
@property (nonatomic, retain) NSNumber * minute;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSDate * solarDate;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) DaysCounterEvent *endDate;
@property (nonatomic, retain) DaysCounterEvent *startDate;

@end
