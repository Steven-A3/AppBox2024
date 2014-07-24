//
//  UnitPriceHistoryItem+extension.h
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UnitPriceHistoryItem.h"

@class UnitItem;

@interface UnitPriceHistoryItem (extension)

- (UnitItem *)unit;

- (double)unitPrice;

- (double)unitPrice2WithPrice1:(UnitPriceHistoryItem *)price1;

- (NSString *)unitPriceStringWithFormatter:(NSNumberFormatter *)currencyFormatter;

- (NSString *)unitPrice2StringWithPrice1:(UnitPriceHistoryItem *)price1 formatter:(NSNumberFormatter *)currencyFormatter;
@end
