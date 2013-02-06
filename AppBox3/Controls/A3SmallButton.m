//
//  A3SmallButton.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3SmallButton.h"

@interface A3SmallButton ()

@property (nonatomic, strong)	CAGradientLayer *gradientLayer;

@end

@implementation A3SmallButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self configureLayers];
	}

	return self;
}

- (void)configureLayers {
	_gradientLayer = [CAGradientLayer layer];
	_gradientLayer.anchorPoint = CGPointMake(0.0, 0.0);
    _gradientLayer.startPoint = CGPointMake(0.5, 0.0);
    _gradientLayer.endPoint = CGPointMake(0.5, 1.0);
	_gradientLayer.bounds = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height - 2.0);
	[self setGradientLayerColor];
	_gradientLayer.borderWidth = 1.0;
	_gradientLayer.borderColor = [UIColor colorWithRed:199.0/255.0 green:200.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor;
	_gradientLayer.cornerRadius = 5.0;
	_gradientLayer.shadowOffset = CGSizeMake(0.0, 0.0);
	_gradientLayer.shadowColor = [UIColor colorWithRed:207.0/255.0 green:210.0/255.0 blue:209.0/255.0 alpha:1.0].CGColor;
	_gradientLayer.shadowOpacity = 1.0;
	_gradientLayer.shadowRadius = 1.0;
	_gradientLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5.0].CGPath;
	[self.layer insertSublayer:_gradientLayer atIndex:0];
}

- (void)awakeFromNib {
	[super awakeFromNib];
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
		_gradientLayer.colors = @[(id)[UIColor colorWithRed:252.0/255.0 green:253.0/255.0 blue:1.0 alpha:1.0].CGColor,
				(id)[UIColor colorWithRed:243.0/255.0 green:244.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor];
	}
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	[self setGradientLayerColor];
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
