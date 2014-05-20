//
//  A3RoundedSideButton.m
//  AppBox3
//
//  Created by A3 on 10/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3RoundedSideButton.h"

@implementation A3RoundedSideButton {
	CALayer *_borderLayer;
}

+ (id)buttonWithType:(UIButtonType)buttonType {
	id button = [super buttonWithType:buttonType];
	[button setupLayout];
	return button;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self setupLayout];
	}

	return self;
}

- (void)setupLayout {
	[self setTitleColor:self.tintColor forState:UIControlStateNormal];
	self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];

	FNLOG(@"%@, %ld", self.titleLabel.text, (long)selected);
	if (selected) {
		if (!_borderLayer) {
			_borderLayer = [CALayer layer];
			_borderLayer.frame = self.bounds;
			_borderLayer.borderColor = self.tintColor.CGColor;
			_borderLayer.borderWidth = 1.0;
			_borderLayer.cornerRadius = self.bounds.size.height / 2.0;
			[self.layer addSublayer:_borderLayer];
		}
	} else {
		[_borderLayer removeFromSuperlayer];
		_borderLayer = nil;
	}
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	[_borderLayer setFrame:self.bounds];
	_borderLayer.cornerRadius = self.bounds.size.height / 2.0;
}

- (void)setBorderColor:(UIColor *)color {
	_borderLayer.borderColor = color.CGColor;
}

@end
