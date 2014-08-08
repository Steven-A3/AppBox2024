//
//  A3ExpenseListAddBudgetViewController.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3ExpenseBudgetSettingDelegate;
@class ExpenseListBudget;
@interface A3ExpenseListAddBudgetViewController : UITableViewController
@property (nonatomic, weak) id<A3ExpenseBudgetSettingDelegate> delegate;

- (id)initWithStyle:(UITableViewStyle)style withExpenseListBudget:(ExpenseListBudget *)budget;
- (void)showKeyboard;
@end
