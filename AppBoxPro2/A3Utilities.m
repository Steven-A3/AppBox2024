//
//  A3Utilities.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 6/11/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3Utilities.h"

@implementation A3Utilities

@end

void addLeftGradientLayer8Point(UIView *targetView) {
	// Gradient layer for Tableview left and right side
	CAGradientLayer *leftGradientOnMenuLayer = [CAGradientLayer layer];
	[leftGradientOnMenuLayer setColors:
			[NSArray arrayWithObjects:
					(__bridge id)[[UIColor colorWithRed:32.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:0.8] CGColor],
					(__bridge id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor],
					nil ] ];
	[leftGradientOnMenuLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
	[leftGradientOnMenuLayer setBounds:[targetView bounds]];
	[leftGradientOnMenuLayer setStartPoint:CGPointMake(0.0, 0.5)];
	[leftGradientOnMenuLayer setEndPoint:CGPointMake(1.0, 0.5)];
	[[targetView layer] insertSublayer:leftGradientOnMenuLayer atIndex:1];
}


void addRightGradientLayer8Point(UIView *targetView) {
	CAGradientLayer *rightGradientOnMenuLayer = [CAGradientLayer layer];
	[rightGradientOnMenuLayer setColors:
			[NSArray arrayWithObjects:
					(__bridge id)[[UIColor colorWithRed:32.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:0.8] CGColor],
					(__bridge id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor],
					nil ] ];
	[rightGradientOnMenuLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
	[rightGradientOnMenuLayer setBounds:[targetView bounds]];
	[rightGradientOnMenuLayer setStartPoint:CGPointMake(1.0, 0.5)];
	[rightGradientOnMenuLayer setEndPoint:CGPointMake(0.0, 0.5)];
	[[targetView layer] insertSublayer:rightGradientOnMenuLayer atIndex:1];
}
