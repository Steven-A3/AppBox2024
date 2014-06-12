//
//  A3LoanCalcMonthlyTableTitleView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 18..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcMonthlyTableTitleView.h"

@interface A3LoanCalcMonthlyTableTitleView ()
{
    UILabel *dateLB;
    UILabel *paymentLB;
    UILabel *principalLB;
    UILabel *interestLB;
    UILabel *balanceLB;
}

@end

@implementation A3LoanCalcMonthlyTableTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        dateLB = [[UILabel alloc] init];
        paymentLB = [[UILabel alloc] init];
        principalLB = [[UILabel alloc] init];
        interestLB = [[UILabel alloc] init];
        balanceLB = [[UILabel alloc] init];
        
        UIFont *font = (IS_IPAD) ? [UIFont systemFontOfSize:14]:[UIFont systemFontOfSize:10];
        UIColor *textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
        
        dateLB.font = font;
        dateLB.textColor = textColor;
        paymentLB.font = font;
        paymentLB.textColor = textColor;
        principalLB.font = font;
        principalLB.textColor = textColor;
        interestLB.font = font;
        interestLB.textColor = textColor;
        balanceLB.font = font;
        balanceLB.textColor = textColor;
        
        dateLB.textAlignment = NSTextAlignmentCenter;
        paymentLB.textAlignment = NSTextAlignmentCenter;
        principalLB.textAlignment = NSTextAlignmentCenter;
        interestLB.textAlignment = NSTextAlignmentCenter;
        balanceLB.textAlignment = NSTextAlignmentCenter;
        
        dateLB.text = NSLocalizedString(@"DATE", @"DATE");
        paymentLB.text = NSLocalizedString(@"PAYMENT", @"PAYMENT");
        principalLB.text = NSLocalizedString(@"PRINCIPAL", @"PRINCIPAL");
        interestLB.text = NSLocalizedString(@"INTEREST", @"INTEREST");
        balanceLB.text = NSLocalizedString(@"BALANCE", @"BALANCE");

        /*
        dateLB.backgroundColor = [UIColor redColor];
        paymentLB.backgroundColor = [UIColor blueColor];
        principalLB.backgroundColor = [UIColor yellowColor];
        interestLB.backgroundColor = [UIColor grayColor];
        balanceLB.backgroundColor = [UIColor greenColor];
        */
        
        [self addSubview:dateLB];
        [self addSubview:paymentLB];
        [self addSubview:principalLB];
        [self addSubview:interestLB];
        [self addSubview:balanceLB];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
    // Date 16%  Payment 21%  Principal 21%  Interest 19% Balance 23%
    
    [super layoutSubviews];
    
//    if (IS_IPHONE) {
//        
//        dateLB.frame = CGRectMake(15, 0, 51, 35);
//        paymentLB.frame = CGRectMake(15+51, 0, 63, 35);
//        principalLB.frame = CGRectMake(15+51+63, 0, 63, 35);
//        interestLB.frame = CGRectMake(15+51+63+63, 0, 58, 35);
//        balanceLB.frame = CGRectMake(15+51+63+63+58, 0, 70, 35);
//    }
//    else {
//        if (IS_LANDSCAPE) {
//            dateLB.frame = CGRectMake(28, 0, 100, 35);
//            paymentLB.frame = CGRectMake(28+100+10, 0, 140-10-10, 35);
//            principalLB.frame = CGRectMake(28+100+140+10, 0, 140-10-10, 35);
//            interestLB.frame = CGRectMake(28+100+140+140+10, 0, 140-10-10, 35);
//            balanceLB.frame = CGRectMake(28+100+140+140+140+10, 0, 156-10-10, 35);
//        }
//        else {
//            dateLB.frame = CGRectMake(28, 0, 110, 35);
//            paymentLB.frame = CGRectMake(28+110+10, 0, 150-10-10, 35);
//            principalLB.frame = CGRectMake(28+110+150+10, 0, 150-10-10, 35);
//            interestLB.frame = CGRectMake(28+110+150+150+10, 0, 150-10-10, 35);
//            balanceLB.frame = CGRectMake(28+110+150+150+150+10, 0, 180-10-10, 35);
//        }
//    }
    

    CGFloat leftInset = IS_IPHONE ? 15 : 28;
    CGFloat dateWidth = ceilf((CGRectGetWidth(self.bounds) - leftInset) * 0.16);
    CGFloat paymentWidth = ceilf((CGRectGetWidth(self.bounds) - leftInset) * 0.21);
    CGFloat principalWdith = ceilf((CGRectGetWidth(self.bounds) - leftInset) * 0.21);
    CGFloat interestWidth = ceilf((CGRectGetWidth(self.bounds) - leftInset) * 0.19);
    CGFloat balanceWidth = ceilf((CGRectGetWidth(self.bounds) - leftInset) * 0.23);
    
    dateLB.frame = CGRectMake(leftInset, 0, dateWidth, 35);
    paymentLB.frame = CGRectMake(leftInset + dateWidth, 0, paymentWidth, 35);
    principalLB.frame = CGRectMake(leftInset + dateWidth + paymentWidth, 0, principalWdith, 35);
    interestLB.frame = CGRectMake(leftInset + dateWidth + paymentWidth + principalWdith, 0, interestWidth, 35);
    balanceLB.frame = CGRectMake(leftInset + dateWidth + paymentWidth + principalWdith + interestWidth, 0, balanceWidth, 35);
}

@end
