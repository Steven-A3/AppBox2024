//
//  A3WalletVideoItemTitleView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 29..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletVideoItemTitleView.h"

@implementation A3WalletVideoItemTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	if (IS_IPHONE) {
		self.timeLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
	}

	if (IS_RETINA) {
		CGRect frame = self.frame;
		frame.size.height = 73.5;
		self.frame = frame;
	}
	[self addSubview:self.favoriteButton];

	[_titleTextField makeConstraints:^(MASConstraintMaker *make) {
		make.baseline.equalTo(self.top).with.offset(39);
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
		make.right.equalTo(_favoriteButton.left).with.offset(5);
	}];
	[_timeLabel makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_titleTextField.bottom);
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
	}];
	[_favoriteButton makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@40);
		make.height.equalTo(@40);
		make.right.equalTo(self.right).with.offset(-5);
		make.centerY.equalTo(_titleTextField.centerY);
	}];
	[_durationLabel makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_timeLabel.bottom).with.offset(10);
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
	}];
	[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_durationLabel.bottom);
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
	}];

	[self setupFonts];
}

- (UIButton *)favoriteButton
{
	if (!_favoriteButton) {
		_favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		[_favoriteButton setContentMode:UIViewContentModeRight];
		[_favoriteButton setImage:[UIImage imageNamed:@"star02"] forState:UIControlStateNormal];
		[_favoriteButton setImage:[UIImage imageNamed:@"star02_on"] forState:UIControlStateSelected];
	}

	return _favoriteButton;
}

- (void)setupFonts {
	_titleTextField.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] : [UIFont boldSystemFontOfSize:17.0];
	_timeLabel.font = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] : [UIFont systemFontOfSize:13.0];
	_durationLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	_dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

@end
