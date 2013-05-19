//
//  A3ExpenseListAddBudgetViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "QuickDialogController.h"
#import "A3QuickDialogContainerController.h"
#import "A3AppViewController.h"

@class Expense;

@interface A3ExpenseListAddBudgetViewController : A3QuickDialogContainerController
@property (nonatomic, weak) Expense *expenseObject;

- (id)initWithObject:(Expense *)expense;
@end
