//
//  A3CurrencyTableViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyTableViewCell.h"

@implementation A3CurrencyTableViewCell

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

- (void)awakeFromNib {
	[super awakeFromNib];

	_separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 83.0, self.bounds.size.width, 1.0)];
	_separatorLineView.backgroundColor = [UIColor clearColor];
	[self addSubview:_separatorLineView];
}

@end
