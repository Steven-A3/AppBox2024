//
//  UnitType.h
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UnitType : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * unitTypeName;
@property (nonatomic, retain) NSDate * updateDate;

@end
