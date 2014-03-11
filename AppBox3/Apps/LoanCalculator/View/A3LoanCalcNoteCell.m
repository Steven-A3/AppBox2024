//
//  A3LoanCalcNoteCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 10..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcNoteCell.h"

@implementation A3LoanCalcNoteCell

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
    
    if (selected) {
        [_textField becomeFirstResponder];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

@end
