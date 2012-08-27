//
//  A3RowSeparatorView.m
//  AppBox3
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
	CGContextSetRGBStrokeColor(context, 31.0f/255.0f, 32.0f/255.0f, 34.0f/255.0f, 1.0f);
	CGContextSetLineWidth(context, 1.0f);

	// Draw a single line from left to right
	CGContextMoveToPoint(context, 0.0f, 0.0f);
	CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), 0.0f);

	// Drawing code
	CGContextSetRGBStrokeColor(context, 78.0f/255.0f, 79.0f/255.0f, 80.0f/255.0f, 1.0f);

	// Draw a single line from left to right
	CGContextMoveToPoint(context, 0.0f, 1.0f);
	CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), 1.0f);
	CGContextStrokePath(context);

	CGContextRestoreGState(context);
}

@end
