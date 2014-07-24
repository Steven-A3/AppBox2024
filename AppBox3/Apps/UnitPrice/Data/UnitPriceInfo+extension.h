//
//  UnitPriceInfo+extension.h
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UnitPriceInfo.h"

@class UnitItem;

@interface UnitPriceInfo (extension)

- (UnitItem *)unit;

- (double)unitPrice;

- (double)unitPrice2WithPrice1:(UnitPriceInfo *)price1;

- (NSString *)unitPriceStringWithFormatter:(NSNumberFormatter *)currencyFormatter;

- (NSString *)unitPrice2StringWithPrice1:(UnitPriceInfo *)price1 formatter:(NSNumberFormatter *)currencyFormatter;
@end
