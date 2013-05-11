//
//  A3SelectItemTableViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SelectItemTableViewCell.h"

@interface A3SelectItemTableViewCell ()

@end

@implementation A3SelectItemTableViewCell

- (id)initWithReuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	if (self) {
		[self addSubview:self.checkMark];
	}

	return self;
}

#define A3SITV_CHECKMARK_WIDTH		26.0

- (UILabel *)checkMark {
	if (nil == _checkMark) {
		_checkMark = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, A3SITV_CHECKMARK_WIDTH, 44.0)];
		_checkMark.backgroundColor = [UIColor clearColor];
		_checkMark.text = @"✓";
		_checkMark.hidden = YES;
		_checkMark.font = [UIFont boldSystemFontOfSize:18.0];
		_checkMark.textColor = [UIColor colorWithRed:50.0 / 255.0 green:79.0 / 255.0 blue:133.0 / 255.0 alpha:1.0];
		_checkMark.textAlignment = NSTextAlignmentCenter;
	}
	return _checkMark;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGRect frame = self.bounds;
	frame.origin.x = A3SITV_CHECKMARK_WIDTH;
	frame.size.width -= A3SITV_CHECKMARK_WIDTH;
	self.textLabel.frame = frame;
}

@end
