//
//  Unitself+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UnitPriceInfo+extension.h"
#import "UnitItem.h"

@implementation UnitPriceInfo (extension)

- (UnitItem *)unit {
	return [UnitItem MR_findFirstByAttribute:@"uniqueID" withValue:self.unitID];
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

		UnitItem *price1Unit = [price1 unit];
		UnitItem *price2Unit = [self unit];
		if (price1.unit && self.unit) {
			price1CnvRate = price1Unit.conversionRate.floatValue;
			price2CnvRate = price2Unit.conversionRate.floatValue;
		}
		else if (price1.unit && !self.unit) {
			price1CnvRate = price1Unit.conversionRate.floatValue;
			price2CnvRate = price1Unit.conversionRate.floatValue;
		}
		else if (!price1.unit && self.unit) {
			price1CnvRate = price2Unit.conversionRate.floatValue;
			price2CnvRate = price2Unit.conversionRate.floatValue;
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

- (NSString *)unitPriceStringWithFormatter:(NSNumberFormatter *)currencyFormatter {
	NSString *unitShortName;
	UnitItem *unitItem = [self unit];
	unitShortName = self.unit ? NSLocalizedStringFromTable(unitItem.unitName, @"unitShort", nil) : NSLocalizedString(@"None", @"None");
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
			if (IS_IPAD && unitItem) {
				unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
			}
			else {
				unitPriceTxt = [currencyFormatter stringFromNumber:@(unitPrice)];
			}
		}
		else if (unitPrice == 0) {
			if (IS_IPAD && unitItem) {
				unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
			}
			else {
				unitPriceTxt = [currencyFormatter stringFromNumber:@(unitPrice)];
			}

		}
		else {
			if (IS_IPAD && unitItem) {
				unitPriceTxt = [NSString stringWithFormat:@"-%@/%@", [currencyFormatter stringFromNumber:@(unitPrice*-1)], unitShortName];
			}
			else {
				unitPriceTxt = [NSString stringWithFormat:@"-%@", [currencyFormatter stringFromNumber:@(unitPrice*-1)]];
			}
		}
	}
	return unitPriceTxt;
}

- (NSString *)unitPrice2StringWithPrice1:(UnitPriceInfo *)price1 formatter:(NSNumberFormatter *)currencyFormatter {
	NSString *unitPriceTxt = @"";
	NSString *price1UnitShortName, *unitShortName;
	price1UnitShortName = price1.unit ? NSLocalizedStringFromTable(price1.unit.unitName, @"unitShort", nil) : NSLocalizedString(@"None", @"None");
	unitShortName = self.unit ? NSLocalizedStringFromTable(self.unit.unitName, @"unitShort", nil) : NSLocalizedString(@"None", @"None");

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

		UnitItem *price1Unit = [price1 unit];
		UnitItem *price2Unit = [self unit];
		if (price1Unit && price2Unit) {
			price1CnvRate = price1Unit.conversionRate.floatValue;
			price2CnvRate = price2Unit.conversionRate.floatValue;
		}
		else if (price1Unit && !price2Unit) {
			price1CnvRate = price1Unit.conversionRate.floatValue;
			price2CnvRate = price1Unit.conversionRate.floatValue;
		}
		else if (!price1Unit && price2Unit) {
			price1CnvRate = price2Unit.conversionRate.floatValue;
			price2CnvRate = price2Unit.conversionRate.floatValue;
		}
		else {
			price1CnvRate = 1;
			price2CnvRate = 1;
		}

		double rate = price2CnvRate / price1CnvRate;

		double unitPrice = (priceValue - discountValue) / (sizeValue * quantityValue * rate);

		if (unitPrice > 0) {
			if (IS_IPAD && price2Unit) {

				if (![price1Unit.uniqueID isEqualToString:price2Unit.uniqueID]) {

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
			if (IS_IPAD && price2Unit) {
				unitPriceTxt = [NSString stringWithFormat:@"%@/%@", [currencyFormatter stringFromNumber:@(unitPrice)], unitShortName];
			}
			else {
				unitPriceTxt = [currencyFormatter stringFromNumber:@(unitPrice)];
			}

		}
		else {
			if (IS_IPAD && price2Unit) {
				unitPriceTxt = [NSString stringWithFormat:@"-%@/%@", [currencyFormatter stringFromNumber:@(unitPrice*-1)], unitShortName];
			}
			else {
				unitPriceTxt = [NSString stringWithFormat:@"-%@", [currencyFormatter stringFromNumber:@(unitPrice*-1)]];
			}
		}
	}
	return unitPriceTxt;
}

@end
