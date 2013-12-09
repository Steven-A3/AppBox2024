//
//  NSFileManager+A3Addtion.m
//  AppBox3
//
//  Created by A3 on 12/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSFileManager+A3Addtion.h"

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

- (void)setupStoreFile {
	NSString *storePath = [self storePath];
	FNLOG(@"%@", storePath);
	if (![self fileExistsAtPath:self.storePath]) {
		NSString *bundlePath = [[NSBundle mainBundle] pathForResource:self.storeName ofType:nil];
		NSString *applicationSupportPath = self.applicationSupportPath;
		[self createDirectoryAtPath:applicationSupportPath withIntermediateDirectories:YES attributes:nil error:NULL];
		[self copyItemAtPath:bundlePath	toPath:storePath error:NULL];
		
		NSString *sharedMemoryPath = [bundlePath stringByAppendingString:@"-shm"];
		NSString *targetPath = [storePath stringByAppendingString:@"-shm"];
		[self copyItemAtPath:sharedMemoryPath toPath:targetPath error:NULL];
		
		NSString *WALPath = [bundlePath stringByAppendingString:@"-wal"];
		targetPath = [storePath stringByAppendingString:@"-wal"];
		[self copyItemAtPath:WALPath toPath:targetPath error:NULL];
	}
}

@end
