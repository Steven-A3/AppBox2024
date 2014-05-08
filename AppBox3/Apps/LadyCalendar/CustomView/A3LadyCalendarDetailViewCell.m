//
//  A3LadyCalendarDetailViewCell.m
//  AppBox3
//
//  Created by A3 on 5/8/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarDetailViewCell.h"
#import "UIColor+A3Addition.h"

@implementation A3LadyCalendarDetailViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		_titleLabel = [UILabel new];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.adjustsFontSizeToFitWidth = YES;
		_titleLabel.minimumScaleFactor = 0.5;
		[self addSubview:_titleLabel];

		[_titleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
			make.baseline.equalTo(self.top).with.offset(31);
		}];

		_subTitleLabel = [UILabel new];
		_subTitleLabel.textColor = [UIColor colorWithRGBRed:159 green:159 blue:159 alpha:255];
		_subTitleLabel.adjustsFontSizeToFitWidth = YES;
		_subTitleLabel.minimumScaleFactor = 0.5;
		[self addSubview:_subTitleLabel];

		[_subTitleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
			make.right.equalTo(self.right).with.offset(IS_IPHONE ? -15 : -28);
			make.baseline.equalTo(self.top).with.offset(51);
		}];

		[self setupFont];
	}

	return self;
}

- (void)setupFont {
	_titleLabel.font = [UIFont systemFontOfSize:14];
	_subTitleLabel.font = [UIFont systemFontOfSize:17];
}

@end
