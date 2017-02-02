//
//  CDEPersistentStoreEventImport.m
//  Ensembles iOS
//
//  Created by Drew McCormack on 10/06/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import "CDEPersistentStoreEventImport.h"
#import "CDEDefines.h"
#import "CDEEventStore.h"
#import "CDEStoreModificationEvent.h"
#import "CDEObjectGraphMigrator.h"
#import "CDEObjectChange.h"

@implementation CDEPersistentStoreEventImport {
    NSManagedObjectContext *importContext;
    NSPersistentStore *fileStore;
}

- (id)initWithEventStore:(CDEEventStore *)newEventStore importURLs:(NSArray *)newURLs
{
    self = [super initWithEventStore:newEventStore importURLs:newURLs];
    if (self) {
        importContext = nil;
    }
    return self;
}

- (void)prepareToImport
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
#pragma clang diagnostic pop
    
    NSPersistentStoreCoordinator *mainCoordinator = self.eventStore.managedObjectContext.persistentStoreCoordinator;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mainCoordinator.managedObjectModel];
    importContext.persistentStoreCoordinator = persistentStoreCoordinator;
}

- (BOOL)addImportStoreForFileAtURL:(NSURL *)fileURL error:(NSError * __autoreleasing *)localError
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:nil URL:fileURL error:localError];
#pragma clang diagnostic pop

    NSString *storeType = metadata[NSStoreTypeKey];
    if (!storeType) return NO;
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
    fileStore = [importContext.persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:nil URL:fileURL options:options error:localError];
    if (!fileStore) return NO;
    
    return YES;
}

- (BOOL)removeImportStore:(NSError * __autoreleasing *)localError
{
    [importContext reset];
    if (![importContext.persistentStoreCoordinator removePersistentStore:fileStore error:localError]) return NO;
    fileStore = nil;
    return YES;
}

- (CDEStoreModificationEvent *)importFirstFileAtURL:(NSURL *)url error:(NSError *__autoreleasing *)localError
{
    CDEStoreModificationEvent *newEvent = nil;
    if (![self addImportStoreForFileAtURL:url error:localError]) return nil;
    newEvent = [self migrateEventForFirstFile:localError];
    if (!newEvent) return nil;
    if (![self migrateObjectChanges:localError]) return nil;
    if (![self removeImportStore:localError]) return nil;
    return newEvent;
}

- (BOOL)importSubsequentFileAtURL:(NSURL *)url error:(NSError *__autoreleasing *)localError
{
    if (![self addImportStoreForFileAtURL:url error:localError]) return NO;
    if (![self migrateObjectChanges:localError]) return NO;
    if (![self removeImportStore:localError]) return NO;
    return YES;
}

- (CDEStoreModificationEvent *)migrateEventForFirstFile:(NSError * __autoreleasing *)anError
{
    NSManagedObjectContext *eventContext = self.eventStore.managedObjectContext;
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDEStoreModificationEvent"];
    NSArray *storeModEventsToMigrate = [importContext executeFetchRequest:fetch error:anError];
    if (!storeModEventsToMigrate) return nil;
    if (storeModEventsToMigrate.count != 1) {
        NSDictionary *info = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Wrong number of events found in file. Should be single event. Events found: %@", storeModEventsToMigrate]};
        if (anError) *anError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeDataCorruptionDetected userInfo:info];
        return nil;
    }
    
    CDEStoreModificationEvent *eventToImport = storeModEventsToMigrate.lastObject;
    CDEStoreModificationEvent *importedEvent = [CDEObjectGraphMigrator migrateEventAndRevisions:eventToImport toContext:eventContext];
    if (![eventContext obtainPermanentIDsForObjects:@[importedEvent] error:anError]) return nil;
    self.eventID = importedEvent.objectID;

    return importedEvent;
}

- (BOOL)migrateObjectChanges:(NSError * __autoreleasing *)anError
{
    NSAssert(self.eventID, @"No eventID");
    
    NSManagedObjectContext *toContext = self.eventStore.managedObjectContext;
    
    // Migrate global identifiers. Enforce uniqueness.
    NSMapTable *toGlobalIdsByFromGlobalId = [CDEObjectGraphMigrator migrateGlobalIdentifiersInManagedObjectContext:importContext toContext:toContext error:anError];
    if (!toGlobalIdsByFromGlobalId) return NO;
    
    // Retrieve imported event
    CDEStoreModificationEvent *importedEvent = (id)[toContext existingObjectWithID:self.eventID error:anError];
    
    // Retrieve event to import
    NSArray *events = [CDEStoreModificationEvent fetchStoreModificationEventsWithTypes:nil persistentStoreIdentifier:nil inManagedObjectContext:importContext];
    CDEStoreModificationEvent *eventToImport = events.lastObject;
    if (events.count != 1) {
        NSDictionary *info = @{NSLocalizedDescriptionKey : @"Wrong number of event objects in file"};
        *anError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeDataCorruptionDetected userInfo:info];
        return NO;
    }
    
    // Migrate mod events
    CDEObjectGraphMigrator *objectMigrator = [[CDEObjectGraphMigrator alloc] init];
    [objectMigrator registerMigratedObjectsByOriginalObjects:toGlobalIdsByFromGlobalId];
    [objectMigrator registerMigratedObject:importedEvent forOriginalObject:eventToImport];
    @try {
        for (CDEObjectChange *changeToImport in eventToImport.objectChanges) {
            [objectMigrator migrateObject:changeToImport andRelatedObjectsToManagedObjectContext:toContext];
        }
    }
    @catch (NSException *exception) {
        *anError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeUnknown userInfo:@{NSLocalizedFailureReasonErrorKey:exception.reason}];
        return NO;
    }
    
    return YES;
}

@end
