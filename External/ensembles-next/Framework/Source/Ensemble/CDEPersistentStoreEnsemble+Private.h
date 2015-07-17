//
//  CDEPersistentStoreEnsemble+Private.h
//  Ensembles Mac
//
//  Created by Drew McCormack on 27/05/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <Ensembles/Ensembles.h>
#import "CDEBaselineConsolidator.h"
#import "CDERebaser.h"
#import "CDEEventIntegrator.h"
#import "CDESaveMonitor.h"
#import "CDEEventStore.h"
#import "CDECloudManager.h"

@interface CDEPersistentStoreEnsemble ()

@property (nonatomic, strong, readwrite) CDECloudManager *cloudManager;
@property (nonatomic, strong, readwrite) id <CDECloudFileSystem> cloudFileSystem;

@property (nonatomic, strong, readwrite) NSString *ensembleIdentifier;

@property (nonatomic, strong, readwrite) NSURL *storeURL;
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readwrite) NSURL *managedObjectModelURL;
@property (nonatomic, strong, readonly) NSString *modelVersionHash;

@property (atomic, assign, readwrite, getter = isLeeched) BOOL leeched;
@property (atomic, assign, readwrite, getter = isLeeching) BOOL leeching;
@property (atomic, assign, readwrite, getter = isDeleeching) BOOL deleeching;
@property (atomic, assign, readwrite, getter = isMerging) BOOL merging;
@property (atomic, assign, readwrite) CDEEnsembleActivity currentActivity;
@property (atomic, assign, readwrite) float activityProgress;

@property (nonatomic, strong, readwrite) CDEEventStore *eventStore;
@property (nonatomic, strong, readwrite) CDESaveMonitor *saveMonitor;
@property (nonatomic, strong, readwrite) CDEEventIntegrator *eventIntegrator;
@property (nonatomic, strong, readwrite) CDEBaselineConsolidator *baselineConsolidator;
@property (nonatomic, strong, readwrite) CDERebaser *rebaser;

- (NSArray *)globalIdentifiersForManagedObjects:(NSArray *)objects;

@end

