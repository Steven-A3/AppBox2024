//
//  A3DaysCounterLocationDetailCell.m
//  AppBox3
//
//  Created by kimjeonghwan on 4/22/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterLocationDetailCell.h"

@implementation A3DaysCounterLocationDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
//    self.contentBaselineConst.constant = IS_RETINA ? 14.5 : 14;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
