//
//  A3WalletMoreTableViewCell.m
//  AppBox3
//
//  Created by A3 on 4/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletMoreTableViewCell.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3AppDelegate+appearance.h"

@interface A3WalletMoreTableViewCell ()

@property (nonatomic, strong) MASConstraint *imageViewLeftConstraint;
@property (nonatomic, strong) UIView *customSeparator;

@end

@implementation A3WalletMoreTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		_checkImageView = [UIImageView new];
		_checkImageView.tintColor = [A3AppDelegate instance].themeColor;
		[self addSubview:_checkImageView];

		_cellImageView = [UIImageView new];
		[self addSubview:_cellImageView];

		_cellTitleLabel = [UILabel new];
		_cellTitleLabel.font = A3UITableViewTextLabelFont;
		[self addSubview:_cellTitleLabel];

		_rightSideLabel = [UILabel new];
		_rightSideLabel.font = [UIFont systemFontOfSize:17];
		_rightSideLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
		[self addSubview:_rightSideLabel];

		[self setupConstraints];

		[self setupSeparator];
	}
	return self;
}

- (void)setupConstraints {

	[_checkImageView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
		make.width.equalTo(@15);
		make.centerY.equalTo(self.centerY);
	}];

	[_cellImageView makeConstraints:^(MASConstraintMaker *make) {
		_imageViewLeftConstraint = make.left.equalTo(_checkImageView.right);
		make.width.equalTo(@30);
		make.centerY.equalTo(self.centerY);
	}];

	[_cellTitleLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_cellImageView.right).with.offset(13);
		make.right.equalTo(self.contentView.right).with.offset(-20);
		make.centerY.equalTo(self.centerY);
	}];

	[_rightSideLabel makeConstraints:^(MASConstraintMaker *make) {
		_rightSideLabelConstraint = make.right.equalTo(self.contentView.right).with.offset(self.editing ? -15 : 0);
		make.centerY.equalTo(self.centerY);
	}];
}

- (void)setupSeparator {
	_customSeparator = [UIView new];
	_customSeparator.backgroundColor = A3UITableViewSeparatorColor;
	[self addSubview:_customSeparator];
	[_customSeparator makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
		make.top.equalTo(self.bottom).with.offset(-1);
		make.right.equalTo(self.right);
		make.height.equalTo(IS_RETINA? @0.5 : @1.0);
	}];
}

- (void)setShowCheckImageView:(BOOL)show {
	_showCheckImageView = show;
	[_checkImageView setHidden:!show];
	[_imageViewLeftConstraint uninstall];

	[_cellImageView makeConstraints:^(MASConstraintMaker *make) {
		if (show) {
			_imageViewLeftConstraint = make.left.equalTo(_checkImageView.right).with.offset(10);
		} else {
			_imageViewLeftConstraint = make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
		}
	}];

	[self layoutIfNeeded];
}

- (void)setShowCheckMark:(BOOL)showCheckMark {
	_checkImageView.image = showCheckMark ? [[UIImage imageNamed:@"check_02"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : nil;
}

- (void)setEditing:(BOOL)editing {
	[super setEditing:editing];
	_rightSideLabelConstraint.with.offset(editing ? -15 : 0);
	[self layoutIfNeeded];
}

@end
