//
//  A3ExpenseListHistoryViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

@class Expense;

@protocol A3ExpenseListHistoryViewControllerDelegate <NSObject>
- (void)historySelected:(Expense *)expenseObject;
@end

@interface A3ExpenseListHistoryViewController : UIViewController

@property (nonatomic, weak) id<A3ExpenseListHistoryViewControllerDelegate> delegate;
@end
