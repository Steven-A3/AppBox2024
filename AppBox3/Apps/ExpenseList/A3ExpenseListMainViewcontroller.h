//
//  A3ExpenseListMainViewController.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATSDragToReorderTableViewController.h"

extern NSString *const A3ExpenseListCurrentBudgetID;
extern NSString *const A3ExpenseListCurrencyCode;
extern NSString *const A3NotificationExpenseListCurrencyCodeChanged;

@class ExpenseListBudget;

@protocol A3ExpenseBudgetSettingDelegate <NSObject>

-(void)setExpenseBudgetDataFor:(ExpenseListBudget *)aBudget;

@end

@interface A3ExpenseListMainViewController : ATSDragToReorderTableViewController
- (NSString *)defaultCurrencyCode;
@end
