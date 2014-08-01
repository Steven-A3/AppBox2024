//
//  CDEFoundationAdditions.h
//  Test App iOS
//
//  Created by Drew McCormack on 4/19/13.
//  Copyright (c) 2013 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (CDEFoundationAdditions)

- (void)cde_enumerateObjectsDrainingEveryIterations:(NSUInteger)iterationsBetweenDrains usingBlock:(void (^)(id object, NSUInteger index, BOOL *stop))block;
- (void)cde_enumerateObjectsInBatchesWithBatchSize:(NSUInteger)batchSize usingBlock:(void (^)(NSArray *batch, NSUInteger batchesRemaining, BOOL *stop))block;

- (NSArray *)cde_arrayByTransformingObjectsWithBlock:(id(^)(id))block;

@end


@interface NSData (CDEFoundationAdditions)

- (NSString *)cde_base64String;

@end
