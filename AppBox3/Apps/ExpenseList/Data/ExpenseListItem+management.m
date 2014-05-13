//
//  ExpenseListItem+management.m
//  AppBox3
//
//  Created by A3 on 5/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "ExpenseListItem+management.h"
#import "NSString+conversion.h"

@implementation ExpenseListItem (management)

- (NSString *)makeOrderString {
	ExpenseListItem *lastItem = [ExpenseListItem MR_findFirstOrderedByAttribute:@"order" ascending:NO];
	return [NSString orderStringWithOrder:[lastItem.order integerValue] + 1000000];
}

@end
