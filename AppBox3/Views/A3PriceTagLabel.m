//
//  A3PriceTagLabel.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/20/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3PriceTagLabel.h"
#import "A3AppDelegate.h"

@interface A3PriceTagLabel ()

@property (nonatomic, strong) UIBezierPath *crossPath;

@end

@implementation A3PriceTagLabel

- (instancetype)init {
	self = [super init];
	if (self) {
		[self setupLayer];
	}

	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setupLayer];
	}

	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self setupLayer];
	}

	return self;
}


- (void)setupLayer {
	self.backgroundColor = [UIColor clearColor];
	self.textAlignment = NSTextAlignmentCenter;
	self.font = [UIFont boldSystemFontOfSize:13];
	self.textColor = [A3AppDelegate instance].themeColor;
	self.layer.borderColor = [A3AppDelegate instance].themeColor.CGColor;
	self.layer.cornerRadius = 3;
	self.layer.borderWidth = 1.0;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];

	[[A3AppDelegate instance].themeColor setStroke];

	[self.crossPath stroke];
}

- (UIBezierPath *)crossPath {
	if (!_crossPath) {
		_crossPath = [UIBezierPath new];
		[_crossPath moveToPoint:CGPointMake(6.5, 4)];
		[_crossPath addLineToPoint:CGPointMake(6.5, 9)];
		[_crossPath moveToPoint:CGPointMake(4, 6.5)];
		[_crossPath addLineToPoint:CGPointMake(9, 6.5)];
		_crossPath.lineWidth = 1;
	}
	return _crossPath;
}

@end
