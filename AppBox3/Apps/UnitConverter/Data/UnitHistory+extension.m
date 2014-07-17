//
//  UnitHistory+extension.m
//  AppBox3
//
//  Created by A3 on 7/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UnitHistory+extension.h"
#import "UnitHistoryItem.h"

@implementation UnitHistory (extension)

- (NSArray *)targets {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unitHistoryID == %@", self.uniqueID];
	return [UnitHistoryItem MR_findAllSortedBy:@"order" ascending:YES withPredicate:predicate];
}

@end
