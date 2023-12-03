//
//  A3LoanCalcMonthlyTableTitleView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 18..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcMonthlyTableTitleView.h"
#import "A3UIDevice.h"

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
        
        dateLB.text = NSLocalizedString(@"LoanCalc_DATE", @"DATE");
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
