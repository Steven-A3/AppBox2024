//
//  DaysCounterLunarDate.h
//  AppBox3
//
//  Created by dotnetguy83 on 5/1/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DaysCounterEvent;

@interface DaysCounterLunarDate : NSManagedObject

@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * isLeapMonth;
@property (nonatomic, retain) DaysCounterEvent *event;

@end
