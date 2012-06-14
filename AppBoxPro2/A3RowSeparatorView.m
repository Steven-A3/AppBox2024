//
//  A3RowSeparatorView.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 6/11/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3RowSeparatorView.h"

@implementation A3RowSeparatorView
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.clipsToBounds = YES;
	}

	return self;
}


- (void)drawRect:(CGRect)rect
{
	CGContextRef context;
	context = UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);
	CGContextSetShouldAntialias(context, false);

	// Drawing code, 31	32	34
	CGContextSetRGBStrokeColor(context, 31.0/255.0, 32.0/255.0, 34.0/255.0, 1.0);
	CGContextSetLineWidth(context, 1.0);

	// Draw a single line from left to right
	CGContextMoveToPoint(context, 0.0, 0.0);
	CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), 0.0);

	// Drawing code
	CGContextSetRGBStrokeColor(context, 78.0/255.0, 79.0/255.0, 80.0/255.0, 1.0);

	// Draw a single line from left to right
	CGContextMoveToPoint(context, 0.0, 1.0);
	CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), 1.0);
	CGContextStrokePath(context);

	CGContextRestoreGState(context);
}

@end
