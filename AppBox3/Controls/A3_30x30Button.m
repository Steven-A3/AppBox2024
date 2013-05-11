//
//  A3_30x30Button
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/9/13 6:18 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3_30x30Button.h"
#import "common.h"


@implementation A3_30x30Button {
	CAGradientLayer *_gradientLayer;
}

- (void)configureLayers {
	if (nil == _gradientLayer) {
		_gradientLayer = [CAGradientLayer layer];
		_gradientLayer.anchorPoint = CGPointMake(0.0, 0.0);
		_gradientLayer.startPoint = CGPointMake(0.5, 0.0);
		_gradientLayer.endPoint = CGPointMake(0.5, 1.0);
		_gradientLayer.bounds = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height - 2.0);
		[self setGradientLayerColor];
		_gradientLayer.borderWidth = 1.0;
		_gradientLayer.borderColor = [UIColor colorWithRed:43.0/255.0 green:11.0/255.0 blue:203.0/255.0 alpha:1.0].CGColor;
		_gradientLayer.cornerRadius = 5.0;
		_gradientLayer.shadowOffset = CGSizeMake(0.0, 0.0);
		_gradientLayer.shadowColor = [UIColor colorWithRed:165.0/255.0 green:152.0/255.0 blue:229.0/255.0 alpha:1.0].CGColor;
		_gradientLayer.shadowOpacity = 1.0;
		_gradientLayer.shadowRadius = 1.0;
		_gradientLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5.0].CGPath;
		[self.layer insertSublayer:_gradientLayer atIndex:0];
	}
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[self configureLayers];

	UIImage *image = [self imageForState:UIControlStateNormal];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.center = CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y - 1.0);
	[self addSubview:imageView];
}

- (void)setGradientLayerColor {
	if (self.highlighted) {
		_gradientLayer.colors = @[(id)[UIColor colorWithRed:202.0/255.0 green:203.0/255.0 blue:203.0/255.0 alpha:1.0].CGColor,
				(id)[UIColor colorWithRed:153.0/255.0 green:154.0/255.0 blue:155.0/255.0 alpha:1.0].CGColor];
	} else {
		_gradientLayer.colors = @[(id)[UIColor colorWithRed:88.0/255.0 green:79.0/255.0 blue:243.0/255.0 alpha:1.0].CGColor,
				(id)[UIColor colorWithRed:54.0/255.0 green:39.0/255.0 blue:198.0/255.0 alpha:1.0].CGColor];
	}
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	[self setGradientLayerColor];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];

	FNLOG(@"Check");

	[self configureLayers];

	UIImage *image = [self imageForState:UIControlStateNormal];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.center = CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y - 1.0);
	[self addSubview:imageView];
}

@end