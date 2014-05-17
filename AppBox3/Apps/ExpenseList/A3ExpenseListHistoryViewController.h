//
//  A3ExpenseListHistoryViewController.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExpenseListBudget;

@protocol A3ExpenseListHistoryDelegate <NSObject>
-(void)didSelectBudgetHistory:(ExpenseListBudget *)aBudget;
-(void)didDismissExpenseHistoryViewController;
@end


@protocol A3ExpenseBudgetSettingDelegate;

@interface A3ExpenseListHistoryViewController : UITableViewController

@property (nonatomic, assign) id<A3ExpenseListHistoryDelegate> delegate;

@end
