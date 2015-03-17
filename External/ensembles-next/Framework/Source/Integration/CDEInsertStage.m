//
//  CDEIntegrationInserter.m
//  Ensembles iOS
//
//  Created by Drew McCormack on 02/05/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import "CDEInsertStage.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "NSMapTable+CDEAdditions.h"
#import "CDEFoundationAdditions.h"
#import "CDEEventBuilder.h"
#import "CDEDefines.h"
#import "CDEEventStore.h"
#import "CDEGlobalIdentifier.h"
#import "CDEPropertyChangeValue.h"
#import "CDEObjectChange.h"

@implementation CDEInsertStage 

@synthesize insertedObjectIDs = insertedObjectIDs;

- (instancetype)initWithEventBuilder:(CDEEventBuilder *)newBuilder objectChangeIDs:(NSArray *)newChangeIDs managedObjectContext:(NSManagedObjectContext *)newContext batchSize:(NSUInteger)newBatchSize
{
    self = [super initWithEventBuilder:newBuilder objectChangeIDs:newChangeIDs managedObjectContext:newContext batchSize:newBatchSize];
    if (self) {
        insertedObjectIDs = nil;
    }
    return self;
}

- (BOOL)applyChangeIDs:(NSArray *)changeIDs error:(NSError * __autoreleasing *)error
{
    NSManagedObjectID *lastChangeID = changeIDs.lastObject;
    if (!lastChangeID) return YES;

    CDEObjectChange *lastChange = (id)[self.eventStore.managedObjectContext objectWithID:lastChangeID];
    NSString *entityName = lastChange.nameOfEntity;
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    BOOL success = [self insertObjectsForEntity:entity objectChangeIDs:changeIDs error:error];
    
    return success;
}

// Called on event context queue
- (BOOL)insertObjectsForEntity:(NSEntityDescription *)entity objectChangeIDs:(NSArray *)insertChangeIDs error:(NSError * __autoreleasing *)error
{
    NSManagedObjectContext *eventContext = self.eventStore.managedObjectContext;
    NSMutableArray *urisForInsertChanges = [[NSMutableArray alloc] initWithCapacity:insertChangeIDs.count];
    NSMutableSet *mutableInsertedObjectIDs = [NSMutableSet set];
    
    [self enumerateObjectChangeIDs:insertChangeIDs withBlock:^(NSArray *changeIDs) {
        // Determine which insertions actually need new objects. Some may already have
        // objects due to insertions on other devices.
        for (NSManagedObjectID *changeID in changeIDs) {
            NSURL *url = nil;
            CDEObjectChange *change = (id)[eventContext objectWithID:changeID];
            if (change.globalIdentifier.storeURI) {
                url = [[NSURL alloc] initWithString:change.globalIdentifier.storeURI];
            }
            [urisForInsertChanges addObject:CDENilToNSNull(url)];
        }
    }];
    
    NSMutableArray *indexesNeedingNewObjects = [[NSMutableArray alloc] initWithCapacity:insertChangeIDs.count];
    [self.managedObjectContext performBlockAndWait:^{
        // Convert URIs to Object IDs
        NSArray *objectIDs = [urisForInsertChanges cde_arrayByTransformingObjectsWithBlock:^(NSURL *url) {
            NSManagedObjectID *objectID = (id)[NSNull null];
            if (url != (id)[NSNull null]) {
                objectID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:url];
                if (!objectID) objectID = (id)[NSNull null];
            }
            return objectID;
        }];
        
        // Gather non-null IDs
        NSArray *nonNullObjectIDs = [objectIDs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return evaluatedObject != (id)[NSNull null];
        }]];
        
        // Check that the object ids really exist by fetching objects with those ids
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:entity.name];
        fetch.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", nonNullObjectIDs];
        fetch.resultType = NSManagedObjectIDResultType;
        NSArray *fetchedObjectIDs = [self.managedObjectContext executeFetchRequest:fetch error:error];
        NSSet *existingObjectIDs = [NSSet setWithArray:fetchedObjectIDs];
        
        // Gather the indexes of objects that need to be created
        [objectIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger i, BOOL *stop) {
            if (![existingObjectIDs containsObject:objectID]) [indexesNeedingNewObjects addObject:@(i)];
        }];
        
        // Store IDs
        [mutableInsertedObjectIDs unionSet:existingObjectIDs];
    }];
    
    NSArray *changeIDsNeedingNewObjects = [indexesNeedingNewObjects cde_arrayByTransformingObjectsWithBlock:^id(NSNumber *index) {
        return insertChangeIDs[index.unsignedIntegerValue];
    }];
    
    // Only now actually create objects, on the main context queue
    NSMutableArray *newObjects = [[NSMutableArray alloc] initWithCapacity:changeIDsNeedingNewObjects.count];
    __block BOOL success = YES;
    NSUInteger numberOfNewObjects = changeIDsNeedingNewObjects.count;
    [self.managedObjectContext performBlockAndWait:^{
        for (NSUInteger i = 0; i < numberOfNewObjects; i++) {
            id newObject = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:self.managedObjectContext];
            if (!newObject) {
                success = NO;
                return;
            }
            [newObjects addObject:newObject];
        }
    }];
    if (!success) return NO;
    
    // Get permanent store object ids, and then URIs
    __block NSArray *uris;
    [self.managedObjectContext performBlockAndWait:^{
        success = [self.managedObjectContext obtainPermanentIDsForObjects:newObjects error:error];
        if (!success) return;
        [mutableInsertedObjectIDs addObjectsFromArray:[newObjects valueForKeyPath:@"objectID"]];
        uris = [newObjects valueForKeyPath:@"objectID.URIRepresentation.absoluteString"];
    }];
    if (!success) return NO;
    
    // Update the global ids with the store object ids
    NSEnumerator *uriEnum = [uris objectEnumerator];
    [self enumerateObjectChangeIDs:changeIDsNeedingNewObjects withBlock:^(NSArray *changeIDs) {
        for (NSManagedObjectID *changeID in changeIDs) {
            CDEObjectChange *change = (id)[eventContext objectWithID:changeID];
            CDEGlobalIdentifier *globalId = change.globalIdentifier;
            NSString *uri = [uriEnum nextObject];
            globalId.storeURI = uri;
        }
    }];
    
    if (![self.eventBuilder saveAndReset:error]) return NO;
    
    // Update the inserted id
    insertedObjectIDs = mutableInsertedObjectIDs;
    
    return YES;
}


@end
