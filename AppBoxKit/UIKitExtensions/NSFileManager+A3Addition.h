//
//  NSFileManager+A3Addition.h
//  AppBox3
//
//  Created by A3 on 12/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (A3Addition)

- (NSString *)applicationSupportPath;
- (NSString *)documentDirectoryPath;
//- (NSString *)storePath;
//- (NSString *)storeName;
- (NSString *)humanReadableFileSize:(unsigned long long)size;
- (NSURL *)storeURL;
- (NSString *)storeFileName;

@end
