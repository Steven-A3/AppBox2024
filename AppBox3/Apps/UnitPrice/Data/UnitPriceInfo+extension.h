//
//  UnitPriceInfo+extension.h
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UnitPriceInfo.h"

extern NSString *const PRICE_KEY;
extern NSString *const SIZE_KEY;
extern NSString *const QUANTITY_KEY;
extern NSString *const UNIT_KEY;
extern NSString *const UNIT_CATEGORY_KEY;
extern NSString *const DISCOUNT_PERCENT_KEY;
extern NSString *const DISCOUNT_PRICE_KEY;
extern NSString *const NOTES_KEY;

@interface UnitPriceInfo (extension)

- (void)initValues;

- (void)copyValueFrom:(NSDictionary *)store;

- (NSDictionary *)dictionaryRepresentation;

- (double)unitPrice;
- (double)unitPrice2WithPrice1:(UnitPriceInfo *)price1;

- (NSString *)unitPriceStringWithFormatter:(NSNumberFormatter *)currencyFormatter showUnit:(BOOL)showUnit;

- (NSString *)unitPrice2StringWithPrice1:(UnitPriceInfo *)price1 formatter:(NSNumberFormatter *)currencyFormatter showUnit:(BOOL)showUnit;

@end
