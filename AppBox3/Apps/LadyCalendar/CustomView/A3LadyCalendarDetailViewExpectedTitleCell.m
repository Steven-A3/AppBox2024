//
//  A3LadyCalendarDetailViewExpectedTitleCell.m
//  AppBox3
//
//  Created by A3 on 5/8/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarDetailViewExpectedTitleCell.h"

@implementation A3LadyCalendarDetailViewExpectedTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		_titleLabel = [UILabel new];
		_titleLabel.adjustsFontSizeToFitWidth = YES;
		_titleLabel.minimumScaleFactor = 0.5;
		[self addSubview:_titleLabel];

		[_titleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
			make.baseline.equalTo(self.top).with.offset(31);
		}];

		_editButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_editButton setTitle:NSLocalizedString(@"Edit", @"Edit") forState:UIControlStateNormal];
		[self addSubview:_editButton];

		[_editButton makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(_titleLabel.right).with.offset(20);
			make.baseline.equalTo(_titleLabel.baseline);
		}];

		[self setupFont];
	}

	return self;
}

- (void)prepareForReuse {
	[self setupFont];
}

- (void)setupFont {
	_titleLabel.font = IS_IPHONE ? [UIFont boldSystemFontOfSize:17] : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

@end
