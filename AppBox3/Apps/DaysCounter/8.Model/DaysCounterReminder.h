//
//  DaysCounterReminder.h
//  AppBox3
//
//  Created by A3 on 7/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DaysCounterEvent;

@interface DaysCounterReminder : NSManagedObject

@property (nonatomic, retain) NSDate * alertDate;
@property (nonatomic, retain) NSNumber * isOn;
@property (nonatomic, retain) NSNumber * isUnread;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) DaysCounterEvent *event;

@end
