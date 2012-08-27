//
//  A3CalendarWeekCurrentTimeMarkView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/13/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3CalendarWeekCurrentTimeMarkView.h"
#import "common.h"
#import "A3Utilities.h"

@implementation A3CalendarWeekCurrentTimeMarkView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
	}
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetAllowsAntialiasing(context, false);

    // Drawing code
	UIBezierPath *bezierPath = [UIBezierPath bezierPath];

	[bezierPath addArcWithCenter:CGPointMake(5.0f + 5.0f, 5.0f + 2.0f) radius:4.5f startAngle:DegreesToRadians(75) endAngle:DegreesToRadians(295) clockwise:YES];
	[bezierPath addLineToPoint:CGPointMake(15.0f + 5.0f, 5.0f + 2.0f)];
	[bezierPath closePath];

	[[UIColor colorWithRed:38.0f / 255.0f green:173.0f / 255.0f blue:53.0f / 255.0f alpha:1.0f] setStroke];

	CGContextMoveToPoint(context, 15.0 + 5.0f, 5.0f + 3.0f);
	CGContextAddLineToPoint(context, CGRectGetWidth(rect), 5.0f + 3.0f);
	CGContextStrokePath(context);

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

	// Start shadow setting
	CGContextSaveGState(context);

	// Draw shadow
	[[UIColor colorWithRed:38.0f / 255.0f green:173.0f / 255.0f blue:53.0f / 255.0f alpha:1.0f] setFill];
	CGFloat shadowColorValues[] = {169.0f/255.0f, 169.0f/255.0f, 169.0f/255.0f, 1.0f};
	CGColorRef shadowColor = CGColorCreate(colorSpace, shadowColorValues);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 2.0f), 2.0f, shadowColor);
	[bezierPath fill];

	// remove shadow setting
	CGContextRestoreGState(context);

	CGRect arrowRect = CGRectMake(CGRectGetMinX(rect) + 5.0f, CGRectGetMinY(rect) + 2.0f, 15.0f, 10.0f);

	// Draw gradient
	[bezierPath addClip];

	NSArray *colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:121.0f/255.0f green:241.0f/255.0f blue:95.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:29.0f/255.0f green:172.0f/255.0f blue:38.0f/255.0f alpha:1.0f].CGColor,
			nil];

	CGFloat locations[] = { 0.0f, 1.0f };

	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);

	CGPoint startPoint = CGPointMake(CGRectGetMinX(arrowRect), CGRectGetMinY(arrowRect));
	CGPoint endPoint = CGPointMake(CGRectGetMaxX(arrowRect), CGRectGetMaxY(arrowRect));

	CGContextSaveGState(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);

	[[UIColor colorWithRed:38.0f / 255.0f green:173.0f / 255.0f blue:53.0f / 255.0f alpha:1.0f] setStroke];
	[bezierPath stroke];

	CGColorRelease(shadowColor);
	CGColorSpaceRelease(colorSpace);
	CGGradientRelease(gradient);
}

@end
