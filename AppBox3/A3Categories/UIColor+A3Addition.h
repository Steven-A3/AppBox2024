//
//  UIColor+A3Addition.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (A3Addition)

+ (UIColor*)colorWithRGBRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (UIColor*)colorWithRGBHexColor:(NSUInteger)color;
+ (UIColor*)colorWithARGBHexColor:(NSUInteger)color;

@end
