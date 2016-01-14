//
//  A3LoanCalcCompareGraphCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3TripleCircleView.h"

@interface A3LoanCalcCompareGraphCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *markA_Label;
@property (strong, nonatomic) IBOutlet UILabel *markB_Label;
@property (strong, nonatomic) IBOutlet UILabel *left_A_Label;
@property (strong, nonatomic) IBOutlet UILabel *right_A_Label;
@property (strong, nonatomic) IBOutlet UILabel *left_B_Label;
@property (strong, nonatomic) IBOutlet UILabel *right_B_Label;
@property (strong, nonatomic) IBOutlet UIView *red_A_Line;
@property (strong, nonatomic) IBOutlet UIView *red_B_Line;
@property (strong, nonatomic) IBOutlet UIView *bg_A_Line;
@property (strong, nonatomic) IBOutlet UIView *bg_B_Line;
@property (strong, nonatomic) A3TripleCircleView *circleA_View;
@property (strong, nonatomic) A3TripleCircleView *circleB_View;
@property (weak, nonatomic) IBOutlet UILabel *totalInterestLB;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLB;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *redLineARightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *redLineBRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLabelACenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLabelBCenterXConstraint;

@property (readwrite) float leftA_X;
@property (readwrite) float leftB_X;
@property (readwrite) float rightA_X;
@property (readwrite) float rightB_X;

- (void)adjustSubviewsFontSize;
- (void)adjustABMarkPosition;
- (void)adjustABMarkPositionForTotalAmountA:(NSNumber *)totalAmountA totalAmountB:(NSNumber *)totalAmountB;
@end
