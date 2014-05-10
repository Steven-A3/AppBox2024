//
//  A3SalesCalcPreferences.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef NS_ENUM(NSUInteger, A3SalesCalcShowPriceType) {
//	ShowPriceType_Origin = 0,
//	ShowPriceType_SalePriceWithTax
//};

@class A3SalesCalcData;
@interface A3SalesCalcPreferences : NSObject

//@property (nonatomic) A3SalesCalcShowPriceType priceType;
//+ (void)setPriceType:(A3SalesCalcShowPriceType)priceType;
//+ (A3SalesCalcShowPriceType)priceType;

@property (nonatomic, strong) A3SalesCalcData *calcData;
@property (nonatomic, strong) A3SalesCalcData *oldCalcData;
@property (nonatomic) BOOL initializedBySaveData;
-(BOOL)didSaveBefore;
@end
