//
//  LadyCalendarPeriod.h
//  AppBox3
//
//  Created by kimjeonghwan on 7/9/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LadyCalendarAccount;

@interface LadyCalendarPeriod : NSManagedObject

@property (nonatomic, retain) NSNumber * cycleLength;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * isAutoSave;
@property (nonatomic, retain) NSNumber * isPredict;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * ovulation;
@property (nonatomic, retain) NSDate * periodEnds;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) LadyCalendarAccount *account;

@end
