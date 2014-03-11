//
//  A3UnitPriceHistoryCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 6..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitPriceHistoryCell.h"

@implementation A3UnitPriceHistoryCell

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

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    for (UILabel *lb in _markLBs) {
        lb.layer.cornerRadius = lb.bounds.size.width/2;
        
        lb.font = [UIFont systemFontOfSize:11];
        lb.backgroundColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
    }
    
}

@end
