//
//  A3BarButton
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/24/13 6:07 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3BarButton.h"

@interface A3BarButton ()
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end


@implementation A3BarButton

- (void)configureLayers {
	if (nil == _gradientLayer) {
		_gradientLayer = [CAGradientLayer layer];
		_gradientLayer.anchorPoint = CGPointMake(0.0, 0.0);
		_gradientLayer.startPoint = CGPointMake(0.5, 0.0);
		_gradientLayer.endPoint = CGPointMake(0.5, 1.0);
		_gradientLayer.bounds = self.bounds;
		[self setGradientLayerColor];
		_gradientLayer.borderWidth = 1.0;
		_gradientLayer.borderColor = [UIColor colorWithRed:55.0/255.0 green:55.0/255.0 blue:55.0/255.0 alpha:1.0].CGColor;
		_gradientLayer.cornerRadius = 5.0;
		[self.layer insertSublayer:_gradientLayer atIndex:0];
	}
	[self setTitleColor:[UIColor colorWithRed:55.0 / 255.0 green:55.0 / 255.0 blue:55.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
}

- (void)setGradientLayerColor {
	if (self.highlighted) {
		_gradientLayer.colors = @[(id)[UIColor colorWithRed:202.0/255.0 green:203.0/255.0 blue:203.0/255.0 alpha:1.0].CGColor,
				(id)[UIColor colorWithRed:153.0/255.0 green:154.0/255.0 blue:155.0/255.0 alpha:1.0].CGColor];
	} else {
		_gradientLayer.colors = @[(id)[UIColor colorWithRed:236.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0].CGColor,
				(id)[UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:214.0/255.0 alpha:1.0].CGColor];
	}
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	[self setGradientLayerColor];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];

	[self configureLayers];
}

@end
