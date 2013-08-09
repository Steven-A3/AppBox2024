//
//  A3CurrencyHistory2RowCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyHistory2RowCell.h"

@implementation A3CurrencyHistory2RowCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[self useDynamicType];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
	[super prepareForReuse];

	[self useDynamicType];
}

- (void)useDynamicType {
	self.L1.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	self.L2.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	self.R1.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
	self.R2.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

@end
