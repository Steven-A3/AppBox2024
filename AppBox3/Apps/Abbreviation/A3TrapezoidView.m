//
//  A3TrapezoidView.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/10/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3TrapezoidView.h"

@implementation A3TrapezoidView

- (void)setupMask {
	if (!_trapezoidMaskEnabled) {
		self.layer.mask = nil;
		return;
	}
	CGRect bounds = self.bounds;
	
	UIBezierPath *trapezoidPath = [UIBezierPath new];
	[trapezoidPath moveToPoint:CGPointMake(7, 0)];
	[trapezoidPath addLineToPoint:CGPointMake(0, bounds.size.height)];
	[trapezoidPath addLineToPoint:CGPointMake(bounds.size.width, bounds.size.height)];
	[trapezoidPath addLineToPoint:CGPointMake(bounds.size.width - 6, 0)];
	[trapezoidPath closePath];
	
	CAShapeLayer *trapezoidShapeLayer = [CAShapeLayer layer];
	trapezoidShapeLayer.frame = bounds;
	trapezoidShapeLayer.fillColor = [UIColor whiteColor].CGColor;
	trapezoidShapeLayer.path = trapezoidPath.CGPath;
	self.layer.mask = trapezoidShapeLayer;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	[self setupMask];
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];
	
	[self setupMask];
}

- (void)setTrapezoidMaskEnabled:(BOOL)trapezoidMaskEnabled {
	_trapezoidMaskEnabled = trapezoidMaskEnabled;
	[self setupMask];
}

@end
