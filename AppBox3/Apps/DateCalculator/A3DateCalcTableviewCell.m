//
//  A3DateCalcTableviewCell.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 28..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcTableviewCell.h"
#import "A3UIDevice.h"

@implementation A3DateCalcTableviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (IS_IPAD) {
//        CGRect rect = self.textLabel.frame;
//        rect.origin.x = 28.0;
//        self.textLabel.frame = rect;
//        self.textLabel.contentMode = UIViewContentModeScaleAspectFit;
        
        UIEdgeInsets inset = self.separatorInset;
        inset.left = 15.0;
        self.separatorInset = inset;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
