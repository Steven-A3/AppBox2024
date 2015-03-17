//
//  CDEManagedObjectContextSaveMonitor.m
//  Test App iOS
//
//  Created by Drew McCormack on 4/16/13.
//  Copyright (c) 2013 The Mental Faculty B.V. All rights reserved.
//

#import "CDESaveMonitor.h"
#import "NSMapTable+CDEAdditions.h"
#import "CDEPersistentStoreEnsemble.h"
#import "CDEEventBuilder.h"
#import "CDEEventIntegrator.h"
#import "CDEDefines.h"
#import "CDEEventRevision.h"
#import "CDERevision.h"
#import "CDERevisionSet.h"
#import "CDEFoundationAdditions.h"
#import "CDEEventStore.h"
#import "CDEStoreModificationEvent.h"
#import "CDEPropertyChangeValue.h"


@implementation CDESaveMonitor {
    NSMapTable *changedValuesByContext;
}

- (instancetype)initWithStorePath:(NSString *)newPath
{
    self = [super init];
    if (self) {
        self.storePath = [newPath copy];
        changedValuesByContext = [NSMapTable cde_strongToStrongObjectsMapTable];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextWillSave:) name:NSManagedObjectContextWillSaveNotification object:nil];
    }
    return self;
}

- (instancetype) init
{
    return [self initWithStorePath:nil];
}

- (void)dealloc
{
    [self stopMonitoring];
}


#pragma mark Stopping Monitoring

- (void)stopMonitoring
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark Determining which contexts to monitor

- (NSPersistentStore *)monitoredPersistentStoreInManagedObjectContext:(NSManagedObjectContext *)context
{
    if (context.parentContext) return nil;
    
    // Check if this context includes the monitored store
    NSPersistentStoreCoordinator *psc = context.persistentStoreCoordinator;
    NSArray *stores = psc.persistentStores;
    NSURL *monitoredStoreURL = [NSURL fileURLWithPath:self.storePath];
    NSPersistentStore *monitoredStore = nil;
    for (NSPersistentStore *store in stores) {
        NSURL *url1 = [store.URL URLByStandardizingPath];
        NSURL *url2 = [monitoredStoreURL URLByStandardizingPath];
        if ([url1 isEqual:url2]) {
            monitoredStore = store;
            break;
        }
    }
    
    return monitoredStore;
}


#pragma mark Monitored Objects

- (NSSet *)monitoredManagedObjectsInSet:(NSSet *)objectsSet
{
    if (objectsSet.count == 0) return [NSSet set];
    
    NSManagedObjectContext *monitoredContext = [objectsSet.anyObject managedObjectContext];
    NSPersistentStore *monitoredStore = [self monitoredPersistentStoreInManagedObjectContext:monitoredContext];
    
    NSMutableSet *returned = [[NSMutableSet alloc] initWithCapacity:objectsSet.count];
    for (NSManagedObject *object in objectsSet) {
        NSManagedObjectID *objectID = object.objectID;
        if (objectID.persistentStore != monitoredStore) continue;
        if ([object.entity.userInfo[CDEIgnoredKey] boolValue]) continue;
        [returned addObject:object];
    }
    
    return returned;
}


#pragma mark Object Updates

- (void)contextWillSave:(NSNotification *)notif
{    
    NSManagedObjectContext *context = notif.object;
    if (!self.eventStore.containsEventData) return;
    
    // Check if this context includes the monitored store
    NSPersistentStore *monitoredStore = [self monitoredPersistentStoreInManagedObjectContext:context];
    if (!monitoredStore) return;
    
    // Give user code chance to make changes before preparing
    NSDictionary *userInfo = self.ensemble ? @{@"persistentStoreEnsemble" : self.ensemble} : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:CDEMonitoredManagedObjectContextWillSaveNotification object:context userInfo:userInfo];
    
    // Store changed values for updates, because they aren't accessible after the save
    [self storePreSaveChangesFromUpdatedObjects:context.updatedObjects];
}

- (void)storePreSaveChangesFromUpdatedObjects:(NSSet *)objects
{
    if (objects.count == 0) return;
    
    CDELog(CDELoggingLevelTrace, @"Storing pre-save changes from updated objects");
    
    NSSet *monitoredObjects = [self monitoredManagedObjectsInSet:objects];
    
    NSMutableDictionary *changedValuesByObjectID = [NSMutableDictionary dictionaryWithCapacity:monitoredObjects.count];
    [monitoredObjects.allObjects cde_enumerateObjectsDrainingEveryIterations:50 usingBlock:^(NSManagedObject *object, NSUInteger index, BOOL *stop) {
        NSArray *propertyChanges = [CDEPropertyChangeValue propertyChangesForObject:object eventStore:self.eventStore propertyNames:object.changedValues.allKeys isPreSave:YES storeValues:NO];
        
        // If all changes are in excluded properties, we don't need to store them pre save
        if (propertyChanges.count > 0) {
            NSManagedObjectID *objectID = object.objectID;
            changedValuesByObjectID[objectID] = propertyChanges;
        }
    }];
    
    NSManagedObjectContext *context = [objects.anyObject managedObjectContext];
    [changedValuesByContext setObject:changedValuesByObjectID forKey:context];
}


#pragma mark Storing Changes

- (void)contextDidSave:(NSNotification *)notif
{
    NSManagedObjectContext *context = notif.object;
    if (!self.eventStore.containsEventData) return;
    if (context == self.eventIntegrator.managedObjectContext) return;
    
    // Check if this context includes the monitored store
    NSPersistentStore *monitoredStore = [self monitoredPersistentStoreInManagedObjectContext:context];
    if (!monitoredStore) return;
    
    CDELog(CDELoggingLevelTrace, @"Storing changes post-save");
    
    // Store changes
    [self asynchronouslyStoreChangesForContext:context changedObjectsDictionary:notif.userInfo];
    
    // Notification
    NSDictionary *userInfo = self.ensemble ? @{@"persistentStoreEnsemble" : self.ensemble} : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:CDEMonitoredManagedObjectContextDidSaveNotification object:context userInfo:userInfo];
}

- (void)asynchronouslyStoreChangesForContext:(NSManagedObjectContext *)context changedObjectsDictionary:(NSDictionary *)changedObjectsDictionary
{
    NSSet *insertedObjects = [changedObjectsDictionary objectForKey:NSInsertedObjectsKey];
    NSSet *deletedObjects = [changedObjectsDictionary objectForKey:NSDeletedObjectsKey];
    NSSet *updatedObjects = [changedObjectsDictionary objectForKey:NSUpdatedObjectsKey];
    if (insertedObjects.count + deletedObjects.count + updatedObjects.count == 0) return;
    
    // Register event, so if there is a crash, we can detect it and clean up
    NSString *newUniqueId = [[NSProcessInfo processInfo] globallyUniqueString];
    [self.eventStore registerIncompleteMandatoryEventIdentifier:newUniqueId];
    
    // Reduce to just the objects belonging to the store
    insertedObjects = [self monitoredManagedObjectsInSet:insertedObjects];
    deletedObjects = [self monitoredManagedObjectsInSet:deletedObjects];
    updatedObjects = [self monitoredManagedObjectsInSet:updatedObjects];
    
    // Get change data. Must be called on the context thread, not the event store thread.
    CDEEventBuilder *eventBuilder = [[CDEEventBuilder alloc] initWithEventStore:self.eventStore];
    eventBuilder.ensemble = self.ensemble;
    NSDictionary *changedValuesByObjectID = [changedValuesByContext objectForKey:context];
    [changedValuesByContext removeObjectForKey:context];

    // Prepare inserts
    NSArray *orderedInsertedObjects = insertedObjects.allObjects;
    NSArray *insertedObjectIDs = [orderedInsertedObjects valueForKeyPath:@"objectID"];
    NSArray *globalIDStrings = [eventBuilder retrieveGlobalIdentifierStringsForManagedObjects:orderedInsertedObjects storedInEventStore:NO];
    NSArray *changeValueArraysForInserts = [eventBuilder propertyChangeValueArraysForInsertedObjects:orderedInsertedObjects objectsAreSaved:YES inManagedObjectContext:context];
    
    // Prepare deletions
    NSArray *orderedDeletedObjects = deletedObjects.allObjects;
    NSArray *objectIDsForDeletions = [orderedDeletedObjects valueForKeyPath:@"objectID"];
    
    // Prepare updates
    NSArray *orderedUpdatedObjects = updatedObjects.allObjects;
    NSArray *objectIDsForUpdates = [orderedUpdatedObjects valueForKeyPath:@"objectID"];
    [eventBuilder updatePropertyChangeValuesForUpdatedObjects:orderedUpdatedObjects inManagedObjectContext:context options:CDEUpdateStoreOptionSavedValue propertyChangeValuesByObjectID:changedValuesByObjectID];

    // Make sure the event is saved atomically
    NSManagedObjectContext *eventContext = self.eventStore.managedObjectContext;
    [eventContext performBlock:^{
        // Add a store mod event
        [eventBuilder makeNewEventOfType:CDEStoreModificationEventTypeSave uniqueIdentifier:newUniqueId];
        
        // Insert global ids
        NSArray *globalIDObjectIDs = [eventBuilder addGlobalIdentifiersForManagedObjectIDs:insertedObjectIDs identifierStrings:globalIDStrings];
    
        // Inserted Objects. Do inserts before updates to make sure each object has a global identifier.
        [eventBuilder addInsertChangesForPropertyChangeValueArrays:changeValueArraysForInserts globalIdentifierObjectIDs:globalIDObjectIDs];
        [self saveEventBuilder:eventBuilder];
        
        // Updated Objects
        [eventBuilder addUpdateChangesForObjectIDs:objectIDsForUpdates propertyChangeValuesByObjectID:changedValuesByObjectID];
        [self saveEventBuilder:eventBuilder];
        
        // Deleted Objects
        [eventBuilder addDeleteChangesForObjectIDs:objectIDsForDeletions];
        [self saveEventBuilder:eventBuilder];

        // Finalize
        [eventBuilder finalizeNewEvent];
        [self saveEventBuilder:eventBuilder];

        // Deregister event, and clean up
        [self.eventStore deregisterIncompleteMandatoryEventIdentifier:eventBuilder.event.uniqueIdentifier];
    }];
}

- (void)saveEventBuilder:(CDEEventBuilder *)eventBuilder
{
    NSError *error;
    if (![eventBuilder saveAndReset:&error]) CDELog(CDELoggingLevelError, @"Could not save and reset event builder: %@", error);
}

@end
