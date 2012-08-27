//
//  A3CalculatorButton.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3CalculatorButton.h"
#import "common.h"

@interface A3CalculatorButton ()
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
- (void)setupLayers;

- (void)animateDown;

- (void)animateUp;


@end

@implementation A3CalculatorButton
@synthesize gradientLayer = _gradientLayer;
@synthesize buttonColor = _buttonColor;
@synthesize titleLabel = _titleLabel;
@synthesize title = _title;


- (void)awakeFromNib {
	[super awakeFromNib];

	[self setupLayers];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (NSArray *)blueColor {
	return [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:47.0f/255.0f
										 green:112.0f/255.0f
										  blue:187.0f/255.0f
										 alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:109.0f/255.0f
										 green:164.0f/255.0f
										  blue:218.0f/255.0f
										 alpha:1.0f].CGColor,
			nil];
}

- (NSArray *)pinkColor {
	return [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:199.0f/255.0f
										 green:68.0f/255.0f
										  blue:113.0f/255.0f
										 alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:228.0f/255.0f
										 green:144.0f/255.0f
										  blue:174.0f/255.0f
										 alpha:1.0f].CGColor,
			nil];
}

- (NSArray *)blackColor {
	return [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:41.0f/255.0f
										 green:43.0f/255.0f
										  blue:46.0f/255.0f
										 alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:103.0f/255.0f
										 green:107.0f/255.0f
										  blue:108.0f/255.0f
										 alpha:1.0f].CGColor,
					nil];
}

- (NSArray *)grayColor {
	return [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:103.0f/255.0f
										 green:112.0f/255.0f
										  blue:120.0f/255.0f
										 alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:155.0f/255.0f
										 green:164.0f/255.0f
										  blue:170.0f/255.0f
										 alpha:1.0f].CGColor,
					nil];
}

- (NSArray *)orangeColor {
	return [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:234.0f/255.0f
										 green:121.0f/255.0f
										  blue:1.0f/255.0f
										 alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:255.0f/255.0f
										 green:156.0f/255.0f
										  blue:50.0f/255.0f
										 alpha:1.0f].CGColor,
					nil];
}

- (NSUInteger)indexOfColor {
	NSArray *availableColors = [NSArray arrayWithObjects:@"blue", @"pink", @"black", @"gray", @"orange", nil];
	NSUInteger colorIndex = [availableColors indexOfObject:self.buttonColor];
	return colorIndex;
}

- (NSArray *)colorArray {
	NSUInteger colorIndex = [self indexOfColor];
	switch (colorIndex) {
		case A3CalculatorButtonColorBlue:
			return [self blueColor];
		case A3CalculatorButtonColorPink:
			return [self pinkColor];
		case A3CalculatorButtonColorBlack:
			return [self blackColor];
		case A3CalculatorButtonColorGray:
			return [self grayColor];
		case A3CalculatorButtonColorOrange:
			return [self orangeColor];
	}
	return [self blueColor];
}

- (UIColor *)borderColor {
	NSUInteger colorIndex = [self indexOfColor];
	switch (colorIndex) {
//		case A3CalculatorButtonColorBlue:
//			return defaultColor;
		case A3CalculatorButtonColorPink:
			return [UIColor colorWithRed:234.0f/255.0f green:186.0f/255.0f blue:202.0f/255.0f alpha:1.0f];
		case A3CalculatorButtonColorBlack:
			return [UIColor colorWithRed:176.0f/255.0f green:176.0f/255.0f blue:177.0f/255.0f alpha:1.0f];
		case A3CalculatorButtonColorGray:
			return [UIColor colorWithRed:199.0f/255.0f green:202.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
		case A3CalculatorButtonColorOrange:
			return [UIColor colorWithRed:247.0f/255.0f green:206.0f/255.0f blue:161.0f/255.0f alpha:1.0f];
	}
	return [UIColor colorWithRed:178.0f/255.0f green:202.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
}

- (void)setupLayers {
	CGRect bounds = self.layer.bounds;

	CALayer *thickRoundedRectLayer = [CALayer layer];
	thickRoundedRectLayer.cornerRadius = 8.0;
	thickRoundedRectLayer.bounds = bounds;
	thickRoundedRectLayer.anchorPoint = CGPointMake(0.0, 0.0);
	thickRoundedRectLayer.borderWidth = 2.0;
	thickRoundedRectLayer.borderColor = [UIColor blackColor].CGColor;
	thickRoundedRectLayer.masksToBounds = YES;

	self.gradientLayer = [CAGradientLayer layer];
	self.gradientLayer.position = CGPointMake(0.0f, 1.5f);
	self.gradientLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
	self.gradientLayer.bounds = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetWidth(bounds), CGRectGetHeight(bounds) + 1.0);
	self.gradientLayer.colors = [self colorArray];
	self.gradientLayer.startPoint = CGPointMake(0.5, 0.0);
	self.gradientLayer.endPoint = CGPointMake(0.5, 1.0);
	self.gradientLayer.borderColor = [self borderColor].CGColor;
	self.gradientLayer.cornerRadius = 8.0;
	self.gradientLayer.borderWidth = 2.0;
	[thickRoundedRectLayer addSublayer:self.gradientLayer];

	[self.layer addSublayer:thickRoundedRectLayer];

	if ([self.title length]) {
		self.titleLabel.text = self.title;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self animateDown];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self animateUp];
}

- (void)animateDown
{
	self.gradientLayer.position         = CGPointMake(0.0f, 0.0f);
}

- (void)animateUp
{
	self.gradientLayer.position         = CGPointMake(0.0f, 1.5f);
}

- (UILabel *)titleLabel {
	if (!_titleLabel) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.font = [UIFont boldSystemFontOfSize:30.0];
		_titleLabel.minimumFontSize = 8.0;
		_titleLabel.adjustsFontSizeToFitWidth = YES;
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:_titleLabel];
	}
	return _titleLabel;
}

@end
