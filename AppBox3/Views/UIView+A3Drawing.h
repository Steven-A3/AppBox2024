//
//  UIView(A3Drawing)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/23/13 3:51 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (A3Drawing)


- (void)drawLinearGradientToContext:(CGContextRef)context rect:(CGRect)rect withColors:(NSArray *)colors;

- (void)drawBookendEffectRect:(CGRect)rect context:(CGContextRef)context;
@end