//
//  A3UIKit.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/29/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface A3UIKit : NSObject

+ (void)drawBookendEffectRect:(CGRect)rect context:(CGContextRef)context;
+ (UIImage *)backspaceImage;
+ (UIImage *)backspaceImage2;
+ (UIColor *)colorForDashLineColor;
+ (UIColor *)gradientColorRect:(CGRect)rect withColors:(NSArray *)gradientColors;
+ (NSString *)mediumStyleDateString:(NSDate *)date;
+ (NSNumberFormatter *)currencyNumberFormatter;
+ (NSNumberFormatter *)percentNumberFormatter;
+ (void)setUserDefaults:(id)object forKey:(NSString *)key;

@end
