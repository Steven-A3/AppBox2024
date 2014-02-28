//
//  A3DateCalcFooterViewCell.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcFooterViewCell.h"
#import "A3DateCalcFooterView.h"

@implementation A3DateCalcFooterViewCell

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

-(void)setFooterView:(A3DateCalcFooterView *)footerView
{
    _footerView = footerView;
    self.contentView.backgroundColor = [UIColor clearColor];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self addSubview:_footerView];
    UIEdgeInsets inset = self.separatorInset;

    inset.left = self.bounds.size.width;
    inset.right = 0.0;
    self.separatorInset = inset;
}

@end
