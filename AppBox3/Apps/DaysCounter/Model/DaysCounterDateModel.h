//
//  DaysCounterDateModel.h
//  AppBox3
//
//  Created by dotnetguy83 on 5/3/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DaysCounterEvent;

@interface DaysCounterDateModel : NSManagedObject

@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * isLeapMonth;
@property (nonatomic, retain) NSNumber * isLunar;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSDate * solarDate;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * hour;
@property (nonatomic, retain) NSNumber * minute;
@property (nonatomic, retain) DaysCounterEvent *endDate;
@property (nonatomic, retain) DaysCounterEvent *startDate;

@end
