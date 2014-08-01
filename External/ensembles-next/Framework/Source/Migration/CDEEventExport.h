//
//  CDEEventExportOperation.h
//  Ensembles Mac
//
//  Created by Drew McCormack on 16/04/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDEEventStore;
@class CDEStoreModificationEvent;


@interface CDEEventExport : NSOperation {
    NSMutableArray *mutableFileURLs;
    CDEStoreModificationEvent *event;
    CDEStoreModificationEvent *migratedEvent;
    NSError *error;
}

@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) NSArray *fileURLs;
@property (nonatomic, readonly) CDEEventStore *eventStore;
@property (nonatomic, readonly) NSManagedObjectID *eventID;
@property (nonatomic, readonly) NSManagedObjectModel *model;

- (instancetype)initWithEventStore:(CDEEventStore *)newStore eventID:(NSManagedObjectID *)newID managedObjectModel:(NSManagedObjectModel *)model;

@end


@interface CDEEventExport (Abstract)

// These are all invoked on the event store context thread
- (BOOL)prepareForExport;
- (BOOL)prepareNewFile;
- (BOOL)prepareForNewEntity:(NSEntityDescription *)entity;
- (BOOL)migrateObjectChanges:(NSArray *)changes;
- (BOOL)completeMigrationSuccessfully:(BOOL)success;

@end


@interface CDEEventExport (Subclassing)

- (NSURL *)createTemporaryFileURL;

- (void)addFileURL:(NSURL *)newURL;

@end
