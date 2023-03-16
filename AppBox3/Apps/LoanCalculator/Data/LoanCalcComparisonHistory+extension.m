//
//  LoanCalcComparisonHistory+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcComparisonHistory+extension.h"
#import "LoanCalcHistory.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"

@implementation LoanCalcComparisonHistory (extension)

- (NSArray *)details {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comparisonHistoryID == %@", self.uniqueID];
	return [LoanCalcHistory findAllWithPredicate:predicate];
}

@end
