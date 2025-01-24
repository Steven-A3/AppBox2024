//
//  A3TranslatorListCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/21/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorListCell.h"
#import "A3UIDevice.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UIDevice.h"

@implementation A3TranslatorListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		_dateLabel = [UILabel new];
		_dateLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];
		_dateLabel.textAlignment = NSTextAlignmentRight;
		[self.contentView addSubview:_dateLabel];

		[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.contentView.right);
			make.centerY.equalTo(self.contentView.centerY).with.offset(1.5);
		}];
		[self setupFont];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	if (IS_IPAD) {
		CGRect frame = self.imageView.frame;
		frame.origin.x = A3UITableViewCellLeftOffset_iPAD_28;
		self.imageView.frame = frame;

		frame = self.textLabel.frame;
		frame.origin.x += 10;
		self.textLabel.frame = frame;
	}
}

- (void)setupFont {
	self.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	_dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}

- (void)prepareForReuse {
	[super prepareForReuse];

	[self setupFont];
	[self layoutIfNeeded];
}

@end
