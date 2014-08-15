//
//  Unitself+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UnitPriceInfo+extension.h"
#import "A3UnitDataManager.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"
#import "A3UnitPriceMainTableController.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

NSString *const PRICE_KEY		= @"price";
NSString *const SIZE_KEY		= @"size";
NSString *const QUANTITY_KEY	= @"quantity";
NSString *const UNIT_KEY		= @"unitID";
NSString *const UNIT_CATEGORY_KEY	= @"unitCategoryID";
NSString *const DISCOUNT_PERCENT_KEY = @"discountPercent";
NSString *const DISCOUNT_PRICE_KEY = @"discountPrice";
NSString *const NOTES_KEY		= @"note";

@implementation UnitPriceInfo (extension)

- (void)initValues {
	self.unitCategoryID = @(-1);
	self.unitID = @(-1);
	self.quantity = @0;
	self.size = @0;
	self.price = @0;
	self.note = nil;
	self.discountPercent = @0;
	self.discountPrice = @0;
	self.historyID = nil;
}

- (void)copyValueFrom:(NSDictionary *)store {
	[self initValues];

	for (NSString *key in [store allKeys]) {
		[self setValue:[store objectForKey:key] forKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation {
	NSMutableDictionary *dictionary = [NSMutableDictionary new];
	[dictionary setObject:self.price forKey:PRICE_KEY];
    if (self.size) {
        [dictionary setObject:self.size forKey:SIZE_KEY];
    }
	[dictionary setObject:self.quantity forKey:QUANTITY_KEY];
	[dictionary setObject:self.unitID forKey:UNIT_KEY];
	[dictionary setObject:self.unitCategoryID forKey:UNIT_CATEGORY_KEY];
    if (self.discountPercent) {
        [dictionary setObject:self.discountPercent forKey:DISCOUNT_PERCENT_KEY];
    }
    if (self.discountPrice) {
        [dictionary setObject:self.discountPrice forKey:DISCOUNT_PRICE_KEY];
    }
	if (self.note) [dictionary setObject:self.note forKey:NOTES_KEY];
	return dictionary;
}

- (double)unitPrice {
	double priceValue = self.price.doubleValue;
	NSInteger sizeValue = (self.size.integerValue <= 0) ? 1:self.size.integerValue;
	NSInteger quantityValue = self.quantity.integerValue;

	// 할인값
	double discountValue = 0;
	if (self.discountPrice.doubleValue > 0) {
		discountValue = self.discountPrice.doubleValue;
		discountValue = MIN(discountValue, priceValue);
	}
	else if (self.discountPercent.doubleValue > 0) {
		discountValue = priceValue * self.discountPercent.doubleValue;
	}

	if ((priceValue > 0) && (quantityValue>0)) {
		return (priceValue - discountValue) / (sizeValue * quantityValue);
	}
	return 0.0;
}

- (double)unitPrice2WithPrice1:(UnitPriceInfo *)price1 {
	double priceValue = self.price.floatValue;
	NSInteger sizeValue = (self.size.integerValue <= 0) ? 1:self.size.integerValue;
	NSInteger quantityValue = self.quantity.integerValue;

	// 할인값
	double discountValue = 0;
	if (self.discountPrice.floatValue > 0) {
		discountValue = self.discountPrice.floatValue;
		discountValue = MIN(discountValue, priceValue);
	}
	else if (self.discountPercent.floatValue > 0) {
		discountValue = priceValue * self.discountPercent.floatValue;
	}

	if ((priceValue>0) && (sizeValue>0) && (quantityValue>0)) {

		double price1CnvRate, price2CnvRate;

		if (validUnit(price1.unitID) && validUnit(self.unitID)) {
			price1CnvRate = conversionTable[[price1.unitCategoryID unsignedIntegerValue]][[price1.unitID unsignedIntegerValue]];
			price2CnvRate = conversionTable[[self.unitCategoryID unsignedIntegerValue]][[self.unitID unsignedIntegerValue]];
		}
		else if (validUnit(price1.unitID) && !validUnit(self.unitID)) {
			price1CnvRate = conversionTable[[price1.unitCategoryID unsignedIntegerValue]][[price1.unitID unsignedIntegerValue]];
			price2CnvRate = conversionTable[[price1.unitCategoryID unsignedIntegerValue]][[price1.unitID unsignedIntegerValue]];
		}
		else if (!validUnit(price1.unitID) && validUnit(self.unitID)) {
			price1CnvRate = conversionTable[[self.unitCategoryID unsignedIntegerValue]][[self.unitID unsignedIntegerValue]];
			price2CnvRate = conversionTable[[self.unitCategoryID unsignedIntegerValue]][[self.unitID unsignedIntegerValue]];
		}
		else {
			price1CnvRate = 1;
			price2CnvRate = 1;
		}

		double rate = price2CnvRate / price1CnvRate;

		return (priceValue - discountValue) / (sizeValue * quantityValue * rate);
	}
	return 0.0;
}

- (NSString *)unitPriceStringWithFormatter:(NSNumberFormatter *)currencyFormatter showUnit:(BOOL)showUnit {
	NSString *unitShortName;
	unitShortName = validUnit(self.unitID) ? [self unitShortNameForPriceInfo:self] : NSLocalizedString(@"None", @"None");
	NSString *unitPriceTxt = @"";

	double priceValue = self.price.doubleValue;
	NSInteger sizeValue = (self.size.integerValue <= 0) ? 1:self.size.integerValue;
	NSInteger quantityValue = self.quantity.integerValue;

	// 할인값
	double discountValue = 0;
	if (self.discountPrice.doubleValue > 0) {
		discountValue = self.discountPrice.doubleValue;
		discountValue = MIN(discountValue, priceValue);
	}
	else if (self.discountPercent.doubleValue > 0) {
		discountValue = priceValue * self.discountPercent.doubleValue;
	}

	if ((priceValue>0) && (quantityValue>0)) {
		double unitPrice = (priceValue - discountValue) / (sizeValue * quantityValue);

		if (unitPrice > 0) {
			if (showUnit && validUnit(self.unitID)) {
				unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
			}
			else {
				unitPriceTxt = [currencyFormatter stringFromNumber:@(unitPrice)];
			}
		}
		else if (unitPrice == 0) {
			if (showUnit && validUnit(self.unitID)) {
				unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
			}
			else {
				unitPriceTxt = [currencyFormatter stringFromNumber:@(unitPrice)];
			}

		}
		else {
			if (showUnit && validUnit(self.unitID)) {
				unitPriceTxt = [NSString stringWithFormat:@"-%@/%@", [currencyFormatter stringFromNumber:@(unitPrice*-1)], unitShortName];
			}
			else {
				unitPriceTxt = [NSString stringWithFormat:@"-%@", [currencyFormatter stringFromNumber:@(unitPrice*-1)]];
			}
		}
	}
	return unitPriceTxt;
}

- (NSString *)unitShortNameForPriceInfo:(UnitPriceInfo *)priceInfo {
	if (!validUnit(priceInfo.unitCategoryID) || !validUnit(priceInfo.unitID)) {
		return @"";
	}
	NSUInteger categoryID = [priceInfo.unitCategoryID unsignedIntegerValue];
	NSUInteger unitID = [priceInfo.unitID unsignedIntegerValue];

	return NSLocalizedStringFromTable([NSString stringWithCString:unitNames[categoryID][unitID] encoding:NSUTF8StringEncoding], @"unitShort", nil);
}

- (NSString *)unitPrice2StringWithPrice1:(UnitPriceInfo *)price1 formatter:(NSNumberFormatter *)currencyFormatter showUnit:(BOOL)showUnit {
	NSString *unitPriceTxt = @"";
	NSString *price1UnitShortName, *unitShortName;
	price1UnitShortName = validUnit(price1.unitID) ? [self unitShortNameForPriceInfo:price1] : NSLocalizedString(@"None", @"None");
	unitShortName = validUnit(self.unitID) ? [self unitShortNameForPriceInfo:self] : NSLocalizedString(@"None", @"None");

	double priceValue = self.price.floatValue;
	NSInteger sizeValue = (self.size.integerValue <= 0) ? 1:self.size.integerValue;
	NSInteger quantityValue = self.quantity.integerValue;

	// 할인값
	double discountValue = 0;
	if (self.discountPrice.floatValue > 0) {
		discountValue = self.discountPrice.floatValue;
		discountValue = MIN(discountValue, priceValue);
	}
	else if (self.discountPercent.floatValue > 0) {
		discountValue = priceValue * self.discountPercent.floatValue;
	}

	if ((priceValue>0) && (sizeValue>0) && (quantityValue>0)) {

		double price1CnvRate, price2CnvRate;

		if (validUnit(price1.unitID) && validUnit(self.unitID)) {
			price1CnvRate = conversionTable[[price1.unitCategoryID unsignedIntegerValue]][[price1.unitID unsignedIntegerValue]];
			price2CnvRate = conversionTable[[self.unitCategoryID unsignedIntegerValue]][[self.unitID unsignedIntegerValue]];
		}
		else if (validUnit(price1.unitID) && !validUnit(self.unitID)) {
			price1CnvRate = conversionTable[[price1.unitCategoryID unsignedIntegerValue]][[price1.unitID unsignedIntegerValue]];
			price2CnvRate = conversionTable[[price1.unitCategoryID unsignedIntegerValue]][[price1.unitID unsignedIntegerValue]];
		}
		else if (!validUnit(price1.unitID) && validUnit(self.unitID)) {
			price1CnvRate = conversionTable[[self.unitCategoryID unsignedIntegerValue]][[self.unitID unsignedIntegerValue]];
			price2CnvRate = conversionTable[[self.unitCategoryID unsignedIntegerValue]][[self.unitID unsignedIntegerValue]];
		}
		else {
			price1CnvRate = 1;
			price2CnvRate = 1;
		}

		double rate = price2CnvRate / price1CnvRate;

		double unitPrice = (priceValue - discountValue) / (sizeValue * quantityValue * rate);

		if (unitPrice > 0) {
			if (showUnit && validUnit(self.unitID)) {

				if (![price1UnitShortName isEqualToString:unitShortName]) {

					double normalPrice = (priceValue - discountValue) / (sizeValue * quantityValue);

					if (IS_IPAD) {
						unitPriceTxt = [NSString stringWithFormat:@"%@/%@ (%@/%@)", [currencyFormatter stringFromNumber:@(unitPrice)], price1UnitShortName, [currencyFormatter stringFromNumber:@(normalPrice)], unitShortName];
					}
					else {
						unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [currencyFormatter stringFromNumber:@(unitPrice)], price1UnitShortName];
					}

				}
				else {
					unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
				}

			}
			else {
				unitPriceTxt = [currencyFormatter stringFromNumber:@(unitPrice)];
			}
		}
		else if (unitPrice == 0) {
			if (showUnit && validUnit(self.unitID)) {
				unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
			}
			else {
				unitPriceTxt = [currencyFormatter stringFromNumber:@(unitPrice)];
			}

		}
		else {
			if (showUnit && validUnit(self.unitID)) {
				unitPriceTxt = [NSString stringWithFormat:@"-%@/%@", [currencyFormatter stringFromNumber:@(unitPrice*-1)], unitShortName];
			}
			else {
				unitPriceTxt = [NSString stringWithFormat:@"-%@", [currencyFormatter stringFromNumber:@(unitPrice*-1)]];
			}
		}
	}
	return unitPriceTxt;
}

+ (void)changeDefaultCurrencyCode:(NSString *)currencyCode {
	if ([currencyCode length]) {
		[[A3SyncManager sharedSyncManager] setObject:currencyCode forKey:A3UnitPriceUserDefaultsCurrencyCode state:A3DataObjectStateModified];

		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationUnitPriceCurrencyCodeChanged object:nil];
		});
	}
}

@end
