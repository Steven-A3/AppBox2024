//
//  A3LoanCalcLoanHistoryCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcLoanHistoryCell.h"

@implementation A3LoanCalcLoanHistoryCell

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

- (void)awakeFromNib {
    [super awakeFromNib];

    CGFloat contentOffset;
    if (IS_IPHONE) {
        contentOffset = [[UIScreen mainScreen] scale] > 2 ? 20 : 15;
    } else {
        contentOffset = 28;
    }
    _topLeftLabelLeadingConstraint.constant = contentOffset;
    _bottomLeftLabelLeadingConstraint.constant = contentOffset;
    _topRightLabelTrailingConstraint.constant = contentOffset;
    _bottomRightLabelTrailingConstraint.constant = contentOffset;
}

@end
