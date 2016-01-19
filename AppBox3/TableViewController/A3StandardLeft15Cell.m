//
//  A3StandardLeft15Cell.m
//  AppBox3
//
//  Created by A3 on 3/9/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3StandardLeft15Cell.h"

@implementation A3StandardLeft15Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
	frame.origin.x = ([[UIScreen mainScreen] scale] > 2 ? 20 : 15);
	self.textLabel.frame = frame;
}

@end
