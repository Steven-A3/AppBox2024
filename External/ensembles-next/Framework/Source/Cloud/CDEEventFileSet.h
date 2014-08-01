//
//  CDEEventFile.h
//  Ensembles Mac
//
//  Created by Drew McCormack on 08/04/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDEEventRevision.h"

@class CDEStoreModificationEvent;

@interface CDEEventFileSet : NSObject

@property (nonatomic, readonly) NSPredicate *eventFetchPredicate;
@property (nonatomic, readonly, getter = isBaseline) BOOL baseline;
@property (nonatomic, readonly) NSString *uniqueIdentifier;
@property (nonatomic, readonly) NSString *persistentStoreIdentifier;
@property (nonatomic, readonly) NSString *persistentStorePrefix;
@property (nonatomic, readonly) BOOL eventShouldBeUnique;
@property (nonatomic, readwrite) NSUInteger totalNumberOfParts;
@property (nonatomic, readonly) NSIndexSet *partIndexSet;
@property (nonatomic, readonly) BOOL hasAllParts;
@property (nonatomic, readonly) NSSet *allAliases;
@property (nonatomic, readonly) CDERevisionNumber revisionNumber;
@property (nonatomic, readonly) CDEGlobalCount globalCount;

+ (NSSet *)eventFileSetsForFilenames:(NSSet *)filenames containingBaselines:(BOOL)base;

- (id)initWithStoreModificationEvent:(CDEStoreModificationEvent *)event;
- (id)initWithFilename:(NSString *)filename isBaseline:(BOOL)baseline;

- (BOOL)containsFile:(NSString *)file;
- (void)addPartIndexForFile:(NSString *)filename;

- (BOOL)representsSameEventAsEventFileSet:(CDEEventFileSet *)otherSet;

- (NSString *)preferredFilenameForPartIndex:(NSUInteger)index;
- (NSArray *)preferredFilenamesForExistingParts;
- (NSArray *)allPreferredFilenames;

- (NSSet *)aliasesForPartIndex:(NSUInteger)index;

@end
