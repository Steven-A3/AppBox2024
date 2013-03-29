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

+ (void)drawLinearGradientToContext:(CGContextRef)context rect:(CGRect)rect withColors:(NSArray *)colors;

+ (void)drawBookendEffectRect:(CGRect)rect context:(CGContextRef)context;


+ (UIImage *)backspaceImage;
+ (UIColor *)colorForDashLineColor;
+ (UIColor *)gradientColorRect:(CGRect)rect withColors:(NSArray *)gradientColors;
+ (void)setBackgroundImageForNavigationBar:(UINavigationBar *)navigationBar;
+ (CAGradientLayer *)addTopGradientLayerToView:(UIView *)view;
+ (NSString *)mediumStyleDateString:(NSDate *)date;
+ (NSNumberFormatter *)currencyNumberFormatter;
+ (NSNumberFormatter *)percentNumberFormatter;
+ (void)setUserDefaults:(id)object forKey:(NSString *)key;

@end
