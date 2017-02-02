//
//  CDERevisionManager.m
//  Ensembles
//
//  Created by Drew McCormack on 25/08/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import "CDERevisionManager.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "CDEEventStore.h"
#import "CDEDataFile.h"
#import "CDERevision.h"
#import "CDERevisionSet.h"
#import "CDEEventRevision.h"
#import "CDEStoreModificationEvent.h"

BOOL CDEPerformIntegrabilityChecks = YES;

@implementation CDERevisionManager

@synthesize eventStore = eventStore;
@synthesize eventManagedObjectContext = eventManagedObjectContext;

#pragma mark Initialization

- (instancetype)initWithEventStore:(CDEEventStore *)newStore eventManagedObjectContext:(NSManagedObjectContext *)newContext
{
    self = [super init];
    if (self) {
        eventStore = newStore;
        eventManagedObjectContext = newContext;
    }
    return self;
}

- (instancetype)initWithEventStore:(CDEEventStore *)newStore
{
    return [self initWithEventStore:newStore eventManagedObjectContext:newStore.managedObjectContext];
}

#pragma mark Fetching from Event Store

+ (NSArray *)sortStoreModificationEvents:(NSArray *)events
{
    // Sort in save order. Use store id to disambiguate in unlikely event of identical timestamps.
    NSArray *sortDescriptors = [CDEStoreModificationEvent sortDescriptorsForEvents];
    return [events sortedArrayUsingDescriptors:sortDescriptors];
}

- (NSArray *)fetchUncommittedStoreModificationEvents:(NSError * __autoreleasing *)error
{
    __block NSArray *result = nil;
    [eventManagedObjectContext performBlockAndWait:^{
        CDEStoreModificationEvent *lastMergeEvent = [CDEStoreModificationEvent fetchNonBaselineEventForPersistentStoreIdentifier:eventStore.persistentStoreIdentifier revisionNumber:eventStore.lastMergeRevisionSaved inManagedObjectContext:eventManagedObjectContext];
        CDEStoreModificationEvent *baseline = [CDEStoreModificationEvent fetchBaselineEventInManagedObjectContext:eventManagedObjectContext];
        CDERevisionSet *baselineRevisionSet = baseline.revisionSet;

        CDERevisionSet *fromRevisionSet = lastMergeEvent.revisionSet;
        if (!fromRevisionSet) { // No previous merge
            fromRevisionSet = baselineRevisionSet ? : [CDERevisionSet new];
        }
        
        // Determine which stores have appeared since last merge
        NSSet *allStoreIds = [CDEEventRevision fetchPersistentStoreIdentifiersInManagedObjectContext:eventManagedObjectContext];
        NSSet *lastMergeStoreIds = fromRevisionSet.persistentStoreIdentifiers;
        NSMutableSet *missingStoreIds = [NSMutableSet setWithSet:allStoreIds];
        [missingStoreIds minusSet:lastMergeStoreIds];
        
        NSMutableArray *events = [[NSMutableArray alloc] init];
        for (CDEEventRevision *revision in fromRevisionSet.revisions) {
            NSArray *recentEvents = [CDEStoreModificationEvent fetchNonBaselineEventsForPersistentStoreIdentifier:revision.persistentStoreIdentifier sinceRevisionNumber:revision.revisionNumber inManagedObjectContext:eventManagedObjectContext];
            [events addObjectsFromArray:recentEvents];
        }
        
        for (NSString *persistentStoreId in missingStoreIds) {
            CDERevision *baselineRevision = [baselineRevisionSet revisionForPersistentStoreIdentifier:persistentStoreId];
            CDERevisionNumber revNumber = baselineRevision ? baselineRevision.revisionNumber : -1;
            NSArray *recentEvents = [CDEStoreModificationEvent fetchNonBaselineEventsForPersistentStoreIdentifier:persistentStoreId sinceRevisionNumber:revNumber inManagedObjectContext:eventManagedObjectContext];
            [events addObjectsFromArray:recentEvents];
        }
        
        result = [self.class sortStoreModificationEvents:events];
    }];
    return result;
}

- (NSArray *)fetchStoreModificationEventsConcurrentWithEvents:(NSArray *)events error:(NSError *__autoreleasing *)error
{
    if (events.count == 0) return @[];
    
    __block NSArray *result = nil;
    [eventManagedObjectContext performBlockAndWait:^{
        CDEStoreModificationEvent *baseline = [CDEStoreModificationEvent fetchBaselineEventInManagedObjectContext:eventManagedObjectContext];
        CDERevisionSet *baselineRevisionSet = baseline.revisionSet;

        CDERevisionSet *minSet = [[CDERevisionSet alloc] init];
        for (CDEStoreModificationEvent *event in events) {
            CDERevisionSet *revSet = event.revisionSet;
            minSet = [minSet revisionSetByTakingStoreWiseMinimumWithRevisionSet:revSet];
        }
        
        // Add concurrent events from the stores present in the events passed in
        NSManagedObjectContext *context = [events.lastObject managedObjectContext];
        NSMutableSet *concurrentEvents = [[NSMutableSet alloc] initWithArray:events]; // Events are concurrent with themselves
        for (CDERevision *minRevision in minSet.revisions) {
            NSArray *recentEvents = [CDEStoreModificationEvent fetchNonBaselineEventsForPersistentStoreIdentifier:minRevision.persistentStoreIdentifier sinceRevisionNumber:minRevision.revisionNumber inManagedObjectContext:context];
            [concurrentEvents addObjectsFromArray:recentEvents];
        }
        
        // Determine which stores are missing from the events
        NSSet *allStoreIds = [CDEEventRevision fetchPersistentStoreIdentifiersInManagedObjectContext:context];
        NSMutableSet *missingStoreIds = [NSMutableSet setWithSet:allStoreIds];
        [missingStoreIds minusSet:minSet.persistentStoreIdentifiers];
        
        // Add events from the missing stores
        for (NSString *persistentStoreId in missingStoreIds) {
            CDERevision *baselineRevision = [baselineRevisionSet revisionForPersistentStoreIdentifier:persistentStoreId];
            CDERevisionNumber revNumber = baselineRevision ? baselineRevision.revisionNumber : -1;
            NSArray *recentEvents = [CDEStoreModificationEvent fetchNonBaselineEventsForPersistentStoreIdentifier:persistentStoreId sinceRevisionNumber:revNumber inManagedObjectContext:context];
            [concurrentEvents addObjectsFromArray:recentEvents];
        }
        
        result = [self.class sortStoreModificationEvents:concurrentEvents.allObjects];
    }];
    
    return result;
}

- (NSArray *)recursivelyFetchStoreModificationEventsConcurrentWithEvents:(NSArray *)events error:(NSError *__autoreleasing *)error
{
    NSArray *resultEvents = events;
    NSUInteger eventCount = 0;
    while (resultEvents.count != eventCount) {
        eventCount = resultEvents.count;
        resultEvents = [self fetchStoreModificationEventsConcurrentWithEvents:resultEvents error:error];
        if (!resultEvents) return nil;
    }
    return resultEvents;
}

#pragma mark Integrable Events

- (BOOL)eventPassesBasicIntegrabilityChecks:(CDEStoreModificationEvent *)event informativeErrorCode:(CDEErrorCode *)errorCode
{
    if (errorCode) *errorCode = 0;
    if (!event) return NO;
    
    BOOL hasKnownModel = [self checkModelVersionsOfStoreModificationEvents:@[event]];
    if (!hasKnownModel) {
        if (errorCode) *errorCode = CDEErrorCodeUnknownModelVersion;
        return NO;
    }
    
    BOOL hasAllDataFiles = [self checkAllDataFilesExistForStoreModificationEvents:@[event]];
    return hasAllDataFiles;
}

- (NSArray *)integrableEventsFromEvents:(NSArray *)events informativeErrorCodes:(NSSet * __autoreleasing *)errorCodes
{
    CDELog(CDELoggingLevelTrace, @"Determining integrable events");
    
    if (errorCodes) *errorCodes = nil;
    
    if (!CDEPerformIntegrabilityChecks) return events;
    
    NSMutableArray *integrableEvents = [events mutableCopy];
    NSMutableSet *informativeErrorCodes = [NSMutableSet set];
    
    [eventManagedObjectContext performBlockAndWait:^{
        CDEStoreModificationEvent *baseline = [CDEStoreModificationEvent fetchBaselineEventInManagedObjectContext:eventManagedObjectContext];
        
        // Check baseline
        CDEErrorCode errorCode = 0;
        BOOL baselineIsIntegrable = [self eventPassesBasicIntegrabilityChecks:baseline informativeErrorCode:&errorCode];
        if (!baselineIsIntegrable) {
            if (errorCode) {
                [informativeErrorCodes addObject:@(errorCode)];
                CDELog(CDELoggingLevelVerbose, @"Informative error codes: %@", informativeErrorCodes);
            }
            
            CDELog(CDELoggingLevelVerbose, @"Baseline is not integrable. There are no integrable events.");
            
            [integrableEvents removeAllObjects];
            return;
        }
        
        // Run basic integrability tests
        NSMutableSet *failingEvents = [NSMutableSet set];
        for (CDEStoreModificationEvent *event in [integrableEvents copy]) {
            @autoreleasepool {
                errorCode = 0;
                if (![self eventPassesBasicIntegrabilityChecks:event informativeErrorCode:&errorCode]) {
                    CDELog(CDELoggingLevelVerbose, @"Not including event because didn't pass integrabililty criteria: %@", event);
                    
                    if (errorCode) {
                        [informativeErrorCodes addObject:@(errorCode)];
                        CDELog(CDELoggingLevelVerbose, @"Informative error code: %li", (long)errorCode);
                    }
                    
                    [failingEvents addObject:event];
                    [integrableEvents removeObject:event];
                }
            }
        }
        
        // Remove events where there is a revision discontinuitity in device event history
        // Repeat until there is no change
        NSUInteger eventCount;
        do {
            @autoreleasepool {
                eventCount = integrableEvents.count;
                
                NSArray *revisionSets = [integrableEvents valueForKeyPath:@"revisionSet"];
                CDERevisionSet *minimumSet = [CDERevisionSet revisionSetByTakingStoreWiseMinimumOfRevisionSets:revisionSets];
                CDERevisionSet *maximumSet = [CDERevisionSet revisionSetByTakingStoreWiseMaximumOfRevisionSets:revisionSets];
                CDERevisionSet *baselineRevisionSet = baseline.revisionSet;
                
                NSMutableSet *stores = [[NSMutableSet alloc] init];
                if (baselineRevisionSet) [stores unionSet:baselineRevisionSet.persistentStoreIdentifiers];
                if (minimumSet) [stores unionSet:minimumSet.persistentStoreIdentifiers];
                if (maximumSet) [stores unionSet:maximumSet.persistentStoreIdentifiers];
                
                for (NSString *store in stores) {
                    CDELog(CDELoggingLevelVerbose, @"Checking store: %@", store);
                    
                    CDERevision *minRevision = [minimumSet revisionForPersistentStoreIdentifier:store];
                    CDERevision *maxRevision = [maximumSet revisionForPersistentStoreIdentifier:store];
                    CDERevision *baselineRevision = [baselineRevisionSet revisionForPersistentStoreIdentifier:store];
                    CDELog(CDELoggingLevelVerbose, @"Revision range: %@ %@", minRevision, maxRevision);
                    
                    if (!minRevision || !maxRevision) continue;
                    
                    BOOL discontinuous = (baselineRevision == nil);
                    for (CDERevisionNumber r = minRevision.revisionNumber; r <= maxRevision.revisionNumber; r++) {
                        
                        CDEStoreModificationEvent *event = [CDEStoreModificationEvent fetchNonBaselineEventForPersistentStoreIdentifier:store revisionNumber:r inManagedObjectContext:eventManagedObjectContext];
                        
                        if (!event) {
                            // If there is a missing event after the baseline,
                            // all future events are invalidated by the discontinuity
                            if (r > baselineRevision.revisionNumber) discontinuous = YES;
                            continue;
                        }
                        
                        // Event exists, now check it
                        if (discontinuous || r <= baselineRevision.revisionNumber) {
                            [failingEvents addObject:event];
                            [integrableEvents removeObject:event];
                            CDELog(CDELoggingLevelVerbose, @"Removed event for revision %lli due to preceeding baseline or discontinuity in history", r);
                        }
                        else {
                            // Check that dependencies are valid
                            NSSet *otherStoreRevs = event.eventRevisionsOfOtherStores;
                            for (CDEEventRevision *otherStoreRev in otherStoreRevs) {
                                CDERevision *otherStoreBaselineRev = [baselineRevisionSet revisionForPersistentStoreIdentifier:otherStoreRev.persistentStoreIdentifier];
                                if (otherStoreBaselineRev.revisionNumber >= otherStoreRev.revisionNumber) continue;
                                CDEStoreModificationEvent *dependency = [CDEStoreModificationEvent fetchNonBaselineEventForPersistentStoreIdentifier:otherStoreRev.persistentStoreIdentifier revisionNumber:otherStoreRev.revisionNumber inManagedObjectContext:event.managedObjectContext];
                                if (!dependency || [failingEvents containsObject:dependency]) {
                                    [failingEvents addObject:event];
                                    [integrableEvents removeObject:event];
                                    CDELog(CDELoggingLevelVerbose, @"Removed event for revision %lli due to invalid or missing dependency", r);
                                }
                            }
                        }
                        
                    }
                }
            }
        } while (eventCount != integrableEvents.count);
    }];
    
    if (errorCodes && informativeErrorCodes.count > 0) *errorCodes = [informativeErrorCodes copy];

    return integrableEvents;
}

#pragma mark Checks

- (BOOL)checkDependenciesOfBaseline:(CDEStoreModificationEvent *)baseline informativeErrorCode:(CDEErrorCode *)errorCode
{
    return [self eventPassesBasicIntegrabilityChecks:baseline informativeErrorCode:errorCode];
}

- (NSArray *)modelHashesForAllVersionsInModelAtURL:(NSURL *)url hashGenerator:(id(^)(NSManagedObjectModel *model))generator
{
    NSMutableArray *entityHashDictionaries = [[NSMutableArray alloc] initWithCapacity:10];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    BOOL isDir;
    if (![fileManager fileExistsAtPath:url.path isDirectory:&isDir]) {
        @throw [NSException exceptionWithName:CDEException reason:@"Could not find model file" userInfo:nil];
    }
    else if (!isDir) {
        // A single file is an unversioned model
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
        id hash = generator(model);
        if (hash) [entityHashDictionaries addObject:hash];
    }
    else {
        // Treat a directory as a versioned model
        NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtURL:url includingPropertiesForKeys:nil options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:NULL];
        for (NSURL *fileURL in dirEnum) {
            if ([fileURL.pathExtension isEqualToString:@"mom"]) {
                NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:fileURL];
                id hash = generator(model);
                if (hash) [entityHashDictionaries addObject:hash];
            }
        }
    }
    
    return entityHashDictionaries;
}

- (NSArray *)entityHashesByNameForAllVersionsInModelAtURL:(NSURL *)url
{
    return [self modelHashesForAllVersionsInModelAtURL:url hashGenerator:^id(NSManagedObjectModel *model) {
        return [model entityVersionHashesByName];
    }];
}

- (NSArray *)compressedModelHashesForAllVersionsInModelAtURL:(NSURL *)url
{
    return [self modelHashesForAllVersionsInModelAtURL:url hashGenerator:^id(NSManagedObjectModel *model) {
        return [model cde_compressedModelHash];
    }];
}

- (BOOL)checkModelVersionsOfStoreModificationEvents:(NSArray *)events
{
    if (!self.managedObjectModelURL) return YES;
    
    NSArray *localEntityDictionaries = [self entityHashesByNameForAllVersionsInModelAtURL:self.managedObjectModelURL];
    NSArray *localCompressedModelHashes = [self compressedModelHashesForAllVersionsInModelAtURL:self.managedObjectModelURL];
    
    for (CDEStoreModificationEvent *event in events) {
        NSString *modelVersion = event.modelVersion;
        if (!modelVersion) continue;
        
        BOOL eventModelIsInLocalModel = NO;
        if ([modelVersion hasPrefix:@"md5"]) {
            eventModelIsInLocalModel = [localCompressedModelHashes containsObject:modelVersion];
        } else {
            NSDictionary *eventEntityHashes = [NSManagedObjectModel cde_entityHashesByNameFromPropertyList:modelVersion];
            if (!eventEntityHashes) continue;
            for (NSDictionary *localEntityHashes in localEntityDictionaries) {
                eventModelIsInLocalModel = [localEntityHashes isEqualToDictionary:eventEntityHashes];
                if (eventModelIsInLocalModel) break;
            }
        }
        
        if (!eventModelIsInLocalModel) return NO;
    }
    
    return YES;
}


- (BOOL)checkContinuityOfStoreModificationEvents:(NSArray *)events
{
    __block BOOL result = YES;
    [eventManagedObjectContext performBlockAndWait:^{
        NSSet *stores = [NSSet setWithArray:[events valueForKeyPath:@"eventRevision.persistentStoreIdentifier"]];
        NSArray *sortDescs = @[[NSSortDescriptor sortDescriptorWithKey:@"eventRevision.revisionNumber" ascending:YES]];
        for (NSString *persistentStoreId in stores) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventRevision.persistentStoreIdentifier = %@ AND type != %d AND type != %d", persistentStoreId, CDEStoreModificationEventTypeBaseline, CDEStoreModificationEventTypeIncomplete];
            NSArray *storeEvents = [events filteredArrayUsingPredicate:predicate];
            storeEvents = [storeEvents sortedArrayUsingDescriptors:sortDescs];
            if (storeEvents.count == 0) continue;
            
            CDEStoreModificationEvent *firstEvent = storeEvents[0];
            CDERevisionNumber revision = firstEvent.eventRevision.revisionNumber;
            for (CDEStoreModificationEvent *event in storeEvents) {
                CDERevisionNumber nextRevision = event.eventRevision.revisionNumber;
                if (nextRevision - revision > 1) {
                    result = NO;
                    return;
                }
                revision = nextRevision;
            }
        }
    }];
    return result;
}

- (BOOL)checkAllDataFilesExistForStoreModificationEvents:(NSArray *)events
{
    __block BOOL result = YES;
    [eventManagedObjectContext performBlockAndWait:^{
        NSSet *filenamesInEvents = [CDEDataFile filenamesInStoreModificationEvents:events];
        NSSet *filenames = self.eventStore.allDataFilenames;
        result = [filenamesInEvents isSubsetOfSet:filenames];
        if (!result) {
            NSMutableSet *missingFilenames = [filenamesInEvents mutableCopy];
            [missingFilenames minusSet:filenames];
            CDELog(CDELoggingLevelVerbose, @"Some data files are missing: %@", missingFilenames);
        }
    }];
    return result;
}

- (BOOL)checkThatLocalPersistentStoreHasNotBeenAbandoned:(NSError * __autoreleasing *)error
{
    __block BOOL passed = NO;
    [eventManagedObjectContext performBlockAndWait:^{
        // Check for merge events newer than baseline. Ignore save events, because they may get generated at any time, and could be based on a newly imported baseline.
        NSArray *localMergeEvents = [CDEStoreModificationEvent fetchStoreModificationEventsWithTypes:@[@(CDEStoreModificationEventTypeMerge)] persistentStoreIdentifier:self.eventStore.persistentStoreIdentifier inManagedObjectContext:eventManagedObjectContext];
        CDEStoreModificationEvent *baseline = [CDEStoreModificationEvent fetchBaselineEventInManagedObjectContext:eventManagedObjectContext];
        
        // If the baseline is just for this device, we have just leeched, so not abandoned
        CDERevision *baselineRevision = [baseline.revisionSet revisionForPersistentStoreIdentifier:self.eventStore.persistentStoreIdentifier];
        if (baseline.revisionSet.revisions.count == 1 && baselineRevision) {
            passed = YES;
            return;
        }
        
        // Check for a merge event ordered fully after the baseline
        for (CDEStoreModificationEvent *event in localMergeEvents) {
            if ([event.revisionSet compare:baseline.revisionSet] == NSOrderedDescending) {
                // This event comes after baseline, so store is not abandoned
                passed = YES;
                return;
            }
        }
    }];
    return passed;
}

#pragma mark Global Count

- (CDEGlobalCount)maximumGlobalCount
{
    __block long long maxCount = -1;
    [eventManagedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"type != %d", CDEStoreModificationEventTypeIncomplete];
        
        NSArray *result = [eventManagedObjectContext executeFetchRequest:fetch error:NULL];
        if (!result) @throw [NSException exceptionWithName:CDEException reason:@"Failed to get global count" userInfo:nil];
        if (result.count == 0) return;
        
        NSNumber *max = [result valueForKeyPath:@"@max.globalCount"];
        maxCount = max.longLongValue;
    }];
    return maxCount;
}

#pragma mark Maximum (Latest) Revisions

- (CDERevisionSet *)revisionSetOfMostRecentIntegrableEvents
{
    __block CDERevisionSet *set = nil;
    [eventManagedObjectContext performBlockAndWait:^{
        NSArray *allEvents = [CDEStoreModificationEvent fetchCompleteStoreModificationEventsInManagedObjectContext:eventManagedObjectContext];
        NSArray *integratableEvents = [self integrableEventsFromEvents:allEvents informativeErrorCodes:NULL];
        
        NSMutableArray *allRevisions = [NSMutableArray array];
        [allRevisions addObjectsFromArray:[integratableEvents valueForKeyPath:@"eventRevision"]];
        [allRevisions addObjectsFromArray:[[integratableEvents valueForKeyPath:@"@unionOfSets.eventRevisionsOfOtherStores"] allObjects]];

        set = [[CDERevisionSet alloc] init];
        for (CDEEventRevision *eventRevision in allRevisions) {
            NSString *identifier = eventRevision.persistentStoreIdentifier;
            CDERevision *currentRecentRevision = [set revisionForPersistentStoreIdentifier:identifier];
            if (!currentRecentRevision || currentRecentRevision.revisionNumber < eventRevision.revisionNumber) {
                if (currentRecentRevision) [set removeRevision:currentRecentRevision];
                [set addRevision:eventRevision.revision];
            }
        }
    }];
    return set;
}

#pragma mark Checkpoint Revisions

- (CDERevisionSet *)revisionSetForLastMergeOrBaseline
{
    __block CDERevisionSet *newRevisionSet = nil;
    [eventManagedObjectContext performBlockAndWait:^{
        CDERevisionNumber lastMergeRevision = eventStore.lastMergeRevisionSaved;
        NSString *persistentStoreId = self.eventStore.persistentStoreIdentifier;
        CDEStoreModificationEvent *lastMergeEvent = [CDEStoreModificationEvent fetchNonBaselineEventForPersistentStoreIdentifier:persistentStoreId revisionNumber:lastMergeRevision inManagedObjectContext:eventManagedObjectContext];
        
        newRevisionSet = lastMergeEvent.revisionSet;
        if (!newRevisionSet) {
            // No previous merge exists. Try baselines.
            NSArray *baselines = [CDEStoreModificationEvent fetchBaselineEventsInManagedObjectContext:eventManagedObjectContext];
            newRevisionSet = [CDERevisionSet revisionSetByTakingStoreWiseMaximumOfRevisionSets:[baselines valueForKeyPath:@"revisionSet"]];
        }
    }];
    return newRevisionSet;
}

#pragma mark Persistent Stores

- (NSSet *)persistentStoreIdentifiersIncludedInIntegrableEvents
{
    CDERevisionSet *latestRevisionSet = [self revisionSetOfMostRecentIntegrableEvents];
    return latestRevisionSet.persistentStoreIdentifiers;
}

@end
