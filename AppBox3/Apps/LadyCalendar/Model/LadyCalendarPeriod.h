//
//  LadyCalendarPeriod.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LadyCalendarAccount;

@interface LadyCalendarPeriod : NSManagedObject{
    BOOL _isPredict;
}

@property (nonatomic, retain) NSString * periodID;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * cycleLength;
//@property (nonatomic, retain) NSDate * ovulation;
@property (nonatomic, retain) NSString * periodNotes;
@property (nonatomic, retain) NSDate * regDate;
@property (nonatomic, retain) NSNumber * isPredict;
@property (nonatomic, retain) NSString * calendarID;
@property (nonatomic, retain) NSNumber * isAutoSave;
@property (nonatomic, retain) NSString * accountID;
@property (nonatomic, retain) LadyCalendarAccount *account;

@end
