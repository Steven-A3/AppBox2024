//
//  A3WalletMoreTableViewCell.m
//  AppBox3
//
//  Created by A3 on 4/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletMoreTableViewCell.h"
#import "UITableViewController+standardDimension.h"

@interface A3WalletMoreTableViewCell ()

@property (nonatomic, strong) MASConstraint *checkButtonWidthConstraint;

@end

@implementation A3WalletMoreTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_checkButton setImage:[UIImage imageNamed:@"check_02"] forState:UIControlStateNormal];
		[self addSubview:_checkButton];

		_cellImageView = [UIImageView new];
		[self addSubview:_cellImageView];

		_cellTitleLabel = [UILabel new];
		_cellTitleLabel.font = A3UITableViewTextLabelFont;
		[self addSubview:_cellTitleLabel];

		[self setupConstraints];

		[self setupSeparator];
	}
	return self;
}

- (void)setupConstraints {

	[_checkButton makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
		make.centerY.equalTo(self.centerY);
		make.height.equalTo(@40);
		_checkButtonWidthConstraint = make.width.equalTo(_showCheckButton ? @40 : @0);
	}];

	[_cellImageView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_checkButton.right);
		make.centerY.equalTo(self.centerY);
	}];

	[_cellTitleLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_cellImageView.right).with.offset(13);
		make.centerY.equalTo(self.centerY);
	}];
}

- (void)setupSeparator {
	UIView *customSeparator = [UIView new];
	customSeparator.backgroundColor = A3UITableViewSeparatorColor;
	[self addSubview:customSeparator];
	[customSeparator makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
			make.top.equalTo(self.bottom).with.offset(-1);
			make.right.equalTo(self.right);
			make.height.equalTo(IS_RETINA? @0.5 : @1.0);
		}];
}

- (void)setShowCheckButton:(BOOL)showCheckButton {
	_showCheckButton = showCheckButton;
	[_checkButtonWidthConstraint uninstall];
	[_checkButton makeConstraints:^(MASConstraintMaker *make) {
		_checkButtonWidthConstraint = make.width.equalTo(_showCheckButton ? @40 : @0);
	}];

	[self layoutIfNeeded];
}

@end
