//
//  A3LoanCalcPaymentInfoCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcPaymentInfoCell.h"
#import "A3UIDevice.h"

@implementation A3LoanCalcPaymentInfoCell

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
    
    UIFont *font = (IS_IPAD) ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]:[UIFont systemFontOfSize:11];
    UIColor *textColor = [UIColor blackColor];
    
    
    _dateLb.font = font;
    _dateLb.textColor = textColor;
    _paymentLb.font = font;
    _paymentLb.textColor = textColor;
    _principalLb.font = font;
    _principalLb.textColor = textColor;
    _interestLb.font = font;
    _interestLb.textColor = textColor;
    _balanceLb.font = font;
    _balanceLb.textColor = textColor;
    
    _dateLb.minimumScaleFactor = 0.8f;
    _paymentLb.minimumScaleFactor = 0.8f;
    _principalLb.minimumScaleFactor = 0.8f;
    _interestLb.minimumScaleFactor = 0.8f;
    _balanceLb.minimumScaleFactor = 0.8f;

    _dateLb.backgroundColor = [UIColor clearColor];
    _paymentLb.backgroundColor = [UIColor clearColor];
    _principalLb.backgroundColor = [UIColor clearColor];
    _interestLb.backgroundColor = [UIColor clearColor];
    _balanceLb.backgroundColor = [UIColor clearColor];
    
//    _dateLb.textAlignment = NSTextAlignmentLeft;
//    _paymentLb.textAlignment = NSTextAlignmentRight;
//    _principalLb.textAlignment = NSTextAlignmentRight;
//    _interestLb.textAlignment = NSTextAlignmentRight;
//    _balanceLb.textAlignment = NSTextAlignmentRight;
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Date 16%  Payment 21%  Principal 21%  Interest 19% Balance 23%
    float cellHeight = 42.0;
    
    CGFloat leftInset = IS_IPHONE ? 15 : 28;
    CGFloat dateWidth = ceilf((CGRectGetWidth(self.bounds) - leftInset) * 0.16);
    CGFloat paymentWidth = ceilf((CGRectGetWidth(self.bounds) - leftInset) * 0.21);
    CGFloat principalWdith = ceilf((CGRectGetWidth(self.bounds) - leftInset) * 0.21);
    CGFloat interestWidth = ceilf((CGRectGetWidth(self.bounds) - leftInset) * 0.19);
    CGFloat balanceWidth = ceilf((CGRectGetWidth(self.bounds) - leftInset) * 0.23);
    
    _dateLb.frame = CGRectMake(leftInset, 1, dateWidth, cellHeight);
    _paymentLb.frame = CGRectMake(leftInset + dateWidth, 1, paymentWidth, cellHeight);
    _principalLb.frame = CGRectMake(leftInset + dateWidth + paymentWidth, 1, principalWdith, cellHeight);
    _interestLb.frame = CGRectMake(leftInset + dateWidth + paymentWidth + principalWdith, 1, interestWidth, cellHeight);
    _balanceLb.frame = CGRectMake(leftInset + dateWidth + paymentWidth + principalWdith + interestWidth, 1, balanceWidth, cellHeight);
}

@end
