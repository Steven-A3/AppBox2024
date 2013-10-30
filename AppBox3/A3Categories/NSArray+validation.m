//
//  NSArray+validation.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/24/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSArray+validation.h"

@implementation NSArray (validation)

- (BOOL)isIndexValid:(NSInteger)index {
	return (index >= 0) && (index < [self count]);
}

@end
