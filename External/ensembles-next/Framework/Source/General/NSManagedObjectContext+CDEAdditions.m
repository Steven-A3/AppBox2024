//
//  NSManagedObjectContext+CDEAdditions.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 14/04/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import "NSManagedObjectContext+CDEAdditions.h"
#import "CDEDefines.h"

@implementation NSManagedObjectContext (CDEAdditions)

- (BOOL)cde_enumerateObjectsForFetchRequest:(NSFetchRequest *)fetch withBatchSize:(NSUInteger)batchSize withBlock:(void(^)(NSArray *objects, NSUInteger batchesRemaining, BOOL *stop))block
{
    NSParameterAssert(block != NULL);
    block = [block copy];
    
    NSError *error = nil;
    NSUInteger count = [self countForFetchRequest:fetch error:&error];
    if (count == NSNotFound) {
        CDELog(CDELoggingLevelError, @"Could not get count: %@", error);
        return NO;
    }

    NSUInteger numberOfBatches = count / MAX(1, batchSize) + (count%batchSize ? 1 : 0);
    NSUInteger batchesRemaining = numberOfBatches;
    for (NSUInteger b = 0; b < numberOfBatches; b++) {
        @autoreleasepool {
            NSFetchRequest *fetchCopy = [fetch copy];
            fetchCopy.fetchOffset = b * batchSize;
            fetchCopy.fetchLimit = batchSize;
            
            NSError *error = nil;
            NSArray *objects = [self executeFetchRequest:fetchCopy error:&error];
            if (!objects) {
                CDELog(CDELoggingLevelError, @"Could not get objects: %@", error);
                return NO;
            }
            
            BOOL stop = NO;
            block(objects, --batchesRemaining, &stop);
            
            if (stop) return NO;
        }
    }
    
    return YES;
}

@end
