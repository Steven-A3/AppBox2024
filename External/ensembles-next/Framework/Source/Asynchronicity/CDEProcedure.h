//
//  CDEProcedure.h
//  Ensembles Mac
//
//  Created by Drew McCormack on 10/29/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDEDefines.h"

@class CDEProcedureStep;
@class CDEAsynchronousTaskQueue;

@interface CDEProcedure : NSObject

@property (nonatomic, readonly) NSArray *procedureSteps;
@property (nonatomic, readonly) NSArray *enabledProcedureSteps;
@property (nonatomic, readonly) double progress; // From 0 to 1. Supports KVO.
@property (nonatomic, readonly) CDEProcedureStep *currentProcedureStep; // Supports KVO.
@property (nonatomic, readwrite) id <NSObject> taskQueueInfo;
@property (nonatomic, readonly) CDEAsynchronousTaskQueue *taskQueue;
@property (nonatomic, copy) CDECodeBlock progressUpdateBlock;

- (void)addProcedureStep:(CDEProcedureStep *)newStep;
- (void)removeProcedureStep:(CDEProcedureStep *)toRemove;

- (NSArray *)procedureStepsForRepresentedObject:(id)object;
- (CDEProcedureStep *)procedureStepAtIndex:(NSUInteger)index;

- (void)prepareToProceed;
- (void)proceedWithCompletion:(CDECompletionBlock)completion;
- (void)proceedInOperationQueue:(NSOperationQueue *)queue withCompletion:(CDECompletionBlock)completion;

- (void)disableAllSteps;

@end
