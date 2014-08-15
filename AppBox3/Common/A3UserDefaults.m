//
//  A3UserDefaults.m
//  AppBox3
//
//  Created by A3 on 8/15/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3UserDefaults.h"
#import "NSFileManager+A3Addtion.h"

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

- (NSMutableDictionary *)mainDatabase {
	NSString *path = [self databasePath];
	if ([_fileManager fileExistsAtPath:path]) {
		NSDictionary *fileAttributes = [_fileManager attributesOfFileSystemForPath:path error:NULL];
		if (![[fileAttributes valueForKey:NSFileProtectionKey] isEqualToString:NSFileProtectionNone]) {
			[_fileManager setAttributes:@{NSFileProtectionKey: NSFileProtectionNone} ofItemAtPath:path error:NULL];
		}
		__block NSData *data = nil;
		NSMutableDictionary *mainDatabase;
		NSError *error;
		NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
		[coordinator coordinateReadingItemAtURL:[NSURL fileURLWithPath:path]
										options:NSFileCoordinatorReadingWithoutChanges
										  error:&error
									 byAccessor:^(NSURL *newURL) {
										 data = [NSData dataWithContentsOfFile:[newURL path]];
									 }];
		if (data) {
			mainDatabase = [NSPropertyListSerialization propertyListWithData:data
																	 options:NSPropertyListMutableContainersAndLeaves
																	  format:NULL
																	   error:&error];
			if (!error) {
				return mainDatabase;
			}
		}
	}
	return [NSMutableDictionary new];
}

- (void)saveDatabase:(NSDictionary *)database {
	if (!database) {
		FNLOG(@"nil value passed with save database");
		return;
	}
	NSError *error;
	NSData *data = [NSPropertyListSerialization dataWithPropertyList:database
															  format:NSPropertyListXMLFormat_v1_0
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

- (void)synchronize {
	[self saveDatabase:_defaultsDictionary];
}

- (id)objectForKey:(id)key {
	return [_defaultsDictionary objectForKey:key];
}

- (void)setObject:(id)object forKey:(id)key {
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
