//
//  A3GradientView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/23/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3GradientView.h"
#import "common.h"

@implementation A3GradientView

@synthesize startColor = _startColor;

- (NSArray *)gradientColors {
	if (nil == _gradientColors) {
		// Set default color
		_gradientColors = @[(__bridge id)[[UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f] CGColor],
		(__bridge id)[[UIColor colorWithRed:232.0f/255.0f green:235.0f/255.0f blue:234.0f/255.0f alpha:1.0f] CGColor]];
	}
	return _gradientColors;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}

	return self;
}

- (void)initialize {
	_vertical = NO;
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
	self.userInteractionEnabled = NO;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	if (_startColor && _endColor) {
		_gradientColors = @[(__bridge id)_startColor.CGColor, (__bridge id)_endColor.CGColor];
	}
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	// Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

	CGFloat *locations;
	if (_locations) {
		locations = malloc(sizeof(CGFloat) * [_locations count]);
		[_locations enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL *stop) {
			locations[idx] = [number doubleValue];
		}];
	} else {
		locations = malloc(sizeof(CGFloat) * 2);
        locations[0] = 0.0;
        locations[1] = 1.0;
	}

	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) self.gradientColors, locations);

	CGPoint startPoint;
	CGPoint endPoint;
	if (_vertical) {
		startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
		endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
	} else {
		startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
		endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	}

	CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);

	CGGradientRelease(gradient);
	free(locations);
}

@end
