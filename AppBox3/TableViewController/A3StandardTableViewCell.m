//
//  A3StandardTableViewCell.m
//  AppBox3
//
//  Created by A3 on 3/5/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3StandardTableViewCell.h"

@implementation A3StandardTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.textLabel.font = [UIFont systemFontOfSize:17];
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

	if (![self isEditing]) {
		CGRect frame = self.textLabel.frame;
		frame.origin.x = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
		if (self.imageView.bounds.size.width) {
			frame.origin.x += self.imageView.bounds.size.width;
			if (IS_IPHONE) frame.origin.x += 13.0;
		}
		self.textLabel.frame = frame;
	} else {
		CGFloat originX = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
		if (self.imageView.bounds.size.width) {
			CGRect frame = self.imageView.frame;
			frame.origin.x = originX;
			self.imageView.frame = frame;
			originX += self.imageView.bounds.size.width + 13.0;
		}
		CGRect frame = self.textLabel.frame;
		frame.origin.x = originX;
		self.textLabel.frame = frame;
	}
	CGPoint center = self.textLabel.center;
	center.y = self.frame.size.height / 2.0;
	self.textLabel.center = center;
}

@end
