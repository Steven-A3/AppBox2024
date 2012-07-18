//
//  A3GrayAppHeaderView.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/13/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3GrayAppHeaderView.h"
#import "A3Utilities.h"

@interface A3GrayAppHeaderView ()

@property (strong, nonatomic) CAGradientLayer *gradientLayer;

@end

@implementation A3GrayAppHeaderView
@synthesize gradientLayer = _gradientLayer;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.clipsToBounds = YES;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	// Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGColorRef glossColor1 = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f].CGColor;
	CGColorRef glossColor2 = [UIColor colorWithRed:172.0f/255.0f green:172.0f/255.0f blue:172.0f/255.0f alpha:1.0f].CGColor;
	drawLinearGradient(context, rect, glossColor1, glossColor2);

	CGContextSaveGState(context);
	CGContextSetShouldAntialias(context, false);

	// Drawing code, 31	32	34
	CGContextSetLineWidth(context, 1.0);
	CGContextSetRGBStrokeColor(context, 255.0f/255.0f, 255.0f/255.0f, 255.0f/255.0f, 1.0f);

	// Draw a single line from left to right
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect) + 1.0f);
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect) + 1.0f);

	// Drawing code
	CGContextSetRGBStrokeColor(context, 133.0f/255.0f, 133.0f/255.0f, 134.0f/255.0f, 1.0f);

	// Draw a single line from left to right
	CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
	CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
	CGContextStrokePath(context);

	CGContextRestoreGState(context);
}

@end
