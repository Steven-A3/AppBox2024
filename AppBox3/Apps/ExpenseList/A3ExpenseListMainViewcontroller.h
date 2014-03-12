//
//  A3ExpenseListMainViewController.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const key_currentBudgetId = @"key_topWhitePaddingView";

@class ExpenseListBudget;

@protocol A3ExpenseBudgetSettingDelegate <NSObject>

-(void)setExpenseBudgetDataFor:(ExpenseListBudget *)aBudget;

@end

@interface A3ExpenseListMainViewController : UITableViewController
//@property (nonatomic, strong) NSString *currentBudgetId;
@end
