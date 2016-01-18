//
//  A3DaysCounterRepeatCustomCell.m
//  AppBox3
//
//  Created by dotnetguy83 on 3/27/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterRepeatCustomCell.h"

@interface A3DaysCounterRepeatCustomCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;

@end

@implementation A3DaysCounterRepeatCustomCell

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
	CGFloat leadingConstant = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	_titleLabelLeadingConstraint.constant = leadingConstant;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
