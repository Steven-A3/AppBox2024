//
//  UnitPriceHistory.h
//  AppBox3
//
//  Created by A3 on 6/30/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UnitPriceHistoryItem;

@interface UnitPriceHistory : NSManagedObject

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSSet *unitPrices;
@end

@interface UnitPriceHistory (CoreDataGeneratedAccessors)

- (void)addUnitPricesObject:(UnitPriceHistoryItem *)value;
- (void)removeUnitPricesObject:(UnitPriceHistoryItem *)value;
- (void)addUnitPrices:(NSSet *)values;
- (void)removeUnitPrices:(NSSet *)values;

@end
