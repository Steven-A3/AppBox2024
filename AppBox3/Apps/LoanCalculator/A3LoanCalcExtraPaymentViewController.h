//
//  A3LoanCalcExtraPaymentViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 10..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoanCalcMode.h"
#import "LoanCalcData.h"

@protocol LoanCalcExtraPaymentDelegate <NSObject>

@required
- (void)didChangedLoanCalcExtraPayment:(LoanCalcData *)loanCalc;

@end

@interface A3LoanCalcExtraPaymentViewController : UITableViewController

@property (nonatomic, weak) id<LoanCalcExtraPaymentDelegate> delegate;
@property (nonatomic, readwrite) A3LoanCalcExtraPaymentType exPaymentType;
@property (nonatomic, strong) LoanCalcData *loanCalcData;

@end
