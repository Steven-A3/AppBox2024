//
//  A3BackgroundWithPatternView.m
//  AppBox3
//
//  Created by A3 on 11/29/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3BackgroundWithPatternView.h"
#import "UIImage+Rotating.h"


@interface A3BackgroundWithPatternView ()
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation A3BackgroundWithPatternView

- (instancetype)initWithStyle:(A3BackgroundPatternStyle)style {
	self = [super init];
	if (self) {
		_style = style;

		self.backgroundColor = [UIColor whiteColor];

		self.gradientLayer = [CAGradientLayer layer];
		self.gradientLayer.anchorPoint = CGPointMake(0, 0);
		self.gradientLayer.position = CGPointMake(0,0);
		self.gradientLayer.startPoint = CGPointMake(0.5, 0.0);
		self.gradientLayer.endPoint = CGPointMake(0.5, 1.0);
		self.gradientLayer.locations = @[@0, @1];
		[self.layer insertSublayer:self.gradientLayer atIndex:0];

		if (_style == A3BackgroundPatternStyleLight) {
			self.gradientLayer.colors = @[
					(id) [UIColor colorWithRed:44.0 / 255.0 green:123.0 / 255.0 blue:174.0 / 255.0 alpha:1.0].CGColor,
					(id) [UIColor colorWithRed:97.0 / 255.0 green:207.0 / 255.0 blue:235.0 / 255.0 alpha:1.0].CGColor
			];
		} else {
			self.gradientLayer.colors = @[
					(id) [UIColor colorWithRed:14.0 / 255.0 green:18.0 / 255.0 blue:40.0 / 255.0 alpha:1.0].CGColor,
					(id) [UIColor colorWithRed:44.0 / 255.0 green:123.0 / 255.0 blue:174.0 / 255.0 alpha:1.0].CGColor
			];
		}
	}
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	self.gradientLayer.bounds = self.bounds;
}

@end
