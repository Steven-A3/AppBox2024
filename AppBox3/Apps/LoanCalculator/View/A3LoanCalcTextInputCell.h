//
//  A3LoanCalcTextInputCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3LoanCalcTextInputCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (assign, nonatomic) CGFloat textLabelOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailLabelRightConstraint;

@end
