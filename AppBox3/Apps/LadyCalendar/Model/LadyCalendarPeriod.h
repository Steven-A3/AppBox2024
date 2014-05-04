//
//  LadyCalendarPeriod.h
//  AppBox3
//
//  Created by A3 on 5/3/14.
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
@property (nonatomic, retain) NSDate * ovulation;
@property (nonatomic, retain) NSDate * periodEnds;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) LadyCalendarAccount *account;

@end
