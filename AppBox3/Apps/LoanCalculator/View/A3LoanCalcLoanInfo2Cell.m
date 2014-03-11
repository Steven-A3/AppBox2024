//
//  A3LoanCalcLoanInfo2Cell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcLoanInfo2Cell.h"
#import "A3TripleCircleView.h"

@implementation A3LoanCalcLoanInfo2Cell

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
    
    A3TripleCircleView *circleView = [A3TripleCircleView new];
	circleView.frame = CGRectMake(0, 0, 31, 31);
	[_lineView addSubview:circleView];
    circleView.center = CGPointMake(_lineView.bounds.size.width, _lineView.bounds.size.height/2);
    circleView.centerColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
}

@end
