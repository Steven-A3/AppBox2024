//
//  A3TripleCircleView.m
//  AppBox3
//
//  Created by A3 on 10/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TripleCircleView.h"

@implementation A3TripleCircleView {
	CALayer *_centerCircle, *_middleCircle;
}

- (id)init {
	self = [super init];
	if (self) {
		[self setupLayer];
	}

	return self;
}

- (void)setupLayer {
	// Outer Circle size 31, 31
	self.layer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.05].CGColor;
	self.layer.cornerRadius = 15.5;

	_middleCircle = [CALayer layer];
	_middleCircle.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
	_middleCircle.frame = CGRectMake(8, 8, 15, 15);
	_middleCircle.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
	_middleCircle.borderWidth = 1.0;
	_middleCircle.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
	_middleCircle.cornerRadius = 7.5;
	[self.layer addSublayer:_middleCircle];

	_centerCircle = [CALayer layer];
	_centerCircle.backgroundColor = _centerColor ? _centerColor.CGColor : [UIColor colorWithRed:0 green:128.0/255.0 blue:252.0/255.0 alpha:1.0].CGColor;
	_centerCircle.frame = CGRectMake(12, 12, 7, 7);
	_centerCircle.cornerRadius = 3.5;
	[self.layer addSublayer:_centerCircle];
}

- (void)setCenterColor:(UIColor *)centerColor {
	_centerColor = centerColor;
	_centerCircle.backgroundColor = _centerColor.CGColor;
}

@end
