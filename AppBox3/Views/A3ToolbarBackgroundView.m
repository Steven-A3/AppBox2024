//
//  A3ToolbarBackgroundView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ToolbarBackgroundView.h"

@implementation A3ToolbarBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
// Drawing code
	CGContextRef context=UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);

	UIColor *ucolor1=[UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255 alpha:1];
	UIColor *ucolor2=[UIColor colorWithRed:26.0/255.0 green:26.0/255.0 blue:27.0/255 alpha:1];

	CGColorRef color1=ucolor1.CGColor;
	CGColorRef color2=ucolor2.CGColor;

	CGGradientRef gradient;
	CGFloat locations[2] = { 0.0, 1.0 };
	NSArray *colors = [NSArray arrayWithObjects:(__bridge id)color1, (__bridge id)color2, nil];

	gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

	CGRect currentBounds = self.bounds;
	CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
	CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));

	CGContextDrawLinearGradient(context, gradient, topCenter, midCenter, 0);
	CGGradientRelease(gradient);

	ucolor1=[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255 alpha:1];
	ucolor2=[UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255 alpha:1];

	[ucolor1 setFill];
	CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, 1));
	[ucolor2 setFill];
	CGContextFillRect(context, CGRectMake(0, 1, rect.size.width, 1));

	CGContextRestoreGState(context);    // Drawing code
}

@end
