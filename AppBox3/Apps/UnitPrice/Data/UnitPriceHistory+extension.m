//
//  UnitPriceHistory+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UnitPriceHistory+extension.h"
#import "UnitPriceHistoryItem.h"

@implementation UnitPriceHistory (extension)

- (NSArray *)unitPrices {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"historyID == %@", self.uniqueID];
	return [UnitPriceHistoryItem MR_findAllWithPredicate:predicate];
}

@end