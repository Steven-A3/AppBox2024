//
//  A3LoanCalcLoanInfoCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3LoanCalcLoanInfoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *markLabel;
@property (strong, nonatomic) IBOutlet UILabel *paymentLabel;
@property (strong, nonatomic) IBOutlet UILabel *principalLabel;
@property (strong, nonatomic) IBOutlet UILabel *interestLabel;
@property (strong, nonatomic) IBOutlet UILabel *termLabel;
@property (strong, nonatomic) IBOutlet UILabel *frequencyLabel;
@property (strong, nonatomic) IBOutlet UILabel *amountLabel;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *hori1PxLines;

@end
