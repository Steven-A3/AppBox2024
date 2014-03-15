//
//  UIImage+extension.h
//  AppBox3
//
//  Created by A3 on 11/27/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (imageWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
@end
