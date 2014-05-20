//
//  A3ExpenseListHistoryCell.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ExpenseListBudget;
@interface A3ExpenseListHistoryCell : UITableViewCell
- (void)setExpenseBudgetData:(ExpenseListBudget *)aBudget currencyFormatter:(NSNumberFormatter *)nFormatter;
@end
