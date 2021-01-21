//
//  A3LadyCalendarDetailViewTitleCell.m
//  AppBox3
//
//  Created by A3 on 5/8/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarDetailViewTitleCell.h"

@implementation A3LadyCalendarDetailViewTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		_titleLabel = [UILabel new];
		_titleLabel.adjustsFontSizeToFitWidth = YES;
		_titleLabel.minimumScaleFactor = 0.5;
		[self.contentView addSubview:_titleLabel];

		CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
		[_titleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(leading);
			make.baseline.equalTo(self.top).with.offset(31);
		}];

		_subTitleLabel = [UILabel new];
		_subTitleLabel.adjustsFontSizeToFitWidth = YES;
		_subTitleLabel.minimumScaleFactor = 0.5;
		[self.contentView addSubview:_subTitleLabel];

		[_subTitleLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(leading);
			make.right.equalTo(self.right).with.offset(-leading);
			make.baseline.equalTo(self.top).with.offset(51);
		}];

		_editButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_editButton setTitle:NSLocalizedString(@"Edit", @"Edit") forState:UIControlStateNormal];
		[self.contentView addSubview:_editButton];

		[_editButton makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.titleLabel.right).with.offset(8);
			make.baseline.equalTo(self.titleLabel.baseline);
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
	if ([[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] isEqualToString:@"de"]) {
		_titleLabel.font = IS_IPHONE ? [UIFont boldSystemFontOfSize:16] : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
	} else {
		_titleLabel.font = IS_IPHONE ? [UIFont boldSystemFontOfSize:17] : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
	}
	_subTitleLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:13] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

@end
