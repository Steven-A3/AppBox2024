//
//  A3LoanCalcLoanInfoCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcLoanInfoCell.h"

@implementation A3LoanCalcLoanInfoCell

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
    
    _markLabel.layer.masksToBounds = YES;
    _markLabel.layer.cornerRadius = _markLabel.bounds.size.height/2;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (IS_RETINA) {
        for (UIView *line in _hori1PxLines) {
            CGRect rect = line.frame;
            rect.size.height = 0.5f;
            line.frame = rect;
        }
    }
}

@end
