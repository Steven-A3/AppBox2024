//
//  A3LoanCalcSelectFrequencyViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 9..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoanCalcMode.h"

@protocol LoanCalcSelectFrequencyDelegate <NSObject>

@required
- (void)didSelectLoanCalcFrequency:(A3LoanCalcFrequencyType) frequencyType;

@end

@interface A3LoanCalcSelectFrequencyViewController : UITableViewController

@property (nonatomic, assign) id<LoanCalcSelectFrequencyDelegate> delegate;
@property (readwrite) A3LoanCalcFrequencyType currentFrequency;

@end
