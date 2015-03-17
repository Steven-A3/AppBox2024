//
//  CDEProcedure.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 10/29/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import "CDEProcedure.h"
#import "CDEProcedureStep.h"
#import "CDEAsynchronousTaskQueue.h"


@interface CDEProcedure ()

@property (nonatomic, readwrite) CDEAsynchronousTaskQueue *taskQueue;
@property (nonatomic, readwrite) CDEProcedureStep *currentProcedureStep;
@property (nonatomic, readwrite) BOOL prepared;
@property (nonatomic, readwrite) double progress;

@end


@implementation CDEProcedure {
    NSMutableArray *mutableSteps;
}

@synthesize taskQueueInfo;

- (instancetype)init
{
    self = [super init];
    if (self) {
        mutableSteps = [NSMutableArray array];
        taskQueueInfo = nil;
    }
    return self;
}

- (void)dealloc
{
    for (CDEProcedureStep *step in mutableSteps) [self stopObservingStep:step];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"totalUnitCount"] || [keyPath isEqualToString:@"numberOfUnitsCompleted"]) {
        [self updateProgress];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Managing Steps

- (void)addProcedureStep:(CDEProcedureStep *)newStep
{
    [self willChangeValueForKey:@"procedureSteps"];
    [mutableSteps addObject:newStep];
    [self didChangeValueForKey:@"procedureSteps"];
    [self startObservingStep:newStep];
}

- (void)removeProcedureStep:(CDEProcedureStep *)toRemove
{
    [self stopObservingStep:toRemove];
    [self willChangeValueForKey:@"procedureSteps"];
    [mutableSteps removeObject:toRemove];
    [self didChangeValueForKey:@"procedureSteps"];
}

- (void)disableAllSteps
{
    for (CDEProcedureStep *step in mutableSteps) {
        step.enabled = NO;
    }
}

- (void)startObservingStep:(CDEProcedureStep *)step
{
    [step addObserver:self forKeyPath:@"totalUnitCount" options:0 context:NULL];
    [step addObserver:self forKeyPath:@"numberOfUnitsCompleted" options:0 context:NULL];
}

- (void)stopObservingStep:(CDEProcedureStep *)step
{
    [step removeObserver:self forKeyPath:@"totalUnitCount"];
    [step removeObserver:self forKeyPath:@"numberOfUnitsCompleted"];
}

- (NSArray *)procedureStepsForRepresentedObject:(id)object
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"representedObject = %@", object];
    NSArray *filtered = [mutableSteps filteredArrayUsingPredicate:predicate];
    return filtered;
}

- (CDEProcedureStep *)procedureStepAtIndex:(NSUInteger)index
{
    return index < mutableSteps.count ? mutableSteps[index] : nil;
}

- (NSArray *)procedureSteps
{
    return [mutableSteps copy];
}

- (NSArray *)enabledProcedureSteps
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isEnabled = TRUE"];
    return [self.procedureSteps filteredArrayUsingPredicate:predicate];
}

#pragma mark Progress

- (void)updateProgress
{
    double sum = 0.0;
    double sumOfWeights = 0.0;
    NSArray *enabledSteps = self.enabledProcedureSteps;
    for (CDEProcedureStep *step in enabledSteps) {
        double progressThisStep = step.numberOfUnitsCompleted / (double)MAX(1, step.totalUnitCount);
        double weight = step.progressWeight;
        progressThisStep = MAX(MIN(1.0, progressThisStep), 0.0);
        sum += progressThisStep * weight;
        sumOfWeights += weight;
    }
    self.progress = sum / MAX(sumOfWeights, 1.e-10);
    if (self.progressUpdateBlock) self.progressUpdateBlock();
}

#pragma mark Proceeding

- (void)prepareToProceed
{
    NSArray *enabledSteps = self.enabledProcedureSteps;
    NSArray *newEnabledSteps = nil;
    while (![enabledSteps isEqualToArray:newEnabledSteps]) {
        for (CDEProcedureStep *step in mutableSteps) {
            [step prepareToProceed];
        }
        if (newEnabledSteps) enabledSteps = newEnabledSteps;
        newEnabledSteps = self.enabledProcedureSteps;
    }
}

- (void)proceedWithCompletion:(CDECompletionBlock)completion
{
    [self proceedInOperationQueue:[NSOperationQueue mainQueue] withCompletion:completion];
}

- (void)proceedInOperationQueue:(NSOperationQueue *)operationQueue withCompletion:(CDECompletionBlock)completion
{
    [self prepareToProceed];
    [self updateProgress];
    
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    for (CDEProcedureStep *step in self.enabledProcedureSteps) {
        CDEAsynchronousTaskBlock task = ^(CDEAsynchronousTaskCallbackBlock next) {
            self.currentProcedureStep = step;
            CDEProcedureStepExecutionBlock block = step.executionBlock;
            if (!block) {
                step.numberOfUnitsCompleted = step.totalUnitCount;
                next(nil, NO);
            }
            else {
                block(step, ^(NSError *stepError) {
                    step.numberOfUnitsCompleted = step.totalUnitCount;
                    next(stepError, NO);
                });
            }
        };
        [tasks addObject:task];
    }
    
    self.taskQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:tasks terminationPolicy:CDETaskQueueTerminationPolicyStopOnError completion:^(NSError *error) {
        self.currentProcedureStep = nil;
        if (completion) completion(error);
        self.taskQueue = nil;
    }];
    self.taskQueue.info = self.taskQueueInfo;
    [operationQueue addOperation:self.taskQueue];
}

@end

