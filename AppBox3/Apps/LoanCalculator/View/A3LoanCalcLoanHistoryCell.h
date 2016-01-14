//
//  A3LoanCalcLoanHistoryCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3LoanCalcLoanHistoryCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *upLeftLb;
@property (strong, nonatomic) IBOutlet UILabel *lowLeftLb;
@property (strong, nonatomic) IBOutlet UILabel *upRightLb;
@property (strong, nonatomic) IBOutlet UILabel *lowRightLb;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLeftLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topRightLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLeftLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomRightLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLeftTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topRightTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLeftBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomRightBottomConstraint;

@end
