//
//  NSFileManager+A3Addtion.h
//  AppBox3
//
//  Created by A3 on 12/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (A3Addtion)

- (NSString *)applicationSupportPath;

- (NSString *)storePath;

- (NSString *)storeName;

- (void)setupCacheStoreFile;

- (NSString *)cacheStorePath;
@end
