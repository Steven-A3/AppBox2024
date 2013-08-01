//
//  NSMutableArray+A3Sort.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/27/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (A3Sort)

- (void)moveItemInSortedArrayFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

- (void)insertObjectToSortedArray:(id)object atIndex:(NSInteger)index1;

- (void)addObjectToSortedArray:(id)object;

- (void)exchangeObjectInSortedArrayAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
@end
