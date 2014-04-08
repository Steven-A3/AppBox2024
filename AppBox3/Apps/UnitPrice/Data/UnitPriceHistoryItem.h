//
//  UnitPriceHistoryItem.h
//  AppBox3
//
//  Created by A3 on 4/8/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UnitItem, UnitPriceHistory;

@interface UnitPriceHistoryItem : NSManagedObject

@property (nonatomic, retain) NSNumber * discountPercent;
@property (nonatomic, retain) NSNumber * discountPrice;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * orderInComparison;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) UnitItem *unit;
@property (nonatomic, retain) UnitPriceHistory *unitPriceHistory;

@end
