//
//  UIView(A3Drawing)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/23/13 3:51 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "UIView+A3Drawing.h"


@implementation UIView (A3Drawing)

- (void)drawLinearGradientToContext:(CGContextRef)context rect:(CGRect)rect withColors:(NSArray *) colors {
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

- (void)drawHorizontalLineWithColors:(NSArray *)colors rect:(CGRect)rect context:(CGContextRef)context {
	CGFloat coordinate_Y = CGRectGetMinY(rect);
	for (UIColor *color in colors) {
		CGContextSetStrokeColorWithColor(context, [color CGColor]);
		CGContextMoveToPoint(context, CGRectGetMinX(rect), coordinate_Y);
		CGContextAddLineToPoint(context, CGRectGetMaxX(rect), coordinate_Y);
		CGContextStrokePath(context);

		coordinate_Y += 1.0f;
	}
}

- (void)drawBookendEffectRect:(CGRect)rect context:(CGContextRef)context {
	// Colors for bookend drawing
	NSArray *colorsForHorizontalLine = [NSArray arrayWithObjects:
			[UIColor colorWithRed:181.0f/255.0f green:186.0f/255.0f blue:186.0f/255.0f alpha:1.0f],
			[UIColor colorWithRed:209.0f/255.0f green:209.0f/255.0f blue:209.0f/255.0f alpha:1.0f],
			[UIColor colorWithRed:171.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f],
			[UIColor colorWithRed:189.0f/255.0f green:189.0f/255.0f blue:189.0f/255.0f alpha:1.0f],
			[UIColor colorWithRed:166.0f/255.0f green:166.0f/255.0f blue:167.0f/255.0f alpha:1.0f],
			[UIColor colorWithRed:182.0f/255.0f green:182.0f/255.0f blue:182.0f/255.0f alpha:1.0f],
			[UIColor colorWithRed:137.0f/255.0f green:136.0f/255.0f blue:135.0f/255.0f alpha:1.0f], nil];

	[self drawHorizontalLineWithColors:colorsForHorizontalLine rect:rect context:context];

	NSArray *colors = [NSArray arrayWithObjects:
			(__bridge id)[[UIColor colorWithRed:181.0f/255.0f green:183.0f/255.0f blue:183.0f/255.0f alpha:1.0f] CGColor],
			(__bridge id)[[UIColor colorWithRed:181.0f/255.0f green:183.0f/255.0f blue:183.0f/255.0f alpha:0.0f] CGColor], nil];
	CGRect bottomGradientRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + (CGFloat)[colorsForHorizontalLine count] - 1.0f, CGRectGetWidth(rect), (CGFloat)[colorsForHorizontalLine count]);
	[self drawLinearGradientToContext:context rect:bottomGradientRect withColors:colors];
}


@end