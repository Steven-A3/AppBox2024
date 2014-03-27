//
//  A3KeyboardMoveButton.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/26/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3KeyboardMoveMarkView.h"

@implementation A3KeyboardMoveMarkView

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
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect drawingRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), 2.0);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0, 1.0), 1.0, [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0].CGColor);
	CGContextSetFillColorWithColor(context, [UIColor colorWithRed:195.0/255.0 green:195.0/255.0 blue:195.0/255.0 alpha:63.0/255.0].CGColor);
	CGContextFillRect(context, drawingRect);

	for (NSInteger count = 0; count < 4; count++) {
		drawingRect = CGRectOffset(drawingRect, 0.0, 5.0);
		CGContextFillRect(context, drawingRect);
	}
}

@end
