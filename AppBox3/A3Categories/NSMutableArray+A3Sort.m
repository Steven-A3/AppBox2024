//
//  NSMutableArray+A3Sort.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/27/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSMutableArray+A3Sort.h"
#import "NSMutableArray+MoveObject.h"
#import "NSString+conversion.h"
#import "common.h"

static NSString *const A3CommonPropertyOrder = @"order";

#define	A3_ORDER_NUMBER_START	1000000
#define A3_ORDER_NUMBER_SPACE	1000000

@implementation NSMutableArray (A3Sort)

- (void)resetAllOrderValue {
	NSInteger index = A3_ORDER_NUMBER_START;
	for (id object in self) {
		[object setValue:[NSString orderStringWithOrder:index] forKey:A3CommonPropertyOrder];

		index += A3_ORDER_NUMBER_SPACE;
	}
}

- (void)moveItemInSortedArrayFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
	if (fromIndex == toIndex) {
		return;
	}
	id fromObject = self[fromIndex];
	id toObject = self[toIndex];

	void (^resetOrder)() = ^() {
		[self moveObjectFromIndex:fromIndex toIndex:toIndex];
		[self resetAllOrderValue];
	};

	if (toIndex == 0) {
		NSInteger oldOrder = [[toObject valueForKey:A3CommonPropertyOrder] integerValue];
		NSInteger newOrder;
		if (oldOrder > 0) {
			newOrder = oldOrder / 2;
			[fromObject setValue:[NSString orderStringWithOrder:newOrder] forKey:A3CommonPropertyOrder];
			[self moveObjectFromIndex:fromIndex toIndex:toIndex];
		} else {
			resetOrder();
		}
		return;
	}
	if (toIndex == [self count] - 1) {
		NSInteger newOrder = [[toObject valueForKey:A3CommonPropertyOrder] integerValue] + A3_ORDER_NUMBER_SPACE;

		[fromObject setValue:[NSString orderStringWithOrder:newOrder] forKey:A3CommonPropertyOrder];
		[self moveObjectFromIndex:fromIndex toIndex:toIndex];
		return;
	}
	id prevToObject = self[toIndex - 1];
	NSInteger orderA = [[prevToObject valueForKey:A3CommonPropertyOrder] integerValue];
	NSInteger orderB = [[toObject valueForKey:A3CommonPropertyOrder] integerValue];
	NSInteger newOrder = orderA + (orderB - orderA) / 2;
	if ((newOrder == 0) || (newOrder == orderA) || (newOrder == orderB)) {
		resetOrder();
		return;
	}
	[fromObject setValue:[NSString orderStringWithOrder:newOrder] forKey:A3CommonPropertyOrder];

	[self moveObjectFromIndex:fromIndex toIndex:toIndex];
}

- (void)insertObjectToSortedArray:(id)object atIndex:(NSInteger)index {
	NSInteger prevOrder, nextOrder, myOrder;
	if (index == 0) {
		prevOrder = 0;
	} else {
		prevOrder = [[self[index - 1] valueForKey:A3CommonPropertyOrder] integerValue];
	}
	if (index == [self count]) {
		// Prev order == last order
		myOrder = prevOrder + A3_ORDER_NUMBER_SPACE;
	} else {
		nextOrder = [[self[index] valueForKey:A3CommonPropertyOrder] integerValue];
		myOrder = prevOrder + (nextOrder - prevOrder) / 2;

		if ((myOrder == 0) || (myOrder == prevOrder) || (myOrder == nextOrder)) {
			[self insertObject:object atIndex:index];
			[self resetAllOrderValue];
			return;
		}
	}

	[self insertObject:object atIndex:index];
	[object setValue:[NSString orderStringWithOrder:myOrder] forKey:A3CommonPropertyOrder];
}

- (void)addObjectToSortedArray:(id)object {
	[self insertObjectToSortedArray:object atIndex:[self count]];
}

- (void)exchangeObjectInSortedArrayAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    SEL selectorOrder = sel_registerName("order");
    SEL selectorSetOrder = sel_registerName("setOrder:");
	if  (	[self[idx1] respondsToSelector:selectorOrder] &&
			[self[idx1] respondsToSelector:selectorSetOrder] &&
			[self[idx2] respondsToSelector:selectorOrder] &&
			[self[idx2] respondsToSelector:selectorSetOrder]
		)
	{
		id order = [self[idx1] valueForKey:A3CommonPropertyOrder];
		[self[idx1] setValue:[self[idx2] valueForKey:A3CommonPropertyOrder] forKey:A3CommonPropertyOrder];
		[self[idx2] setValue:order forKey:A3CommonPropertyOrder];
	}

	[self exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

@end
