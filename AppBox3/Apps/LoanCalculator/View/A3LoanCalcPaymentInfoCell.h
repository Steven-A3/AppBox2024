//
//  A3LoanCalcPaymentInfoCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3LoanCalcPaymentInfoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dateLb;
@property (strong, nonatomic) IBOutlet UILabel *paymentLb;
@property (strong, nonatomic) IBOutlet UILabel *principalLb;
@property (strong, nonatomic) IBOutlet UILabel *interestLb;
@property (strong, nonatomic) IBOutlet UILabel *balanceLb;

@end
