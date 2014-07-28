//
//  UnitHistoryItem.h
//  AppBox3
//
//  Created by A3 on 7/28/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UnitHistoryItem : NSManagedObject

@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSNumber * targetUnitItemID;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * unitHistoryID;
@property (nonatomic, retain) NSDate * updateDate;

@end
