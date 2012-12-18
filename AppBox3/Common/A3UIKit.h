//
//  A3UIKit.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/29/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A3UIKit : NSObject

+ (void)drawLinearGradientToContext:(CGContextRef)context rect:(CGRect)rect withColors:(NSArray *)colors;

+ (void)drawBookendEffectRect:(CGRect)rect context:(CGContextRef)context;


+(UIColor *)colorForDashLineColor;

+ (UIColor *)gradientColorRect:(CGRect)rect withColors:(NSArray *)gradientColors;

@end
