//
//  CDEIntegrationStage.h
//  Ensembles iOS
//
//  Created by Drew McCormack on 05/05/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDEEventBuilder;
@class CDEEventStore;

@interface CDEIntegrationStage : NSObject

@property (nonatomic, readonly) NSUInteger batchSize;
@property (nonatomic, readonly) NSUInteger numberOfBatchesRemaining;
@property (nonatomic, readonly) NSUInteger numberOfChangesInNextBatch;
@property (nonatomic, readonly) NSUInteger firstIndexOfNextBatch;
@property (nonatomic, readonly) NSArray *objectChangeIDs;
@property (nonatomic, readonly) CDEEventBuilder *eventBuilder;
@property (nonatomic, readonly) CDEEventStore *eventStore;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (instancetype)initWithEventBuilder:(CDEEventBuilder *)newBuilder objectChangeIDs:(NSArray *)changeIDs managedObjectContext:(NSManagedObjectContext *)context batchSize:(NSUInteger)batchSize;

- (BOOL)applyNextBatchOfChanges:(NSError * __autoreleasing *)error;

- (NSMapTable *)fetchObjectsByGlobalIdentifierForChanges:(id)objectChanges relationshipsToInclude:(NSArray *)relationships error:(NSError * __autoreleasing *)error;
- (void)enumerateObjectChangeIDs:(NSArray *)changeIDs withBlock:(void(^)(NSArray *batchIDs))block;

// Use these to avoid calling a custom accessor. Fires KVO.
+ (id)valueForKey:(NSString *)key inObject:(id)object;
+ (void)setValue:(id)value forKey:(NSString *)key inObject:(id)object;

@end

@interface CDEIntegrationStage (Subclassing)

- (BOOL)applyChangeIDs:(NSArray *)changeIDs error:(NSError * __autoreleasing *)error; // Abstract

@end