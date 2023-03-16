//
//  ExpenseListHistory+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "ExpenseListHistory+extension.h"
#import "ExpenseListBudget.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"

@implementation ExpenseListHistory (extension)

- (ExpenseListBudget *)budgetData {
	return [ExpenseListBudget findFirstByAttribute:@"uniqueID" withValue:self.budgetID];
}

@end
