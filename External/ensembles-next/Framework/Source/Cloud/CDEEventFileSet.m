//
//  CDEEventFile.m
//  Ensembles Mac
//
//  Created by Drew McCormack on 08/04/14.
//  Copyright (c) 2014 Drew McCormack. All rights reserved.
//

#import "CDEEventFileSet.h"
#import "CDEStoreModificationEvent.h"

@implementation CDEEventFileSet {
    NSMutableIndexSet *mutableIndexSet;
    NSSet *cachedAliases;
}

@synthesize eventShouldBeUnique = eventShouldBeUnique;
@synthesize baseline = baseline;
@synthesize totalNumberOfParts = totalNumberOfParts;
@synthesize persistentStoreIdentifier;
@synthesize persistentStorePrefix;
@synthesize uniqueIdentifier;
@synthesize globalCount;
@synthesize revisionNumber;


#pragma mark Creating Sets

+ (NSSet *)eventFileSetsForFilenames:(NSSet *)filenames containingBaselines:(BOOL)base
{
    NSMutableSet *newEventSets = [NSMutableSet set];
    
    for (NSString *filename in filenames) {
        BOOL fileHandled = NO;
        for (CDEEventFileSet *fileSet in newEventSets) {
            if ([fileSet containsFile:filename]) {
                [fileSet addPartIndexForFile:filename];
                fileHandled = YES;
                break;
            }
        }
        if (fileHandled) continue;
        
        CDEEventFileSet *newSet = [[CDEEventFileSet alloc] initWithFilename:filename isBaseline:base];
        if (newSet)
            [newEventSets addObject:newSet];
        else
            CDELog(CDELoggingLevelWarning, @"Unknown file found: %@", filename);
    }
    
    return newEventSets;
}


#pragma mark Initialization

- (void)commonInit
{
    cachedAliases = nil;
    totalNumberOfParts = 1;
    mutableIndexSet = [NSMutableIndexSet indexSet];
}

- (id)initWithStoreModificationEvent:(CDEStoreModificationEvent *)event
{
    self = [super init];
    if (self) {
        [self commonInit];
        baseline = event.type == CDEStoreModificationEventTypeBaseline;
        globalCount = event.globalCount;
        uniqueIdentifier = event.uniqueIdentifier;
        revisionNumber = event.eventRevision.revisionNumber;
        persistentStoreIdentifier = event.eventRevision.persistentStoreIdentifier;
        persistentStorePrefix = [persistentStoreIdentifier substringToIndex:MIN(8,persistentStoreIdentifier.length)];
        eventShouldBeUnique = YES;
    }
    return self;
}

- (id)initWithFilename:(NSString *)filename isBaseline:(BOOL)isBase
{
    self = [super init];
    if (self) {
        [self commonInit];
        NSArray *components = [[filename stringByDeletingPathExtension] componentsSeparatedByString:@"_"];
        if (isBase && components.count >= 3) {
            baseline = YES;
            globalCount = [components[0] longLongValue];
            revisionNumber = -1;
            persistentStoreIdentifier = nil;
            persistentStorePrefix = components[2];
            uniqueIdentifier = components[1];
            eventShouldBeUnique = YES;
            [self updateTotalNumberOfPartsWithFilename:filename];
            [self addPartIndexForFile:filename];
        }
        else if (!isBase && components.count >= 3) {
            baseline = NO;
            globalCount = [components[0] longLongValue];
            revisionNumber = [components[2] longLongValue];
            persistentStoreIdentifier = components[1];
            persistentStorePrefix = [persistentStoreIdentifier substringToIndex:MIN(8, persistentStoreIdentifier.length)];
            uniqueIdentifier = nil;
            eventShouldBeUnique = YES;
            [self updateTotalNumberOfPartsWithFilename:filename];
            [self addPartIndexForFile:filename];
        }
        else if (isBase && components.count == 2) {
            // Legacy baseline
            baseline = YES;
            globalCount = [components[0] longLongValue];
            revisionNumber = -1;
            persistentStoreIdentifier = nil;
            persistentStorePrefix = nil;
            uniqueIdentifier = components[1];
            eventShouldBeUnique = NO;
        }
        else {
            self = nil;
        }
    }
    return self;
}

#pragma mark Comparison

- (BOOL)representsSameEventAsEventFileSet:(CDEEventFileSet *)otherSet
{
    BOOL baselineSame = (self.baseline && otherSet.baseline) || (!self.baseline && !otherSet.baseline);
    if (!baselineSame) return NO;
    
    if (self.persistentStoreIdentifier && otherSet.persistentStoreIdentifier) {
        if (![self.persistentStoreIdentifier isEqualToString:otherSet.persistentStoreIdentifier]) return NO;
    }
    
    if (self.uniqueIdentifier && otherSet.uniqueIdentifier) {
        if (![self.uniqueIdentifier isEqualToString:otherSet.uniqueIdentifier]) return NO;
    }
    
    if (self.globalCount != otherSet.globalCount) return NO;
    
    if (self.isBaseline) {
        if (self.persistentStorePrefix && otherSet.persistentStorePrefix) {
            if (![self.persistentStorePrefix isEqualToString:otherSet.persistentStorePrefix]) return NO;
        }
    }
    else {
        if (self.revisionNumber != otherSet.revisionNumber) return NO;
    }
    
    return YES;
}

#pragma mark Filenames

- (NSString *)preferredFilenameForPartIndex:(NSUInteger)index
{
    NSString *result = nil;
    
    if (baseline) {
        NSString *storeSubstring = persistentStorePrefix ? : [persistentStoreIdentifier substringToIndex:MIN(8, persistentStoreIdentifier.length)];
        result = [NSString stringWithFormat:@"%lli_%@_%@", globalCount, uniqueIdentifier, storeSubstring];
    }
    else {
        result = [NSString stringWithFormat:@"%lli_%@_%lli", globalCount, persistentStoreIdentifier, revisionNumber];
    }
    
    if (totalNumberOfParts > 1) {
        NSAssert(index >= 1 && index <= totalNumberOfParts, @"Out-of-bounds part index");
        result = [result stringByAppendingFormat:@"_%luof%lu", (unsigned long)index, (unsigned long)totalNumberOfParts];
    }
    
    result = [result stringByAppendingPathExtension:@"cdeevent"];
    
    return result;
}

- (NSArray *)preferredFilenamesForExistingParts
{
    NSIndexSet *indexSet = self.partIndexSet;
    NSUInteger index = [indexSet firstIndex];
    NSMutableArray *filenames = [[NSMutableArray alloc] init];
    while (index != NSNotFound) {
        [filenames addObject:[self preferredFilenameForPartIndex:index]];
        index = [self.partIndexSet indexGreaterThanIndex:index];
    }
    return filenames;
}

- (NSArray *)allPreferredFilenames
{
    NSMutableArray *filenames = [NSMutableArray array];
    for (NSUInteger i = 1; i <= totalNumberOfParts; i++) {
        [filenames addObject:[self preferredFilenameForPartIndex:i]];
    }
    return filenames;
}

#pragma mark Aliases

- (NSSet *)aliasesForPartIndex:(NSUInteger)index;
{
    NSMutableSet *aliases = [NSMutableSet set];
    if (baseline) {
        NSString *storeSubstring = persistentStorePrefix ? : [persistentStoreIdentifier substringToIndex:MIN(8, persistentStoreIdentifier.length)];
        NSString *s1 = [NSString stringWithFormat:@"%lli_%@_%@", globalCount, uniqueIdentifier, storeSubstring];
        NSString *s2 = [NSString stringWithFormat:@"%lli_%@", globalCount, uniqueIdentifier];
        [aliases addObjectsFromArray:@[s1,s2]];
    }
    else {
        NSString *s1 = [NSString stringWithFormat:@"%lli_%@_%lli", globalCount, persistentStoreIdentifier, revisionNumber];
        [aliases addObjectsFromArray:@[s1]];
    }
    
    // Add part variants
    if (totalNumberOfParts > 1) {
        for (NSString *s in [aliases copy]) {
            NSString *partString = [s stringByAppendingFormat:@"_%luof%lu", (unsigned long)index, (unsigned long)totalNumberOfParts];
            [aliases addObject:partString];
            [aliases removeObject:s];
        }
    }

    for (NSString *s in [aliases copy]) {
        NSString *aliasWithExt = [s stringByAppendingPathExtension:@"cdeevent"];
        [aliases addObject:aliasWithExt];
        [aliases removeObject:s];
    }

    return aliases;
}

- (NSSet *)allAliases
{
    if (cachedAliases) return cachedAliases;

    NSMutableSet *aliases = [NSMutableSet set];
    NSUInteger n = MAX(totalNumberOfParts, 1);
    for (NSUInteger i = 1; i <= n; i++) {
        [aliases unionSet:[self aliasesForPartIndex:i]];
    }
    
    cachedAliases = aliases;
    return aliases;
}


#pragma mark Parts

- (BOOL)containsFile:(NSString *)file
{
    return [self.allAliases containsObject:file];
}

- (NSArray *)partFractionForFilename:(NSString *)filename
{
    NSArray *components = [[filename stringByDeletingPathExtension] componentsSeparatedByString:@"_"];
    if (components.count <= 3) return nil;
    
    NSString *partComponent = components[3];
    NSArray *fraction = [partComponent componentsSeparatedByString:@"of"];
    NSAssert(fraction.count == 2, @"Wrong number of components in part fraction: %@", filename);

    return [fraction valueForKeyPath:@"integerValue"];
}

- (void)updateTotalNumberOfPartsWithFilename:(NSString *)filename
{
    NSArray *fraction = [self partFractionForFilename:filename];
    if (!fraction) {
        totalNumberOfParts = 1;
        [mutableIndexSet addIndex:1];
        return;
    }
    
    NSUInteger total = [fraction[1] unsignedIntegerValue];
    NSUInteger index = [fraction[0] unsignedIntegerValue];
    [mutableIndexSet removeAllIndexes];
    [mutableIndexSet addIndex:index];
    totalNumberOfParts = total;
    cachedAliases = nil;
}

- (void)addPartIndexForFile:(NSString *)filename
{
    NSArray *fraction = [self partFractionForFilename:filename];
    if (!fraction) {
        totalNumberOfParts = 1;
        [mutableIndexSet addIndex:1];
        return;
    }
    
    NSUInteger index = [fraction[0] unsignedIntegerValue];
    __unused NSUInteger total = [fraction[1] unsignedIntegerValue];
    NSAssert(total == totalNumberOfParts, @"Wrong number of parts in filename: %@", filename);
    NSAssert(index > 0 && index <= totalNumberOfParts, @"Index of file part out of range: %@", filename);
    
    NSParameterAssert(index <= totalNumberOfParts && index >= 1);
    [mutableIndexSet addIndex:index];
}

- (NSIndexSet *)partIndexSet
{
    return [mutableIndexSet copy];
}

- (BOOL)hasAllParts
{
    return mutableIndexSet.count == totalNumberOfParts;
}

#pragma mark Predicate

- (NSPredicate *)eventFetchPredicate
{
    NSPredicate *predicate = nil;
    if (baseline) {
        NSPredicate *basePredicate = [NSPredicate predicateWithFormat:@"type = %d AND globalCount = %lld AND uniqueIdentifier = %@", CDEStoreModificationEventTypeBaseline, globalCount, uniqueIdentifier];
        if (persistentStorePrefix) {
            NSPredicate *storePredicate = [NSPredicate predicateWithFormat:@"eventRevision.persistentStoreIdentifier BEGINSWITH %@", persistentStorePrefix];
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[basePredicate, storePredicate]];
        }
        else {
            predicate = basePredicate;
        }
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"(type = %d OR type = %d) AND globalCount = %lld AND eventRevision.persistentStoreIdentifier = %@ AND eventRevision.revisionNumber = %lld", CDEStoreModificationEventTypeSave, CDEStoreModificationEventTypeMerge, globalCount, persistentStoreIdentifier, revisionNumber];
    }
    return predicate;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"baseline: %d\nnumber of parts: %lu\nunique id: %@\nstore id: %@\nstore prefix: %@\nhas all parts: %d\nrevision: %lli\nglobal count: %lli", self.isBaseline, (unsigned long)self.totalNumberOfParts, self.uniqueIdentifier, self.persistentStoreIdentifier, self.persistentStorePrefix, self.hasAllParts, self.revisionNumber, self.globalCount];
}

@end

