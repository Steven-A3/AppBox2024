//
//  NSObject(SortInArray)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/18/13 1:57 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "NSObject+SortInArray.h"
#import "NSString+conversion.h"

static NSString *const A3CommonPropertyOrder = @"order";

@implementation NSObject (SortInArray)

+ (void)moveItemInSortedArray:(NSArray *)array fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
	id fromObject = array[fromIndex];
	id toObject = array[toIndex];
	NSInteger startValue = 1000000;
	NSInteger space = 1000000;

	void (^resetOrder)(NSArray *) = ^(NSArray *array) {
		NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
		[mutableArray moveObjectFromIndex:fromIndex toIndex:toIndex];
		NSInteger index = startValue;
		for (id object in mutableArray) {
			[object setValue:[NSString orderStringWithOrder:index] forKey:A3CommonPropertyOrder];

			index += space;
		}
	};

	if (toIndex == 0) {
		NSInteger oldOrder = [[toObject valueForKey:A3CommonPropertyOrder] integerValue];
		NSInteger newOrder;
		if (oldOrder > 0) {
			newOrder = oldOrder / 2;
            [fromObject setValue:[NSString orderStringWithOrder:newOrder] forKey:A3CommonPropertyOrder];
		} else {
			resetOrder(array);
		}
		return;
	}
	if (toIndex == [array count] - 1) {
		NSInteger newOrder = [[toObject valueForKey:A3CommonPropertyOrder] integerValue] + space;

		[fromObject setValue:[NSString orderStringWithOrder:newOrder] forKey:A3CommonPropertyOrder];
		return;
	}
	id prevToObject = array[toIndex - 1];
	NSInteger orderA = [[prevToObject valueForKey:A3CommonPropertyOrder] integerValue];
	NSInteger orderB = [[toObject valueForKey:A3CommonPropertyOrder] integerValue];
	NSInteger newOrder = orderA + (orderB - orderA)/2;
	if (newOrder == orderA) {
		resetOrder(array);
		return;
	}
	[fromObject setValue:[NSString orderStringWithOrder:newOrder] forKey:A3CommonPropertyOrder];
}

@end