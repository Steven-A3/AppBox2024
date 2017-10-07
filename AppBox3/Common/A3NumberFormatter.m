//
//  A3NumberFormatter.m
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 10/6/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3NumberFormatter.h"

@implementation A3NumberFormatter

- (void)setCurrencyCode:(NSString *)currencyCode {
    if ([currencyCode isEqualToString:@"BTC"]) {
        [super setCurrencyCode:@"USD"];
        [self setCurrencySymbol:@"₿"];
        [self setMinimumFractionDigits:4];
    } else {
        [super setCurrencyCode:currencyCode];
    }
}

@end
