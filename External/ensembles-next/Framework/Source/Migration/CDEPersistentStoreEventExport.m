//
//  CDEPersistentStoreEventExport.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 27/05/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CDEPersistentStoreEventExport.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "NSManagedObjectContext+CDEAdditions.h"
#import "CDEStoreModificationEvent.h"
#import "CDEObjectGraphMigrator.h"
#import "CDEEventStore.h"
#import "CDEObjectChange.h"

@implementation CDEPersistentStoreEventExport {
    CDEObjectGraphMigrator *objectGraphMigrator;
    NSPersistentStore *fileStore;
    NSManagedObjectContext *fileContext;
}

@synthesize fileStoreType = fileStoreType;

- (instancetype)initWithEventStore:(CDEEventStore *)newStore eventID:(NSManagedObjectID *)newID managedObjectModel:(NSManagedObjectModel *)model
{
    self = [super initWithEventStore:newStore eventID:newID managedObjectModel:model];
    if (self) {
        fileStoreType = NSBinaryStoreType;
        objectGraphMigrator = [[CDEObjectGraphMigrator alloc] init];
    }
    return self;
}

- (BOOL)prepareForExport
{
    __block BOOL success = YES;
    __block NSError *localError = nil;
    NSManagedObjectContext *eventStoreContext = self.eventStore.managedObjectContext;
    
    // Create context for files
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    fileContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
#pragma clang diagnostic pop
    
    NSPersistentStoreCoordinator *mainCoordinator = self.eventStore.managedObjectContext.persistentStoreCoordinator;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mainCoordinator.managedObjectModel];
    fileContext.persistentStoreCoordinator = persistentStoreCoordinator;
    fileContext.undoManager = nil;
    
    // Add file persistent store, and add the event
    fileStore = [self replacePersistentStore:nil inExportContext:fileContext error:&localError];
    event = (id)[eventStoreContext existingObjectWithID:self.eventID error:&localError];
    migratedEvent = [CDEObjectGraphMigrator migrateEventAndRevisions:event toContext:fileContext];
    
    [objectGraphMigrator registerMigratedObject:migratedEvent forOriginalObject:event];
    [self addFileURL:fileStore.URL];
    
    success = (event && fileStore && migratedEvent);
    if (!success) error = localError;
    return success;
}

- (BOOL)prepareNewFile
{
    NSError *localError = nil;

    if (![fileContext save:&localError]) {
        error = localError;
        return NO;
    }
    [fileContext reset];
    
    // Swap in new file store
    fileStore = [self replacePersistentStore:fileStore inExportContext:fileContext error:&localError];
    if (!fileStore) {
        error = localError;
        return NO;
    }
    [self addFileURL:fileStore.URL];
    
    // Create event in new file
    migratedEvent = [CDEObjectGraphMigrator migrateEventAndRevisions:event toContext:fileContext];
    
    // Setup migrator
    objectGraphMigrator = [[CDEObjectGraphMigrator alloc] init];
    [objectGraphMigrator registerMigratedObject:migratedEvent forOriginalObject:event];

    return YES;
}

- (BOOL)prepareForNewEntity:(NSEntityDescription *)entity
{
    [objectGraphMigrator clearRegisteredObjects];
    [objectGraphMigrator registerMigratedObject:migratedEvent forOriginalObject:event];
    return YES;
}

- (BOOL)migrateObjectChanges:(NSArray *)changes
{
    for (CDEObjectChange *change in changes) {
        [objectGraphMigrator migrateObject:change andRelatedObjectsToManagedObjectContext:fileContext];
    }
    return YES;
}

- (BOOL)completeMigrationSuccessfully:(BOOL)success
{
    // Last save
    NSError *localError = nil;
    if (success) success = [fileContext save:&localError];
    [fileContext reset];
    if (!success) error = localError;
    return success;
}

- (NSPersistentStore *)replacePersistentStore:(NSPersistentStore *)existingStore inExportContext:(NSManagedObjectContext *)context error:(NSError * __autoreleasing *)theError
{
    if (existingStore) {
        BOOL success = [context.persistentStoreCoordinator removePersistentStore:existingStore error:theError];
        if (!success) return nil;
    }
    
    NSURL *fileURL = [self createTemporaryFileURL];
    NSPersistentStore *newFileStore = [context.persistentStoreCoordinator addPersistentStoreWithType:self.fileStoreType configuration:nil URL:fileURL options:nil error:theError];
    
    return newFileStore;
}

@end
