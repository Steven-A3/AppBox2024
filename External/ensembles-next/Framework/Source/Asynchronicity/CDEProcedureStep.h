//
//  CDEProcedureStep.h
//  Ensembles Mac
//
//  Created by Drew McCormack on 10/29/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDEAsynchronousTaskQueue.h"

@class CDEProcedureStep;

typedef void (^CDEProcedureStepExecutionBlock)(CDEProcedureStep *step, CDECompletionBlock next);

@interface CDEProcedureStep : NSObject

@property (nonatomic, assign) NSUInteger totalUnitCount;
@property (nonatomic, assign) NSUInteger numberOfUnitsCompleted;
@property (nonatomic, readwrite) double progressWeight; // Higher is heavier weight in progress. Default 1.
@property (nonatomic, readwrite) id representedObject;
@property (nonatomic, readonly) NSArray *dependencies;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, copy) CDEProcedureStepExecutionBlock executionBlock;

- (void)addDependency:(CDEProcedureStep *)otherStep;
- (void)removeDependency:(CDEProcedureStep *)otherStep;

- (void)prepareToProceed;

@end
