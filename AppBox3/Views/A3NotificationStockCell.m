//
//  A3NotificationStockCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/14/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3NotificationStockCell.h"
#import "A3HouseArrowView.h"

@implementation A3NotificationStockCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		CGFloat width = CGRectGetWidth(self.bounds);
		CGFloat offset = 10.0f;
		CGFloat chartWidth = (width - offset * 2.0f) / 2.0f;
		CGFloat chartHeight = 60.0f;
		_leftChart = [[A3HouseArrowView alloc] initWithFrame:CGRectMake(offset, offset, chartWidth, chartHeight)];
		[self addSubview:_leftChart];

		_rightChart = [[A3HouseArrowView alloc] initWithFrame:CGRectMake(offset + chartWidth, offset, chartWidth, chartHeight)];
		[self addSubview:_rightChart];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
