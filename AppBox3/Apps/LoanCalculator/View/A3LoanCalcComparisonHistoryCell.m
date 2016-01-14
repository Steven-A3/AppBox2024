//
//  A3LoanCalcComparisonHistoryCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcComparisonHistoryCell.h"

@implementation A3LoanCalcComparisonHistoryCell

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
    
    for (UILabel *markLB in _markLbs) {
        markLB.layer.cornerRadius = markLB.bounds.size.height/2;
    }
	
	if ([[UIScreen mainScreen] scale] > 2) {
		FNLOG(@"[[UIScreen mainScreen] scale] > 2");
		_leadingConstraint.constant = 12;
	}
}

@end
