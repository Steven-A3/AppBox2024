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

/**
 * Generates the URL for the app's store file within a shared app group container.
 *
 * This method constructs the full file path for the app's store file by:
 * 1. Retrieving the URL for the app group's shared container.
 * 2. Appending the path component "Library/AppBox" to the container URL.
 * 3. Appending the store file name to the resulting URL.
 *
 * @return A NSURL object representing the full path to the store file within the app group's container.
 *
 * Example usage:
 * NSURL *storeFileURL = [self storeURL];
 *
 * Note:
 * - The method assumes that A3AppGroupIdentifier is a valid app group identifier.
 * - The method `[self storeFileName]` should return the appropriate file name for the store file.
 */
- (NSURL *)storeURL
{
    // Retrieve the URL for the app group's shared container
    NSURL *appGroupContainerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:A3AppGroupIdentifier];
    
    // Append the "Library/AppBox" path component to the container URL
    NSURL *storeURL = [appGroupContainerURL URLByAppendingPathComponent:@"Library/AppBox"];
    
    // Append the store file name to the resulting URL and return it
    return [storeURL URLByAppendingPathComponent:[self storeFileName]];
}

- (NSString *)storeFileName {
    return @"AppBoxStore.sqlite";
}

@end
