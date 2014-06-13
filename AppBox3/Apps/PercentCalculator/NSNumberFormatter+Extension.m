//
//  NSNumberFormatter+Extention.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSNumberFormatter+Extension.h"

@implementation NSNumberFormatter (Extension)

+(NSString *)exponentStringFromNumber:(NSNumber *)aNumber {
    NSNumberFormatter * formatter = [NSNumberFormatter new];
    
    if (IS_IPHONE) {
        if (fabs(aNumber.doubleValue)>10e16 || fabs(aNumber.doubleValue)<-10e16) {
            [formatter setNumberStyle:NSNumberFormatterScientificStyle];
            [formatter setMinimumFractionDigits:0];
            [formatter setMaximumFractionDigits:2];
        }
        else {
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [formatter setRoundingMode:NSNumberFormatterRoundDown];
        }
        
    } else {
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setRoundingMode:NSNumberFormatterRoundDown];
    }

    
    return [formatter stringFromNumber:aNumber];
}

+(NSString *)currencyStringExceptedSymbolFromNumber:(NSNumber *)aNumber {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString * inputString = [formatter stringFromNumber:aNumber];
    inputString = [inputString stringByReplacingOccurrencesOfString:[formatter currencySymbol] withString:@""];
    return inputString;
}

@end
