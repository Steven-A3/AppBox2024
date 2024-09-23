//
//  A3UserDefaults.m
//  AppBox3
//
//  Created by A3 on 8/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3UserDefaults.h"
#import "NSFileManager+A3Addition.h"

NSString *const A3PrivatePreferencesFilename = @"A3PrivatePreferences";
NSString *const A3UserDefaultsDidChangeNotification = @"A3UserDefaultsDidChangeNotification";
NSString *const A3UserDefaultsChangedKey = @"A3UserDefaultsChangedKey";

@implementation A3UserDefaults {
	NSFileManager *_fileManager;
	NSMutableDictionary *_defaultsDictionary;
}

+ (instancetype)standardUserDefaults {
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[A3UserDefaults alloc] init];
	});
	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		_fileManager = [NSFileManager new];
		_defaultsDictionary = [self mainDatabase];
	}
	return self;
}

- (NSString *)databasePath {
	return [[_fileManager applicationSupportPath] stringByAppendingPathComponent:A3PrivatePreferencesFilename];
}

/**
 * Retrieves the main database as a mutable dictionary.
 *
 * This method locates the database file at the specified path and ensures that its file protection attributes
 * are set to NSFileProtectionNone for availability purposes. It then reads the contents of the file, deserializes
 * it into a mutable dictionary, and returns it. If any errors occur during these operations, an empty mutable dictionary
 * is returned instead.
 *
 * @return NSMutableDictionary* - The main database as a mutable dictionary. Returns a new empty mutable dictionary if the file
 *                                does not exist or if any errors occur during file access or deserialization.
 *
 * Error Handling:
 * - Logs an error message if unable to retrieve file attributes.
 * - Logs an error message if unable to set file protection attributes.
 * - Logs an error message if unable to read the file.
 * - Logs an error message if unable to deserialize the property list.
 * - Logs an error message if the file does not exist at the specified path.
 *
 * Security Considerations:
 * - Ensures the database file is protected using NSFileProtectionComplete to enhance security.
 *
 * Usage:
 * Call this method to obtain the main database for read and write operations. Ensure that the database file path
 * is correctly set up before invoking this method.
 */
- (NSMutableDictionary *)mainDatabase {
    @autoreleasepool {
        NSString *path = [self databasePath];
        if ([_fileManager fileExistsAtPath:path]) {
            NSError *error = nil;
            NSDictionary *fileAttributes = [_fileManager attributesOfItemAtPath:path error:&error];
            if (error) {
                NSLog(@"Error getting file attributes: %@", error.localizedDescription);
                return [NSMutableDictionary new];
            }

            // Consider using a more secure file protection level
            if (![[fileAttributes valueForKey:NSFileProtectionKey] isEqualToString:NSFileProtectionComplete]) {
                error = nil;
                [_fileManager setAttributes:@{NSFileProtectionKey: NSFileProtectionComplete} ofItemAtPath:path error:&error];
                if (error) {
                    NSLog(@"Error setting file attributes: %@", error.localizedDescription);
                    return [NSMutableDictionary new];
                }
            }

            __block NSData *data = nil;
            __block NSError *readError = nil;
            NSMutableDictionary *mainDatabase = nil;
            NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            [coordinator coordinateReadingItemAtURL:[NSURL fileURLWithPath:path]
                                            options:NSFileCoordinatorReadingWithoutChanges
                                              error:&error
                                         byAccessor:^(NSURL *newURL) {
                data = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&readError];
                if (readError) {
                    NSLog(@"Error reading file: %@", readError.localizedDescription);
                }
            }];
            if (data && !readError) {
                error = nil;
                NSPropertyListFormat format;
                mainDatabase = [NSPropertyListSerialization propertyListWithData:data
                                                                         options:NSPropertyListMutableContainersAndLeaves
                                                                          format:&format
                                                                           error:&error];
                if (error) {
                    NSLog(@"Error deserializing property list: %@", error.localizedDescription);
                } else if (format != NSPropertyListBinaryFormat_v1_0 && format != NSPropertyListXMLFormat_v1_0) {
                    NSLog(@"Unexpected property list format");
                    mainDatabase = nil;
                }
                if (mainDatabase) {
                    return mainDatabase;
                }
            } else {
                NSLog(@"Error: No data read from file.");
            }
        } else {
            NSLog(@"File does not exist at path: %@", path);
        }
        return [NSMutableDictionary new];
    }
}

- (void)saveDatabase:(NSDictionary *)database {
    @autoreleasepool {
        if (!database) {
            FNLOG(@"nil value passed with save database");
            return;
        }
        NSError *error;
        NSData *data = [NSPropertyListSerialization dataWithPropertyList:database
#if TARGET_IPHONE_SIMULATOR
                                                                  format:NSPropertyListXMLFormat_v1_0
#else
                                                                  format:NSPropertyListBinaryFormat_v1_0
#endif
                                                                 options:0
                                                                   error:&error];
        if (error) {
            FNLOG(@"Error converting userdefaults dictinoary to NSData: %@", [error localizedDescription]);
        } else {
            NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            [coordinator coordinateWritingItemAtURL:[NSURL fileURLWithPath:[self databasePath]]
                                            options:NSFileCoordinatorWritingForReplacing
                                              error:&error
                                         byAccessor:^(NSURL *newURL) {
                NSError *error1;
                [data writeToFile:[newURL path] options:NSDataWritingAtomic|NSDataWritingFileProtectionNone error:&error1];
                if (error1) {
                    FNLOG(@"Error writing userdefaults dictinoary NSData: %@", [error localizedDescription]);
                }
            }];
        }
    }
}

- (void)synchronize {
	[self saveDatabase:_defaultsDictionary];
}

- (id)objectForKey:(id)key {
	return [_defaultsDictionary objectForKey:key];
}

- (void)setObject:(id)object forKey:(id)key {
	if (!object) return;
	[_defaultsDictionary setObject:object forKey:key];
	[[NSNotificationCenter defaultCenter] postNotificationName:A3UserDefaultsDidChangeNotification object:self userInfo:@{A3UserDefaultsChangedKey:key}];
}

- (BOOL)boolForKey:(id)key {
	NSNumber *object = [self objectForKey:key];
	return object ? [object boolValue] : NO;
}

- (void)setBool:(BOOL)boolValue forKey:(id)key {
	[self setObject:@(boolValue) forKey:key];
}

- (NSInteger)integerForKey:(id)key {
	NSNumber *object = [self objectForKey:key];
	return object ? [object integerValue] : 0;
}

- (void)setInteger:(NSInteger)integerValue forKey:(id)key {
	[self setObject:@(integerValue) forKey:key];
}

- (double)doubleForKey:(id)key {
	NSNumber *object = [self objectForKey:key];
	return object ? [object doubleValue] : 0.0;
}

- (void)setDouble:(double)doubleValue forKey:(id)key {
	[self setObject:@(doubleValue) forKey:key];
}

- (void)setDateComponents:(NSDateComponents *)dateComponents forKey:(NSString *)key {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dateComponents];
	[self setObject:data forKey:key];
}

- (NSDateComponents *)dateComponentsForKey:(NSString *)key {
	NSData *data = [self objectForKey:key];
	if (data) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	}
	return nil;
}

- (void)removeObjectForKey:(id)key {
	[_defaultsDictionary removeObjectForKey:key];
}

@end
