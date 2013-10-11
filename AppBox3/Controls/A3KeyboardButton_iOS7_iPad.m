//
//  A3KeyboardButton_iOS7_iPad.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3KeyboardButton_iOS7_iPad.h"

@interface A3KeyboardButton_iOS7_iPad ()

@property (nonatomic, strong) CALayer *buttonLayer;

@end

@implementation A3KeyboardButton_iOS7_iPad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self setupLayer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self setupLayer];
	}

	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	_buttonLayer.backgroundColor = _normalBackgroundColor.CGColor;
	self.layer.backgroundColor = _shadowColor.CGColor;

	[self bringSubviewToFront:self.imageView];
	[self bringSubviewToFront:self.titleLabel];
}

- (void)setupLayer {
	_normalBackgroundColor = [UIColor colorWithRed:250.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1.0];
	_highlightedBackgroundColor = [UIColor colorWithRed:212.0/255.0 green:214.0/255.0 blue:216.0/255.0 alpha:1.0];
	_shadowColor = [UIColor colorWithRed:132.0/255.0 green:134.0/255.0 blue:136.0/255.0 alpha:1.0];

	CALayer *layer = self.layer;
	layer.backgroundColor = _shadowColor.CGColor;
	layer.cornerRadius = 7.0;

	_buttonLayer = [CALayer layer];
	_buttonLayer.anchorPoint = CGPointMake(0.0, 0.0);
	_buttonLayer.backgroundColor = _normalBackgroundColor.CGColor;
	CGRect bounds = layer.bounds;
	bounds.size.height -= 1.0;
	_buttonLayer.bounds = bounds;
	_buttonLayer.cornerRadius = 7.0;
	[layer addSublayer:_buttonLayer];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];

	_buttonLayer.backgroundColor = highlighted ?
			_highlightedBackgroundColor.CGColor :
			_normalBackgroundColor.CGColor;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	CGRect bounds = self.bounds;
	bounds.size.height -= 1.0;
	_buttonLayer.bounds = bounds;
}

@end
