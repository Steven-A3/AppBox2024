//
//  CDEPersistentStoreImporter.m
//  Ensembles
//
//  Created by Drew McCormack on 21/09/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import "CDEPersistentStoreImporter.h"
#import "CDEStoreModificationEvent.h"
#import "NSManagedObjectContext+CDEAdditions.h"
#import "CDEEventStore.h"
#import "CDEEventBuilder.h"
#import "CDEEventRevision.h"

@implementation CDEPersistentStoreImporter

@synthesize persistentStorePath = persistentStorePath;
@synthesize eventStore = eventStore;
@synthesize managedObjectModel = managedObjectModel;
@synthesize ensemble = ensemble;
@synthesize persistentStoreOptions = persistentStoreOptions;
@synthesize importPersistentStoreData = importPersistentStoreData;
@synthesize progressUnitsCompletionBlock;

- (id)initWithPersistentStoreAtPath:(NSString *)newPath managedObjectModel:(NSManagedObjectModel *)newModel eventStore:(CDEEventStore *)newEventStore;
{
    self = [super init];
    if (self) {
        persistentStorePath = [newPath copy];
        eventStore = newEventStore;
        managedObjectModel = newModel;
        persistentStoreOptions = nil;
        importPersistentStoreData = YES;
    }
    return self;
}

- (NSUInteger)numberOfProgressUnits
{
    return managedObjectModel.entities.count * 2;
}

- (void)importWithCompletion:(CDECompletionBlock)completion
{
    CDELog(CDELoggingLevelTrace, @"Importing persistent store");

    __block NSError *error = nil;
    CDEEventBuilder *eventBuilder = [self makeEventBuilder];
    
    // If not importing data, just finalize the event and complete
    if (!self.importPersistentStoreData) {
        NSError *localError;
        CDELog(CDELoggingLevelTrace, @"Saving");
        [eventBuilder finalizeNewEvent];
        BOOL success = [eventBuilder saveAndReset:&localError];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(success ? nil : localError);
        });
        return;
    }
    
    // If importing, setup a context
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context performBlockAndWait:^{
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        context.persistentStoreCoordinator = coordinator;
        context.undoManager = nil;
        
        __block id store;
        NSURL *storeURL = [NSURL fileURLWithPath:persistentStorePath];
        NSDictionary *options = self.persistentStoreOptions;
        if (!options) options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
        
        if ([coordinator respondsToSelector:@selector(performBlockAndWait:)]) {
            [coordinator performBlockAndWait:^{
                NSError *localError = nil;
                store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&localError];
                if (!store) error = localError;
            }];
        }
        else {
            [(id)coordinator lock];
            NSError *localError = nil;
            store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&localError];
            [(id)coordinator unlock];
            if (!store) error = localError;
        }
    }];
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(error);
        });
        return;
    }
    
    __block BOOL success = YES;
    [context performBlock:^{
        @try {
            // Add global ids for all objects first. Otherwise we can't setup relationships.
            CDELog(CDELoggingLevelTrace, @"Adding Global Identifiers");
            NSError *localError = nil;
            success = [self addGlobalIdentifiersWithEventBuilder:eventBuilder forObjectsInContext:context error:&localError];
            if (!success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(localError);
                });
                return;
            }
            
            // Now generate object changes.
            CDELog(CDELoggingLevelTrace, @"Adding Object Changes");
            success = [self addObjectChangesWithEventBuilder:eventBuilder forObjectsInContext:context error:&localError];
            
            // Finalize event, which makes its type no longer incomplete
            if (success) {
                CDELog(CDELoggingLevelTrace, @"Saving");
                [eventBuilder finalizeNewEvent];
                success = [eventBuilder saveAndReset:&localError];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(success ? nil : localError);
            });
        }
        @catch ( NSException *exception ) {
            NSDictionary *info = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Exception during store import: %@", exception]};
            error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeExceptionRaised userInfo:info];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(error);
            });
        }
    }];
}

- (CDEEventBuilder *)makeEventBuilder
{
    CDEEventBuilder *eventBuilder = [[CDEEventBuilder alloc] initWithEventStore:self.eventStore];
    eventBuilder.ensemble = self.ensemble;
    [eventBuilder makeNewEventOfType:CDEStoreModificationEventTypeBaseline uniqueIdentifier:nil];
    [eventBuilder performBlockAndWait:^{
        // Use distant past for the time, so the leeched data gets less
        // priority than existing data.
        eventBuilder.event.globalCount = 0;
        eventBuilder.event.timestamp = [[NSDate distantPast] timeIntervalSinceReferenceDate];
    }];
    return eventBuilder;
}

- (BOOL)addGlobalIdentifiersWithEventBuilder:(CDEEventBuilder *)eventBuilder forObjectsInContext:(NSManagedObjectContext *)context error:(NSError * __autoreleasing *)error
{
    __block BOOL success = YES;
    if (error) *error = nil;
    NSArray *entities = [managedObjectModel cde_entitiesOrderedByMigrationPriority];
    for (NSEntityDescription *entity in entities) {
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:entity.name];
        fetch.returnsObjectsAsFaults = NO;
        fetch.includesSubentities = NO;
        
        success = [context cde_enumerateObjectsForFetchRequest:fetch withBatchSize:500 withBlock:^(NSArray *objects, NSUInteger remaining, BOOL *stop) {
            NSArray *globalIDStrings = [eventBuilder retrieveGlobalIdentifierStringsForManagedObjects:objects storedInEventStore:NO];
            NSArray *objectIDs = [objects valueForKeyPath:@"objectID"];
            [eventBuilder addGlobalIdentifiersForManagedObjectIDs:objectIDs identifierStrings:globalIDStrings];
            BOOL saveSucceeded = [eventBuilder saveAndReset:error];
            [context reset];
            if (!saveSucceeded) *stop = YES;
        }];
        
        if (!success) break;
        
        if (self.progressUnitsCompletionBlock) self.progressUnitsCompletionBlock(1);
    }
    if (error && !success && !(*error)) *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeUnknown userInfo:nil];
    return success;
}

- (BOOL)addObjectChangesWithEventBuilder:(CDEEventBuilder *)eventBuilder forObjectsInContext:(NSManagedObjectContext *)context error:(NSError * __autoreleasing *)error
{
    __block BOOL success = YES;
    if (error) *error = nil;
    NSArray *entities = [managedObjectModel cde_entitiesOrderedByMigrationPriority];
    for (NSEntityDescription *entity in entities) {
        CDELog(CDELoggingLevelVerbose, @"Importing Entity %@", entity.name);
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:entity.name];
        fetch.returnsObjectsAsFaults = NO;
        fetch.includesSubentities = NO;
        
        NSInteger batchSize = entity.cde_migrationBatchSize ? : 500;
        success = [context cde_enumerateObjectsForFetchRequest:fetch withBatchSize:batchSize withBlock:^(NSArray *objects, NSUInteger remaining, BOOL *stop) {
            CDELog(CDELoggingLevelVerbose, @"Approx. objects remaining for this entity: %lu", (unsigned long)remaining * batchSize);

            NSSet *objectsSet = [NSSet setWithArray:objects];
            [eventBuilder addChangesForInsertedObjects:objectsSet objectsAreSaved:YES useGlobalIdentifiersInEventStore:YES inManagedObjectContext:context];
            BOOL saveSucceeded = [eventBuilder saveAndReset:error];
            [context reset];
            if (!saveSucceeded) *stop = YES;
        }];
        
        if (!success) break;
        
        if (self.progressUnitsCompletionBlock) self.progressUnitsCompletionBlock(1);
    }
    if (error && !success && !(*error)) *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeUnknown userInfo:nil];
    return success;
}

@end

