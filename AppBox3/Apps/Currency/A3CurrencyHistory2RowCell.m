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
		_L1 = [self addUILabelWithColor:[UIColor blackColor]];
		_L2 = [self addUILabelWithColor:[UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0]];

		_R1 = [self addUILabelWithColor:[UIColor colorWithRed:142.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1.0]];
		_R2 = [self addUILabelWithColor:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]];

		[self useDynamicType];
		[self doAutolayout];
    }
    return self;
}

- (void)doAutolayout {
	[self addConstraintLeft:_L1 right:_R1 centerY:2.0 * (1.0 / 4.0)];
	[self addConstraintLeft:_L2 right:_R2 centerY:1.0];
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
	self.L1.font = [UIFont systemFontOfSize:15];
	self.L2.font = [UIFont systemFontOfSize:13];
	self.R1.font = [UIFont systemFontOfSize:12];
	self.R2.font = [UIFont systemFontOfSize:13];
}

@end
