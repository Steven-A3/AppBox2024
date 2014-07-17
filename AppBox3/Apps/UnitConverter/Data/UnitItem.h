//
//  UnitItem.h
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UnitItem : NSManagedObject

@property (nonatomic, retain) NSNumber * conversionRate;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * unitName;
@property (nonatomic, retain) NSString * unitShortName;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * typeID;

@end
