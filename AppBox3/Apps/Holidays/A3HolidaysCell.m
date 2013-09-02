//
//  A3HolidaysCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysCell.h"
#import "UITableViewCell+accessory.h"
#import "common.h"
#import "A3UIDevice.h"

@implementation A3HolidaysCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// Initialization code

		_titleLabel = [UILabel new];
		_titleLabel.textColor = [UIColor whiteColor];
		[self addSubview:_titleLabel];

		[_titleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
			make.centerY.equalTo(self.centerY).with.offset(-10);
		}];

		_dateLabel = [UILabel new];
		_dateLabel.textColor = [UIColor whiteColor];
		[self addSubview:_dateLabel];

		[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(IS_IPHONE ? 15 : 28);
			make.centerY.equalTo(self.centerY).with.offset(10);
		}];

		_publicMark = [self createAddPublicMarkToSelf];

		[_publicMark makeConstraints:^(MASConstraintMaker *make) {
			make.width.equalTo(@18);
			make.height.equalTo(@18);
			make.centerY.equalTo(self.centerY).with.offset(10);
			make.left.equalTo(_dateLabel.right).with.offset(2);
		}];

		_lunarDateLabel = [UILabel new];
		_lunarDateLabel.textAlignment = NSTextAlignmentRight;
		_lunarDateLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
		[self addSubview:_lunarDateLabel];

		[_lunarDateLabel makeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.right).with.offset(IS_IPHONE ? -15 : -28);
			make.baseline.equalTo(_dateLabel.baseline);
		}];

		_lunarImageView = [UIImageView new];
		_lunarImageView.image = [[UIImage imageNamed:@"lunar_stroke"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		_lunarImageView.tintColor = [UIColor colorWithWhite:1.0 alpha:0.7];
		[self addSubview:_lunarImageView];

		[_lunarImageView makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(_lunarDateLabel.centerY);
			make.right.equalTo(_lunarDateLabel.left).with.offset(-10);
		}];

		self.backgroundColor = [UIColor clearColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textLabel.textColor = [UIColor whiteColor];

		[self assignFontsToLabels];
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
	[super prepareForReuse];

	FNLOG();
	[_publicMark setHidden:YES];
	[self assignFontsToLabels];
}

- (void)assignFontsToLabels {
	_titleLabel.textColor = [UIColor whiteColor];
	_dateLabel.textColor = [UIColor whiteColor];
	_lunarImageView.tintColor = [UIColor colorWithWhite:1.0 alpha:0.7];
	_lunarDateLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
	_publicMark.layer.borderColor = [UIColor whiteColor].CGColor;
	UILabel *label = _publicMark.subviews[0];
	label.textColor = [UIColor whiteColor];

	_titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	_dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	_lunarDateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

	[_lunarImageView setHidden:YES];
	[_lunarDateLabel setHidden:YES];
}

@end
