//
//  A3TranslatorFavoriteCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorFavoriteCell.h"
#import "A3UIDevice.h"

@implementation A3TranslatorFavoriteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
		self.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
		self.detailTextLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];

		// Initialization code
		_dateLabel = [UILabel new];
		_dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
		_dateLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];
		_dateLabel.textAlignment = NSTextAlignmentRight;
		[self.contentView addSubview:_dateLabel];

		[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(self.contentView.right);
			if (IS_IPAD) {
				make.centerY.equalTo(self.contentView.centerY);
			} else {
				make.top.equalTo(self.contentView.top).with.offset(6);
			}
		}];
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
