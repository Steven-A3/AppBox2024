//
//  CDEEventStore.m
//  Test App iOS
//
//  Created by Drew McCormack on 4/15/13.
//  Copyright (c) 2013 The Mental Faculty B.V. All rights reserved.
//

#import "CDEEventStore.h"
#import "CDEDefines.h"
#import "NSData+CDEAdditions.h"
#import "CDEStoreModificationEvent.h"
#import "CDERevisionSet.h"
#import "CDERevision.h"
#import "CDEGlobalIdentifier.h"
#import "CDEDataFile.h"


NSString * const kCDEPersistentStoreIdentifierKey = @"persistentStoreIdentifier";
NSString * const kCDECloudFileSystemIdentityKey = @"cloudFileSystemIdentity";
NSString * const kCDEIncompleteMandatoryEventIdentifiersKey = @"incompleteMandatoryEventIdentifiers";
NSString * const kCDEVerifiesStoreRegistrationInCloudKey = @"verifiesStoreRegistrationInCloud";
NSString * const kCDEIdentifierOfBaselineUsedToConstructStore = @"identifierOfBaselineUsedToConstructStore";

static NSString *defaultPathToEventDataRootDirectory = nil;


@interface CDEEventStore ()

@property (nonatomic, copy, readwrite) NSString *pathToEventStoreRootDirectory;
@property (nonatomic, strong, readonly) NSString *pathToEventStore;
@property (nonatomic, strong, readonly) NSString *pathToDataFileDirectory;
@property (nonatomic, strong, readonly) NSString *pathToNewlyImportedDataFileDirectory;
@property (nonatomic, strong, readonly) NSString *pathToStoreInfoFile;
@property (nonatomic, copy, readwrite) NSString *persistentStoreIdentifier;

@end


@implementation CDEEventStore {
    NSFileManager *fileManager;
    NSCountedSet *mandatoryEventCountedSet;
}

@synthesize ensembleIdentifier = ensembleIdentifier;
@synthesize managedObjectContext = managedObjectContext;
@synthesize persistentStoreIdentifier = persistentStoreIdentifier;
@synthesize pathToEventDataRootDirectory = pathToEventDataRootDirectory;
@synthesize cloudFileSystemIdentityToken = cloudFileSystemIdentityToken;
@synthesize verifiesStoreRegistrationInCloud = verifiesStoreRegistrationInCloud;
@synthesize identifierOfBaselineUsedToConstructStore = identifierOfBaselineUsedToConstructStore;
@synthesize currentBaselineIdentifier = currentBaselineIdentifier;

+ (void)initialize
{
    if ([CDEEventStore class] == self) {
        NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
        NSString *appSupportDir = [(NSURL *)urls.lastObject path];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        if (!bundleIdentifier) bundleIdentifier = @"com.mentalfaculty.ensembles.tests";
        NSString *path = [appSupportDir stringByAppendingPathComponent:bundleIdentifier];
        path = [path stringByAppendingPathComponent:@"com.mentalfaculty.ensembles.eventdata"];
        [self setDefaultPathToEventDataRootDirectory:path];
    }
}

// Designated
- (instancetype)initWithEnsembleIdentifier:(NSString *)newIdentifier pathToEventDataRootDirectory:(NSString *)rootDirectory
{
    NSParameterAssert(newIdentifier != nil);
    self = [super init];
    if (self) {
        fileManager = [[NSFileManager alloc] init];
        
        pathToEventDataRootDirectory = [rootDirectory copy];
        if (!pathToEventDataRootDirectory) pathToEventDataRootDirectory = [self.class defaultPathToEventDataRootDirectory];
        
        ensembleIdentifier = [newIdentifier copy];
        mandatoryEventCountedSet = nil;
        
        [self restoreStoreMetadata];
        
        NSError *error;
        if (self.persistentStoreIdentifier) {
            BOOL success = [self createEventStoreDirectoriesIfNecessary:&error];
            if (!success) return nil;
            
            if ( ![self setupCoreDataStack:&error]) {
                CDELog(CDELoggingLevelError, @"Could not setup core data stack for event store: %@", error);
                return nil;
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Store Metadata

- (void)saveStoreMetadata
{
    @try {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        if (self.persistentStoreIdentifier) {
            NSData *identityData = [NSKeyedArchiver archivedDataWithRootObject:self.cloudFileSystemIdentityToken];
            [dictionary addEntriesFromDictionary:@{
                kCDEPersistentStoreIdentifierKey : self.persistentStoreIdentifier,
                kCDECloudFileSystemIdentityKey : identityData,
                kCDEIncompleteMandatoryEventIdentifiersKey : mandatoryEventCountedSet.allObjects,
                kCDEVerifiesStoreRegistrationInCloudKey : @(self.verifiesStoreRegistrationInCloud)
            }];
            
            NSString *baseline = self.identifierOfBaselineUsedToConstructStore;
            if (baseline) dictionary[kCDEIdentifierOfBaselineUsedToConstructStore] = baseline;
        }
        
        if (![dictionary writeToFile:self.pathToStoreInfoFile atomically:YES]) {
            CDELog(CDELoggingLevelError, @"Could not write store info file");
        }
    }
    @catch ( NSException *exception ) {
        CDELog(CDELoggingLevelError, @"Could not save store metadata. Exception: %@", exception);
    }
}

- (void)restoreStoreMetadata
{
    NSString *path = self.pathToStoreInfoFile;
    NSDictionary *storeMetadata = [NSDictionary dictionaryWithContentsOfFile:path];
    if (storeMetadata) {
        NSData *identityData = storeMetadata[kCDECloudFileSystemIdentityKey];
        cloudFileSystemIdentityToken = identityData ? [NSKeyedUnarchiver unarchiveObjectWithData:identityData] : nil;
        persistentStoreIdentifier = storeMetadata[kCDEPersistentStoreIdentifierKey];
        mandatoryEventCountedSet = [NSCountedSet setWithArray:storeMetadata[kCDEIncompleteMandatoryEventIdentifiersKey]];
        identifierOfBaselineUsedToConstructStore = storeMetadata[kCDEIdentifierOfBaselineUsedToConstructStore];
        
        NSNumber *value = storeMetadata[kCDEVerifiesStoreRegistrationInCloudKey];
        verifiesStoreRegistrationInCloud = value ? value.boolValue : NO;
    }
    else {
        cloudFileSystemIdentityToken = nil;
        persistentStoreIdentifier = nil;
        mandatoryEventCountedSet = nil;
        identifierOfBaselineUsedToConstructStore = nil;
        verifiesStoreRegistrationInCloud = YES;
    }
    
    if (!mandatoryEventCountedSet) {
        mandatoryEventCountedSet = [NSCountedSet set];
    }
}


#pragma mark - Incomplete Events

- (void)registerIncompleteMandatoryEventIdentifier:(NSString *)identifier
{
    @synchronized (self) {
        [mandatoryEventCountedSet addObject:identifier];
        [self saveStoreMetadata];
    }
}

- (void)deregisterIncompleteMandatoryEventIdentifier:(NSString *)identifier
{
    @synchronized (self) {
        [mandatoryEventCountedSet removeObject:identifier];
        [self saveStoreMetadata];
    }
}

- (NSArray *)incompleteMandatoryEventIdentifiers
{
    @synchronized (self) {
        return mandatoryEventCountedSet.allObjects;
    }
}


#pragma mark - Revisions

- (CDERevisionNumber)lastRevisionNumberSavedForEventRevisionPredicate:(NSPredicate *)predicate
{
    __block CDERevisionNumber result = -1;
    [self.managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CDEEventRevision"];
        request.predicate = predicate;
        request.includesPendingChanges = NO; // Only consider saved revisions
        
        NSError *error = nil;
        NSArray *revisions = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (!revisions) @throw [NSException exceptionWithName:CDEException reason:@"Failed to fetch revisions" userInfo:nil];
        
        if (revisions.count > 0) {
            NSNumber *max = [revisions valueForKeyPath:@"@max.revisionNumber"];
            result = max.longLongValue;
        }
    }];
    CDERevisionNumber returnNumber = result;
    return returnNumber;
}

- (CDERevisionNumber)lastMergeRevisionSaved
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentStoreIdentifier = %@ AND storeModificationEvent.type = %d", self.persistentStoreIdentifier, CDEStoreModificationEventTypeMerge];
    CDERevisionNumber result = [self lastRevisionNumberSavedForEventRevisionPredicate:predicate];
    return result;
}

- (CDERevisionNumber)lastSaveRevisionSaved
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentStoreIdentifier = %@ AND storeModificationEvent.type = %d", self.persistentStoreIdentifier, CDEStoreModificationEventTypeSave];
    CDERevisionNumber result = [self lastRevisionNumberSavedForEventRevisionPredicate:predicate];
    return result;
}

- (CDERevisionNumber)lastRevisionSaved
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentStoreIdentifier = %@ AND (storeModificationEvent.type != %d OR storeModificationEventForOtherStores.type != %d)", self.persistentStoreIdentifier, CDEStoreModificationEventTypeIncomplete, CDEStoreModificationEventTypeIncomplete];
    CDERevisionNumber result = [self lastRevisionNumberSavedForEventRevisionPredicate:predicate];
    return result;
}

- (CDERevisionNumber)baselineRevision
{
    __block CDERevisionNumber revisionNumber = -1;
    [managedObjectContext performBlockAndWait:^{
        CDEStoreModificationEvent *event = [CDEStoreModificationEvent fetchMostRecentBaselineStoreModificationEventInManagedObjectContext:managedObjectContext];
        CDERevision *revision = [event.revisionSet revisionForPersistentStoreIdentifier:self.persistentStoreIdentifier];
        if (revision) revisionNumber = revision.revisionNumber;
    }];
    return revisionNumber;
}


#pragma mark - Baselines

- (NSString *)currentBaselineIdentifier
{
    __block NSString *result = nil;
    [managedObjectContext performBlockAndWait:^{
        CDEStoreModificationEvent *event = [CDEStoreModificationEvent fetchMostRecentBaselineStoreModificationEventInManagedObjectContext:managedObjectContext];
        result = event.uniqueIdentifier;
    }];
    return result;
}

- (void)setIdentifierOfBaselineUsedToConstructStore:(NSString *)newId
{
    if (![newId isEqualToString:identifierOfBaselineUsedToConstructStore]) {
        identifierOfBaselineUsedToConstructStore = [newId copy];
        [self saveStoreMetadata];
    }
}


#pragma mark - Cleaning Up Old Data

- (void)removeUnusedDataWithCompletion:(CDECompletionBlock)completion
{
    // Delete unused global ids
    [self.managedObjectContext performBlock:^{
        NSError *error;
        NSArray *unusedGlobalIds = [CDEGlobalIdentifier fetchUnreferencedGlobalIdentifiersInManagedObjectContext:self.managedObjectContext];
        for (CDEGlobalIdentifier *globalId in unusedGlobalIds) [self.managedObjectContext deleteObject:globalId];
        BOOL success = [self.managedObjectContext save:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(success ? nil : error);
        });
    }];
}


#pragma mark - Data Files

- (NSSet *)allDataFilenames
{
    return [[self previouslyReferencedDataFilenames] setByAddingObjectsFromSet:[self newlyImportedDataFilenames]];
}

- (NSSet *)previouslyReferencedDataFilenames
{
    NSError *error;
    NSArray *newFilenames = [fileManager contentsOfDirectoryAtPath:self.pathToDataFileDirectory error:&error];
    if (!newFilenames) CDELog(CDELoggingLevelError, @"Could not get data filenames: %@", error);
    return [NSSet setWithArray:newFilenames];
}

- (NSSet *)newlyImportedDataFilenames
{
    NSError *error;
    NSArray *newFilenames = [fileManager contentsOfDirectoryAtPath:self.pathToNewlyImportedDataFileDirectory error:&error];
    if (!newFilenames) CDELog(CDELoggingLevelError, @"Could not get data filenames: %@", error);
    return [NSSet setWithArray:newFilenames];
}

- (BOOL)importDataFile:(NSString *)fromPath
{
    NSError *error;
    NSString *filename = [fromPath lastPathComponent];
    NSString *toPath = [self.pathToNewlyImportedDataFileDirectory stringByAppendingPathComponent:filename];
    BOOL success = [fileManager moveItemAtPath:fromPath toPath:toPath error:&error];
    if (!success) CDELog(CDELoggingLevelError, @"Could not move file to event store data directory: %@", error);
    return success;
}

- (NSString *)storeDataInFile:(NSData *)data
{
    NSString *filename = [data cde_md5Checksum];
    NSString *toPath = [self.pathToDataFileDirectory stringByAppendingPathComponent:filename];
    [fileManager removeItemAtPath:toPath error:NULL];
    BOOL success = [data writeToFile:toPath atomically:YES];
    if (!success) filename = nil;
    return filename;
}

- (BOOL)exportDataFile:(NSString *)filename toDirectory:(NSString *)dirPath
{
    NSError *error;
    NSString *fromPath = [self.pathToDataFileDirectory stringByAppendingPathComponent:filename];
    NSString *toPath = [dirPath stringByAppendingPathComponent:filename];
    BOOL success = [fileManager copyItemAtPath:fromPath toPath:toPath error:&error];
    if (!success) CDELog(CDELoggingLevelError, @"Could not move file to event store data directory: %@", error);
    return success;
}

- (NSData *)dataForFile:(NSString *)filename
{
    NSError *error = nil;
    NSString *filePath = [self.pathToDataFileDirectory stringByAppendingPathComponent:filename];
    NSString *newFilePath = [self.pathToNewlyImportedDataFileDirectory stringByAppendingPathComponent:filename];
    
    // If file is newly imported, move it across to the standard data files first.
    if (![fileManager fileExistsAtPath:filePath] && [fileManager fileExistsAtPath:newFilePath]) {
        BOOL success = [fileManager moveItemAtPath:newFilePath toPath:filePath error:&error];
        if (!success) CDELog(CDELoggingLevelError, @"Could not move file: %@", error);
    }
    
    NSData *data = [NSData dataWithContentsOfFile:filePath options:(NSDataReadingMappedIfSafe | NSDataReadingUncached) error:&error];
    if (!data) CDELog(CDELoggingLevelError, @"Failed to get file data for file %@: %@", filename, error);
    
    return data;
}

- (BOOL)removePreviouslyReferencedDataFile:(NSString *)filename
{
    NSString *path = [self.pathToDataFileDirectory stringByAppendingPathComponent:filename];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:path error:&error];
    return success;
}

- (BOOL)removeNewlyImportedDataFile:(NSString *)filename
{
    NSString *path = [self.pathToNewlyImportedDataFileDirectory stringByAppendingPathComponent:filename];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:path error:&error];
    return success;
}

- (void)removeUnreferencedDataFiles
{
    [self.managedObjectContext performBlockAndWait:^{
        NSSet *contextFilenames = [CDEDataFile allFilenamesInManagedObjectContext:self.managedObjectContext];
        NSMutableSet *filenames = [self.previouslyReferencedDataFilenames mutableCopy];
        [filenames minusSet:contextFilenames];
        for (NSString *filename in filenames) [self removePreviouslyReferencedDataFile:filename];
    }];
}


#pragma mark - Flushing out queued operations

- (void)flushWithCompletion:(CDECompletionBlock)completion
{
    [self saveStoreMetadata];
    
    if (self.managedObjectContext) {
        [self.managedObjectContext performBlock:^{
            NSError *error = nil;
            __block BOOL success = [managedObjectContext save:&error];
            if (!success) {
                CDELog(CDELoggingLevelError, @"Failed to save during flush. Will reset event store context: %@", error);
                [managedObjectContext reset];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(success ? nil : error);
            });
        }];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(nil);
        });
    }
}


#pragma mark - Removing and Installing

- (BOOL)prepareNewEventStore:(NSError * __autoreleasing *)error
{
    [self removeEventStore];
    
    // Directories
    BOOL success = [self createEventStoreDirectoriesIfNecessary:error];
    if (!success) return NO;
    
    // Core Data Stack. 
    success = [self setupCoreDataStack:error];
    if (!success) return NO;
    
    // Store store info
    persistentStoreIdentifier = [[NSProcessInfo processInfo] globallyUniqueString];
    identifierOfBaselineUsedToConstructStore = nil;
    mandatoryEventCountedSet = [NSCountedSet set];
    [self saveStoreMetadata];
    
    return YES;
}

- (BOOL)removeEventStore
{
    CDELog(CDELoggingLevelTrace, @"Removing event store");
    self.persistentStoreIdentifier = nil;
    mandatoryEventCountedSet = nil;
    [self tearDownCoreDataStack];
    return [fileManager removeItemAtPath:self.pathToEventStoreRootDirectory error:NULL];
}

- (BOOL)containsEventData
{
    return self.persistentStoreIdentifier && self.managedObjectContext;
}


#pragma mark - Paths

+ (NSString *)defaultPathToEventDataRootDirectory
{
    return defaultPathToEventDataRootDirectory;
}

+ (void)setDefaultPathToEventDataRootDirectory:(NSString *)newPath
{
    NSParameterAssert(newPath != nil);
    defaultPathToEventDataRootDirectory = [newPath copy];
}

+ (NSString *)pathToEventDataRootDirectoryForRootDirectory:(NSString *)rootDir ensembleIdentifier:(NSString *)identifier
{
    NSString *path = [rootDir stringByAppendingPathComponent:identifier];
    return path;
}

- (NSString *)pathToEventStoreRootDirectory
{
    return [self.class pathToEventDataRootDirectoryForRootDirectory:self.pathToEventDataRootDirectory ensembleIdentifier:self.ensembleIdentifier];
}

- (NSString *)pathToEventStore
{
    return [self.pathToEventStoreRootDirectory stringByAppendingPathComponent:@"events.sqlite"];
}

- (NSString *)pathToStoreInfoFile
{
    return [self.pathToEventStoreRootDirectory stringByAppendingPathComponent:@"store.plist"];
}

- (NSString *)pathToDataFileDirectory
{
    return [self.pathToEventStoreRootDirectory stringByAppendingPathComponent:@"data"];
}

- (NSString *)pathToTemporaryDirectory
{
    return [self.pathToEventStoreRootDirectory stringByAppendingPathComponent:@"tmp"];
}

- (NSString *)pathToNewlyImportedDataFileDirectory
{
    return [self.pathToEventStoreRootDirectory stringByAppendingPathComponent:@"newdata"];
}

- (BOOL)createDirectoryIfNecessary:(NSString *)path error:(NSError * __autoreleasing *)error
{
    BOOL success = YES;
    BOOL isDir;
    if ( ![fileManager fileExistsAtPath:path isDirectory:&isDir] ) {
        success = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
    }
    else if (!isDir) {
        success = NO;
    }
    return success;
}

- (BOOL)createEventStoreDirectoriesIfNecessary:(NSError * __autoreleasing *)error
{
    NSArray *paths = @[self.pathToEventStoreRootDirectory, self.pathToDataFileDirectory, self.pathToTemporaryDirectory, self.pathToNewlyImportedDataFileDirectory];
    for (NSString *path in paths) {
        if (![self createDirectoryIfNecessary:path error:error]) return NO;
    }
    
    // Prevent event store being backed up
	NSURL *url = [NSURL fileURLWithPath:self.pathToEventStoreRootDirectory];
	NSError *metadataError;
	BOOL success = [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&metadataError];
	if (!success) CDELog(CDELoggingLevelWarning, @"Could not exclude event store directory from backup");
	
    return YES;
}


#pragma mark - Core Data Stack

- (NSURL *)eventStoreModelURL
{
    NSBundle *bundle = [NSBundle bundleForClass:[CDEEventStore class]];
    NSURL *modelURL = [bundle URLForResource:@"CDEEventStoreModel" withExtension:@"momd"];
    if (!modelURL) {
        // Search for bundle
        NSURL *resourcesBundleURL = [bundle URLForResource:@"Ensembles" withExtension:@"bundle"];
        NSBundle *resourceBundle = resourcesBundleURL ? [NSBundle bundleWithURL:resourcesBundleURL] : nil;
        modelURL = [resourceBundle URLForResource:@"CDEEventStoreModel" withExtension:@"momd"];
    }
    return modelURL;
}

- (BOOL)setupCoreDataStack:(NSError * __autoreleasing *)error
{
    NSURL *modelURL = [self eventStoreModelURL];
    NSAssert(modelURL != nil, @"Ensembles internal model resource not found. Make sure it is copied into your app bundle");
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSURL *storeURL = [NSURL fileURLWithPath:self.pathToEventStore];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
    NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:error];
    if (!store) return NO;
    
    managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [managedObjectContext performBlockAndWait:^{
        managedObjectContext.persistentStoreCoordinator = coordinator;
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        managedObjectContext.undoManager = nil;
    }];
    
    BOOL success = managedObjectContext != nil;
    if (success) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    return success;
}

- (void)tearDownCoreDataStack
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    [managedObjectContext performBlockAndWait:^{
        [managedObjectContext reset];
    }];
    managedObjectContext = nil;
}


#pragma mark - Merging Changes

- (void)managedObjectContextDidSave:(NSNotification *)notif
{
    NSManagedObjectContext *context = notif.object;
    if (context.parentContext == self.managedObjectContext) {
        [self.managedObjectContext performBlockAndWait:^{
            [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notif];
        }];
    }
}


@end
