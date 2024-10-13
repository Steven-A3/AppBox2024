//
//  ExpenseListHistory+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/AppBoxKit.h>
#import "ExpenseListHistory+extension.h"

@implementation ExpenseListHistory_ (extension)

- (ExpenseListBudget_ *)budgetData {
	return [ExpenseListBudget_ findFirstByAttribute:@"uniqueID" withValue:self.budgetID];
}

@end
