//
//  A3UIKit.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/29/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <mm_malloc.h>
#import "A3UIKit.h"
#import "A3Utilities.h"

@implementation A3UIKit

+(void)drawHorizontalGradientToRect:(CGRect)rect withColors:(NSArray *)colors withContext:(CGContextRef)context {
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

@end
