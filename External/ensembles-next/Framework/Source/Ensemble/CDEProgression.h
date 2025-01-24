//
//  CDEProgression.h
//  Ensembles Mac
//
//  Created by Drew McCormack on 27/05/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CDEPersistentStoreEnsemble;

@protocol CDEProgression;

typedef void (^CDEProgressUnitsCompletionBlock)(NSUInteger numberOfNewUnitsCompleted);

@protocol CDEProgression <NSObject>

@property (nonatomic, readonly) NSUInteger numberOfProgressUnits;
@property (nonatomic, copy) CDEProgressUnitsCompletionBlock progressUnitsCompletionBlock;

@end

