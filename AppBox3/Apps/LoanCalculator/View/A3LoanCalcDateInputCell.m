//
//  A3LoanCalcDateInputCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 16..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcDateInputCell.h"

@implementation A3LoanCalcDateInputCell

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
    
    CGRect frame = _picker.frame;
    frame.size.height = 216;
    _picker.frame = frame;
}

@end
