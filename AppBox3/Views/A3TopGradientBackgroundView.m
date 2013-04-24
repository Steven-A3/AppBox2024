//
//  A3TopGradientBackgroundView
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/24/13 7:59 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3TopGradientBackgroundView.h"
#import "UIView+A3Drawing.h"


@implementation A3TopGradientBackgroundView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
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

	CGContextSetFillColorWithColor(context, [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:243.0/255.0 alpha:1.0].CGColor);
	CGRect drawingRect = rect;
	drawingRect.size.height = 1.0;
	CGContextFillRect(context, drawingRect);

	drawingRect.origin.y = 1.0;
	drawingRect.size.height = 8.0;
	[self drawLinearGradientToContext:context rect:drawingRect withColors:@[(id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor]];

	CGContextStrokePath(context);
}

@end