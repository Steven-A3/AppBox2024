//
//  CDEEventImportOperation.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 16/04/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import "CDEEventImport.h"
#import "NSManagedObjectModel+CDEAdditions.h"
#import "NSManagedObjectContext+CDEAdditions.h"
#import "CDEStoreModificationEvent.h"
#import "CDEEventStore.h"
#import "CDEObjectChange.h"
#import "CDEEventRevision.h"
#import "CDERevision.h"
#import "CDEObjectGraphMigrator.h"

@implementation CDEEventImport {
    CDEStoreModificationEventType eventType;
}

@synthesize eventStore = eventStore;
@synthesize importURLs = importURLs;
@synthesize error = error;
@synthesize eventID = eventID;

- (id)initWithEventStore:(CDEEventStore *)newEventStore importURLs:(NSArray *)newURLs
{
    self = [super init];
    if (self) {
        eventStore = newEventStore;
        importURLs = [newURLs copy];
        eventType = CDEStoreModificationEventTypeIncomplete;
        error = nil;
        eventID = nil;
    }
    return self;
}

- (void)main
{
    CDELog(CDELoggingLevelTrace, @"Migrating file events to event store");
    
    if (importURLs.count == 0) return;
        
    NSManagedObjectContext *eventContext = self.eventStore.managedObjectContext;
    [eventContext performBlockAndWait:^{
        [self prepareToImport];
    }];
    
    // Import files
    __block BOOL success = YES;
    for (NSURL *fileURL in importURLs) {
        [eventContext performBlockAndWait:^{
            @try {
                CDELog(CDELoggingLevelVerbose, @"Importing file at URL: %@", fileURL);
                @autoreleasepool {
                    NSError *localError = nil;
                    
                    if (fileURL == importURLs[0]) {
                        CDEStoreModificationEvent *event = [self importFirstFileAtURL:fileURL error:&localError];
                        success = event != nil;
                        if (success) {
                            eventType = event.type;
                            event.type = CDEStoreModificationEventTypeIncomplete;
                        }
                    }
                    else {
                        success = [self importSubsequentFileAtURL:fileURL error:&localError];
                    }
                    
                    if (!success) {
                        error = localError;
                        return;
                    }
                    
                    success = [eventContext save:&localError];
                    if (!success) error = localError;
                    [eventContext reset];
                }
            }
            @catch ( NSException *exception ) {
                CDELog(CDELoggingLevelVerbose, @"Exception occurred during event import. Stopping.");
                success = NO;
                error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeExceptionRaised userInfo:nil];
            }
        }];
        if (!success) break;
    }
    
    // Finalize event and save
    if (success && eventID) {
        [eventContext performBlockAndWait:^{
            NSError *localError = nil;
            CDEStoreModificationEvent *event = (id)[eventContext existingObjectWithID:self.eventID error:&localError];
            success = event != nil;
            if (!success) {
                error = localError;
                return;
            }
            
            event.type = eventType;
            success = [eventContext save:&localError];
            if (!success) error = localError;
            [eventContext reset];
        }];
    }

    if (!success && eventID) {
        [eventContext performBlockAndWait:^{
            // Delete event
            CDEStoreModificationEvent *event = (id)[eventContext existingObjectWithID:eventID error:NULL];
            if (event) {
                NSError *saveError;
                [eventContext deleteObject:event];
                BOOL saved = [eventContext save:&saveError];
                if (!saved) CDELog(CDELoggingLevelError, @"Could not save the event store after import: %@", saveError);
                [eventContext reset];
            }
        }];
        eventID = nil;
    }
    
    // Report error
    if (!success) CDELog(CDELoggingLevelError, @"Failed to migrate modification events: %@", error);
}

@end
