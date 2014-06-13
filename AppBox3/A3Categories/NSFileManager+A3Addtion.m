//
//  NSFileManager+A3Addtion.m
//  AppBox3
//
//  Created by A3 on 12/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSFileManager+A3Addtion.h"

static NSString *const A3CacheStoreFilename = @"AppBoxCacheStore.sqlite";

@implementation NSFileManager (A3Addtion)

- (NSString *)directory:(NSSearchPathDirectory)type {
	return [NSSearchPathForDirectoriesInDomains(type, NSUserDomainMask, YES) lastObject];
}

- (NSString *)applicationSupportPath {
	NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
	return [[self directory:NSApplicationSupportDirectory] stringByAppendingPathComponent:applicationName];
}

- (NSString *)storePath {
	return [self.applicationSupportPath stringByAppendingPathComponent:self.storeName];
}

- (NSString *)storeName {
	return @"AppBox3.sqlite";
}

- (void)setupCacheStoreFile {
	NSString *cacheStorePath = [self cacheStorePath];
	FNLOG(@"%@", cacheStorePath);
	if (![self fileExistsAtPath:self.storePath]) {
		NSError *error = nil;
		@try {
			NSString *bundlePath = [[NSBundle mainBundle] pathForResource:A3CacheStoreFilename ofType:nil];
			NSString *applicationSupportPath = self.applicationSupportPath;
			[self createDirectoryAtPath:applicationSupportPath withIntermediateDirectories:YES attributes:nil error:NULL];
			[self copyItemAtPath:bundlePath toPath:cacheStorePath error:&error];

			NSString *sharedMemoryPath = [bundlePath stringByAppendingString:@"-shm"];
			NSString *targetPath = [cacheStorePath stringByAppendingString:@"-shm"];
			[self copyItemAtPath:sharedMemoryPath toPath:targetPath error:&error];

			NSString *WALPath = [bundlePath stringByAppendingString:@"-wal"];
			targetPath = [cacheStorePath stringByAppendingString:@"-wal"];
			[self copyItemAtPath:WALPath toPath:targetPath error:&error];
		}
		@catch (id exception) {
			FNLOG(@"FAILD to COPY %@ from Bundle to Cache Directory.", A3CacheStoreFilename);
			FNLOG(@"%@", [(id<NSObject>)exception description]);
		}
	}
}

- (NSString *)cacheStorePath {
	return [[self directory:NSCachesDirectory] stringByAppendingPathComponent:A3CacheStoreFilename];
}

@end
