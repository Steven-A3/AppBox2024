//
//  CDEEventExportOperation.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 16/04/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import "CDEEventExport.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "NSManagedObjectContext+CDEAdditions.h"
#import "CDEStoreModificationEvent.h"
#import "CDEEventStore.h"
#import "CDEObjectChange.h"
#import "CDEEventRevision.h"
#import "CDEObjectGraphMigrator.h"

@interface CDEEventExport ()

@property (nonatomic, readonly) NSString *pathToMigratorTemporaryDirectory;

@end

@implementation CDEEventExport 

@synthesize error = error;
@synthesize eventStore = eventStore;
@synthesize eventID = eventID;
@synthesize model = model;

- (id)initWithEventStore:(CDEEventStore *)newStore eventID:(NSManagedObjectID *)newID managedObjectModel:(NSManagedObjectModel *)newModel
{
    NSParameterAssert(newModel != nil);
    NSParameterAssert(newID != nil);
    NSParameterAssert(newStore != nil);
    self = [super init];
    if (self) {
        model = newModel;
        eventStore = newStore;
        eventID = [newID copy];
        mutableFileURLs = nil;
        error = nil;
        
        if (self.pathToMigratorTemporaryDirectory) {
            NSError *localError = nil;
            [[NSFileManager defaultManager] removeItemAtPath:self.pathToMigratorTemporaryDirectory error:NULL];
            if (![[NSFileManager defaultManager] createDirectoryAtPath:self.pathToMigratorTemporaryDirectory withIntermediateDirectories:YES attributes:nil error:&localError]) {
                CDELog(CDELoggingLevelError, @"Failed to create migrator temporary directory: %@", localError);
                self = nil;
            }
        }
    }
    return self;
}

- (void)main
{
    __block BOOL success = YES;
    __block NSError *localError = nil;
    error = nil;
    mutableFileURLs = [NSMutableArray array];

    NSManagedObjectContext *eventStoreContext = self.eventStore.managedObjectContext;
    [eventStoreContext performBlockAndWait:^{
        event = (id)[eventStoreContext existingObjectWithID:eventID error:&localError];
        success = [self prepareForExport];
    }];
    
    // Iterate over entities
    __block float fileProgress = 0.0f;
    NSArray *entities = [model cde_entitiesOrderedByMigrationPriority];
    for (NSEntityDescription *entity in entities) {
        if (!success) break;
        
        CDELog(CDELoggingLevelVerbose, @"Exporting files for entity: %@", entity.name);
        
        // Fetch request for object changes
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"CDEObjectChange"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"storeModificationEvent = %@ AND nameOfEntity = %@", eventID, entity.name];
        fetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"globalIdentifier.globalIdentifier" ascending:YES]];
        
        // Determine batch size
        NSUInteger batchSize = [entity cde_migrationBatchSize];
        if (0 == batchSize) batchSize = 2000;
        float progressDelta = 1.0f / batchSize;
        
        [eventStoreContext performBlockAndWait:^{
            @try {
                // The event store context could have been reset by another operation (eg save)
                // so refetch and register the event again.
                event = (id)[eventStoreContext existingObjectWithID:eventID error:&localError];
                if (!event) {
                    NSDictionary *info = @{NSLocalizedDescriptionKey : @"Could not refetch event in exporter."};
                    success = NO;
                    localError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeUnknown userInfo:info];
                    return;
                }
                
                success = [self prepareForNewEntity:entity];
                if (!success) return;
                
                // Iterate the object changes in batches
                success = [eventStoreContext cde_enumerateObjectsForFetchRequest:fetch withBatchSize:batchSize withBlock:^(NSArray *objectChanges, NSUInteger batchesRemaining, BOOL *stop) {
                    @try {
                        CDELog(CDELoggingLevelVerbose, @"Number of object changes remaining: %lu", (unsigned long)batchesRemaining * batchSize);

                        // Migrate object changes
                        [CDEObjectChange prefetchRelatedObjectsForObjectChanges:objectChanges];
                        success = [self migrateObjectChanges:objectChanges];
                        if (!success) *stop = YES;
                        fileProgress += progressDelta * objectChanges.count;
                        
                        // Create new store if necessary
                        if (success && fileProgress >= 1.0f && batchesRemaining > 0) {
                            // Reset event store to save memory
                            [eventStoreContext reset];
                            event = (id)[eventStoreContext existingObjectWithID:self.eventID error:&localError];
                            if (!event) {
                                success = NO;
                                *stop = YES;
                                return;
                            }
                            
                            // Prepare new file
                            success = [self prepareNewFile];
                            if (!success) {
                                *stop = YES;
                                return;
                            }
                            
                            fileProgress = 0.0f;
                        }
                    }
                    @catch (NSException *e) {
                        NSDictionary *info = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%@", e]};
                        error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeExceptionRaised userInfo:info];
                        *stop = YES;
                        success = NO;
                    }
                }];
            }
            @catch (NSException *e) {
                success = NO;
                localError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeExceptionRaised userInfo:nil];
            }
        }];
    }
    
    [eventStoreContext performBlockAndWait:^{
        event = (id)[eventStoreContext existingObjectWithID:eventID error:&localError];
        success = [self completeMigrationSuccessfully:success];
    }];

    if (!error && localError) error = localError;
}

- (NSString *)pathToMigratorTemporaryDirectory
{
    return [self.eventStore.pathToTemporaryDirectory stringByAppendingPathComponent:@"EventMigrator"];
}

- (NSURL *)createTemporaryFileURL
{
    NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.pathToMigratorTemporaryDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    NSString *path = [self.pathToMigratorTemporaryDirectory stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    return fileURL;
}

- (NSArray *)fileURLs
{
    return [mutableFileURLs copy];
}

- (void)addFileURL:(NSURL *)newURL
{
    [mutableFileURLs addObject:newURL];
}

@end
