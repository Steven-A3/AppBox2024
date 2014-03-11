//
//  UnitItem.h
//  AppBox3
//
//  Created by A3 on 3/11/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UnitConvertItem, UnitFavorite, UnitHistory, UnitHistoryItem, UnitPriceFavorite, UnitPriceHistoryItem, UnitPriceInfo, UnitType;

@interface UnitItem : NSManagedObject

@property (nonatomic, retain) NSNumber * conversionRate;
@property (nonatomic, retain) NSString * unitName;
@property (nonatomic, retain) NSString * unitShortName;
@property (nonatomic, retain) UnitFavorite *favorite;
@property (nonatomic, retain) UnitType *type;
@property (nonatomic, retain) UnitConvertItem *unitConvertItem;
@property (nonatomic, retain) UnitHistory *unitHistory;
@property (nonatomic, retain) UnitHistoryItem *unitHistoryItem;
@property (nonatomic, retain) UnitPriceFavorite *unitPriceFavorite;
@property (nonatomic, retain) NSSet *unitPriceHistories;
@property (nonatomic, retain) NSSet *unitPriceInfos;
@end

@interface UnitItem (CoreDataGeneratedAccessors)

- (void)addUnitPriceHistoriesObject:(UnitPriceHistoryItem *)value;
- (void)removeUnitPriceHistoriesObject:(UnitPriceHistoryItem *)value;
- (void)addUnitPriceHistories:(NSSet *)values;
- (void)removeUnitPriceHistories:(NSSet *)values;

- (void)addUnitPriceInfosObject:(UnitPriceInfo *)value;
- (void)removeUnitPriceInfosObject:(UnitPriceInfo *)value;
- (void)addUnitPriceInfos:(NSSet *)values;
- (void)removeUnitPriceInfos:(NSSet *)values;

@end
