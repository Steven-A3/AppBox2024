//
//  A3GradientView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/23/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3GradientView.h"
#import "A3Utilities.h"

@implementation A3GradientView

- (NSArray *)gradientColors {
	if (nil == _gradientColors) {
		// Set default color
		_gradientColors = @[(__bridge id)[[UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f] CGColor],
		(__bridge id)[[UIColor colorWithRed:232.0f/255.0f green:235.0f/255.0f blue:234.0f/255.0f alpha:1.0f] CGColor]];
	}
	return _gradientColors;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		_vertical = NO;
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		_vertical = NO;
		self.backgroundColor = [UIColor clearColor];
	}

	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat locations[] = { 0.0f, 1.0f };

	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) self.gradientColors, locations);

	CGPoint startPoint;
	CGPoint endPoint;
	if (_vertical) {
		startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
		endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
	} else {
		startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
		endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	}

	CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);

	CGGradientRelease(gradient);
}

@end
