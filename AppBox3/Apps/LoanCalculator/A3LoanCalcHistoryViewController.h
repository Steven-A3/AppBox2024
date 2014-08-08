//
//  A3LoanCalcHistoryViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoanCalcHistory;
@class LoanCalcComparisonHistory;

@protocol LoanCalcHistoryViewControllerDelegate <NSObject>

@required
- (void)historyViewController:(UIViewController *)viewController selectLoanCalcHistory:(LoanCalcHistory *)history;
- (void)historyViewController:(UIViewController *)viewController selectLoanCalcComparisonHistory:(LoanCalcComparisonHistory *)comparison;
- (void)historyViewControllerDismissed:(UIViewController *)viewController;
@end

@interface A3LoanCalcHistoryViewController : UITableViewController

@property (nonatomic, weak) id<LoanCalcHistoryViewControllerDelegate> delegate;
@property (readwrite) BOOL isComparisonMode;

@end
