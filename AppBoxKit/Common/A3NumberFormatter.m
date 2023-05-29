//
//  A3NumberFormatter.m
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 10/6/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3NumberFormatter.h"
#import "common.h"
#import "A3UIDevice.h"

@implementation A3NumberFormatter

- (void)setCurrencyCode:(NSString *)currencyCode {
    if ([currencyCode isEqualToString:@"BTC"]) {
        [super setCurrencyCode:@"USD"];
        if SYSTEM_VERSION_LESS_THAN(@"10") {
            [self setCurrencySymbol:@""];
        } else {
            [self setCurrencySymbol:@"₿"];
        }
        [self setMinimumFractionDigits:4];
    } else {
        [super setCurrencyCode:currencyCode];
    }
}

@end
