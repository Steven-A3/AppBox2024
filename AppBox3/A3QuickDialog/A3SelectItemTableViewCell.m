//
//  A3SelectItemTableViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SelectItemTableViewCell.h"
#import "A3GradientView.h"
#import "common.h"

#define SITV_TOP_GRADIENT_VIEW_TAG		30234
#define	SITV_BOTTOM_GRADIENT_VIEW_TAG	30235

@interface A3SelectItemTableViewCell ()

@end

@implementation A3SelectItemTableViewCell

- (id)initWithReuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	if (self) {
		[self.contentView addSubview:self.checkMark];
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
		_checkMark.font = [UIFont boldSystemFontOfSize:24.0];
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

- (void)setStartRow:(BOOL)startRow {
	_startRow = startRow;

	[[self viewWithTag:SITV_TOP_GRADIENT_VIEW_TAG] removeFromSuperview];

	if (!startRow) return;
	CGRect frame = self.contentView.bounds;
	frame.origin.y += 1.0;
	frame.size.height = 2.0;
	A3GradientView *gradientView = [[A3GradientView alloc] initWithFrame:frame];
	gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	gradientView.gradientColors = @[
			(__bridge id)[UIColor colorWithRed:199.0/255.0 green:200.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor,
			(__bridge id) [UIColor colorWithRed:220.0/255.0 green:221.0/255.0 blue:222.0/255.0 alpha:1.0].CGColor];
	gradientView.tag = SITV_TOP_GRADIENT_VIEW_TAG;
	[self.contentView addSubview:gradientView];
}

- (void)setEndRow:(BOOL)endRow {
	_endRow = endRow;

	[[self viewWithTag:SITV_BOTTOM_GRADIENT_VIEW_TAG] removeFromSuperview];

	if (!endRow) return;
	CGRect frame = self.contentView.bounds;
	frame.origin.y = frame.origin.y + frame.size.height - 2.0;
	frame.size.height = 2.0;
	A3GradientView *gradientView = [[A3GradientView alloc] initWithFrame:frame];
	gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	gradientView.gradientColors = @[
			(__bridge id)[UIColor colorWithRed:220./255.0 green:221.0/255.0 blue:222.0/255.0 alpha:1.0].CGColor,
			(__bridge id) [UIColor colorWithRed:213.0/255.0 green:214.0/255.0 blue:215.0/255.0 alpha:1.0].CGColor];
	gradientView.tag = SITV_BOTTOM_GRADIENT_VIEW_TAG;
	[self.contentView addSubview:gradientView];
}

@end
