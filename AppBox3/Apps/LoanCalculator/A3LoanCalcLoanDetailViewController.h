//
//  A3LoanCalcLoanDetailViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3LoanCalcContentsTableViewController.h"

@class LoanCalcData;

@protocol LoanCalcLoanDataDelegate <NSObject>

@required
- (void)didEditedLoanData:(LoanCalcData *)loanCalc;

@end

@interface A3LoanCalcLoanDetailViewController : A3LoanCalcContentsTableViewController

@property (nonatomic, assign) id<LoanCalcLoanDataDelegate> delegate;

@end
