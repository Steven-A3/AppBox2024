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

+ (void)drawLinearGradientToContext:(CGContextRef)context rect:(CGRect)rect withColors:(NSArray *) colors {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat locations[] = { 0.0f, 1.0f };

	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);

	CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));

	CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);

	CGGradientRelease(gradient);
}

+ (void)drawHorizontalGradientToRect:(CGRect)rect withColors:(NSArray *)colors withContext:(CGContextRef)context {
	drawLinearGradient(context, rect, colors);

	CGContextSaveGState(context);
	CGContextSetShouldAntialias(context, false);

	// Top horizontal line
	CGContextSetLineWidth(context, 1.0);
	CGContextSetRGBStrokeColor(context, 149.0f/255.0f, 154.0f/255.0f, 149.0f/255.0f, 1.0f);

	// Draw a single line from left to right
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect) + 1.0f);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect) + 1.0f);

	// Bottom horizontal line
	// Draw a single line from left to right
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect) - 4.0f);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - 4.0f);
	CGContextStrokePath(context);

	NSArray *bottomGradient = @[(__bridge id)[[UIColor colorWithRed:215.0f/255.0f green:217.0f/255.0f blue:219.0f/255.0f alpha:1.0f] CGColor],
	(__bridge id)[[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:237.0f/255.0f alpha:1.0f] CGColor]];


	drawLinearGradient(context, CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - 3.0f, CGRectGetWidth(rect), 3.0f), bottomGradient);

	CGContextRestoreGState(context);

}

+ (void)drawHorizontalLineWithColors:(NSArray *)colors rect:(CGRect)rect context:(CGContextRef)context {
	CGFloat coordinate_Y = CGRectGetMinY(rect);
	for (UIColor *color in colors) {
		CGContextSetStrokeColorWithColor(context, [color CGColor]);
		CGContextMoveToPoint(context, CGRectGetMinX(rect), coordinate_Y);
		CGContextAddLineToPoint(context, CGRectGetMaxX(rect), coordinate_Y);
		CGContextStrokePath(context);

		coordinate_Y += 1.0f;
	}
}

+ (void)drawBookendEffectRect:(CGRect)rect context:(CGContextRef)context {
	// Colors for bookend drawing
	NSArray *colorsForHorizontalLine = [NSArray arrayWithObjects:
			[UIColor colorWithRed:181.0f/255.0f green:186.0f/255.0f blue:186.0f/255.0f alpha:1.0f],
			[UIColor colorWithRed:209.0f/255.0f green:209.0f/255.0f blue:209.0f/255.0f alpha:1.0f],
			[UIColor colorWithRed:171.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f],
			[UIColor colorWithRed:189.0f/255.0f green:189.0f/255.0f blue:189.0f/255.0f alpha:1.0f],
			[UIColor colorWithRed:166.0f/255.0f green:166.0f/255.0f blue:167.0f/255.0f alpha:1.0f],
			[UIColor colorWithRed:182.0f/255.0f green:182.0f/255.0f blue:182.0f/255.0f alpha:1.0f],
			[UIColor colorWithRed:137.0f/255.0f green:136.0f/255.0f blue:135.0f/255.0f alpha:1.0f], nil];

	[A3UIKit drawHorizontalLineWithColors:colorsForHorizontalLine rect:rect context:context];

	NSArray *colors = [NSArray arrayWithObjects:
			(__bridge id)[[UIColor colorWithRed:181.0f/255.0f green:183.0f/255.0f blue:183.0f/255.0f alpha:1.0f] CGColor],
			(__bridge id)[[UIColor colorWithRed:181.0f/255.0f green:183.0f/255.0f blue:183.0f/255.0f alpha:0.0f] CGColor], nil];
	CGRect bottomGradientRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + (CGFloat)[colorsForHorizontalLine count] - 1.0f, CGRectGetWidth(rect), (CGFloat)[colorsForHorizontalLine count]);
	drawLinearGradient(context, bottomGradientRect, colors);
}

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
	[@"×" drawAtPoint:CGPointMake(minX + 9.0 + 2.0, -5.0) forWidth:14.0 withFont:[UIFont boldSystemFontOfSize:19.0] lineBreakMode:NSLineBreakByWordWrapping];

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

+ (UIImage *)navigationBarBackgroundImageForBarMetrics:(UIBarMetrics)barMetrics {
	CGRect screenBounds = [UIScreen mainScreen].bounds;
	CGSize imageSize = CGSizeMake(barMetrics == UIBarMetricsDefault ? CGRectGetWidth(screenBounds) : CGRectGetHeight(screenBounds), 44.0f);
	UIGraphicsBeginImageContextWithOptions(imageSize, YES, 2.0f);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rect = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);

	CGContextSetRGBStrokeColor(context, 66.0f/255.0f, 66.0f/255.0f, 67.0f/255.0f, 1.0f);
	CGContextAddRect(context, rect);
	CGContextStrokePath(context);

	CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.8f);
	CGContextAddRect(context, rect);
	CGContextFillPath(context);

	NSArray *colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:48.0f/255.0f green:48.0f/255.0f blue:48.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:24.0f/255.0f green:25.0f/255.0f blue:27.0f/255.0f alpha:0.0f].CGColor,
			nil];
	[A3UIKit drawLinearGradientToContext:context rect:CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), 8.0f) withColors:colors];

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

+ (void)setBackgroundImageForNavigationBar:(UINavigationBar *)navigationBar {
	[navigationBar setBackgroundImage:[A3UIKit navigationBarBackgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
	[navigationBar setBackgroundImage:[A3UIKit navigationBarBackgroundImageForBarMetrics:UIBarMetricsLandscapePhone] forBarMetrics:UIBarMetricsLandscapePhone];
}

+ (void)addTopGradientLayerToView:(UIView *)view {
	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
	gradientLayer.anchorPoint = CGPointMake(0.0, 0.0);
	gradientLayer.position = CGPointMake(0.0, 1.0);
	gradientLayer.startPoint = CGPointMake(0.5, 0.0);
	gradientLayer.endPoint = CGPointMake(0.5, 1.0);
	gradientLayer.bounds = CGRectMake(0.0, 0.0, view.bounds.size.width, 7.0);
	gradientLayer.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor];
	[view.layer addSublayer:gradientLayer];
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
@end
