//
//  A3HorizontalGradientView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/23/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3HorizontalGradientView.h"
#import "A3Utilities.h"

@implementation A3HorizontalGradientView

- (NSArray *)gradientColors {
	if (nil == _gradientColors) {
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
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	drawLinearGradient(context, rect, self.gradientColors);

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

@end
