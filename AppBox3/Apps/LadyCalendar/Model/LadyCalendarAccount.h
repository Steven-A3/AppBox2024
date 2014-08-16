//
//  LadyCalendarAccount.h
//  AppBox3
//
//  Created by A3 on 8/16/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LadyCalendarAccount : NSManagedObject

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * watchingDate;

@end
