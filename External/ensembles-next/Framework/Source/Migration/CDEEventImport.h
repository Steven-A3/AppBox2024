//
//  CDEEventImportOperation.h
//  Ensembles Mac
//
//  Created by Drew McCormack on 16/04/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDEEventStore;
@class CDEStoreModificationEvent;

@interface CDEEventImport : NSOperation

@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) NSArray *importURLs;
@property (nonatomic, readwrite) NSManagedObjectID *eventID;
@property (nonatomic, readonly) CDEEventStore *eventStore;

- (id)initWithEventStore:(CDEEventStore *)newEventStore importURLs:(NSArray *)newURLs;

@end


@interface CDEEventImport (Abstract)

- (void)prepareToImport;
- (CDEStoreModificationEvent *)importFirstFileAtURL:(NSURL *)url error:(NSError * __autoreleasing *)error;
- (BOOL)importSubsequentFileAtURL:(NSURL *)url error:(NSError * __autoreleasing *)error;

@end