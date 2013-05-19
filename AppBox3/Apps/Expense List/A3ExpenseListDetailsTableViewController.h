//
//  A3ExpenseListDetailsTableViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/13/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "ATSDragToReorderTableViewController.h"
#import "A3ExpenseListHistoryViewController.h"

@class A3HorizontalBarContainerView;
@class Expense;

@interface A3ExpenseListDetailsTableViewController : ATSDragToReorderTableViewController <A3ExpenseListHistoryViewControllerDelegate>

@property (nonatomic, weak) A3HorizontalBarContainerView *chartContainerView;

@property (nonatomic, strong) Expense *expenseObject;

- (void)addNewItemButtonAction;

- (void)makeNewList;

- (void)calculate;
@end
