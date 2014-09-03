//
//  CDEPersistentStoreEnsemble.m
//  Ensembles
//
//  Created by Drew McCormack on 4/11/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import "CDEPersistentStoreEnsemble.h"
#import "CDEPersistentStoreEnsemble+Private.h"
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

NSString * const CDEMonitoredManagedObjectContextWillSaveNotification = @"CDEMonitoredManagedObjectContextWillSaveNotification";
NSString * const CDEMonitoredManagedObjectContextDidSaveNotification = @"CDEMonitoredManagedObjectContextDidSaveNotification";
NSString * const CDEPersistentStoreEnsembleDidSaveMergeChangesNotification = @"CDEPersistentStoreEnsembleDidSaveMergeChangesNotification";
NSString * const CDEPersistentStoreEnsembleDidBeginActivityNotification = @"CDEPersistentStoreEnsembleDidBeginActivityNotification";
NSString * const CDEPersistentStoreEnsembleDidMakeProgressWithActivityNotification = @"CDEPersistentStoreEnsembleDidMakeProgressWithActivityNotification";
NSString * const CDEPersistentStoreEnsembleWillEndActivityNotification = @"CDEPersistentStoreEnsembleWillEndActivityNotification";

NSString * const CDEManagedObjectContextSaveNotificationKey = @"managedObjectContextSaveNotification";
NSString * const CDEEnsembleActivityKey = @"CDEEnsembleActivityKey";
NSString * const CDEProgressFractionKey = @"CDEProgressFractionKey";


@implementation CDEPersistentStoreEnsemble {
    BOOL saveOccurredDuringImport;
    NSOperationQueue *operationQueue;
    BOOL rebaseCheckDone;
    BOOL observingIdentityToken;
}

@synthesize cloudFileSystem = cloudFileSystem;
@synthesize ensembleIdentifier = ensembleIdentifier;
@synthesize storeURL = storeURL;
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

- (instancetype)initWithEnsembleIdentifier:(NSString *)identifier persistentStoreURL:(NSURL *)newStoreURL persistentStoreOptions:(NSDictionary *)storeOptions managedObjectModelURL:(NSURL *)modelURL cloudFileSystem:(id <CDECloudFileSystem>)newCloudFileSystem localDataRootDirectoryURL:(NSURL *)eventDataRootURL
{
    NSParameterAssert(identifier != nil);
    NSParameterAssert(newStoreURL != nil);
    NSParameterAssert(modelURL != nil);
    NSParameterAssert(newCloudFileSystem != nil);
    self = [super init];
    if (self) {
        persistentStoreOptions = storeOptions;
        
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
        
        observingIdentityToken = NO;
        rebaseCheckDone = NO;
        
        self.ensembleIdentifier = identifier;
        self.storeURL = newStoreURL;
        self.managedObjectModelURL = modelURL;
        self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        self.cloudFileSystem = newCloudFileSystem;
    
        self.eventStore = [[CDEEventStore alloc] initWithEnsembleIdentifier:self.ensembleIdentifier pathToEventDataRootDirectory:eventDataRootURL.path];
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
    NSURL *url = self.storeURL;
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

- (void)dealloc
{
    if (observingIdentityToken) [(id)self.cloudFileSystem removeObserver:self forKeyPath:@"identityToken"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [saveMonitor stopMonitoring];
}

#pragma mark - Discovering and Managing Ensembles

+ (void)retrieveEnsembleIdentifiersFromCloudFileSystem:(id <CDECloudFileSystem>)cloudFileSystem completion:(void(^)(NSError *error, NSArray *identifiers))completion
{
    [cloudFileSystem contentsOfDirectoryAtPath:@"/" completion:^(NSArray *contents, NSError *error) {
        NSArray *names = [contents valueForKeyPath:@"name"];
        if (completion) completion(error, names);
    }];
}

+ (void)removeEnsembleWithIdentifier:(NSString *)identifier inCloudFileSystem:(id <CDECloudFileSystem>)cloudFileSystem completion:(void(^)(NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"/%@", identifier];
    [cloudFileSystem removeItemAtPath:path completion:completion];
}

#pragma mark - Initial Checks

- (void)performInitialChecks
{
    if (![self checkIncompleteEvents]) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkCloudFileSystemIdentityWithCompletion:^(NSError *error) {
            if (!error) {
                observingIdentityToken = YES;
                [(id)self.cloudFileSystem addObserver:self forKeyPath:@"identityToken" options:0 context:(__bridge void *)kCDEIdentityTokenContext];
            }
        }];
    });
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

#pragma mark - Progress

- (void)resetProgress
{
    numberOfUnitsCompleted = 0;
    self.activityProgress = 0.0f;
    CDELog(CDELoggingLevelVerbose, @"Reset progress");
}

- (void)incrementProgress
{
    [self incrementProgressBy:1];
}

- (void)incrementProgressBy:(NSUInteger)incrementAmount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        numberOfUnitsCompleted += incrementAmount;
        self.activityProgress = numberOfUnitsCompleted / (float)MAX(1, totalUnitsInActivity);
        CDELog(CDELoggingLevelVerbose, @"Made progress: %f", self.activityProgress);
        
        NSDictionary *info = @{CDEProgressFractionKey : @(self.activityProgress), CDEEnsembleActivityKey : @(self.currentActivity)};
        [[NSNotificationCenter defaultCenter] postNotificationName:CDEPersistentStoreEnsembleDidMakeProgressWithActivityNotification object:self userInfo:info];
    });
}

#pragma mark - Leeching and Deleeching Stores

- (void)leechPersistentStoreWithCompletion:(CDECompletionBlock)completion;
{
    NSAssert(self.cloudFileSystem, @"No cloud file system set");
    NSAssert([NSThread isMainThread], @"leech method called off main thread");
    
    CDELog(CDELoggingLevelTrace, @"Beginning leech");
    
    __weak typeof(self) weakSelf = self;
    NSMutableArray *tasks = [NSMutableArray array];
    
    CDEPersistentStoreImporter *importer = [[CDEPersistentStoreImporter alloc] initWithPersistentStoreAtPath:self.storeURL.path managedObjectModel:self.managedObjectModel eventStore:self.eventStore];
    importer.persistentStoreOptions = self.persistentStoreOptions;
    importer.ensemble = self;

    CDEAsynchronousTaskBlock setupTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        if (self.isLeeched) {
            NSError *error = [[NSError alloc] initWithDomain:CDEErrorDomain code:CDEErrorCodeDisallowedStateChange userInfo:nil];
            next(error, NO);
            return;
        }
        
        self.leeching = YES;
        self.currentActivity = CDEEnsembleActivityLeeching;
        totalUnitsInActivity = tasks.count + importer.numberOfProgressUnits;
        [self resetProgress];
        
        // Notify of leeching
        [[NSNotificationCenter defaultCenter] postNotificationName:CDEPersistentStoreEnsembleDidBeginActivityNotification object:self userInfo:@{CDEEnsembleActivityKey : @(CDEEnsembleActivityLeeching)}];
        
        [self incrementProgress];
        next(nil, NO);
    };
    [tasks addObject:setupTask];

    CDEAsynchronousTaskBlock connectTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudFileSystem connect:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:connectTask];
    
    if ([self.cloudFileSystem respondsToSelector:@selector(performInitialPreparation:)]) {
        CDEAsynchronousTaskBlock initialPrepTask = ^(CDEAsynchronousTaskCallbackBlock next) {
            [self.cloudFileSystem performInitialPreparation:^(NSError *error) {
                [self incrementProgress];
                next(error, NO);
            }];
        };
        [tasks addObject:initialPrepTask];
    }

    CDEAsynchronousTaskBlock remoteStructureTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudManager createRemoteDirectoryStructureWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:remoteStructureTask];
    
    CDEAsynchronousTaskBlock eventStoreTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self setupEventStoreWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:eventStoreTask];
    
    CDEAsynchronousTaskBlock importTask = ^(CDEAsynchronousTaskCallbackBlock next) {
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
            
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:importTask];
    
    CDEAsynchronousTaskBlock completeLeechTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        // Deleech if a save occurred during import
        if (saveOccurredDuringImport) {
            NSError *error = nil;
            error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeSaveOccurredDuringLeeching userInfo:nil];
            [self incrementProgress];
            next(error, NO);
            return;
        }
        
        // Register in cloud
        NSDictionary *info = @{kCDEStoreIdentifierKey: self.eventStore.persistentStoreIdentifier, kCDELeechDate: [NSDate date]};
        [self.cloudManager setRegistrationInfo:info forStoreWithIdentifier:self.eventStore.persistentStoreIdentifier completion:^(NSError *error) {
            [weakSelf incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:completeLeechTask];
    
    CDEAsynchronousTaskQueue *taskQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:tasks terminationPolicy:CDETaskQueueTerminationPolicyStopOnError completion:^(NSError *error) {
        if (error) [eventStore removeEventStore];
        
        if (self.leeching) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CDEPersistentStoreEnsembleWillEndActivityNotification object:self userInfo:@{CDEEnsembleActivityKey : @(CDEEnsembleActivityLeeching)}];
        }
        
        self.leeching = NO;
        self.currentActivity = CDEEnsembleActivityNone;
        [self dispatchCompletion:completion withError:error];
        
        CDELog(CDELoggingLevelTrace, @"Completed leech");
    }];
    
    [operationQueue addOperation:taskQueue];
}

- (void)setupEventStoreWithCompletion:(CDECompletionBlock)completion
{    
    NSError *error = nil;
    eventStore.cloudFileSystemIdentityToken = self.cloudFileSystem.identityToken;
    BOOL success = [eventStore prepareNewEventStore:&error];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.leeched = success;
        if (completion) completion(error);
    });
}

- (void)deleechPersistentStoreWithCompletion:(CDECompletionBlock)completion
{
    NSAssert([NSThread isMainThread], @"Deleech method called off main thread");
    
    CDELog(CDELoggingLevelTrace, @"Enqueuing deleech");

    __block BOOL firedNotification = NO;
    CDEAsynchronousTaskBlock deleechTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        if (!self.isLeeched) {
            [eventStore removeEventStore];
            NSError *error = [[NSError alloc] initWithDomain:CDEErrorDomain code:CDEErrorCodeDisallowedStateChange userInfo:nil];
            next(error, NO);
            return;
        }
        
        CDELog(CDELoggingLevelTrace, @"Beginning deleech");
        
        self.deleeching = YES;
        self.currentActivity = CDEEnsembleActivityDeleeching;
        totalUnitsInActivity = 1;
        [self resetProgress];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CDEPersistentStoreEnsembleDidBeginActivityNotification object:self userInfo:@{CDEEnsembleActivityKey : @(CDEEnsembleActivityDeleeching)}];
        firedNotification = YES;
        
        BOOL removedStore = [eventStore removeEventStore];
        self.leeched = eventStore.containsEventData;
        
        NSError *error = nil;
        if (!removedStore) error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeUnknown userInfo:nil];
        next(error, NO);
    };
    
    CDEAsynchronousTaskQueue *deleechQueue = [[CDEAsynchronousTaskQueue alloc] initWithTask:deleechTask completion:^(NSError *error) {
        [self incrementProgress];
        self.deleeching = NO;
        self.currentActivity = CDEEnsembleActivityNone;
        if (firedNotification) [[NSNotificationCenter defaultCenter] postNotificationName:CDEPersistentStoreEnsembleWillEndActivityNotification object:self userInfo:@{CDEEnsembleActivityKey : @(CDEEnsembleActivityDeleeching)}];
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
        NSURL *url1 = [self.storeURL URLByStandardizingPath];
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
    BOOL identityValid = [self.cloudFileSystem.identityToken isEqual:self.eventStore.cloudFileSystemIdentityToken];
    if (self.leeched && !identityValid) {
        NSError *deleechError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeCloudIdentityChanged userInfo:nil];
        [self forceDeleechDueToError:deleechError];
        if (completion) completion(deleechError);
    }
    else {
        [self dispatchCompletion:completion withError:nil];
    }
}

- (void)checkStoreRegistrationInCloudWithCompletion:(CDECompletionBlock)completion
{
    if (!self.eventStore.verifiesStoreRegistrationInCloud) {
        [self dispatchCompletion:completion withError:nil];
        return;
    }
    
    NSString *storeId = self.eventStore.persistentStoreIdentifier;
    [self.cloudManager retrieveRegistrationInfoForStoreWithIdentifier:storeId completion:^(NSDictionary *info, NSError *error) {
        if (!error && !info) {
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

#pragma mark Accessors

- (NSURL *)localDataRootDirectoryURL
{
    return [NSURL fileURLWithPath:self.eventStore.pathToEventDataRootDirectory];
}

#pragma mark Merging Changes

- (void)mergeWithCompletion:(CDECompletionBlock)completion
{
    NSAssert([NSThread isMainThread], @"Merge method called off main thread");
    
    CDELog(CDELoggingLevelTrace, @"Enqueuing merge");
    
    NSMutableArray *tasks = [NSMutableArray array];
    
    CDEAsynchronousTaskBlock setupTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        CDELog(CDELoggingLevelTrace, @"Beginning merge");

        if (!self.leeched) {
            NSError *error = [[NSError alloc] initWithDomain:CDEErrorDomain code:CDEErrorCodeDisallowedStateChange userInfo:@{NSLocalizedDescriptionKey : @"Attempt to merge a store that is not leeched."}];
            next(error, NO);
            return;
        }
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if (![fileManager fileExistsAtPath:storeURL.path]) {
            NSError *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeMissingStore userInfo:nil];
            next(error, NO);
            return;
        }
        
        self.merging = YES;
        self.currentActivity = CDEEnsembleActivityMerging;
        totalUnitsInActivity = tasks.count + self.eventIntegrator.numberOfProgressUnits;
        [self resetProgress];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CDEPersistentStoreEnsembleDidBeginActivityNotification object:self userInfo:@{CDEEnsembleActivityKey : @(CDEEnsembleActivityMerging)}];
        
        [self.eventIntegrator startMonitoringSaves]; // Will cancel merge if save occurs
        
        [self incrementProgress];
        next(nil, NO);
    };
    [tasks addObject:setupTask];
    
    CDEAsynchronousTaskBlock checkIdentityTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self checkCloudFileSystemIdentityWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:checkIdentityTask];
    
    CDEAsynchronousTaskBlock checkRegistrationTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self checkStoreRegistrationInCloudWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:checkRegistrationTask];
    
    CDEAsynchronousTaskBlock processChangesTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [eventStore flushWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:processChangesTask];
    
    CDEAsynchronousTaskBlock remoteStructureTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudManager createRemoteDirectoryStructureWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:remoteStructureTask];
    
    CDEAsynchronousTaskBlock snapshotRemoteFilesTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudManager snapshotRemoteFilesWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:snapshotRemoteFilesTask];
    
    CDEAsynchronousTaskBlock removeIncompleteFileSetsTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudManager removeLocallyProducedIncompleteRemoteFileSets:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:removeIncompleteFileSetsTask];

    CDEAsynchronousTaskBlock removeOutOfDateNewlyImportedFiles = ^(CDEAsynchronousTaskCallbackBlock next) {
        NSError *error = nil;
        [self.cloudManager removeOutOfDateNewlyImportedFiles:&error];
        [self incrementProgress];
        next(error, NO);
    };
    [tasks addObject:removeOutOfDateNewlyImportedFiles];

    CDEAsynchronousTaskBlock importDataFilesTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudManager importNewDataFilesWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:importDataFilesTask];

    CDEAsynchronousTaskBlock importBaselinesTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudManager importNewBaselineEventsWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:importBaselinesTask];
    
    CDEAsynchronousTaskBlock mergeBaselinesTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.baselineConsolidator consolidateBaselineWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:mergeBaselinesTask];
    
    CDEAsynchronousTaskBlock importRemoteEventsTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudManager importNewRemoteNonBaselineEventsWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:importRemoteEventsTask];
    
    CDEAsynchronousTaskBlock removeOutdatedEventsTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.rebaser deleteEventsPreceedingBaselineWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:removeOutdatedEventsTask];
    
    CDEAsynchronousTaskBlock rebaseTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        if (rebaseCheckDone && !rebaser.forceRebase) {
            [self incrementProgress];
            next(nil, NO);
            return;
        }
        
        [self.rebaser shouldRebaseWithCompletion:^(BOOL result) {
            if (result) {
                [self.rebaser rebaseWithCompletion:^(NSError *error) {
                    rebaseCheckDone = YES;
                    [self incrementProgress];
                    next(error, NO);
                }];
            }
            else {
                rebaseCheckDone = YES;
                [self incrementProgress];
                next(nil, NO);
            }
        }];
    };
    [tasks addObject:rebaseTask];
    
    CDEAsynchronousTaskBlock mergeEventsTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.eventIntegrator mergeEventsWithCompletion:^(NSError *error) {
            // Store baseline id if everything went well
            if (nil == error) self.eventStore.identifierOfBaselineUsedToConstructStore = [self.eventStore currentBaselineIdentifier];
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:mergeEventsTask];
    
    CDEAsynchronousTaskBlock exportDataFilesTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.eventStore removeUnreferencedDataFiles];
        [self.cloudManager exportDataFilesWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:exportDataFilesTask];
    
    CDEAsynchronousTaskBlock exportBaselinesTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudManager exportNewLocalBaselineWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:exportBaselinesTask];
    
    CDEAsynchronousTaskBlock exportEventsTask = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudManager exportNewLocalNonBaselineEventsWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:exportEventsTask];
    
    CDEAsynchronousTaskBlock removeRemoteFiles = ^(CDEAsynchronousTaskCallbackBlock next) {
        [self.cloudManager removeOutdatedRemoteFilesWithCompletion:^(NSError *error) {
            [self incrementProgress];
            next(error, NO);
        }];
    };
    [tasks addObject:removeRemoteFiles];
    
    CDEAsynchronousTaskQueue *taskQueue = [[CDEAsynchronousTaskQueue alloc] initWithTasks:tasks terminationPolicy:CDETaskQueueTerminationPolicyStopOnError completion:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CDEPersistentStoreEnsembleWillEndActivityNotification object:self userInfo:@{CDEEnsembleActivityKey : @(CDEEnsembleActivityMerging)}];
        [self.eventIntegrator stopMonitoringSaves];
        self.merging = NO;
        self.currentActivity = CDEEnsembleActivityNone;
        [self dispatchCompletion:completion withError:error];
        CDELog(CDELoggingLevelTrace, @"Completing Merge");
    }];
    
    taskQueue.info = kCDEMergeTaskInfo;
    [operationQueue addOperation:taskQueue];
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

- (void)stopMonitoringSaves
{
    NSAssert([NSThread isMainThread], @"stop monitor method called off main thread");
    [saveMonitor stopMonitoring];
}

#pragma mark Global Identifiers

- (NSArray *)globalIdentifiersForManagedObjects:(NSArray *)objects
{
    NSArray *result = nil;
    if ([self.delegate respondsToSelector:@selector(persistentStoreEnsemble:globalIdentifiersForManagedObjects:)]) {
        result = [self.delegate persistentStoreEnsemble:self globalIdentifiersForManagedObjects:objects];
    }
    return result;
}

@end
