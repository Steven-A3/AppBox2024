//
//  A3DaysCounterEventListDateCell.m
//  AppBox3
//
//  Created by dotnetguy83 on 3/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterEventListDateCell.h"

@implementation A3DaysCounterEventListDateCell

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
	[super awakeFromNib];
	
    self.titleBottomConst.constant = IS_RETINA ? 35.5 : 35;
    self.sinceBottomConst.constant = IS_RETINA ? 18.5 : 18;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
