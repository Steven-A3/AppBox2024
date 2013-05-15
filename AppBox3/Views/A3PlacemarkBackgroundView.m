//
//  A3PlacemarkBackgroundView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/15/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3PlacemarkBackgroundView.h"

@implementation A3PlacemarkBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[self configureLayer];

	[super willMoveToSuperview:newSuperview];
}

- (void)configureLayer {
	CAGradientLayer *gradientLayer;
	gradientLayer = [CAGradientLayer layer];
	gradientLayer.anchorPoint = CGPointMake(0.0, 0.0);
	gradientLayer.startPoint = CGPointMake(0.5, 0.0);
	gradientLayer.endPoint = CGPointMake(0.5, 1.0);
	gradientLayer.bounds = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height - 1.0);
	gradientLayer.colors = @[(id)[UIColor colorWithRed:252.0/255.0 green:254.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor,
			(id)[UIColor colorWithRed:243.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor];
	gradientLayer.borderWidth = 1.0;
	gradientLayer.borderColor = [UIColor colorWithRed:224.0/255.0 green:222.0/255.0 blue:214.0/255.0 alpha:1.0].CGColor;
	gradientLayer.shadowOffset = CGSizeMake(0.0, 0.0);
	gradientLayer.shadowColor = [UIColor colorWithRed:203.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
	gradientLayer.shadowOpacity = 1.0;
	gradientLayer.shadowRadius = 0.0;
	gradientLayer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
	[self.layer insertSublayer:gradientLayer atIndex:0];
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
