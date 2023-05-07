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
    
//    float cellHeight = 42.0;
//
//    if (IS_IPHONE) {
//        _dateLb.frame = CGRectMake(15, 1, 51, cellHeight);
//        _paymentLb.frame = CGRectMake(15+51, 1, 63-5, cellHeight);
//        _principalLb.frame = CGRectMake(15+51+63, 1, 63-5, cellHeight);
//        _interestLb.frame = CGRectMake(15+51+63+63, 1, 58-5, cellHeight);
//        _balanceLb.frame = CGRectMake(15+51+63+63+58, 1, 70-5, cellHeight);
//    }
//    else {
//        if (IS_LANDSCAPE) {
//            _dateLb.frame = CGRectMake(28, 1, 100, cellHeight);
//            _paymentLb.frame = CGRectMake(28+100+10, 1, 140-10-10, cellHeight);
//            _principalLb.frame = CGRectMake(28+100+140+10, 1, 140-10-10, cellHeight);
//            _interestLb.frame = CGRectMake(28+100+140+140+10, 1, 140-10-10, cellHeight);
//            _balanceLb.frame = CGRectMake(28+100+140+140+140+10, 1, 156-10-10, cellHeight);
//        }
//        else {
//            _dateLb.frame = CGRectMake(28, 1, 110, cellHeight);
//            _paymentLb.frame = CGRectMake(28+110+10, 1, 150-10-10, cellHeight);
//            _principalLb.frame = CGRectMake(28+110+150+10, 1, 150-10-10, cellHeight);
//            _interestLb.frame = CGRectMake(28+110+150+150+10, 1, 150-10-10, cellHeight);
//            _balanceLb.frame = CGRectMake(28+110+150+150+150+10, 1, 180-10-10, cellHeight);
//        }
//    }
    
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
