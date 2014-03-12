//
//  UIImage+Extension.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 1/25/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JHExtension)

+(UIImage *) getImageWithUnsaturatedPixelsOfImage:(UIImage *)image;
+(UIImage *) getImageWithTintedColor:(UIImage *)image withTint:(UIColor *)color withIntensity:(float)alpha;
//+(UIImage *) getImageToGreyImage:(UIImage *)image;
+ (UIImage *) getImageToGreyImage:(UIImage *)image grayColor:(UIColor *)color;

+ (UIImage*)setBackgroundImageByColor:(UIColor *)backgroundColor withFrame:(CGRect )rect;
+ (UIImage*) replaceColor:(UIColor*)color inImage:(UIImage*)image withTolerance:(float)tolerance;
+(UIImage *)changeWhiteColorTransparent: (UIImage *)image;
+(UIImage *)changeColorTo:(NSMutableArray*) array Transparent: (UIImage *)image;
//resizing Stuff...
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
