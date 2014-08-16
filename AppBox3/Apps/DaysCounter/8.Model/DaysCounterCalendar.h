//
//  DaysCounterCalendar.h
//  AppBox3
//
//  Created by A3 on 8/16/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DaysCounterCalendar : NSManagedObject

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * colorID;
@property (nonatomic, retain) NSNumber * isShow;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * order;

@end
