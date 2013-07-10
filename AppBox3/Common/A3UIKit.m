//
//  A3UIKit.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/29/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <mm_malloc.h>
#import <QuartzCore/QuartzCore.h>
#import "A3UIKit.h"
#import "A3Utilities.h"
#import "common.h"

@implementation A3UIKit

+ (UIImage *)dashImage {
	CGSize dashImageSize = CGSizeMake(5.0f, 5.0f);
	UIGraphicsBeginImageContextWithOptions(dashImageSize, NO, 2.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetAllowsAntialiasing(context, false);

	UIColor *greyColor = [UIColor colorWithRed:217.0f/255.0f green:217.0f/255.0f blue:217.0f/255.0f alpha:1.0f];
	CGContextSetStrokeColorWithColor(context, greyColor.CGColor);
	CGContextSetFillColorWithColor(context, greyColor.CGColor);

	CGContextAddRect(context, CGRectMake(0.0f, 0.0f, 2.0f, 2.0f));
	CGContextAddRect(context, CGRectMake(2.0f, 2.0f, 3.0f, 3.0f));
	CGContextStrokePath(context);
	CGContextFillPath(context);

	UIImage *dashImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return dashImage;
}

+ (UIImage *)backspaceImage {
	CGSize imageSize = CGSizeMake(80.0, 18.0);
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, 2.0);

	CGSize shapeSize = CGSizeMake(27.0, 18.0);

	UIBezierPath *backspaceShape = [UIBezierPath bezierPath];
	CGFloat minX = imageSize.width - shapeSize.width;
	[backspaceShape moveToPoint:CGPointMake(minX, imageSize.height / 2.0 - 1.0)];
	[backspaceShape addLineToPoint:CGPointMake(minX + 9.0, 0.0)];
	CGFloat radius = 3.0;
	CGFloat centerX = imageSize.width - radius - 1.0;
	[backspaceShape addLineToPoint:CGPointMake(centerX, 0.0)];
	[backspaceShape addArcWithCenter:CGPointMake(centerX, radius) radius:radius startAngle:DegreesToRadians(270.0) endAngle:DegreesToRadians(0.0) clockwise:YES];
	[backspaceShape addLineToPoint:CGPointMake(imageSize.width - 1.0, imageSize.height - radius - 1.0)];
	[backspaceShape addArcWithCenter:CGPointMake(centerX, imageSize.height - radius - 1.0) radius:radius startAngle:DegreesToRadians(0.0) endAngle:DegreesToRadians(90.0) clockwise:YES];
	[backspaceShape addLineToPoint:CGPointMake(minX + 9.0, 17.0)];
	[backspaceShape closePath];

	UIColor *fillColor = [UIColor colorWithRed:61.0/255.0 green:61.0/255.0 blue:61.0/255.0 alpha:1.0];
	[fillColor setFill];
	[fillColor setStroke];
	[backspaceShape fill];
	[backspaceShape stroke];

	UIColor *textColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
	[textColor setFill];
	[textColor setStroke];
    CGRect drawingRect = CGRectMake(minX + 9.0 + 2.0, -5.0, 14.0, 19.0);
    [@"x" drawInRect:drawingRect withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19.0]}];

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}


+ (UIImage *)backspaceImage2 {
	CGSize imageSize = CGSizeMake(27.0, 18.0);
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, 2.0);

	UIBezierPath *backspaceShape = [UIBezierPath bezierPath];
	CGFloat minX = 0.0;
	[backspaceShape moveToPoint:CGPointMake(minX, imageSize.height / 2.0 - 1.0)];
	[backspaceShape addLineToPoint:CGPointMake(minX + 9.0, 0.0)];
	CGFloat radius = 3.0;
	CGFloat centerX = imageSize.width - radius - 1.0;
	[backspaceShape addLineToPoint:CGPointMake(centerX, 0.0)];
	[backspaceShape addArcWithCenter:CGPointMake(centerX, radius) radius:radius startAngle:DegreesToRadians(270.0) endAngle:DegreesToRadians(0.0) clockwise:YES];
	[backspaceShape addLineToPoint:CGPointMake(imageSize.width - 1.0, imageSize.height - radius - 1.0)];
	[backspaceShape addArcWithCenter:CGPointMake(centerX, imageSize.height - radius - 1.0) radius:radius startAngle:DegreesToRadians(0.0) endAngle:DegreesToRadians(90.0) clockwise:YES];
	[backspaceShape addLineToPoint:CGPointMake(minX + 9.0, 17.0)];
	[backspaceShape closePath];

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
//	CGContextSetShadowWithColor(context, CGSizeMake(0.0, -0.5), 1.0, [UIColor colorWithRed:49.0/255.0 green:53.0/255.0 blue:60.0/255.0 alpha:1.0].CGColor);
	UIColor *fillColor = [UIColor whiteColor];
	[fillColor setFill];
	[fillColor setStroke];
	[backspaceShape fill];
	[backspaceShape stroke];

	CGContextRestoreGState(context);

	CGContextSetShadowWithColor(context, CGSizeMake(0.0, 0.5), 0.0, [UIColor colorWithRed:54.0/255.0 green:57.0/255.0 blue:60.0/255.0 alpha:1.0].CGColor);
	UIColor *textColor = [UIColor colorWithRed:95.0/255.0 green:102.0/255.0 blue:115.0/255.0 alpha:1.0];
	[textColor setFill];
	[textColor setStroke];
    CGRect drawingRect = CGRectMake(minX + 9.0 + 2.0, -5.0, 14.0, 19.0);
    [@"x" drawInRect:drawingRect withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19.0]}];

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

+ (UIColor *)colorForDashLineColor {
	return [UIColor colorWithPatternImage:[A3UIKit dashImage]];
}

+ (UIColor *)gradientColorRect:(CGRect)rect withColors:(NSArray *)gradientColors {
	CGSize size = CGSizeMake(rect.size.width, rect.size.height);
	UIGraphicsBeginImageContextWithOptions(size, NO, 2.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect drawingRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
	drawLinearGradient(context, drawingRect, gradientColors);
	UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return [UIColor colorWithPatternImage:gradientImage];
}

+ (NSString *)mediumStyleDateString:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];

	return [dateFormatter stringFromDate:date];
}

+ (NSNumberFormatter *)currencyNumberFormatter {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

	return numberFormatter;
}

+ (NSNumberFormatter *)percentNumberFormatter {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
	[numberFormatter setMaximumFractionDigits:3];
	return numberFormatter;
}

+ (void)setUserDefaults:(id)object forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
