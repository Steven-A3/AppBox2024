//
//  DaysCounterEventLocation.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 5..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DaysCounterEvent;

@interface DaysCounterEventLocation : NSManagedObject

@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) DaysCounterEvent *event;

@end
