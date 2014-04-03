//
//  A3SalesCalcData.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3TableViewInputElement.h"

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
@property (nonatomic, assign) A3TableElementValueType priceType; // must be AMOUNT
@property (nonatomic, strong) NSNumber *discount;
@property (nonatomic, assign) A3TableElementValueType discountType;
@property (nonatomic, strong) NSNumber *additionalOff;
@property (nonatomic, assign) A3TableElementValueType additionalOffType;
@property (nonatomic, strong) NSNumber *tax;
@property (nonatomic, assign) A3TableElementValueType taxType;
@property (nonatomic, strong) NSString *notes;

-(BOOL)saveData;
-(BOOL)saveDataForcingly;
+(A3SalesCalcData *)loadDataFromHistory:(SalesCalcHistory *)history;

@end
