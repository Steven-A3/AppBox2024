//
//  A3LoanCalcLoanInfo3Cell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 17..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3LoanCalcLoanInfo3Cell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (strong, nonatomic) IBOutlet UILabel *upSecondTitleLB;
@property (strong, nonatomic) IBOutlet UILabel *amountValueLB;
@property (strong, nonatomic) IBOutlet UILabel *upSecondValueLB;
@property (strong, nonatomic) NSArray *downTitleLBs;
@property (strong, nonatomic) NSArray *downValueLBs;
@property (nonatomic, readwrite) NSUInteger valueCount;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *hori1PxLines;

+ (float)heightForValueCount:(NSUInteger) count;

@end
