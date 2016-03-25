//
//  A3HomeScreenButton.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/22/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3HomeScreenButton.h"

@interface A3HomeScreenButton ()

@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation A3HomeScreenButton

- (void)setIconNamed:(NSString *)iconName {
	UIImage *image = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	if (!_iconImageView) {
		_iconImageView = [UIImageView new];
	}
	_iconImageView.image = image;
	_iconImageView.tintColor = self.tintColor;
	[self addSubview:_iconImageView];
	
	[_iconImageView remakeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.centerX);
		make.centerY.equalTo(self.centerY);
		make.width.equalTo(IS_IPHONE ? @30 : IS_IPAD_PRO ? @40 : @35);
		make.height.equalTo(IS_IPHONE ? @30 : IS_IPAD_PRO ? @40 : @35);
	}];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	
	_iconImageView.tintColor = highlighted ? [UIColor lightGrayColor] : self.tintColor;
}

@end
