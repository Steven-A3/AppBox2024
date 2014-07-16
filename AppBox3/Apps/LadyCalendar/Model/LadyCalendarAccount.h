//
//  LadyCalendarAccount.h
//  AppBox3
//
//  Created by A3 on 7/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LadyCalendarAccount : NSManagedObject

@property (nonatomic, retain) NSDate * birthDay;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSDate * watchingDate;

@end
