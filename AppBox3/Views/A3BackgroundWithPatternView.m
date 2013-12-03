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
@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation A3BackgroundWithPatternView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}

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
		self.gradientLayer.locations = @[@0, @0.6, @0.8, @1];
		[self.layer insertSublayer:self.gradientLayer atIndex:0];

		UIImage *patternImage = [UIImage imageNamed:@"Holidays_bg"];
		UIImage *rotatedImage = [patternImage rotateImagePixelsInDegrees:90];

		_maskLayer = [CALayer layer];
		_maskLayer.backgroundColor = [UIColor colorWithPatternImage:rotatedImage].CGColor;
		_maskLayer.anchorPoint = CGPointMake(0, 0);
		_maskLayer.position = CGPointMake(0,0);

		[self.layer addSublayer:_maskLayer];

		if (_style == A3BackgroundPatternStyleLight) {
			self.gradientLayer.colors = @[
					(id) [UIColor colorWithRed:44.0 / 255.0 green:123.0 / 255.0 blue:174.0 / 255.0 alpha:1.0].CGColor,
					(id) [UIColor colorWithRed:151.0 / 255.0 green:193.0 / 255.0 blue:220.0 / 255.0 alpha:1.0].CGColor,
					(id) [UIColor colorWithRed:233.0 / 255.0 green:198.0 / 255.0 blue:135.0 / 255.0 alpha:1.0].CGColor,
					(id) [UIColor colorWithRed:208.0 / 255.0 green:82.0 / 255.0 blue:61.0 / 255.0 alpha:1.0].CGColor
			];
			_maskLayer.opacity = 0.1;
		} else {
			self.gradientLayer.colors = @[
					(id) [UIColor colorWithRed:14.0 / 255.0 green:18.0 / 255.0 blue:40.0 / 255.0 alpha:1.0].CGColor,
					(id) [UIColor colorWithRed:49.0 / 255.0 green:59.0 / 255.0 blue:88.0 / 255.0 alpha:1.0].CGColor,
					(id) [UIColor colorWithRed:116.0 / 255.0 green:155.0 / 255.0 blue:178.0 / 255.0 alpha:1.0].CGColor,
					(id) [UIColor colorWithRed:34.0 / 255.0 green:83.0 / 255.0 blue:115.0 / 255.0 alpha:1.0].CGColor
			];
			_maskLayer.opacity = 0.05;
		}

//		UIView *patternView = [UIView new];
//		patternView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Holidays_bg"]];
//		[self addSubview:patternView];
//
//		[patternView makeConstraints:^(MASConstraintMaker *make) {
//			make.edges.equalTo(self);
//		}];
	}
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	self.gradientLayer.bounds = self.bounds;
	self.maskLayer.bounds = self.bounds;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
