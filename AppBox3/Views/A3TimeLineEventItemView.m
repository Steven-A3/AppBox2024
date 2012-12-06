//
//  A3TimeLineEventItemView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/5/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3TimeLineEventItemView.h"
#import "A3UIDevice.h"
#import "A3Utilities.h"

@implementation A3TimeLineEventItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		// Initialization code
		self.backgroundColor = [UIColor whiteColor];

		self.clipsToBounds = NO;
		self.layer.masksToBounds = NO;

		CALayer *shadowLayer = [self layer];
		shadowLayer.masksToBounds = NO;
		shadowLayer.bounds = self.bounds;
		[shadowLayer setShadowOffset:CGSizeMake(0.0, 1.0)];
		[shadowLayer setShadowColor:[UIColor darkGrayColor].CGColor];
		[shadowLayer setShadowOpacity:0.5];
		[shadowLayer setShadowRadius:2.0];
		shadowLayer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
	}
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	CGContextRef context;
	context = UIGraphicsGetCurrentContext();

	CGContextSetAllowsAntialiasing(context, false);

	// Drawing lines with a light gray stroke color
	CGContextSetRGBStrokeColor(context, 217.0f/255.0f, 217.0f/255.0f, 217.0f/255.0f, 1.0f);

	CGContextSetLineDash(context, 1.0f, dash_line_pattern, 2);
	CGContextSetLineWidth(context, 1.0f);

	// Draw a horizontal line, vertical line, rectangle and circle for comparison
	CGFloat dashlineLatitude = 44.0f;
	CGContextMoveToPoint(context, CGRectGetMinX(self.bounds), dashlineLatitude);
	CGContextAddLineToPoint(context, CGRectGetMaxX(self.bounds), dashlineLatitude);

	CGContextStrokePath(context);
}

@end
