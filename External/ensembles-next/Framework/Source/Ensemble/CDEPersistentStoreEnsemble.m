//
//  CDEPersistentStoreEnsemble.m
//  Ensembles
//
//  Created by Drew McCormack on 4/11/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import "CDEPersistentStoreEnsemble.h"
#import "CDEPersistentStoreEnsemble+Private.h"
#import "CDEProcedure.h"
#import "CDEProcedureStep.h"
#import "CDECloudManager.h"
#import "CDEPersistentStoreImporter.h"
#import "CDEEventStore.h"
#import "CDEDefines.h"
#import "CDEAsynchronousTaskQueue.h"
#import "CDECloudFile.h"
#import "CDECloudDirectory.h"
#import "CDECloudFileSystem.h"
#import "CDESaveMonitor.h"
#import "CDEEventIntegrator.h"
#import "CDEEventBuilder.h"
#import "CDEBaselineConsolidator.h"
#import "CDERebaser.h"
#import "CDERevisionManager.h"


static NSString * const kCDEIdentityTokenContext = @"kCDEIdentityTokenContext";

static NSString * const kCDEStoreIdentifierKey = @"storeIdentifier";
static NSString * const kCDELeechDate = @"leechDate";

static NSString * const kCDEMergeTaskInfo = @"Merge";

static NSMutableSet *persistentStoreURLs;
static NSMutableSet *eventStoreRootDirectories;

NSString * const CDEMonitoredManagedObjectContextWillSaveNotification = @"CDEMonitoredManagedObjectContextWillSaveNotification";
NSString * const CDEMonitoredManagedObjectContextDidSaveNotification = @"CDEMonitoredManagedObjectContextDidSaveNotification";
NSString * const CDEMonitoredManagedObjectContextSaveChangesWereStoredNotification = @"CDEMonitoredManagedObjectContextSaveChangesWereStoredNotification";
NSString * const CDEPersistentStoreEnsembleDidSaveMergeChangesNotification = @"CDEPersistentStoreEnsembleDidSaveMergeChangesNotification";
NSString * const CDEPersistentStoreEnsembleDidBeginActivityNotification = @"CDEPersistentStoreEnsembleDidBeginActivityNotification";
NSString * const CDEPersistentStoreEnsembleDidMakeProgressWithActivityNotification = @"CDEPersistentStoreEnsembleDidMakeProgressWithActivityNotification";
NSString * const CDEPersistentStoreEnsembleWillEndActivityNotification = @"CDEPersistentStoreEnsembleWillEndActivityNotification";

NSString * const CDEManagedObjectContextSaveNotificationKey = @"managedObjectContextSaveNotification";
NSString * const CDEEnsembleActivityKey = @"CDEEnsembleActivityKey";
NSString * const CDEActivityErrorKey = @"CDEActivityErrorKey";
NSString * const CDEActivityPhaseKey = @"CDEActivityPhaseKey";
NSString * const CDEProgressFractionKey = @"CDEProgressFractionKey";


@implementation CDEPersistentStoreEnsemble {
    BOOL saveOccurredDuringImport;
    NSOperationQueue *operationQueue;
    BOOL rebaseCheckDone;
}

@synthesize cloudFileSystem = cloudFileSystem;
@synthesize ensembleIdentifier = ensembleIdentifier;
@synthesize persistentStoreURL = persistentStoreURL;
@synthesize persistentStoreOptions = persistentStoreOptions;
@synthesize cloudManager = cloudManager;
@synthesize eventStore = eventStore;
@synthesize saveMonitor = saveMonitor;
@synthesize eventIntegrator = eventIntegrator;
@synthesize managedObjectModel = managedObjectModel;
@synthesize managedObjectModelURL = managedObjectModelURL;
@synthesize baselineConsolidator = baselineConsolidator;
@synthesize rebaser = rebaser;
@synthesize activityProgress = activityProgress;
@synthesize currentActivity = currentActivity;

#pragma mark - Initialization and Deallocation

+ (void)initialize
{
    if (self == [CDEPersistentStoreEnsemble class]) {
        persistentStoreURLs = [NSMutableSet set];
        eventStoreRootDirectories = [NSMutableSet set];
    }
}

- (instancetype)initWithEnsembleIdentifier:(NSString *)identifier persistentStoreURL:(NSURL *)newStoreURL persistentStoreOptions:(NSDictionary *)storeOptions managedObjectModelURL:(NSURL *)modelURL cloudFileSystem:(id <CDECloudFileSystem>)newCloudFileSystem localDataRootDirectoryURL:(NSURL *)eventDataRootURL
{
    NSParameterAssert(identifier != nil);
    NSParameterAssert(newStoreURL != nil);
    NSParameterAssert(modelURL != nil);
    NSParameterAssert(newCloudFileSystem != nil);
    
    // Make sure no two Ensembles share a persistent store
    if ([persistentStoreURLs containsObject:newStoreURL]) {
        CDELog(CDELoggingLevelError, @"Attempt to create an Ensemble for a persistent store for which an ensemble is already active: %@. Call 'dismantle' if you want to stop using an Ensemble.", newStoreURL);
        return nil;
    }
    [persistentStoreURLs addObject:newStoreURL];
    
    self = [super init];
    if (self) {
        persistentStoreOptions = storeOptions;
        
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
        if ([operationQueue respondsToSelector:@selector(setQualityOfService:)]) {
            [operationQueue setQualityOfService:NSQualityOfServiceUserInitiated];
        }
        
        rebaseCheckDone = NO;
        
        self.compressModelHashes = NO;
        
        self.ensembleIdentifier = identifier;
        self.persistentStoreURL = newStoreURL;
        self.managedObjectModelURL = modelURL;
        self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        self.cloudFileSystem = newCloudFileSystem;
        
        BOOL success = [self setupEventStoreWithDataRootDirectoryURL:eventDataRootURL];
        if (!success) return nil;
        
        // Make sure no two Ensembles share an event store location
        NSString *eventStoreRoot = eventStore.pathToEventStoreRootDirectory;
        if ([eventStoreRootDirectories containsObject:eventStoreRoot]) {
            CDELog(CDELoggingLevelError, @"Attempt to create an Ensemble that wants to use the same local data directory as another ensemble: %@", eventStoreRoot);
            return nil;
        }
        [eventStoreRootDirectories addObject:eventStoreRoot];
        
        self.leeching = NO;
        self.merging = NO;
        self.deleeching = NO;
        
        self.leeched = eventStore.containsEventData;
        if (self.leeched) [self.eventStore removeUnusedDataWithCompletion:NULL];
        
        [self initializeEventIntegrator];
        
        self.saveMonitor = [[CDESaveMonitor alloc] initWithStorePath:newStoreURL.path];
        self.saveMonitor.ensemble = self;
        self.saveMonitor.eventStore = eventStore;
        self.saveMonitor.eventIntegrator = self.eventIntegrator;
        
        self.cloudManager = [[CDECloudManager alloc] initWithEventStore:self.eventStore cloudFileSystem:self.cloudFileSystem managedObjectModel:self.managedObjectModel];
        
        self.baselineConsolidator = [[CDEBaselineConsolidator alloc] initWithEventStore:self.eventStore];
        self.rebaser = [[CDERebaser alloc] initWithEventStore:self.eventStore];
        
        [self performInitialChecks];
    }
    return self;
}

- (instancetype)initWithEnsembleIdentifier:(NSString *)identifier persistentStoreURL:(NSURL *)url managedObjectModelURL:(NSURL *)modelURL cloudFileSystem:(id <CDECloudFileSystem>)newCloudFileSystem
{
    return [self initWithEnsembleIdentifier:identifier persistentStoreURL:url persistentStoreOptions:nil managedObjectModelURL:modelURL cloudFileSystem:newCloudFileSystem localDataRootDirectoryURL:nil];
}

- (void)initializeEventIntegrator
{
    NSURL *url = self.persistentStoreURL;
    self.eventIntegrator = [[CDEEventIntegrator alloc] initWithStoreURL:url managedObjectModel:self.managedObjectModel eventStore:self.eventStore];
    self.eventIntegrator.ensemble = self;
    self.eventIntegrator.persistentStoreOptions = persistentStoreOptions;
    
    __weak typeof(self) weakSelf = self;
    self.eventIntegrator.shouldSaveBlock = ^(NSManagedObjectContext *savingContext, NSManagedObjectContext *reparationContext) {
        BOOL result = YES;
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return NO;
        if ([strongSelf.delegate respondsToSelector:@selector(persistentStoreEnsemble:shouldSaveMergedChangesInManagedObjectContext:reparationManagedObjectContext:)]) {
            result = [strongSelf.delegate persistentStoreEnsemble:strongSelf shouldSaveMergedChangesInManagedObjectContext:savingContext reparationManagedObjectContext:reparationContext];
        }
        return result;
    };
    
    self.eventIntegrator.failedSaveBlock = ^(NSManagedObjectContext *savingContext, NSError *error, NSManagedObjectContext *reparationContext) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return NO;
        if ([strongSelf.delegate respondsToSelector:@selector(persistentStoreEnsemble:didFailToSaveMergedChangesInManagedObjectContext:error:reparationManagedObjectContext:)]) {
            return [strongSelf.delegate persistentStoreEnsemble:strongSelf didFailToSaveMergedChangesInManagedObjectContext:savingContext error:error reparationManagedObjectContext:reparationContext];
        }
        return NO;
    };
    
    self.eventIntegrator.didSaveBlock = ^(NSManagedObjectContext *context, NSDictionary *info) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        NSNotification *notification = [NSNotification notificationWithName:NSManagedObjectContextDidSaveNotification object:context userInfo:info];
        if ([strongSelf.delegate respondsToSelector:@selector(persistentStoreEnsemble:didSaveMergeChangesWithNotification:)]) {
            [strongSelf.delegate persistentStoreEnsemble:strongSelf didSaveMergeChangesWithNotification:notification];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CDEPersistentStoreEnsembleDidSaveMergeChangesNotification object:strongSelf userInfo:@{CDEManagedObjectContextSaveNotificationKey : notification}];
    };
    
    self.eventIntegrator.willBeginMergingEntityBlock = ^(NSEntityDescription *entity) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        if ([strongSelf.delegate respondsToSelector:@selector(persistentStoreEnsemble:willMergeChangesForEntity:)]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [strongSelf.delegate persistentStoreEnsemble:strongSelf willMergeChangesForEntity:entity];
            });
        }
    };
    
    self.eventIntegrator.didFinishMergingEntityBlock = ^(NSEntityDescription *entity) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        if ([strongSelf.delegate respondsToSelector:@selector(persistentStoreEnsemble:didMergeChangesForEntity:)]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [strongSelf.delegate persistentStoreEnsemble:strongSelf didMergeChangesForEntity:entity];
            });
        }
    };
}

- (BOOL)setupEventStoreWithDataRootDirectoryURL:(NSURL *)eventDataRootURL
{
    self.eventStore = [[CDEEventStore alloc] initWithEnsembleIdentifier:self.ensembleIdentifier pathToEventDataRootDirectory:eventDataRootURL.path];
    if (!self.eventStore) {
        // Attempt to recover by removing local data
        CDELog(CDELoggingLevelError, @"Failed to create event store. Serious error, so removing local data.");
        NSString *ensembleRoot = [CDEEventStore pathToEventDataRootDirectoryForRootDirectory:eventDataRootURL.path ensembleIdentifier:self.ensembleIdentifier];
        NSError *error = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:ensembleRoot error:&error]) {
            CDELog(CDELoggingLevelError, @"Attempt to remove corrupt ensemble data failed. Giving up: %@", error);
            return NO;
        }
        else {
            self.eventStore = [[CDEEventStore alloc] initWithEnsembleIdentifier:self.ensembleIdentifier pathToEventDataRootDirectory:eventDataRootURL.path];
            if (!self.eventStore) {
                CDELog(CDELoggingLevelError, @"Attempt to remove create event store failed again. Giving up.");
                return NO;
            }
        }
    }
    return YES;
}

- (void)dismantle
{
    if (persistentStoreURL) [persistentStoreURLs removeObject:persistentStoreURL];
    if (eventStore.pathToEventStoreRootDirectory) [eventStoreRootDirectories removeObject:eventStore.pathToEventStoreRootDirectory];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [saveMonitor stopMonitoring];
    [eventStore dismantle];
}

- (void)dealloc
{
    [self dismantle];
}

#pragma mark - Discovering and Managing Ensembles

+ (void)retrieveEnsembleIdentifiersFromCloudFileSystem:(id <CDECloudFileSystem>)cloudFileSystem completion:(void(^)(NSError *error, NSArray *identifiers))completion
{
    [cloudFileSystem connect:^(NSError *connectError) {
        if (connectError) {
            if (completion) completion(connectError, nil);
            return;
        }
        
        [cloudFileSystem contentsOfDirectoryAtPath:@"/" completion:^(NSArray *contents, NSError *error) {
            NSArray *names = [contents valueForKeyPath:@"name"];
            if (completion) completion(error, names);
        }];
    }];
}

+ (void)removeEnsembleWithIdentifier:(NSString *)identifier inCloudFileSystem:(id <CDECloudFileSystem>)cloudFileSystem completion:(void(^)(NSError *error))completion
{
    [cloudFileSystem connect:^(NSError *connectError) {
        if (connectError) {
            if (completion) completion(connectError);
            return;
        }
        
        NSString *path = [NSString stringWithFormat:@"/%@", identifier];
        BOOL shouldPrime = [cloudFileSystem respondsToSelector:@selector(primeForActivityWithCompletion:)];
        if (shouldPrime) {
            [cloudFileSystem primeForActivityWithCompletion:^(NSError *error) {
                if (error) {
                    completion(error);
                    return;
                }
            
                [cloudFileSystem removeItemAtPath:path completion:completion];
            }];
        }
        else {
            [cloudFileSystem removeItemAtPath:path completion:completion];
        }
    }];
}

#pragma mark - Initial Checks

- (void)performInitialChecks
{
    if (![self checkIncompleteEvents]) return;
    
    if (self.isLeeched) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkCloudFileSystemIdentityWithCompletion:^(NSError *error) {
                if (error) CDELog(CDELoggingLevelError, @"Identity check failed: %@", error);
            }];
        });
    }
}

- (BOOL)checkIncompleteEvents
{
    BOOL succeeded = YES;
    if (eventStore.incompleteMandatoryEventIdentifiers.count > 0) {
        // Delay until after init... returns, because we want to inform the delegate
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (!self.isLeeched) return;
            [self deleechPersistentStoreWithCompletion:^(NSError *error) {
                if (!error) {
                    if ([self.delegate respondsToSelector:@selector(persistentStoreEnsemble:didDeleechWithError:)]) {
                        NSError *deleechError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeDataCorruptionDetected userInfo:nil];
                        [self.delegate persistentStoreEnsemble:self didDeleechWithError:deleechError];
                    }
                }
                else {
                    CDELog(CDELoggingLevelError, @"Could not deleech after failing incomplete event check: %@", error);
                }
            }];
        }];
        succeeded = NO;
    }
    else {
        // Submit a block, to monopolize the operation queue.
        // Without this, there could be unexpected deadlocks between this code and other
        // ongoing operations.
        [operationQueue addOperationWithBlock:^{
            NSManagedObjectContext *context = eventStore.managedObjectContext;
            [context performBlockAndWait:^{
                NSArray *incompleteEvents = [CDEStoreModificationEvent fetchStoreModificationEventsWithTypes:@[@(CDEStoreModificationEventTypeIncomplete)] persistentStoreIdentifier:nil inManagedObjectContext:context];
                for (CDEStoreModificationEvent *event in incompleteEvents) [context deleteObject:event];
                NSError *error;
                if (![context save:&error]) {
                    CDELog(CDELoggingLevelError, @"Failed to delete incomplete events: %@", error);
                }
            }];
        }];
    }
    
    return succeeded;
}

#pragma mark - Completing Operations

- (void)dispatchCompletion:(CDECompletionBlock)completion withError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) completion(error);
    });
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)kCDEIdentityTokenContext) {
        [self checkCloudFileSystemIdentityWithCompletion:NULL];
    }
}

#pragma mark - Posting Notifications

- (void)postDidBeginActivity:(CDEEnsembleActivity)activity {
    [[NSNotificationCenter defaultCenter] postNotificationName:CDEPersistentStoreEnsembleDidBeginActivityNotification object:self userInfo:@{CDEEnsembleActivityKey : @(activity)}];
}

- (void)postWillEndActivity:(CDEEnsembleActivity)activity error:(NSError*)error {
    NSDictionary *userInfo;
    if (error) {
        userInfo = @{CDEEnsembleActivityKey : @(activity),
                     CDEActivityErrorKey : error};
    } else {
        userInfo = @{CDEEnsembleActivityKey : @(activity)};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CDEPersistentStoreEnsembleWillEndActivityNotification object:self userInfo:userInfo];
}

#pragma mark - Progress

- (void)updateActivityProgressTo:(float)progress forPhase:(NSNumber *)phaseNumber
{
    CDEEnsembleActivity activity = self.currentActivity;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityProgress = progress;
        CDELog(CDELoggingLevelVerbose, @"Made progress: %f", self.activityProgress);
        
        NSDictionary *info = nil;
        if (phaseNumber)
            info = @{CDEProgressFractionKey : @(progress), CDEEnsembleActivityKey : @(activity), CDEActivityPhaseKey : phaseNumber};
        else
            info = @{CDEProgressFractionKey : @(progress), CDEEnsembleActivityKey : @(activity)};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CDEPersistentStoreEnsembleDidMakeProgressWithActivityNotification object:self userInfo:info];
    });
}

#pragma mark - Leeching Stores

- (void)leechPersistentStoreWithCompletion:(CDECompletionBlock)completion
{
    [self leechPersistentStoreWithSeedPolicy:CDESeedPolicyMergeAllData completion:completion];
}

- (void)leechPersistentStoreWithSeedPolicy:(CDESeedPolicy)policy completion:(CDECompletionBlock)completion
{
    NSAssert(self.cloudFileSystem, @"No cloud file system set");
    NSAssert([NSThread isMainThread], @"leech method called off main thread");
    
    CDELog(CDELoggingLevelTrace, @"Beginning leech");
    
    // Setup procedure of asynchronous steps
    CDEProcedure *procedure = [[CDEProcedure alloc] init];
    
    CDEProcedureStep *setupStep = [self newLeechSetupStep];
    [procedure addProcedureStep:setupStep];
    
    CDEProcedureStep *connectStep = [self newConnectStep];
    [procedure addProcedureStep:connectStep];
    
    CDEProcedureStep *primeStep = [self newPrimeCloudFileSystemForLeechStep];
    [procedure addProcedureStep:primeStep];
    
    CDEProcedureStep *initialPrepStep = [self newInitialPreparationStep];
    [procedure addProcedureStep:initialPrepStep];
    
    CDEProcedureStep *remoteStructureStep = [self newRemoteStructureStep];
    [procedure addProcedureStep:remoteStructureStep];
    
    CDEProcedureStep *eventStoreStep = [self newEventStoreStep];
    [procedure addProcedureStep:eventStoreStep];
    
    CDEProcedureStep *importStep = [self newImportStoreStepWithSeedPolicy:policy];
    [procedure addProcedureStep:importStep];
    
    CDEProcedureStep *completeLeechStep = [self newCompleteLeechStep];
    [procedure addProcedureStep:completeLeechStep];
    
    // Monitor progress
    __weak typeof(procedure) weakProcedure = procedure;
    procedure.progressUpdateBlock = ^{
        [self updateActivityProgressTo:weakProcedure.progress forPhase:weakProcedure.currentProcedureStep.representedObject];
    };
    
    // Proceed
    [procedure proceedInOperationQueue:operationQueue withCompletion:^(NSError *error) {
        if (error) CDELog(CDELoggingLevelError, @"Error caused leech to fail: %@", error);
        
        BOOL stateChangeError = (error != nil) && [error.domain isEqualToString:CDEErrorDomain] && error.code == CDEErrorCodeDisallowedStateChange;
        if (error && !stateChangeError) [eventStore removeEventStore:NULL];
        
        if (self.leeching) {
            [self postWillEndActivity:CDEEnsembleActivityLeeching error:error];
        }
        
        self.leeching = NO;
        self.currentActivity = CDEEnsembleActivityNone;
        
        if (completion) completion(error);
        
        CDELog(CDELoggingLevelTrace, @"Completed leech");
    }];
}

#pragma mark Leeching Steps

- (CDEProcedureStep *)newLeechSetupStep
{
    CDEProcedureStep *setupStep = [[CDEProcedureStep alloc] init];
    setupStep.representedObject = @(CDELeechingPhasePreparation);
    setupStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        self.nonCriticalErrorCodes = nil;

        if (self.isLeeched) {
            NSError *error = [[NSError alloc] initWithDomain:CDEErrorDomain code:CDEErrorCodeDisallowedStateChange userInfo:nil];
            next(error);
            return;
        }
        
        self.leeching = YES;
        self.currentActivity = CDEEnsembleActivityLeeching;
        
        // Notify of leeching
        [self postDidBeginActivity:CDEEnsembleActivityLeeching];
        
        next(nil);
    };
    return setupStep;
}

- (CDEProcedureStep *)newConnectStep
{
    CDEProcedureStep *connectStep = [[CDEProcedureStep alloc] init];
    connectStep.representedObject = @(CDELeechingPhasePreparation);
    connectStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudFileSystem connect:^(NSError *error) {
            next(error);
        }];
    };
    return connectStep;
}

- (CDEProcedureStep *)newPrimeCloudFileSystemForLeechStep
{
    CDEProcedureStep *primeStep = [[CDEProcedureStep alloc] init];
    primeStep.representedObject = @(CDELeechingPhasePreparation);
    primeStep.enabled = ([self.cloudFileSystem respondsToSelector:@selector(primeForActivityWithCompletion:)]);
    primeStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudFileSystem primeForActivityWithCompletion:^(NSError *error) {
            next(error);
        }];
    };
    return primeStep;
}

- (CDEProcedureStep *)newInitialPreparationStep
{
    CDEProcedureStep *initialPrepStep = [[CDEProcedureStep alloc] init];
    initialPrepStep.representedObject = @(CDELeechingPhasePreparation);
    initialPrepStep.enabled = ([self.cloudFileSystem respondsToSelector:@selector(performInitialPreparation:)]);
    initialPrepStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudFileSystem performInitialPreparation:^(NSError *error) {
            next(error);
        }];
    };
    return initialPrepStep;
}

- (CDEProcedureStep *)newRemoteStructureStep
{
    CDEProcedureStep *remoteStructureStep = [[CDEProcedureStep alloc] init];
    remoteStructureStep.representedObject = @(CDELeechingPhaseSettingUpCloudStructure);
    remoteStructureStep.progressWeight = 5.0;
    remoteStructureStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudManager setup];
        [self.cloudManager createRemoteDirectoryStructureWithCompletion:^(NSError *error) {
            next(error);
        }];
    };
    return remoteStructureStep;
}

- (CDEProcedureStep *)newEventStoreStep
{
    CDEProcedureStep *eventStoreStep = [[CDEProcedureStep alloc] init];
    eventStoreStep.representedObject = @(CDELeechingPhaseSettingUpLocalStructure);
    eventStoreStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudFileSystem fetchUserIdentityWithCompletion:^(id<NSObject,NSCoding,NSCopying> token, NSError *error) {
            if (error) {
                next(error);
                return;
            }
            
            eventStore.cloudFileSystemIdentityToken = token;
            BOOL success = [eventStore prepareNewEventStore:&error];
            self.leeched = success;
            
            next(error);
        }];
    };
    return eventStoreStep;
}

- (CDEProcedureStep *)newImportStoreStepWithSeedPolicy:(CDESeedPolicy)seedPolicy
{
    CDEPersistentStoreImporter *importer = [[CDEPersistentStoreImporter alloc] initWithPersistentStoreAtPath:self.persistentStoreURL.path managedObjectModel:self.managedObjectModel eventStore:self.eventStore];
    importer.persistentStoreOptions = self.persistentStoreOptions;
    importer.importPersistentStoreData = (seedPolicy == CDESeedPolicyMergeAllData);
    importer.ensemble = self;
    
    CDEProcedureStep *importStep = [[CDEProcedureStep alloc] init];
    importStep.representedObject = @(CDELeechingPhaseImportingPersistentStore);
    importStep.totalUnitCount = importer.numberOfProgressUnits;
    importStep.progressWeight = 50.0;
    
    __weak typeof(importStep) weakImportStep = importStep;
    importer.progressUnitsCompletionBlock = ^(NSUInteger numberOfNewUnitsCompleted) {
        weakImportStep.numberOfUnitsCompleted += numberOfNewUnitsCompleted;
    };
    
    importStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        // Listen for save notifications, and fail if a save to the store happens during the import
        saveOccurredDuringImport = NO;
        [self beginObservingSaveNotifications];
        
        // Inform delegate of import
        if ([self.delegate respondsToSelector:@selector(persistentStoreEnsembleWillImportStore:)]) {
            [self.delegate persistentStoreEnsembleWillImportStore:self];
        }
        
        [importer importWithCompletion:^(NSError *error) {
            [self endObservingSaveNotifications];
            
            if (nil == error) {
                // Store baseline
                self.eventStore.identifierOfBaselineUsedToConstructStore = [self.eventStore currentBaselineIdentifier];
                
                // Inform delegate
                if ([self.delegate respondsToSelector:@selector(persistentStoreEnsembleDidImportStore:)]) {
                    [self.delegate persistentStoreEnsembleDidImportStore:self];
                }
            }
            
            next(error);
        }];
    };
    
    return importStep;
}

- (CDEProcedureStep *)newCompleteLeechStep
{
    CDEProcedureStep *completeLeechStep = [[CDEProcedureStep alloc] init];
    completeLeechStep.representedObject = @(CDELeechingPhaseRegisteringPeer);
    completeLeechStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        // Deleech if a save occurred during import
        if (saveOccurredDuringImport) {
            NSError *error = nil;
            error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeSaveOccurredDuringLeeching userInfo:nil];
            next(error);
            return;
        }
        
        // Register in cloud
        NSDictionary *info = @{kCDEStoreIdentifierKey: self.eventStore.persistentStoreIdentifier, kCDELeechDate: [NSDate date]};
        [self.cloudManager setRegistrationInfo:info forStoreWithIdentifier:self.eventStore.persistentStoreIdentifier completion:^(NSError *error) {
            next(error);
        }];
    };
    return completeLeechStep;
}


#pragma mark Deleeching

- (void)deleechPersistentStoreWithCompletion:(CDECompletionBlock)completion
{
    NSAssert([NSThread isMainThread], @"Deleech method called off main thread");
    
    CDELog(CDELoggingLevelTrace, @"Enqueuing deleech");
    
    __block BOOL firedNotification = NO;
    CDEAsynchronousTaskBlock deleechTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        self.nonCriticalErrorCodes = nil;

        if (!self.isLeeched) {
            [eventStore removeEventStore:NULL];
            NSError *error = [[NSError alloc] initWithDomain:CDEErrorDomain code:CDEErrorCodeDisallowedStateChange userInfo:nil];
            next(error, NO);
            return;
        }
        
        CDELog(CDELoggingLevelTrace, @"Beginning deleech");
        
        self.deleeching = YES;
        self.currentActivity = CDEEnsembleActivityDeleeching;
        self.activityProgress = 0.0f;
        totalUnitsInActivity = 1;
        
        [self postDidBeginActivity:CDEEnsembleActivityDeleeching];
        firedNotification = YES;
        
        [eventStore removeEventStoreWithCompletion:^(NSError *error) {
            self.leeched = eventStore.containsEventData;
            next(error, NO);
        }];
    };
    
    CDEAsynchronousTaskQueue *deleechQueue = [[CDEAsynchronousTaskQueue alloc] initWithTask:deleechTask completion:^(NSError *error) {
        self.activityProgress = 1.0f;
        self.deleeching = NO;
        self.currentActivity = CDEEnsembleActivityNone;
        if (firedNotification) [self postWillEndActivity:CDEEnsembleActivityDeleeching error:error];
        [self dispatchCompletion:completion withError:error];
        CDELog(CDELoggingLevelTrace, @"Completed deleech");
    }];
    
    [operationQueue addOperation:deleechQueue];
}

#pragma mark Observing saves during import

- (void)beginObservingSaveNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextWillSave:) name:NSManagedObjectContextWillSaveNotification object:nil];
}

- (void)endObservingSaveNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:nil];
}

- (void)managedObjectContextWillSave:(NSNotification *)notif
{
    NSManagedObjectContext *context = notif.object;
    NSArray *stores = context.persistentStoreCoordinator.persistentStores;
    for (NSPersistentStore *store in stores) {
        NSURL *url1 = [self.persistentStoreURL URLByStandardizingPath];
        NSURL *url2 = [store.URL URLByStandardizingPath];
        if ([url1 isEqual:url2]) {
            saveOccurredDuringImport = YES;
            break;
        }
    }
}

#pragma mark Checks

- (void)forceDeleechDueToError:(NSError *)deleechError
{
    CDELog(CDELoggingLevelTrace, @"Forcing deleech due to error: %@", deleechError);
    if (!self.isLeeched) return;
    [self deleechPersistentStoreWithCompletion:^(NSError *error) {
        if (!error) {
            if ([self.delegate respondsToSelector:@selector(persistentStoreEnsemble:didDeleechWithError:)]) {
                [self.delegate persistentStoreEnsemble:self didDeleechWithError:deleechError];
            }
        }
        else {
            CDELog(CDELoggingLevelError, @"Could not force deleech");
        }
    }];
}

- (void)checkCloudFileSystemIdentityWithCompletion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Checking identity in cloud system");
    [self.cloudFileSystem fetchUserIdentityWithCompletion:^(id<NSObject,NSCoding,NSCopying> token, NSError *error) {
        BOOL identityValid = !token || [token isEqual:self.eventStore.cloudFileSystemIdentityToken];
        if (self.leeched && !identityValid && !error) {
            NSDictionary *info = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Cloud identity changed from %@ to %@. Forced to deleech", self.eventStore.cloudFileSystemIdentityToken, token]};
            CDELog(CDELoggingLevelError, @"Cloud identity changed from %@ to %@. Forced to deleech", self.eventStore.cloudFileSystemIdentityToken, token);
            NSError *deleechError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeCloudIdentityChanged userInfo:info];
            [self forceDeleechDueToError:deleechError];
            if (completion) completion(deleechError);
        }
        else {
            CDELog(CDELoggingLevelVerbose, @"Passed identity check with identity: %@", self.eventStore.cloudFileSystemIdentityToken);
            [self dispatchCompletion:completion withError:nil];
        }
    }];
}

- (void)checkStoreRegistrationInCloudWithCompletion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Checking registration info");
    
    if (!self.eventStore.verifiesStoreRegistrationInCloud) {
        [self dispatchCompletion:completion withError:nil];
        return;
    }
    
    NSString *storeId = self.eventStore.persistentStoreIdentifier;
    [self.cloudManager checkExistenceOfRegistrationInfoForStoreWithIdentifier:storeId completion:^(BOOL exists, NSError *error) {
        if (!error && !exists) {
            NSError *unregisteredError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeStoreUnregistered userInfo:nil];
            [self forceDeleechDueToError:unregisteredError];
            if (completion) completion(unregisteredError);
        }
        else {
            // If there was an error, can't conclude anything about registration state. Assume registered.
            // Don't want to deleech for no good reason.
            [self dispatchCompletion:completion withError:nil];
        }
    }];
}

- (NSString *)modelVersionHash {
    NSString *modelVersionHash = nil;
    if (self.compressModelHashes) {
        modelVersionHash = [self.managedObjectModel cde_compressedModelHash];
    }
    else {
        modelVersionHash = [self.managedObjectModel cde_entityHashesPropertyList];
    }
    return modelVersionHash;
}

#pragma mark Accessors

- (NSURL *)localDataRootDirectoryURL
{
    return [NSURL fileURLWithPath:self.eventStore.pathToEventDataRootDirectory];
}

#pragma mark Merging Changes

- (void)mergeWithCompletion:(CDECompletionBlock)completion
{
    [self mergeWithOptions:CDEMergeOptionsNone completion:completion];
}

- (void)mergeWithOptions:(CDEMergeOptions)mergeOptions completion:(CDECompletionBlock)completion
{
    NSAssert([NSThread isMainThread], @"Merge method called off main thread");
    
    CDELog(CDELoggingLevelTrace, @"Enqueuing merge");
    
    // Setup procedure from asynchronous steps
    CDEProcedure *procedure = [[CDEProcedure alloc] init];
    procedure.taskQueueInfo = kCDEMergeTaskInfo;
    
    CDEProcedureStep *setupStep = [self newMergeSetupStep];
    [procedure addProcedureStep:setupStep];
    
    CDEProcedureStep *primeStep = [self newPrimeCloudFileSystemForMergingStep];
    [procedure addProcedureStep:primeStep];
    
    CDEProcedureStep *repairStep = [self newRepairStep];
    [procedure addProcedureStep:repairStep];
    
    CDEProcedureStep *checkIdentityStep = [self newCheckIdentityStep];
    [procedure addProcedureStep:checkIdentityStep];
    
    CDEProcedureStep *checkRegistrationStep = [self newCheckRegistrationStep];
    [procedure addProcedureStep:checkRegistrationStep];
    
    CDEProcedureStep *processChangesStep = [self newProcessChangesStep];
    [procedure addProcedureStep:processChangesStep];
    
    CDEProcedureStep *snapshotRemoteFilesStep = [self newSnapshotRemoteFilesStep];
    [snapshotRemoteFilesStep addDependency:checkRegistrationStep];
    [snapshotRemoteFilesStep addDependency:checkIdentityStep];
    [snapshotRemoteFilesStep addDependency:repairStep];
    [snapshotRemoteFilesStep addDependency:primeStep];
    [procedure addProcedureStep:snapshotRemoteFilesStep];
    
    CDEProcedureStep *removeIncompleteFilesSetsStep = [self newRemoveIncompleteFileSetsStep];
    [removeIncompleteFilesSetsStep addDependency:snapshotRemoteFilesStep];
    [procedure addProcedureStep:removeIncompleteFilesSetsStep];
    
    CDEProcedureStep *removeOutOfDateNewlyImportedFilesStep = [self newRemoveOutOfDateNewlyImportedFilesStep];
    [removeOutOfDateNewlyImportedFilesStep addDependency:snapshotRemoteFilesStep];
    [procedure addProcedureStep:removeOutOfDateNewlyImportedFilesStep];
    
    CDEProcedureStep *importDataFilesStep = [self newImportDataFilesStep];
    [importDataFilesStep addDependency:snapshotRemoteFilesStep];
    [procedure addProcedureStep:importDataFilesStep];
    
    CDEProcedureStep *importBaselinesStep = [self newImportBaselinesStep];
    [importBaselinesStep addDependency:snapshotRemoteFilesStep];
    [procedure addProcedureStep:importBaselinesStep];
    
    CDEProcedureStep *mergeBaselinesStep = [self newMergeBaselinesStep];
    [procedure addProcedureStep:mergeBaselinesStep];
    
    CDEProcedureStep *importRemoteEventsStep = [self newImportRemoteEventsStep];
    [importRemoteEventsStep addDependency:snapshotRemoteFilesStep];
    [procedure addProcedureStep:importRemoteEventsStep];
    
    CDEProcedureStep *removeOutdatedEventsStep = [self newRemoveOutdatedEventsStep];
    [procedure addProcedureStep:removeOutdatedEventsStep];
    
    CDEProcedureStep *rebaseStep = [self newRebaseStep];
    [procedure addProcedureStep:rebaseStep];
    
    CDEProcedureStep *mergeEventsStep = [self newMergeEventsStep];
    [procedure addProcedureStep:mergeEventsStep];
    
    CDEProcedureStep *exportDataFilesStep = [self newExportDataFilesStep];
    [exportDataFilesStep addDependency:snapshotRemoteFilesStep];
    [procedure addProcedureStep:exportDataFilesStep];
    
    CDEProcedureStep *exportBaselinesStep = [self newExportBaselinesStep];
    [exportBaselinesStep addDependency:snapshotRemoteFilesStep];
    [procedure addProcedureStep:exportBaselinesStep];
    
    CDEProcedureStep *exportEventsStep = [self newExportEventsStep];
    [exportEventsStep addDependency:snapshotRemoteFilesStep];
    [procedure addProcedureStep:exportEventsStep];
    
    CDEProcedureStep *removeRemoteFilesStep = [self newRemoveRemoteFilesStep];
    [procedure addProcedureStep:removeRemoteFilesStep];
    
    // Apply options
    BOOL forceRebase = ((CDEMergeOptionsForceRebase & mergeOptions) != 0);
    BOOL suppressRebase = ((CDEMergeOptionsSuppressRebase & mergeOptions) != 0);
    BOOL retrieveCloudFilesOnly = ((CDEMergeOptionsCloudFileRetrievalOnly & mergeOptions) != 0);
    BOOL depositCloudFilesOnly = ((CDEMergeOptionsCloudFileDepositionOnly & mergeOptions) != 0);
    BOOL suppressDeposition = ((CDEMergeOptionsSuppressCloudFileDeposition & mergeOptions) != 0);
    
    NSAssert(!(retrieveCloudFilesOnly && depositCloudFilesOnly), @"Attempt to only retrieve files and only deposit files in one merge");
    
    if (retrieveCloudFilesOnly) {
        [procedure disableAllSteps];
        importDataFilesStep.enabled = YES;
        importBaselinesStep.enabled = YES;
        importRemoteEventsStep.enabled = YES;
    }
    else if (depositCloudFilesOnly) {
        [procedure disableAllSteps];
        exportDataFilesStep.enabled = YES;
        exportBaselinesStep.enabled = YES;
        exportEventsStep.enabled = YES;
    }
    
    NSAssert(!(forceRebase && suppressRebase), @"Attempt to force a rebase and suppress a rebase in one merge");
    
    if (forceRebase) {
        rebaser.forceRebase = YES;
        rebaseStep.enabled = YES;
    }
    else if (suppressRebase) {
        rebaseStep.enabled = NO;
    }
    
    NSAssert(!(suppressDeposition && depositCloudFilesOnly), @"Attempt suppress deposition and deposit at the same time");
    
    if (suppressDeposition) {
        exportDataFilesStep.enabled = NO;
        exportBaselinesStep.enabled = NO;
        exportEventsStep.enabled = NO;
    }
    
    // Setup progress monitoring
    __weak typeof(procedure) weakProcedure = procedure;
    procedure.progressUpdateBlock = ^{
        [self updateActivityProgressTo:weakProcedure.progress forPhase:weakProcedure.currentProcedureStep.representedObject];
    };
    
    // Proceed
    [procedure proceedInOperationQueue:operationQueue withCompletion:^(NSError *error) {
        [self postWillEndActivity:CDEEnsembleActivityMerging error:error];
        [self.eventIntegrator stopMonitoringSaves];
        self.merging = NO;
        self.currentActivity = CDEEnsembleActivityNone;
        if (completion) completion(error);
        CDELog(CDELoggingLevelTrace, @"Completing Merge");
    }];
}

- (void)cancelMergeWithCompletion:(CDECompletionBlock)completion
{
    NSAssert([NSThread isMainThread], @"cancel merge method called off main thread");
    CDELog(CDELoggingLevelTrace, @"Cancelling Merge");
    for (NSOperation *operation in operationQueue.operations) {
        if ([operation respondsToSelector:@selector(info)] && [[(id)operation info] isEqual:kCDEMergeTaskInfo]) {
            [operation cancel];
        }
    }
    [operationQueue addOperationWithBlock:^{
        [self dispatchCompletion:completion withError:nil];
    }];
}

#pragma mark Merge Procedure Steps

- (CDEProcedureStep *)newMergeSetupStep
{
    CDEProcedureStep *setupStep = [[CDEProcedureStep alloc] init];
    setupStep.representedObject = @(CDEMergingPhasePreparation);
    setupStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        CDELog(CDELoggingLevelTrace, @"Beginning merge");
        
        self.nonCriticalErrorCodes = nil;
        
        if (!self.leeched) {
            NSError *error = [[NSError alloc] initWithDomain:CDEErrorDomain code:CDEErrorCodeDisallowedStateChange userInfo:@{NSLocalizedDescriptionKey : @"Attempt to merge a store that is not leeched."}];
            next(error);
            return;
        }
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if (![fileManager fileExistsAtPath:persistentStoreURL.path]) {
            NSError *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeMissingStore userInfo:nil];
            next(error);
            return;
        }
        
        self.merging = YES;
        self.currentActivity = CDEEnsembleActivityMerging;
        
        [self postDidBeginActivity:CDEEnsembleActivityMerging];
        
        [self.eventIntegrator startMonitoringSaves]; // Will cancel merge if save occurs
        
        next(nil);
    };
    return setupStep;
}

- (CDEProcedureStep *)newRepairStep
{
    CDEProcedureStep *repairStep = [[CDEProcedureStep alloc] init];
    repairStep.representedObject = @(CDEMergingPhasePreparation);
    repairStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        if ([cloudFileSystem respondsToSelector:@selector(repairEnsembleDirectory:completion:)]) {
            [cloudFileSystem repairEnsembleDirectory:self.cloudManager.remoteEnsembleDirectory completion:^(NSError *error) {
                next(error);
            }];
        }
        else {
            next(nil);
        }
    };
    return repairStep;
}

- (CDEProcedureStep *)newPrimeCloudFileSystemForMergingStep
{
    CDEProcedureStep *primeStep = [[CDEProcedureStep alloc] init];
    primeStep.representedObject = @(CDEMergingPhasePreparation);
    primeStep.enabled = ([self.cloudFileSystem respondsToSelector:@selector(primeForActivityWithCompletion:)]);
    primeStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        if ([self.cloudFileSystem respondsToSelector:@selector(primeForActivityWithCompletion:)]) {
            [self.cloudFileSystem primeForActivityWithCompletion:^(NSError *error) {
                next(error);
            }];
        }
        else {
            next(nil);
        }
    };
    return primeStep;
}

- (CDEProcedureStep *)newCheckIdentityStep
{
    CDEProcedureStep *checkIdentityStep = [[CDEProcedureStep alloc] init];
    checkIdentityStep.representedObject = @(CDEMergingPhasePreparation);
    checkIdentityStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self checkCloudFileSystemIdentityWithCompletion:^(NSError *error) {
            next(error);
        }];
    };
    return checkIdentityStep;
}

- (CDEProcedureStep *)newCheckRegistrationStep
{
    CDEProcedureStep *checkRegistrationStep = [[CDEProcedureStep alloc] init];
    checkRegistrationStep.representedObject = @(CDEMergingPhasePreparation);
    checkRegistrationStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self checkStoreRegistrationInCloudWithCompletion:^(NSError *error) {
            next(error);
        }];
    };
    return checkRegistrationStep;
}

- (CDEProcedureStep *)newProcessChangesStep
{
    CDEProcedureStep *processChangesStep = [[CDEProcedureStep alloc] init];
    processChangesStep.representedObject = @(CDEMergingPhasePreparation);
    processChangesStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [eventStore flushWithCompletion:^(NSError *error) {
            next(error);
        }];
    };
    return processChangesStep;
}

- (CDEProcedureStep *)newSnapshotRemoteFilesStep
{
    CDEProcedureStep *snapshotRemoteFilesStep = [[CDEProcedureStep alloc] init];
    snapshotRemoteFilesStep.representedObject = @(CDEMergingPhasePreparation);
    snapshotRemoteFilesStep.progressWeight = 5.0;
    snapshotRemoteFilesStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudManager snapshotRemoteFilesWithCompletion:^(NSError *snapshotError) {
            if (snapshotError) {
                [self.cloudManager createRemoteDirectoryStructureWithCompletion:^(NSError *error) {
                    next(snapshotError);
                }];
            }
            else {
                next(nil);
            }
        }];
    };
    return snapshotRemoteFilesStep;
}

- (CDEProcedureStep *)newRemoveIncompleteFileSetsStep
{
    CDEProcedureStep *removeIncompleteFilesSetsStep = [[CDEProcedureStep alloc] init];
    removeIncompleteFilesSetsStep.representedObject = @(CDEMergingPhasePreparation);
    removeIncompleteFilesSetsStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudManager removeLocallyProducedIncompleteRemoteFileSets:^(NSError *error) {
            next(error);
        }];
    };
    return removeIncompleteFilesSetsStep;
}

- (CDEProcedureStep *)newRemoveOutOfDateNewlyImportedFilesStep
{
    CDEProcedureStep *removeOutOfDateNewlyImportedFilesStep = [[CDEProcedureStep alloc] init];
    removeOutOfDateNewlyImportedFilesStep.representedObject = @(CDEMergingPhasePreparation);
    removeOutOfDateNewlyImportedFilesStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        NSError *error = nil;
        [self.cloudManager removeOutOfDateNewlyImportedFiles:&error];
        next(error);
    };
    return removeOutOfDateNewlyImportedFilesStep;
}

- (CDEProcedureStep *)newImportDataFilesStep
{
    CDEProcedureStep *importDataFilesStep = [[CDEProcedureStep alloc] init];
    __weak typeof(importDataFilesStep) weakStep = importDataFilesStep;
    importDataFilesStep.representedObject = @(CDEMergingPhaseDataFileRetrieval);
    importDataFilesStep.progressWeight = 20.0;
    importDataFilesStep.totalUnitCount = 100;
    importDataFilesStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudManager importNewDataFilesWithProgress:^(NSError *error, float progress, BOOL isFinished) {
            if (error) [self.cloudManager setup];
            if (!error) weakStep.numberOfUnitsCompleted = progress * weakStep.totalUnitCount;
            if (error || isFinished) next(error);
        }];
    };
    return importDataFilesStep;
}

- (CDEProcedureStep *)newImportBaselinesStep
{
    CDEProcedureStep *importBaselinesStep = [[CDEProcedureStep alloc] init];
    __weak typeof(importBaselinesStep) weakStep = importBaselinesStep;
    importBaselinesStep.representedObject = @(CDEMergingPhaseBaselineRetrieval);
    importBaselinesStep.progressWeight = 20.0;
    importBaselinesStep.totalUnitCount = 100;
    importBaselinesStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudManager importNewBaselineEventsWithProgress:^(NSError *error, float progress, BOOL isFinished) {
            if (error) [self.cloudManager setup];
            if (!error) weakStep.numberOfUnitsCompleted =  progress * weakStep.totalUnitCount;
            if (error || isFinished) next(error);
        }];
    };
    return importBaselinesStep;
}

- (CDEProcedureStep *)newMergeBaselinesStep
{
    CDEProcedureStep *mergeBaselinesStep = [[CDEProcedureStep alloc] init];
    mergeBaselinesStep.representedObject = @(CDEMergingPhaseBaselineConsolidation);
    mergeBaselinesStep.progressWeight = 20.0;
    mergeBaselinesStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.baselineConsolidator consolidateBaselineWithCompletion:^(NSError *error) {
            if (self.baselineConsolidator.createdCompletelyNewBaseline) rebaseCheckDone = NO; // Good time to rebase
            next(error);
        }];
    };
    return mergeBaselinesStep;
}

- (CDEProcedureStep *)newImportRemoteEventsStep
{
    CDEProcedureStep *importRemoteEventsStep = [[CDEProcedureStep alloc] init];
    __weak typeof(importRemoteEventsStep) weakStep = importRemoteEventsStep;
    importRemoteEventsStep.representedObject = @(CDEMergingPhaseEventRetrieval);
    importRemoteEventsStep.progressWeight = 20.0;
    importRemoteEventsStep.totalUnitCount = 100;
    importRemoteEventsStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudManager importNewRemoteNonBaselineEventsWithProgress:^(NSError *error, float progress, BOOL isFinished) {
            if (error) [self.cloudManager setup];
            if (!error) weakStep.numberOfUnitsCompleted = progress * weakStep.totalUnitCount;
            if (error || isFinished) next(error);
        }];
    };
    return importRemoteEventsStep;
}

- (CDEProcedureStep *)newRemoveOutdatedEventsStep
{
    CDEProcedureStep *removeOutdatedEventsStep = [[CDEProcedureStep alloc] init];
    removeOutdatedEventsStep.representedObject = @(CDEMergingPhaseEventRetrieval);
    removeOutdatedEventsStep.progressWeight = 5.0;
    removeOutdatedEventsStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.rebaser deleteEventsPreceedingBaselineWithCompletion:^(NSError *error) {
            next(error);
        }];
    };
    return removeOutdatedEventsStep;
}

- (CDEProcedureStep *)newRebaseStep
{
    CDEProcedureStep *rebaseStep = [[CDEProcedureStep alloc] init];
    rebaseStep.representedObject = @(CDEMergingPhaseRebasing);
    rebaseStep.enabled = rebaser.forceRebase || !rebaseCheckDone;
    rebaseStep.progressWeight = 20.0;
    rebaseStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.rebaser shouldRebaseWithCompletion:^(BOOL result) {
            if (result) {
                [self.rebaser rebaseWithCompletion:^(NSError *error) {
                    rebaseCheckDone = YES;
                    next(error);
                }];
            }
            else {
                rebaseCheckDone = YES;
                next(nil);
            }
        }];
    };
    return rebaseStep;
}

- (CDEProcedureStep *)newMergeEventsStep
{
    CDEProcedureStep *mergeEventsStep = [[CDEProcedureStep alloc] init];
    mergeEventsStep.representedObject = @(CDEMergingPhaseIntegratingEvents);
    mergeEventsStep.totalUnitCount = self.eventIntegrator.numberOfProgressUnits;
    mergeEventsStep.progressWeight = 100.0;
    
    __weak typeof(mergeEventsStep) weakMergeEventsStep = mergeEventsStep;
    self.eventIntegrator.progressUnitsCompletionBlock = ^(NSUInteger numberOfNewUnitsCompleted) {
        weakMergeEventsStep.numberOfUnitsCompleted += numberOfNewUnitsCompleted;
    };
    
    mergeEventsStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.eventIntegrator mergeEventsWithCompletion:^(NSError *error) {
            // Store baseline id if everything went well
            if (nil == error) self.eventStore.identifierOfBaselineUsedToConstructStore = [self.eventStore currentBaselineIdentifier];
            next(error);
        }];
    };
    
    return mergeEventsStep;
}

- (CDEProcedureStep *)newExportDataFilesStep
{
    CDEProcedureStep *exportDataFilesStep = [[CDEProcedureStep alloc] init];
    __weak typeof(exportDataFilesStep) weakStep = exportDataFilesStep;
    exportDataFilesStep.representedObject = @(CDEMergingPhaseDataFileDeposition);
    exportDataFilesStep.progressWeight = 20.0;
    exportDataFilesStep.totalUnitCount = 100;
    exportDataFilesStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.eventStore removeUnreferencedDataFiles];
        [self.cloudManager exportDataFilesWithProgress:^(NSError *error, float progress, BOOL isFinished) {
            if (!error) weakStep.numberOfUnitsCompleted = progress * weakStep.totalUnitCount;
            if (error || isFinished) next(error);
        }];
    };
    return exportDataFilesStep;
}

- (CDEProcedureStep *)newExportBaselinesStep
{
    CDEProcedureStep *exportBaselinesStep = [[CDEProcedureStep alloc] init];
    __weak typeof(exportBaselinesStep) weakStep = exportBaselinesStep;
    exportBaselinesStep.representedObject = @(CDEMergingPhaseBaselineDeposition);
    exportBaselinesStep.progressWeight = 20.0;
    exportBaselinesStep.totalUnitCount = 100;
    exportBaselinesStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudManager exportNewLocalBaselineWithProgress:^(NSError *error, float progress, BOOL isFinished) {
            if (!error) weakStep.numberOfUnitsCompleted = progress * weakStep.totalUnitCount;
            if (error || isFinished) next(error);
        }];
    };
    return exportBaselinesStep;
}

- (CDEProcedureStep *)newExportEventsStep
{
    CDEProcedureStep *exportEventsStep = [[CDEProcedureStep alloc] init];
    __weak typeof(exportEventsStep) weakStep = exportEventsStep;
    exportEventsStep.representedObject = @(CDEMergingPhaseEventDeposition);
    exportEventsStep.progressWeight = 20.0;
    exportEventsStep.totalUnitCount = 100;
    exportEventsStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudManager exportNewLocalNonBaselineEventsWithProgress:^(NSError *error, float progress, BOOL isFinished) {
            if (!error) weakStep.numberOfUnitsCompleted = progress * weakStep.totalUnitCount;
            if (error || isFinished) next(error);
        }];
    };
    return exportEventsStep;
}

- (CDEProcedureStep *)newRemoveRemoteFilesStep
{
    CDEProcedureStep *removeRemoteFilesStep = [[CDEProcedureStep alloc] init];
    removeRemoteFilesStep.representedObject = @(CDEMergingPhaseFileDeletion);
    removeRemoteFilesStep.progressWeight = 5.0;
    removeRemoteFilesStep.executionBlock = ^(CDEProcedureStep *step, CDECompletionBlock next) {
        [self.cloudManager removeOutdatedRemoteFilesWithCompletion:^(NSError *error) {
            next(error);
        }];
    };
    return removeRemoteFilesStep;
}

#pragma mark Prepare for app termination

- (void)processPendingChangesWithCompletion:(CDECompletionBlock)completion
{
    NSAssert([NSThread isMainThread], @"Process pending changes invoked off main thread");
    
    CDELog(CDELoggingLevelTrace, @"Processing pending changes in ensemble");
    
    if (!self.leeched) {
        [self dispatchCompletion:completion withError:nil];
        return;
    }
    
    [operationQueue addOperationWithBlock:^{
        [eventStore flushWithCompletion:^(NSError *error) {
            [self dispatchCompletion:completion withError:error];
        }];
    }];
}

#pragma mark Global Identifiers

- (NSArray *)globalIdentifiersForManagedObjects:(NSArray *)objects
{
    NSArray *result = nil;
    if ([self.delegate respondsToSelector:@selector(persistentStoreEnsemble:globalIdentifiersForManagedObjects:)]) {
        result = [self.delegate persistentStoreEnsemble:self globalIdentifiersForManagedObjects:objects];
        NSAssert(result.count == objects.count, @"Wrong number of global identifiers returned from persistentStoreEnsemble:globalIdentifiersForManagedObjects:");
    }
    return result;
}

@end
