//
//  A3TranslatorListCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/21/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorListCell.h"
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
			make.right.equalTo(self.contentView.right).with.offset(-32);
			make.centerY.equalTo(self.contentView.centerY).with.offset(1.5);
		}];
		[self setupFont];
    }
    return self;
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
