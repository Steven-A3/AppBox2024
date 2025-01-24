//
//  CDEStoreModificationEvent.m
//  Test App iOS
//
//  Created by Drew McCormack on 4/14/13.
//  Copyright (c) 2013 The Mental Faculty B.V. All rights reserved.
//

#import "CDEStoreModificationEvent.h"
#import "CDEDefines.h"
#import "CDEGlobalIdentifier.h"
#import "CDEEventRevision.h"
#import "CDERevisionSet.h"
#import "CDERevision.h"
#import "CDERevisionManager.h"


@implementation CDEStoreModificationEvent

@dynamic uniqueIdentifier;
@dynamic type;
@dynamic timestamp;
@dynamic eventRevision;
@dynamic eventRevisionsOfOtherStores;
@dynamic modelVersion;
@dynamic objectChanges;
@dynamic globalCount;


#pragma mark - Awaking

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    if (!self.uniqueIdentifier) self.uniqueIdentifier = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    if (!self.uniqueIdentifier) self.uniqueIdentifier = [[NSProcessInfo processInfo] globallyUniqueString];
}


#pragma mark - Revisions

- (CDERevisionSet *)revisionSet
{
    CDERevisionSet *set = [self revisionSetOfOtherStoresAtCreation];
    [set addRevision:self.eventRevision.revision];
    return set;
}

- (void)setRevisionSet:(CDERevisionSet *)newRevisionSet forPersistentStoreIdentifier:(NSString *)persistentStoreId
{
    NSManagedObjectContext *context = self.managedObjectContext;
    
    CDERevision *localRevision = [newRevisionSet revisionForPersistentStoreIdentifier:persistentStoreId];
    [newRevisionSet removeRevisionForPersistentStoreIdentifier:persistentStoreId];
    
    [self deleteEventRevisions];
    
    CDEEventRevision *eventRevision = [NSEntityDescription insertNewObjectForEntityForName:@"CDEEventRevision" inManagedObjectContext:context];
    eventRevision.persistentStoreIdentifier = persistentStoreId;
    eventRevision.revisionNumber = localRevision ? localRevision.revisionNumber : -1;
    eventRevision.storeModificationEvent = self;
    
    self.eventRevision = eventRevision;
    self.eventRevisionsOfOtherStores = [CDEEventRevision makeEventRevisionsForRevisionSet:newRevisionSet inManagedObjectContext:context];
    
    if (localRevision) [newRevisionSet addRevision:localRevision]; // Add back removed revision
}

- (void)setRevisionSetOfOtherStoresAtCreation:(CDERevisionSet *)newSet
{
    NSSet *eventRevisions = [CDEEventRevision makeEventRevisionsForRevisionSet:newSet inManagedObjectContext:self.managedObjectContext];
    self.eventRevisionsOfOtherStores = eventRevisions;
}

- (CDERevisionSet *)revisionSetOfOtherStoresAtCreation
{
    CDERevisionSet *set = [[CDERevisionSet alloc] init];
    for (CDEEventRevision *rev in self.eventRevisionsOfOtherStores) {
        [set addRevision:rev.revision];
    }
    return set;
}

- (void)deleteEventRevisions
{
    NSManagedObjectContext *context = self.managedObjectContext;
    if (self.eventRevision) [context deleteObject:self.eventRevision];
    if (self.eventRevisionsOfOtherStores) {
        for (CDEEventRevision *eventRev in [self.eventRevisionsOfOtherStores copy]) {
            [context deleteObject:eventRev];
        }
    }
    [context processPendingChanges];
}


#pragma mark - Fetching

+ (NSPredicate *)predicateForAllowedTypes:(NSArray *)types persistentStoreIdentifier:(NSString *)persistentStoreIdentifier
{
    NSPredicate *storePredicate = nil;
    if (persistentStoreIdentifier) {
        storePredicate = [NSPredicate predicateWithFormat:@"eventRevision.persistentStoreIdentifier = %@", persistentStoreIdentifier];
    }
    
    NSMutableArray *typePredicates = [[NSMutableArray alloc] init];
    for (NSNumber *typeNumber in types) {
        NSPredicate *p = [NSPredicate predicateWithFormat:@"type = %@", typeNumber];
        [typePredicates addObject:p];
    }
    
    NSPredicate *typePredicate = nil;
    if (typePredicates.count > 1) {
        typePredicate = [NSCompoundPredicate orPredicateWithSubpredicates:typePredicates];
    }
    else if (typePredicates.count == 1) {
        typePredicate = typePredicates.lastObject;
    }
    
    NSPredicate *predicate = nil;
    if (storePredicate == nil)
        predicate = typePredicate;
    else if (typePredicate == nil)
        predicate = storePredicate;
    else
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[storePredicate, typePredicate]];
    
    return predicate;
}

+ (NSArray *)fetchCompleteStoreModificationEventsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"NOT (type in %@)", @[@(CDEStoreModificationEventTypeIncomplete), @(CDEStoreModificationEventTypeBaselineMissingDependencies)]];
    fetch.relationshipKeyPathsForPrefetching = @[@"eventRevision"];
    
    NSError *error;
    NSArray *events = [context executeFetchRequest:fetch error:&error];
    if (!events) {
        CDELog(CDELoggingLevelError, @"Could not retrieve all events");
    }
    
    return events;
}

+ (NSArray *)fetchStoreModificationEventsWithTypes:(NSArray *)types persistentStoreIdentifier:(NSString *)persistentStoreIdentifier inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
    fetch.relationshipKeyPathsForPrefetching = @[@"eventRevision"];
    fetch.predicate = [self predicateForAllowedTypes:types persistentStoreIdentifier:persistentStoreIdentifier];
    
    NSError *error;
    NSArray *events = [context executeFetchRequest:fetch error:&error];
    if (!events) {
        CDELog(CDELoggingLevelError, @"Could not retrieve local events");
    }
    
    return events;
}

+ (instancetype)fetchStoreModificationEventWithUniqueIdentifier:(NSString *)uniqueId inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"CDEStoreModificationEvent"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier = %@", uniqueId];
    
    NSError *error;
    NSArray *events = [context executeFetchRequest:fetch error:&error];

    if (nil == events) CDELog(CDELoggingLevelError, @"Could not fetch store mod events: %@", error);
    if (events.count > 1) {
        CDELog(CDELoggingLevelError, @"Multiple events with same revision from same device found: %@", events);
        events = nil;
    }
    
    return events.lastObject;
}

+ (instancetype)fetchStoreModificationEventWithUniqueIdentifier:(NSString *)uniqueId globalCount:(CDEGlobalCount)count persistentStorePrefix:(NSString *)storePrefix inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"CDEStoreModificationEvent"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier = %@ AND globalCount = %lld AND eventRevision.persistentStoreIdentifier BEGINSWITH %@", uniqueId, count, storePrefix];
    
    NSError *error;
    NSArray *events = [context executeFetchRequest:fetch error:&error];

    if (nil == events) CDELog(CDELoggingLevelError, @"Could not fetch store mod events: %@", error);
    if (events.count > 1) {
        CDELog(CDELoggingLevelError, @"Multiple events with same revision from same device found: %@", events);
        events = nil;
    }
    
    return events.lastObject;
}

+ (instancetype)fetchStoreModificationEventWithAllowedTypes:(NSArray *)types persistentStoreIdentifier:(NSString *)persistentStoreId revisionNumber:(CDERevisionNumber)revision inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (persistentStoreId == nil || revision < 0) return nil;
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"CDEStoreModificationEvent"];
    NSPredicate *storeAndTypePredicate = [self predicateForAllowedTypes:types persistentStoreIdentifier:persistentStoreId];
    NSPredicate *revisionPredicate = [NSPredicate predicateWithFormat:@"eventRevision.revisionNumber = %lld", revision];
    fetch.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[storeAndTypePredicate, revisionPredicate]];
    
    NSError *error;
    NSArray *events = [context executeFetchRequest:fetch error:&error];
    
    if (nil == events) CDELog(CDELoggingLevelError, @"Could not fetch store mod events: %@", error);
    if (events.count > 1) {
        CDELog(CDELoggingLevelError, @"Multiple events with same revision from same device found: %@", events);
        events = nil;
    }
    
    return events.lastObject;
}

+ (instancetype)fetchNonBaselineEventForPersistentStoreIdentifier:(NSString *)persistentStoreId revisionNumber:(CDERevisionNumber)revision inManagedObjectContext:(NSManagedObjectContext *)context
{
    return [self fetchStoreModificationEventWithAllowedTypes:self.completeNonBaselineEventTypes persistentStoreIdentifier:persistentStoreId revisionNumber:revision inManagedObjectContext:context];
}

+ (NSArray *)completeNonBaselineEventTypes
{
    return @[@(CDEStoreModificationEventTypeSave), @(CDEStoreModificationEventTypeMerge)];
}

+ (NSArray *)fetchNonBaselineEventsForPersistentStoreIdentifier:(NSString *)persistentStoreId sinceRevisionNumber:(CDERevisionNumber)revision inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"CDEStoreModificationEvent"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"eventRevision.persistentStoreIdentifier = %@ AND eventRevision.revisionNumber > %lld AND type IN %@", persistentStoreId, revision, self.completeNonBaselineEventTypes];

    NSError *error;
    NSArray *events = [context executeFetchRequest:fetch error:&error];
    if (nil == events) CDELog(CDELoggingLevelError, @"Could not fetch store mod events: %@", error);

    return events;
}

+ (NSArray *)fetchNonBaselineEventsForPersistentStoreIdentifier:(NSString *)persistentStoreId inRevisionNumberRange:(NSRange)range inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"CDEStoreModificationEvent"];
    CDERevisionNumber minRevision = range.location;
    CDERevisionNumber maxRevision = range.location+range.length-1;
    fetch.predicate = [NSPredicate predicateWithFormat:@"eventRevision.persistentStoreIdentifier = %@ AND revisionNumber >= %lld AND revisionNumber <= %lld AND type IN %@", persistentStoreId, minRevision, maxRevision, self.completeNonBaselineEventTypes];
    
    NSError *error;
    NSArray *events = [context executeFetchRequest:fetch error:&error];
    if (nil == events) CDELog(CDELoggingLevelError, @"Could not fetch store mod events: %@", error);
    
    return events;
}

+ (instancetype)fetchBaselineEventInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSArray *events = [self fetchBaselineEventsInManagedObjectContext:context];
    NSAssert(events.count <= 1, @"Multiple baselines found where there should be one.");
    return events.lastObject;
}

+ (NSArray *)fetchBaselineEventsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"CDEStoreModificationEvent"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"type = %d", CDEStoreModificationEventTypeBaseline];
    
    NSError *error;
    NSArray *events = [context executeFetchRequest:fetch error:&error];
    if (!events) CDELog(CDELoggingLevelError, @"Could not fetch baselines: %@", error);
    
    return [CDERevisionManager sortStoreModificationEvents:events];
}

+ (NSArray *)fetchNonBaselineEventsUpToGlobalCount:(CDEGlobalCount)globalCount inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSError *error;
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"type IN %@ AND globalCount <= %lld", self.completeNonBaselineEventTypes, globalCount];
    NSArray *events = [context executeFetchRequest:fetch error:&error];
    if (!events) CDELog(CDELoggingLevelError, @"Could not fetch events: %@", error);
    return [CDERevisionManager sortStoreModificationEvents:events];
}

+ (NSArray *)fetchNonBaselineEventsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSError *error;
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"type IN %@", self.completeNonBaselineEventTypes];
    NSArray *events = [context executeFetchRequest:fetch error:&error];
    if (!events) CDELog(CDELoggingLevelError, @"Could not fetch events: %@", error);
    return [CDERevisionManager sortStoreModificationEvents:events];
}

+ (void)prefetchRelatedObjectsForStoreModificationEvents:(NSArray *)storeModEvents
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEObjectChange"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"storeModificationEvent IN %@", storeModEvents];
    fetch.relationshipKeyPathsForPrefetching = @[@"globalIdentifier"];
    fetch.fetchLimit = 10000;
    NSManagedObjectContext *context = [storeModEvents.lastObject managedObjectContext];
    [context executeFetchRequest:fetch error:NULL];
}

#pragma mark - Sorting

+ (NSArray *)sortDescriptorsForEvents
{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"globalCount" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"eventRevision.persistentStoreIdentifier" ascending:YES]];
}

@end
