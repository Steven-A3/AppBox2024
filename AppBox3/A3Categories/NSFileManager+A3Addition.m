//
//  NSFileManager+A3Addition.m
//  AppBox3
//
//  Created by A3 on 12/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSFileManager+A3Addition.h"

static NSString *const A3CacheStoreFilename = @"AppBoxCacheStore.sqlite";

@implementation NSFileManager (A3Addition)

- (NSString *)directory:(NSSearchPathDirectory)type {
	return [NSSearchPathForDirectoriesInDomains(type, NSUserDomainMask, YES) lastObject];
}

- (NSString *)applicationSupportPath {
	NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
	return [[self directory:NSApplicationSupportDirectory] stringByAppendingPathComponent:applicationName];
}

- (NSString *)documentDirectoryPath {
    return [self directory:NSDocumentDirectory];
}

- (NSString *)storePath {
	return [self.applicationSupportPath stringByAppendingPathComponent:self.storeName];
}

- (NSString *)storeName {
	return @"AppBox3.sqlite";
}

- (void)setupCacheStoreFile {
	NSString *cacheStorePath = [self cacheStorePath];
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

- (NSString *)humanReadableFileSize:(unsigned long long)size
{
	NSString *formattedStr = nil;
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatter setMaximumFractionDigits:2];

	if (size == 0)
		formattedStr = @"Empty";
	else if (size > 0 && size < 1024)
		formattedStr = [NSString stringWithFormat:@"%@ bytes", [numberFormatter stringFromNumber:@(size)]];
	else if (size >= 1024 && size < pow(1024, 2))
		formattedStr = [NSString stringWithFormat:@"%@ KB", [numberFormatter stringFromNumber:@(size / 1024.)]];
	else if (size >= pow(1024, 2) && size < pow(1024, 3))
		formattedStr = [NSString stringWithFormat:@"%@ MB", [numberFormatter stringFromNumber:@(size / pow(1024, 2))]];
	else if (size >= pow(1024, 3) && size < pow(1024, 4))
		formattedStr = [NSString stringWithFormat:@"%@ GB", [numberFormatter stringFromNumber:@(size / pow(1024, 3))]];
	else if (size >= pow(1024, 4))
		formattedStr = [NSString stringWithFormat:@"%@ TB", [numberFormatter stringFromNumber:@(size / pow(1024, 4))]];

	return formattedStr;
}

@end
