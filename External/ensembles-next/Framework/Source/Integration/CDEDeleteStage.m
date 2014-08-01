//
//  CDEIntegrationDeleter.m
//  Ensembles iOS
//
//  Created by Drew McCormack on 02/05/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import "CDEDeleteStage.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "CDEFoundationAdditions.h"
#import "NSMapTable+CDEAdditions.h"
#import "CDEDefines.h"
#import "CDEEventStore.h"
#import "CDEGlobalIdentifier.h"
#import "CDEPropertyChangeValue.h"
#import "CDEObjectChange.h"

@implementation CDEDeleteStage

// Called on event child context queue
- (BOOL)applyChangeIDs:(NSArray *)changeIDs error:(NSError *__autoreleasing *)error
{
    NSManagedObjectContext *eventContext = self.eventStore.managedObjectContext;
    NSArray *changes = [changeIDs cde_arrayByTransformingObjectsWithBlock:^(NSManagedObjectID *changeID) {
        return [eventContext objectWithID:changeID];
    }];
    
    NSMapTable *objectsByGlobalId = [self fetchObjectsByGlobalIdentifierForChanges:changes relationshipsToInclude:nil error:error];
    if (!objectsByGlobalId) return NO;
    
    for (CDEObjectChange *change in changes) {
        NSManagedObject *object = [objectsByGlobalId objectForKey:change.globalIdentifier.globalIdentifier];
        
        // Clear the store URI in the global id
        change.globalIdentifier.storeURI = nil;
        
        [self.managedObjectContext performBlockAndWait:^{
            [self.class nullifyRelationshipsAndDeleteObject:object];
        }];
    }
    
    return YES;
}

// Called on managedObjectContext thread
+ (void)nullifyRelationshipsAndDeleteObject:(NSManagedObject *)object
{
    if (!object) return;
    if (object.isDeleted || object.managedObjectContext == nil) return;
    
    // Nullify relationships first to prevent cascading
    NSEntityDescription *entity = object.entity;
    for (NSString *relationshipName in entity.relationshipsByName) {
        @try {
            id related = [self valueForKey:relationshipName inObject:object];
            if (related == nil) continue;
            
            NSRelationshipDescription *description = entity.relationshipsByName[relationshipName];
            if (description.isToMany && [related count] > 0) {
                if (description.isOrdered) {
                    related = [object mutableOrderedSetValueForKey:relationshipName];
                    [related removeAllObjects];
                } else {
                    related = [object mutableSetValueForKey:relationshipName];
                    [related removeAllObjects];
                }
            }
            else {
                [self setValue:nil forKey:relationshipName inObject:object];
            }
        }
        @catch ( NSException *exception ) {
            CDELog(CDELoggingLevelError, @"Exception while nullifying relationships: %@", exception);
        }
    }
    
    [object.managedObjectContext deleteObject:object];
}

@end
