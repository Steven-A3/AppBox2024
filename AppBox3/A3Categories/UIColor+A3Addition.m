//
//  UIColor+A3Addition.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "UIColor+A3Addition.h"

@implementation UIColor (A3Addition)

+ (UIColor*)colorWithRGBRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {

    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0 green:((rgbValue & 0xFF00) >> 8) / 255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
