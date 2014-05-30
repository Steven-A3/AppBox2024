//
//  A3LoanCalcLoanGraphCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3TripleCircleView;

@interface A3LoanCalcLoanGraphCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *upLabel;
@property (strong, nonatomic) IBOutlet UIView *bgLineView;
@property (strong, nonatomic) IBOutlet UIView *redLineView;
@property (strong, nonatomic) IBOutlet UILabel *lowLabel;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *monthlyButton;
@property (strong, nonatomic) IBOutlet UIButton *totalButton;
@property (strong, nonatomic) A3TripleCircleView *circleView;

- (void)adjustSubviewsFontSize;
- (void)adjustSubviewsPosition;
@end
