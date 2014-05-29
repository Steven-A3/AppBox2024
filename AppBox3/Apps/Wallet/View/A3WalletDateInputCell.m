//
//  A3WalletDateInputCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletDateInputCell.h"

@implementation A3WalletDateInputCell

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
    
    CGRect frame = _datePicker.frame;
    frame.size.height = 216;
    frame.size.width = 320;
    _datePicker.frame = frame;
    CGPoint center = _datePicker.center;
    center.x = self.center.x;
    _datePicker.center = center;
}

@end
