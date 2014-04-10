//
//  A3DaysCounterEventListNameCell.m
//  AppBox3
//
//  Created by dotnetguy83 on 3/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterEventListNameCell.h"

@implementation A3DaysCounterEventListNameCell

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
    self.titleBottomConst.constant = IS_RETINA ? 37.5 : 37;
    self.sinceBottomConst.constant = IS_RETINA ? 20.5 : 20;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
