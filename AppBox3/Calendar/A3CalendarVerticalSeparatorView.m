//
//  A3CalendarVerticalSeparatorView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/28/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarVerticalSeparatorView.h"

@implementation A3CalendarVerticalSeparatorView

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
    // Drawing code
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat locations[] = { 0.0f, 0.4f, 0.6f, 1.0f };

	NSArray *colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f].CGColor,
			(__bridge id)[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f].CGColor,
			(__bridge id)[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f].CGColor,
			(__bridge id)[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f].CGColor,
			nil];

	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);

	CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));

	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);

	CGGradientRelease(gradient);
}

@end
