//
//  A3LoanCalcLoanInfoCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcLoanInfoCell.h"

@interface A3LoanCalcLoanInfoCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstraint;

@end

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
	
	self.separatorHeightConstraint.constant = 1/[[UIScreen mainScreen] scale];
	[self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

}

@end
