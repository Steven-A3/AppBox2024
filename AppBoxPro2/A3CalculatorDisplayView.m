//
//  A3CalculatorDisplayView.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3CalculatorDisplayView.h"
#import "common.h"

@interface A3CalculatorDisplayView ()
- (void)addGradientLayerForDisplayView;


@end

@implementation A3CalculatorDisplayView

- (id)initWithFrame:(CGRect)frame
{
	FNLOG(@"");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self addGradientLayerForDisplayView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	FNLOG(@"");
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self addGradientLayerForDisplayView];
	}

	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)addGradientLayerForDisplayView {
	FNLOG(@"");

	self.clipsToBounds = YES;

	CALayer *thickRoundedRectLayer = [CALayer layer];
	thickRoundedRectLayer.cornerRadius = 8.0;
	thickRoundedRectLayer.bounds = self.layer.bounds;
	thickRoundedRectLayer.anchorPoint = CGPointMake(0.0, 0.0);
	thickRoundedRectLayer.borderWidth = 2.0;
	thickRoundedRectLayer.borderColor = [UIColor blackColor].CGColor;
	thickRoundedRectLayer.masksToBounds = YES;

	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
	gradientLayer.anchorPoint = CGPointMake(0.0, 0.0);
	gradientLayer.bounds = self.layer.bounds;
	gradientLayer.startPoint = CGPointMake(0.5, 0.0);
	gradientLayer.endPoint = CGPointMake(0.5, 1.0);
	gradientLayer.colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:207.0f/256.0f
										 green:212.0f/256.0f
										  blue:188.0f/256.0f
										 alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:164.0f/256.0f
										 green:171.0f/256.0f
										  blue:135.0f/256.0f
										 alpha:1.0f].CGColor,
			nil];
	[thickRoundedRectLayer addSublayer:gradientLayer];

	CAGradientLayer *leftInnerShadow = [CAGradientLayer layer];
	leftInnerShadow.anchorPoint = CGPointMake(0.0, 0.0);
	leftInnerShadow.startPoint = CGPointMake(0.0, 0.5);
	leftInnerShadow.endPoint = CGPointMake(1.0, 0.5);
	leftInnerShadow.bounds = CGRectMake(CGRectGetMinX(self.layer.bounds), CGRectGetMinY(self.layer.bounds), 8.0, CGRectGetHeight(self.layer.bounds));
	leftInnerShadow.colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:32.0f/256.0f
										 green:34.0f/256.0f
										  blue:34.0f/256.0f
										 alpha:0.8f].CGColor,
			(__bridge id)[UIColor colorWithRed:0.0f/256.0f
										 green:0.0f/256.0f
										  blue:0.0f/256.0f
										 alpha:0.0f].CGColor,
			nil];
	[thickRoundedRectLayer addSublayer:leftInnerShadow];

	CAGradientLayer *topInnerShadow = [CAGradientLayer layer];
	topInnerShadow.anchorPoint = CGPointMake(0.0, 0.0);
	topInnerShadow.startPoint = CGPointMake(0.5, 0.0);
	topInnerShadow.endPoint = CGPointMake(0.5, 1.0);
	topInnerShadow.bounds = CGRectMake(CGRectGetMinX(self.layer.bounds), CGRectGetMinY(self.layer.bounds), CGRectGetWidth(self.layer.bounds), 8.0);
	topInnerShadow.colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:32.0f/256.0f
										 green:34.0f/256.0f
										  blue:34.0f/256.0f
										 alpha:0.8f].CGColor,
			(__bridge id)[UIColor colorWithRed:0.0f/256.0f
										 green:0.0f/256.0f
										  blue:0.0f/256.0f
										 alpha:0.0f].CGColor,
			nil];
	[thickRoundedRectLayer addSublayer:topInnerShadow];

	CAGradientLayer *rightInnerShadow = [CAGradientLayer layer];
	rightInnerShadow.anchorPoint = CGPointMake(0.0, 0.0);
	rightInnerShadow.startPoint = CGPointMake(1.0, 0.5);
	rightInnerShadow.endPoint = CGPointMake(0.0, 0.5);
	rightInnerShadow.bounds = CGRectMake(CGRectGetMinX(self.layer.bounds), CGRectGetMinY(self.layer.bounds), 8.0, CGRectGetHeight(self.layer.bounds));
	rightInnerShadow.position = CGPointMake(CGRectGetMaxX(self.layer.bounds) - 8.0, 0.0);
	rightInnerShadow.colors = [NSArray arrayWithObjects:
			(__bridge id)[UIColor colorWithRed:32.0f/256.0f
										 green:34.0f/256.0f
										  blue:34.0f/256.0f
										 alpha:0.8f].CGColor,
			(__bridge id)[UIColor colorWithRed:0.0f/256.0f
										 green:0.0f/256.0f
										  blue:0.0f/256.0f
										 alpha:0.0f].CGColor,
			nil];
	[thickRoundedRectLayer addSublayer:rightInnerShadow];

	[self.layer addSublayer:thickRoundedRectLayer];

}

@end
