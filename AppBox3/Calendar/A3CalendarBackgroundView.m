//
//  A3CalendarBackgroundView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/1/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarBackgroundView.h"
#import "A3Utilities.h"
#import "A3UIKit.h"

#define A3_CBV_TOP_GRADIENT_HEIGHT		4.0f
#define A3_CBV_BOOKEND_AREA_HEIGHT		7.0f
#define A3_CBV_BOTTOM_GRADIENT_HEIGHT	7.0f
#define A3_CBV_BOTTOM_AREA_HEIGHT		50.0f

@implementation A3CalendarBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
	}

	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetAllowsAntialiasing(context, false);

	[self drawTopGradientRect:rect context:context];
	[self drawBottomGradientRect:rect context:context];
}

- (void)drawBottomGradientRect:(CGRect)rect context:(CGContextRef)context {
	CGContextSetRGBFillColor(context, 240.0f/255.0f, 242.0f/255.0f, 243.0f/255.0f, 1.0f);
	CGContextAddRect(context, CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - A3_CBV_BOTTOM_AREA_HEIGHT, CGRectGetWidth(rect), A3_CBV_BOTTOM_AREA_HEIGHT));
	CGContextFillPath(context);

	CGRect bookendRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - A3_CBV_BOTTOM_AREA_HEIGHT - A3_CBV_BOOKEND_AREA_HEIGHT + 1.0f, CGRectGetWidth(rect), CGRectGetHeight(rect));
	[A3UIKit drawBookendEffectRect:bookendRect context:context];

	NSArray *colorsB = [NSArray arrayWithObjects:
			(__bridge id)[[UIColor colorWithRed:235.0f/255.0f green:237.0f/255.0f blue:238.0f/255.0f alpha:1.0f] CGColor],
			(__bridge id)[[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f] CGColor], nil];
	CGRect bottomGradientRectB = CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - (A3_CBV_BOTTOM_GRADIENT_HEIGHT - 2.0f), CGRectGetWidth(rect), (A3_CBV_BOTTOM_GRADIENT_HEIGHT - 2.0f));
	drawLinearGradient(context, bottomGradientRectB, colorsB);
}

- (void)drawTopGradientRect:(CGRect)rect context:(CGContextRef)context {
	NSArray *colors = [NSArray arrayWithObjects:
			(__bridge id)[[UIColor colorWithRed:219.0f/255.0f green:105.0f/255.0f blue:110.0f/255.0f alpha:1.0f] CGColor],
			(__bridge id)[[UIColor colorWithRed:138.0f/255.0f green:32.0f/255.0f blue:35.0f/255.0f alpha:1.0f] CGColor], nil];
	CGRect topGradientRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), A3_CBV_TOP_GRADIENT_HEIGHT);
	drawLinearGradient(context, topGradientRect, colors);

	CGContextSetRGBStrokeColor(context, 44.0f/255.0f, 44.0f/255.0f, 44.0f/255.0f, 1.0f);
	CGContextSetLineWidth(context, 1.0f);
	CGContextMoveToPoint(context, CGRectGetMinX(rect), A3_CBV_TOP_GRADIENT_HEIGHT + 1.0f);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), A3_CBV_TOP_GRADIENT_HEIGHT + 1.0f);
	CGContextStrokePath(context);
}

@end
