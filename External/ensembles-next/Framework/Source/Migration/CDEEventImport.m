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
    __block NSError *localError = nil;
    __block BOOL success = YES;
    for (NSURL *fileURL in importURLs) {
        [eventContext performBlockAndWait:^{
            @try {
                CDELog(CDELoggingLevelVerbose, @"Importing file at URL: %@", fileURL);
                @autoreleasepool {
                    if (fileURL == importURLs[0]) {
                        CDEStoreModificationEvent *event = [self importFirstFileAtURL:fileURL error:&localError];
                        if (success) {
                            eventType = event.type;
                            event.type = CDEStoreModificationEventTypeIncomplete;
                        }
                    }
                    else {
                        success = [self importSubsequentFileAtURL:fileURL error:&localError];
                    }
                    if (!success) return;
                    success = [eventContext save:&localError];
                    [eventContext reset];
                }
            }
            @catch ( NSException *exception ) {
                success = NO;
                localError = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeExceptionRaised userInfo:nil];
            }
        }];
        if (!success) break;
    }
    
    // Finalize event and save
    if (success && eventID) {
        [eventContext performBlockAndWait:^{
            CDEStoreModificationEvent *event = (id)[eventContext existingObjectWithID:self.eventID error:&localError];
            event.type = eventType;
            success = [eventContext save:&localError];
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
                if (!saved) CDELog(CDELoggingLevelError, @"Could not save the vent store after import: %@", saveError);
                [eventContext reset];
            }
        }];
        eventID = nil;
    }
    
    // Set error
    error = localError;
    if (error) CDELog(CDELoggingLevelError, @"Failed to migrate modification events: %@", error);
}

@end
