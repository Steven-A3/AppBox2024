//
//  A3MoreTableViewCell.m
//  AppBox3
//
//  Created by A3 on 4/10/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3MoreTableViewCell.h"
#import "UIViewController+tableViewStandardDimension.h"

@implementation A3MoreTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		_cellImageView = [UIImageView new];
		[self addSubview:_cellImageView];

		CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
		[_cellImageView makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(leading);
			make.centerY.equalTo(self.centerY);
		}];
		_cellTitleLabel = [UILabel new];
		_cellTitleLabel.font = A3UITableViewTextLabelFont;
		[self addSubview:_cellTitleLabel];

		[_cellTitleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self->_cellImageView.right).with.offset(13);
			make.centerY.equalTo(self.centerY);
		}];

		UIView *customSeparator = [UIView new];
		customSeparator.backgroundColor = A3UITableViewSeparatorColor;
		[self addSubview:customSeparator];
		[customSeparator makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(leading);
			make.top.equalTo(self.bottom).with.offset(-1);
			make.right.equalTo(self.right);
			make.height.equalTo(IS_RETINA? @0.5 : @1.0);
		}];
    }
    return self;
}

@end
