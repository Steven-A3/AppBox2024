//
//  A3KeyboardButton_iOS7.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3KeyboardButton_iOS7.h"

@implementation A3KeyboardButton_iOS7

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (UIColor *)subTitleColor {
	return [UIColor colorWithRed:80.0/255.0 green:89.0/255.0 blue:102.0/255.0 alpha:1.0];
}

- (UILabel *)mainTitle {
	if (nil == _mainTitle) {
		CGRect frame = self.bounds;
		frame.size.height = frame.size.height * 0.8;
		_mainTitle = [[UILabel alloc] initWithFrame:frame];
		_mainTitle.backgroundColor = [UIColor clearColor];
		_mainTitle.font = super.titleLabel.font;
		_mainTitle.textColor = [super titleColorForState:UIControlStateNormal];
		_mainTitle.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_mainTitle];
	}
	return _mainTitle;
}

- (UILabel *)subTitle {
	if (nil == _subTitle) {
		CGRect frame = self.bounds;
		frame.origin.y += frame.size.height * 0.4;
		frame.size.height -= frame.size.height * 0.4;
		_subTitle = [[UILabel alloc] initWithFrame:frame];
		_subTitle.backgroundColor = [UIColor clearColor];
		_subTitle.font = [UIFont boldSystemFontOfSize:14.0];
		_subTitle.textColor = [self subTitleColor];
		_subTitle.textAlignment = NSTextAlignmentCenter;
		_subTitle.shadowOffset = CGSizeMake(0.0, 1.0);
		_subTitle.shadowColor = [UIColor whiteColor];
		[self addSubview:_subTitle];
	}
	return _subTitle;
}

- (void)removeExtraLabels {
	[_mainTitle removeFromSuperview];
	_mainTitle = nil;
	[_subTitle removeFromSuperview];
	_subTitle = nil;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];

	if (_backgroundColorForSelectedState) {
		self.backgroundColor = selected ? _backgroundColorForSelectedState : _backgroundColorForDefaultState;
	}
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];

	if (_backgroundColorForHighlightedState) {
		self.backgroundColor = highlighted ? _backgroundColorForHighlightedState : _backgroundColorForDefaultState;
	}
}


@end
