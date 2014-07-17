//
//  ExpenseListHistory+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "ExpenseListHistory+extension.h"
#import "ExpenseListBudget.h"

@implementation ExpenseListHistory (extension)

- (ExpenseListBudget *)budgetData {
	return [ExpenseListBudget MR_findFirstByAttribute:@"uniqueID" withValue:@"budgetID"];
}

@end
