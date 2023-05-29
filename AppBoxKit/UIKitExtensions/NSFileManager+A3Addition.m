//
//  NSFileManager+A3Addition.m
//  AppBox3
//
//  Created by A3 on 12/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSFileManager+A3Addition.h"

NSString *const A3AppGroupIdentifier = @"group.allaboutapps.appbox";

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

- (NSURL *)storeURL
{
    NSURL *appGroupContainerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:A3AppGroupIdentifier];
    NSURL *storeURL = [appGroupContainerURL URLByAppendingPathComponent:@"Library/AppBox"];
    return [storeURL URLByAppendingPathComponent:[self storeFileName]];
}

- (NSString *)storeFileName {
    return @"AppBoxStore.sqlite";
}

@end
