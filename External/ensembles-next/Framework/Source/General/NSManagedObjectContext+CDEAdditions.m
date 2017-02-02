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
    NSFetchRequest *objectIDFetch = [fetch copy];
    objectIDFetch.resultType = NSManagedObjectIDResultType;
    NSArray *objectIDs = [self executeFetchRequest:objectIDFetch error:&error];
    if (nil == objectIDs) {
        CDELog(CDELoggingLevelError, @"Could not fetch object ids: %@", error);
        return NO;
    }
    
    NSUInteger count = objectIDs.count;
    if (batchSize == 0) batchSize = count;
    
    NSUInteger numberOfBatches = count / MAX(1, batchSize) + (count%batchSize ? 1 : 0);
    NSUInteger batchesRemaining = numberOfBatches;
    for (NSUInteger b = 0; b < numberOfBatches; b++) {
        @autoreleasepool {
            NSUInteger start = b*batchSize;
            NSUInteger end = MIN((b+1)*batchSize, count);
            NSArray *batchIDs = [objectIDs subarrayWithRange:NSMakeRange(start, end-start)];
            
            NSFetchRequest *objectFetchRequest = [fetch copy];
            NSPredicate *batchPredicate = [NSPredicate predicateWithFormat:@"SELF IN %@", batchIDs];
            objectFetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[batchPredicate, fetch.predicate ? : [NSPredicate predicateWithValue:YES]]];
            
            NSError *error = nil;
            NSArray *objects = [self executeFetchRequest:objectFetchRequest error:&error];
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
