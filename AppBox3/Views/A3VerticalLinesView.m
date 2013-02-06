//
//  A3VerticalLinesView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3VerticalLinesView.h"

@implementation A3VerticalLinesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
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
- (void)drawRect:(CGRect)rect {
	// Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetAllowsAntialiasing(context, false);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:181.0/255.0 green:204.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
	for (NSNumber *position in _positions) {
		CGContextMoveToPoint(context, [position floatValue], CGRectGetMinY(rect));
		CGContextAddLineToPoint(context, [position floatValue], CGRectGetMaxY(rect));
	}
	CGContextStrokePath(context);
}

@end
