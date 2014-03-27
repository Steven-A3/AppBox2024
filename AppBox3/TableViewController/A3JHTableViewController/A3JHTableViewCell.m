//
//  A3JHTableViewCell.m
//  AppBox3
//
//  Created by A3 on 11/2/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3JHTableViewCell.h"
#import "A3UIDevice.h"

@implementation A3JHTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _leftSeparatorInset = IS_IPHONE ? 15 : 28;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGRect frame = self.textLabel.frame;
	frame.origin.x = _leftSeparatorInset;
	self.textLabel.frame = frame;
}


@end
