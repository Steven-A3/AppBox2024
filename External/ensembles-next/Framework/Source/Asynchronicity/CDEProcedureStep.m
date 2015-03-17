//
//  CDEProcedureStep.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 10/29/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import "CDEProcedureStep.h"

@implementation CDEProcedureStep {
    NSMutableArray *mutableDependencies;
}

@synthesize totalUnitCount, numberOfUnitsCompleted;
@synthesize progressWeight;
@synthesize enabled;

- (instancetype)init
{
    self = [super init];
    if (self) {
        mutableDependencies = [NSMutableArray array];
        totalUnitCount = 1;
        numberOfUnitsCompleted = 0;
        progressWeight = 1.0;
        enabled = YES;
    }
    return self;
}

- (NSArray *)dependencies
{
    return [mutableDependencies copy];
}

- (void)addDependency:(CDEProcedureStep *)otherStep
{
    [mutableDependencies removeObject:otherStep];
    [mutableDependencies addObject:otherStep];
}

- (void)removeDependency:(CDEProcedureStep *)otherStep
{
    [mutableDependencies removeObject:otherStep];
}

- (void)prepareToProceed
{
    if (self.isEnabled) {
        for (CDEProcedureStep *step in self.dependencies) {
            step.enabled = YES;
        }
    }
}

@end
