//
//  A3ActionMenuBackgroundView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ActionMenuBackgroundView.h"
#import "A3UIKit.h"
#import "UIView+A3Drawing.h"

@implementation A3ActionMenuBackgroundView

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
	}

	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	CGFloat polyLineStartFromRight = 35.0;
	CGFloat polyLineTopFromRight = 25.0;
	CGFloat polyLineEndFromRight = 15.0;
	CGFloat polyLineHeight = 10.0;

    // Drawing code
    UIBezierPath *clipPath = [UIBezierPath bezierPath];
	[clipPath moveToPoint:CGPointMake(0.0, polyLineHeight)];	// Left Top
	[clipPath addLineToPoint:CGPointMake(CGRectGetMaxX(rect) - polyLineStartFromRight, polyLineHeight)];
    [clipPath addLineToPoint:CGPointMake(CGRectGetMaxX(rect) - polyLineTopFromRight, 0.0)];
	[clipPath addLineToPoint:CGPointMake(CGRectGetMaxX(rect) - polyLineEndFromRight, polyLineHeight)];
	[clipPath addLineToPoint:CGPointMake(CGRectGetMaxX(rect), 10.0)];	// Right Top
	[clipPath addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];	// Right bottom
	[clipPath addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))];	// Left bottom
	[clipPath closePath];

	NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"bg_actionMenu" ofType:@"png"];
	[[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:imagePath]] setFill];

	[clipPath fill];

	CGContextRef context = UIGraphicsGetCurrentContext();

	NSArray *topGradientColors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor,
	(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor];
	CGFloat gradientHeight = 3.0;
	CGRect gradientRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + polyLineHeight, CGRectGetWidth(rect) - polyLineStartFromRight, gradientHeight);
	[self drawLinearGradientToContext:context rect:gradientRect withColors:topGradientColors];
	gradientRect = CGRectMake(CGRectGetWidth(rect) - polyLineEndFromRight, CGRectGetMinY(rect) + polyLineHeight, polyLineEndFromRight, gradientHeight);
	[self drawLinearGradientToContext:context rect:gradientRect withColors:topGradientColors];

	NSArray *bottomGradientColors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
	(id)[UIColor colorWithWhite:0.0 alpha:0.9].CGColor];
	gradientRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - gradientHeight, CGRectGetWidth(rect), gradientHeight);
	[self drawLinearGradientToContext:context rect:gradientRect withColors:bottomGradientColors];
}

@end
