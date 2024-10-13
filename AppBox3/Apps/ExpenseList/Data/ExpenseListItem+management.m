//
//  ExpenseListItem+management.m
//  AppBox3
//
//  Created by A3 on 5/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/AppBoxKit.h>
#import "ExpenseListItem+management.h"

@implementation ExpenseListItem_ (management)

- (NSString *)makeOrderString {
	ExpenseListItem_ *lastItem = [ExpenseListItem_ findFirstOrderedByAttribute:@"order" ascending:NO];
	return [NSString orderStringWithOrder:[lastItem.order integerValue] + 1000000];
}

@end
