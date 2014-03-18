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

+ (UIColor*)colorWithRGBHexColor:(NSUInteger)color
{
    CGFloat red = (CGFloat)(color & 0x00FF0000);
    CGFloat green = (CGFloat)(color & 0x0000FF00);
    CGFloat blue = (CGFloat)(color & 0x000000FF);
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

+ (UIColor*)colorWithARGBHexColor:(NSUInteger)color
{
    CGFloat alpha = (CGFloat)(color & 0xFF000000);
    CGFloat red = (CGFloat)(color & 0x00FF0000);
    CGFloat green = (CGFloat)(color & 0x0000FF00);
    CGFloat blue = (CGFloat)(color & 0x000000FF);
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

@end
