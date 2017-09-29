//
//  A3LadyCalendarDetailViewCell.m
//  AppBox3
//
//  Created by A3 on 5/8/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarDetailViewCell.h"
#import "UIColor+A3Addition.h"

@interface A3LadyCalendarDetailViewCell ()

@property (nonatomic, strong) UIView *bottomSeparator;

@end

@implementation A3LadyCalendarDetailViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		_titleLabel = [UILabel new];
		_titleLabel.adjustsFontSizeToFitWidth = YES;
		_titleLabel.minimumScaleFactor = 0.5;
		[self addSubview:_titleLabel];

		CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
		[_titleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(leading);
			make.baseline.equalTo(self.top).with.offset(31);
		}];

		_subTitleLabel = [UILabel new];
		_subTitleLabel.adjustsFontSizeToFitWidth = YES;
		_subTitleLabel.minimumScaleFactor = 0.5;
		[self addSubview:_subTitleLabel];

		[_subTitleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(leading);
			make.right.equalTo(self.right).with.offset(-leading);
			make.baseline.equalTo(self.top).with.offset(51);
		}];

		_bottomSeparator = [UIView new];
		_bottomSeparator.backgroundColor = [UIColor colorWithRGBRed:200 green:200 blue:200 alpha:255];
		[self addSubview:_bottomSeparator];

		[_bottomSeparator makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(leading);
			make.right.equalTo(self.right);
			make.bottom.equalTo(self.bottom);
			make.height.equalTo(IS_RETINA ? @0.5 : @1.0);
		}];

		[self setupFont];
	}

	return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
	[self setupFont];
}

- (void)setupFont {
	_titleLabel.font = [UIFont systemFontOfSize:14];
	_subTitleLabel.font = [UIFont systemFontOfSize:17];
	_titleLabel.textColor = [UIColor blackColor];
	_subTitleLabel.textColor = [UIColor colorWithRGBRed:159 green:159 blue:159 alpha:255];
}

@end
