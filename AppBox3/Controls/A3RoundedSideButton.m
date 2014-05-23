//
//  A3RoundedSideButton.m
//  AppBox3
//
//  Created by A3 on 10/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3RoundedSideButton.h"
#import "A3AppDelegate+appearance.h"

@implementation A3RoundedSideButton

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
	FNLOG();
	[self setTitleColor:self.tintColor forState:UIControlStateNormal];
	self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
	self.layer.cornerRadius = self.bounds.size.height / 2.0;
	self.layer.borderWidth = 1.0;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];

	FNLOG(@"%@, %ld", self.titleLabel.text, (long)selected);
	if (selected) {
		self.layer.cornerRadius = self.bounds.size.height / 2.0;
		self.layer.borderColor = [[A3AppDelegate instance] themeColor].CGColor;
	} else {
		self.layer.borderColor = [UIColor clearColor].CGColor;
	}
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	self.layer.cornerRadius = self.bounds.size.height / 2.0;
}

- (void)setBorderColor:(UIColor *)color {
	self.layer.borderColor = color.CGColor;
}

@end
