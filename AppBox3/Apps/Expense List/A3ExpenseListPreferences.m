//
//  A3ExpenseListPreferences.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListPreferences.h"
#import "A3UserDefaults.h"

@implementation A3ExpenseListPreferences

- (BOOL)addBudgetShowAdvanced {
	return [[NSUserDefaults standardUserDefaults] boolForKey:A3ExpenseListAddBudgetDefaultShowAdvanced];
}

- (void)setAddBudgetShowAdvanced:(BOOL)showAdvanced {
	[[NSUserDefaults standardUserDefaults] setBool:showAdvanced forKey:A3ExpenseListAddBudgetDefaultShowAdvanced];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
