//
//  A3SalesCalcData.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SCValueType) {
    SCValueType_PERCENT = 0,
    SCValueType_AMOUNT
};

typedef NS_ENUM(NSUInteger, A3SalesCalcShowPriceType) {
	ShowPriceType_Origin = 0,
	ShowPriceType_Sale
};


@class SalesCalcHistory;
@class A3SalesCalcPreferences;
@interface A3SalesCalcData : NSObject <NSCoding>

@property (nonatomic, strong) NSDate *historyDate;
@property (assign) A3SalesCalcShowPriceType shownPriceType;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, assign) SCValueType priceType; // must be AMOUNT
@property (nonatomic, strong) NSNumber *discount;
@property (nonatomic, assign) SCValueType discountType;
@property (nonatomic, strong) NSNumber *additionalOff;
@property (nonatomic, assign) SCValueType additionalOffType;
@property (nonatomic, strong) NSNumber *tax;
@property (nonatomic, assign) SCValueType taxType;
@property (nonatomic, strong) NSString *notes;

-(BOOL)saveData;
-(BOOL)saveDataForcingly;
+(A3SalesCalcData *)loadDataFromHistory:(SalesCalcHistory *)history;

@end
