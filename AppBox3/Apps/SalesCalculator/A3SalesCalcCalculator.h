//
//  A3SalesCalcCalculator.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 19..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class A3SalesCalcData;

@interface A3SalesCalcCalculator : NSObject

+ (NSDictionary *)resultInfoForSalesCalcData:(A3SalesCalcData *)aData;
#pragma mark -
+ (NSNumber *)originalPriceBeforeTaxAndDiscountForCalcData:(A3SalesCalcData *)aData;
+ (NSNumber *)originalPriceTaxForCalcData:(A3SalesCalcData *)aData;
+ (NSNumber *)originalPriceWithTax:(A3SalesCalcData *)aData;
#pragma mark -
+ (NSNumber *)salePriceWithoutTaxForCalcData:(A3SalesCalcData *)aData;
+ (NSNumber *)salePriceTaxForCalcData:(A3SalesCalcData *)aData;
#pragma mark -
+ (NSNumber *)discountPercentForCalcData:(A3SalesCalcData *)aData;
+ (NSNumber *)additionalOffPercentForCalcData:(A3SalesCalcData *)aData;
+ (NSNumber *)taxPercentForCalcData:(A3SalesCalcData *)aData;
#pragma mark -
+ (NSNumber *)savedAmountForCalcData:(A3SalesCalcData *)aData;
+ (NSNumber *)savedAmountTaxForCalcData:(A3SalesCalcData *)aData;
+ (NSNumber *)savedTotalAmountForCalcData:(A3SalesCalcData *)aData;

@end
