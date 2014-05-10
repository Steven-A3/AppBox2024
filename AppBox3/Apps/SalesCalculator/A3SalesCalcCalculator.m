//
//  A3SalesCalcCalculator.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 19..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcCalculator.h"
#import "A3SalesCalcData.h"
#import "A3TableViewInputElement.h"

@implementation A3SalesCalcCalculator

+(NSDictionary *)resultInfoForSalesCalcData:(A3SalesCalcData *)aData {
    
    NSDictionary *result;

    if (aData.shownPriceType == ShowPriceType_Origin) {
        result = [A3SalesCalcCalculator salesCalcDataForOriginalPrice:aData];

    } else {    // ShowPriceType_SalePriceWithTax
        result = [A3SalesCalcCalculator salesCalcDataForSalePrice:aData];
    }

    NSLog(@"result : %@", result);
    return result;
}

+(NSDictionary *)salesCalcDataForOriginalPrice:(A3SalesCalcData *)aData
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    double discountedPrice = 0.0;
    double taxedOriginalPrice;
    double originalPrice;
    
    originalPrice = aData.price.doubleValue;
//    double tax = 100.0 * aData.tax.doubleValue;
//    
//    if (tax!=0.0) {
//        taxedOriginalPrice = originalPrice + (originalPrice / 100.0 * aData.tax.doubleValue);
//    } else {
//        taxedOriginalPrice = originalPrice;
//    }
	taxedOriginalPrice = originalPrice;
    

    // 할인
    if (aData.discountType == A3TableViewValueTypePercent) {
        
        double discount = 100.0 * aData.discount.doubleValue;
        
        if (discount!=0.0) {
            discountedPrice = taxedOriginalPrice - (taxedOriginalPrice / 100.0 * aData.discount.doubleValue);
        } else {
            discountedPrice = taxedOriginalPrice;
        }
        
    } else if (aData.discountType == A3TableViewValueTypeCurrency) {
        discountedPrice = taxedOriginalPrice - aData.discount.doubleValue;
    }
    
    
    // 추가 할인
    if (aData.additionalOff && [aData.additionalOff isEqualToNumber:@0]==NO) {
        
        if (aData.additionalOffType == A3TableViewValueTypePercent) {
            double additionalOff = 100.0 * aData.additionalOff.doubleValue;
            if (additionalOff!=0.0) {
                discountedPrice = discountedPrice - (discountedPrice / 100.0 * aData.additionalOff.doubleValue);
            } else {
                discountedPrice = discountedPrice;
            }
            
        } else if (aData.additionalOffType == A3TableViewValueTypeCurrency) {
            discountedPrice = discountedPrice - aData.additionalOff.doubleValue;
        }
    }
    
    [result setObject:@(discountedPrice) forKey:@"Sale Price"];
    [result setObject:@(originalPrice) forKey:@"Original Price"];
    [result setObject:@(taxedOriginalPrice - discountedPrice) forKey:@"Saved Amount"];
    [result setObject:@(aData.shownPriceType) forKey:@"Shown Price Type"];
    
    if (aData.tax && ![aData.tax isEqualToNumber:@0]) {
        [result setObject:@(taxedOriginalPrice)  forKey:@"Taxed Original Price"];
        double salePriceTax = discountedPrice / 100.0 * aData.tax.doubleValue;
        double originalPriceTax = originalPrice / 100.0 * aData.tax.doubleValue;
        [result setObject:@(salePriceTax) forKey:@"Sale Price Tax"];
        [result setObject:@(originalPriceTax) forKey:@"Original Price Tax"];
        [result setObject:@(originalPriceTax - salePriceTax) forKey:@"Saved Amount Tax"];
        //[result setObject:@((aData.originalPrice.doubleValue - discountedPrice) / 100.0 * aData.tax.doubleValue) forKey:@"Saved Amount Tax"];
    }
    
    NSLog(@"result : %@", result);
    
    return result;
}

+(NSDictionary *)salesCalcDataForSalePrice:(A3SalesCalcData *)aData
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    double discountedPrice = 0.0;
    double taxedOriginalPrice;
    double originalPrice;

    // Original Price 계산.
    if (aData.additionalOffType == A3TableViewValueTypePercent) {
        
        // 추가 할인 전 Original Price.
        double addionalOff = 100.0 - aData.additionalOff.doubleValue;
        if (addionalOff != 0) {
            originalPrice = (aData.price.doubleValue * 100.0) / (100.0 - aData.additionalOff.doubleValue);
        } else {
            originalPrice = aData.price.doubleValue;
        }
        
    } else {
        originalPrice = aData.price.doubleValue + aData.additionalOff.doubleValue;
    }

    if (aData.discountType == A3TableViewValueTypePercent) {
        
        // 할인 전 Original 가격.
        double discount = 100.0 - aData.discount.doubleValue;
        if (discount!=0.0) {
            originalPrice = (originalPrice * 100.0) / (100.0 - aData.discount.doubleValue);
        } else {
            originalPrice = originalPrice;
        }
        
        // 세금 적용된 Origial 가격.
        taxedOriginalPrice = originalPrice;
        
    } else {
        originalPrice = originalPrice + aData.discount.doubleValue;
        taxedOriginalPrice = originalPrice;
    }
    
    
    
    // 할인
    if (aData.discountType == A3TableViewValueTypePercent) {
        
        // 세금 포함 가격, 할인.
        double discount = 100.0 * aData.discount.doubleValue;
        if (discount!=0.0) {
            discountedPrice = taxedOriginalPrice - (taxedOriginalPrice / 100.0 * aData.discount.doubleValue);
            
        } else {
            discountedPrice = taxedOriginalPrice;

        }
        
    } else if (aData.discountType == A3TableViewValueTypeCurrency) {
        discountedPrice = taxedOriginalPrice - aData.discount.doubleValue;

    }
    
    
    // 추가 할인
    if (aData.additionalOff && [aData.additionalOff isEqualToNumber:@0]==NO) {
        
        if (aData.additionalOffType == A3TableViewValueTypePercent) {

            double additionalOff = 100.0 * aData.additionalOff.doubleValue;
            if (additionalOff!=0.0) {
                discountedPrice = discountedPrice - (discountedPrice / 100.0 * aData.additionalOff.doubleValue);
            } else {
                discountedPrice = discountedPrice;
            }
        } else if (aData.additionalOffType == A3TableViewValueTypeCurrency) {
            discountedPrice = discountedPrice - aData.additionalOff.doubleValue;
        }
    }

    originalPrice = originalPrice * (100 / (100 + aData.tax.floatValue));   // 세금을 제외한 OriginalPrice
    
    [result setObject:aData.price forKey:@"Sale Price"];                // 사용자로부터 입력받은 값이 이미 Sale 적용된 가격을 그대로 반영.
    [result setObject:@(originalPrice) forKey:@"Original Price"];
    [result setObject:@(taxedOriginalPrice - discountedPrice) forKey:@"Saved Amount"];
    [result setObject:@(aData.shownPriceType) forKey:@"Shown Price Type"];
    
    if (aData.tax && [aData.tax isEqualToNumber:@0]==NO) {
        [result setObject:@(taxedOriginalPrice)  forKey:@"Taxed Original Price"];
        double salePriceTax = aData.price.doubleValue / 100.0 * aData.tax.doubleValue;
        double originalPriceTax = originalPrice / 100.0 * aData.tax.doubleValue;
        [result setObject:@(salePriceTax) forKey:@"Sale Price Tax"];
        [result setObject:@(originalPriceTax) forKey:@"Original Price Tax"];
        [result setObject:@(originalPriceTax - salePriceTax) forKey:@"Saved Amount Tax"];
        //[result setObject:@((aData.originalPrice.doubleValue - discountedPrice) / 100.0 * aData.tax.doubleValue) forKey:@"Saved Amount Tax"];
    }
    
    NSLog(@"result : %@", result);
    
    return result;
}

#pragma mark -
+ (NSNumber *)originalPriceBeforeTaxAndDiscountForCalcData:(A3SalesCalcData *)aData {
    
    NSNumber *result;
    
    if (aData.shownPriceType == ShowPriceType_Origin) {
        result = aData.price;
    }
    else {
        NSNumber *salePrice = [self salePriceWithoutTaxForCalcData:aData];
        
        double preAdditionalOff;
        double preDiscount;

        // 추가할인 전.
        if (aData.additionalOff && ![aData.additionalOff isEqualToNumber:@0]) {
            if (aData.additionalOffType == A3TableViewValueTypeCurrency) {
                preAdditionalOff = [salePrice doubleValue] + [aData.additionalOff doubleValue];
            }
            else {
                preAdditionalOff = [salePrice doubleValue] * (100.0 / (100.0 - [aData.additionalOff doubleValue]));
            }
        }
        else {
            preAdditionalOff = [salePrice doubleValue];
        }
        
        // 할인 전.
        if (aData.discount && ![aData.discount isEqualToNumber:@0]) {
            if (aData.discountType == A3TableViewValueTypeCurrency) {
                preDiscount = preAdditionalOff + [aData.discount doubleValue];
            }
            else {
                if ([aData.discount isEqualToNumber:@100]) {
                    preDiscount = 0.0;
                }
                else {
                    preDiscount = preAdditionalOff * (100.0 / (100.0 - [aData.discount doubleValue]));
                }
            }
        }
        else {
            preDiscount = preAdditionalOff;
        }
        
        result = @(preDiscount);
    }


    return result;
}

+ (NSNumber *)originalPriceTaxForCalcData:(A3SalesCalcData *)aData {
    NSNumber *result;
    
    if (aData.shownPriceType == ShowPriceType_Origin) {
        if (aData.taxType == A3TableViewValueTypeCurrency) {
            result = aData.tax;
        }
        else {
            result = @([aData.price doubleValue] / 100.0 * [aData.tax doubleValue]);
        }
    }
    else if (aData.shownPriceType == ShowPriceType_SalePriceWithTax) {
        if (aData.taxType == A3TableViewValueTypeCurrency) {
            NSNumber *originalPrice = [self originalPriceBeforeTaxAndDiscountForCalcData:aData];
            NSNumber *taxPercent = [self taxPercentForCalcData:aData];
            if ([taxPercent isEqualToNumber:@0]) {
                return @0;
            }
            result = @([originalPrice doubleValue] / 100.0 * [taxPercent doubleValue]);
        }
        else {
            NSNumber *originalPrice = [self originalPriceBeforeTaxAndDiscountForCalcData:aData];
            result = @([originalPrice doubleValue] / 100.0 * [aData.tax doubleValue]);
        }
    }
    
    return result;
}

+ (NSNumber *)originalPriceWithTax:(A3SalesCalcData *)aData {
    NSNumber *result;
    result = @([[self originalPriceBeforeTaxAndDiscountForCalcData:aData] doubleValue] + [[self originalPriceTaxForCalcData:aData] doubleValue]);
    return result;
}

#pragma mark -
+ (NSNumber *)salePriceWithoutTaxForCalcData:(A3SalesCalcData *)aData {
    NSNumber * result;
    
    if (aData.shownPriceType == ShowPriceType_Origin) {
        double discountedPrice;
        double additionalOffPrice;
        
        // 할인.
        if (aData.discount && ![aData.discount isEqualToNumber:@0]) {
            if (aData.discountType == A3TableViewValueTypeCurrency) {
                discountedPrice = [aData.price doubleValue] - [aData.discount doubleValue];
            }
            else {
                discountedPrice = [aData.price doubleValue] - ([aData.price doubleValue] * [aData.discount doubleValue] / 100.0);
            }
        }
        else {
            discountedPrice = [[aData price] doubleValue];
        }
        
        // 추가할인.
        if (aData.additionalOff && ![aData.additionalOff isEqualToNumber:@0]) {
            if (aData.additionalOffType == A3TableViewValueTypeCurrency) {
                additionalOffPrice = discountedPrice - [aData.additionalOff doubleValue];
            }
            else {
                additionalOffPrice = discountedPrice - (discountedPrice * [aData.additionalOff doubleValue] / 100.0);
            }
            
            result = @(additionalOffPrice);
        }
        else {
            result = @(discountedPrice);
        }
    }
    else if (aData.shownPriceType == ShowPriceType_SalePriceWithTax) {
        // 세금제거.
        if (aData.tax && ![aData.tax isEqualToNumber:@0]) {
            double preTaxPrice;
            if (aData.taxType == A3TableViewValueTypeCurrency) {
                preTaxPrice = [aData.price doubleValue] - [aData.tax doubleValue];
            }
            else {
                preTaxPrice = [aData.price doubleValue] * (100 / (100 + [aData.tax doubleValue]));
            }
            
            result = @(preTaxPrice);
        }
        else {
            result = aData.price;
        }
    }
    
    
    if (!result) {
        result = @0;
    }
    
    return result;
}

+ (NSNumber *)salePriceTaxForCalcData:(A3SalesCalcData *)aData {
    NSNumber * result;

    if (aData.taxType == A3TableViewValueTypeCurrency) {
        NSNumber *salePrice = [self salePriceWithoutTaxForCalcData:aData];
        NSNumber *taxPercent = @([aData.tax doubleValue] / [salePrice doubleValue] * 100.0);
        result = @([salePrice doubleValue] / 100.0 * [taxPercent doubleValue]);
    }
    else {
        NSNumber *salePriceBeforeTax = [self salePriceWithoutTaxForCalcData:aData];
        result = @([salePriceBeforeTax doubleValue] * [aData.tax doubleValue] / 100.0);
    }

    return result;
}
#pragma mark -
+ (NSNumber *)discountPercentForCalcData:(A3SalesCalcData *)aData {
    NSNumber * result;

    if (aData.discountType == A3TableViewValueTypeCurrency) {
        NSNumber * originalPrice = [self originalPriceBeforeTaxAndDiscountForCalcData:aData];
        result = @([aData.discount doubleValue] / [originalPrice doubleValue] * 100.0);
    }
    else {
        result = aData.discount;
    }

    return result;
}

+ (NSNumber *)additionalOffPercentForCalcData:(A3SalesCalcData *)aData {
    NSNumber * result;

    if (aData.additionalOffType == A3TableViewValueTypeCurrency) {
        NSNumber * originalPrice = [self originalPriceBeforeTaxAndDiscountForCalcData:aData];
        double discountedPrice;
        if (aData.discountType == A3TableViewValueTypeCurrency) {
            discountedPrice = [originalPrice doubleValue] - [aData.discount doubleValue];
        }
        else {
            discountedPrice = [originalPrice doubleValue] - ([originalPrice doubleValue] / 100.0 * [aData.discount doubleValue]);
        }
        
        result = @([aData.additionalOff doubleValue] / discountedPrice * 100.0);
    }
    else {
        result = aData.additionalOff;
    }

    return result;
}

+ (NSNumber *)taxPercentForCalcData:(A3SalesCalcData *)aData {
    NSNumber * result;
    
    if (aData.shownPriceType == ShowPriceType_Origin) {
        if (aData.taxType == A3TableViewValueTypeCurrency) {
            result = @([aData.tax doubleValue] / [aData.price doubleValue] * 100.0);
        }
        else {
            result = aData.tax;
        }
    }
    else if (aData.shownPriceType == ShowPriceType_SalePriceWithTax) {
        if (aData.taxType == A3TableViewValueTypeCurrency) {
            NSNumber *salePriceBeforeTax = [self salePriceWithoutTaxForCalcData:aData];
            if ([salePriceBeforeTax isEqualToNumber:@0]) {
                return @0;
            }
            result = @([aData.tax doubleValue] / [salePriceBeforeTax doubleValue] * 100.0);
        }
        else {
            result = aData.tax;
        }
    }
    
    return result;
}
#pragma mark -
+ (NSNumber *)savedAmountForCalcData:(A3SalesCalcData *)aData {
    NSNumber * result;
    NSNumber * originalPrice = [self originalPriceBeforeTaxAndDiscountForCalcData:aData];
    NSNumber * salePrice = [self salePriceWithoutTaxForCalcData:aData];
    result = @([originalPrice doubleValue] - [salePrice doubleValue]);

    return result;
}

+ (NSNumber *)savedAmountTaxForCalcData:(A3SalesCalcData *)aData {
    NSNumber * result;
    NSNumber * originalPriceTax = [self originalPriceTaxForCalcData:aData];
    NSNumber * salePriceTax = [self salePriceTaxForCalcData:aData];
    result = @([originalPriceTax doubleValue] - [salePriceTax doubleValue]);
    
    return result;
}

+ (NSNumber *)savedTotalAmountForCalcData:(A3SalesCalcData *)aData {
    NSNumber * result;
    result = @([[self savedAmountForCalcData:aData] doubleValue] + [[self savedAmountTaxForCalcData:aData] doubleValue]);
    return result;
}

@end
