//
//  ExpenseListBudget+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/AppBoxKit.h>
#import "ExpenseListBudget+extension.h"

@implementation ExpenseListBudget_ (extension)

- (NSInteger)expenseItemsCount {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"budgetID == %@", self.uniqueID];
	return [ExpenseListItem_ countOfEntitiesWithPredicate:predicate];
}

- (NSArray *)expenseItems {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"budgetID == %@", self.uniqueID];
	return [ExpenseListItem_ findAllSortedBy:@"order" ascending:YES withPredicate:predicate];
}

- (NSArray *)expenseItemsHasData {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"budgetID == %@ AND hasData == YES", self.uniqueID];
	return [ExpenseListItem_ findAllSortedBy:@"order" ascending:YES withPredicate:predicate];
}

@end
