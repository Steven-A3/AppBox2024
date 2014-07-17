//
//  CurrencyHistory(handler)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/16/13 11:55 AM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "CurrencyHistory+handler.h"
#import "CurrencyHistoryItem.h"

@implementation CurrencyHistory (handler)

- (NSInteger)targetCount {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"historyID == %@", self.uniqueID];
	return [CurrencyHistoryItem MR_countOfEntitiesWithPredicate:predicate];
}

- (NSArray *)targets {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"historyID == %@", self.uniqueID];
	return [CurrencyHistoryItem MR_findAllSortedBy:@"order" ascending:YES withPredicate:predicate];
}

@end
