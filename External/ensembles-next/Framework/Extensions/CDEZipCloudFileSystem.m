//
//  CDEZipCloudFileSystem.m
//  Idiomatic
//
//  Created by Drew McCormack on 12/06/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import "CDEZipCloudFileSystem.h"

static NSString * const CDEZipFilePathExtension = @"cdezip";

@implementation CDEZipCloudFileSystem {
    NSFileManager *fileManager;
    NSString *tempDirPath;
}

@synthesize cloudFileSystem = cloudFileSystem;

- (instancetype)initWithCloudFileSystem:(id <CDECloudFileSystem>)wrappedFileSystem
{
    self = [super init];
    if (self) {
        cloudFileSystem = wrappedFileSystem;
        fileManager = [[NSFileManager alloc] init];
        tempDirPath = [NSTemporaryDirectory() stringByAppendingFormat:@"/CDEZipCloudFileSystem/%@", [[NSProcessInfo processInfo] globallyUniqueString]];
        [self clearTempDir];
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:CDEException reason:@"Wrong initializer invoked" userInfo:nil];
}

- (void)dealloc
{
    [[NSFileManager defaultManager] removeItemAtPath:tempDirPath error:NULL];
}

- (void)clearTempDir
{
    [fileManager removeItemAtPath:tempDirPath error:NULL];
    [fileManager createDirectoryAtPath:tempDirPath withIntermediateDirectories:YES attributes:nil error:NULL];
}

- (void)connect:(CDECompletionBlock)completion
{
    [cloudFileSystem connect:completion];
}

- (BOOL)isConnected
{
    return cloudFileSystem.isConnected;
}

- (id <NSObject, NSCopying, NSCoding>) identityToken
{
    return cloudFileSystem.identityToken;
}

- (void)fileExistsAtPath:(NSString *)path completion:(CDEFileExistenceCallback)completion
{
    NSString *zippedPath = [path stringByAppendingPathExtension:CDEZipFilePathExtension];
    [cloudFileSystem fileExistsAtPath:zippedPath completion:^(BOOL exists, BOOL isDirectory, NSError *error) {
        if (error) {
            if (completion) completion(NO, NO, error);
            return;
        }
        
        if (!exists) {
            [cloudFileSystem fileExistsAtPath:path completion:completion];
            return;
        }
        
        if (completion) completion(exists, isDirectory, nil);
    }];
}

- (void)createDirectoryAtPath:(NSString *)path completion:(CDECompletionBlock)completion
{
    [cloudFileSystem createDirectoryAtPath:path completion:completion];
}

- (void)removeItemAtPath:(NSString *)fromPath completion:(CDECompletionBlock)completion
{
    NSString *zippedPath = [fromPath stringByAppendingPathExtension:CDEZipFilePathExtension];
    [cloudFileSystem removeItemAtPath:zippedPath completion:^(NSError *error) {
        if (error) {
            [cloudFileSystem removeItemAtPath:fromPath completion:completion];
            return;
        }

        if (completion) completion(nil);
    }];
}

- (void)contentsOfDirectoryAtPath:(NSString *)path completion:(CDEDirectoryContentsCallback)completion
{
    [cloudFileSystem contentsOfDirectoryAtPath:path completion:^(NSArray *contents, NSError *error) {
        if (error) {
            if (completion) completion(nil, error);
            return;
        }
        
        for (id item in contents) {
            CDECloudFile *file = item;
            if ([item isKindOfClass:[CDECloudFile class]] && [file.name.pathExtension isEqualToString:CDEZipFilePathExtension]) {
                file.name = [file.name stringByDeletingPathExtension];
            }
        }
        if (completion) completion(contents, nil);
    }];
}

- (NSString *)tempFilePath
{
    NSString *tempFilePath = [tempDirPath stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    return tempFilePath;
}

- (void)downloadFromPath:(NSString *)fromPath toLocalFile:(NSString *)toPath completion:(CDECompletionBlock)completion
{
    NSString *tempFilePath = [self tempFilePath];
    NSString *zippedPath = [fromPath stringByAppendingPathExtension:CDEZipFilePathExtension];
    [cloudFileSystem downloadFromPath:zippedPath toLocalFile:tempFilePath completion:^(NSError *error) {
        if (error) {
            [cloudFileSystem downloadFromPath:fromPath toLocalFile:toPath completion:completion];
            return;
        }
        
        NSError *localError;
        NSString *destinationDir = [toPath stringByDeletingLastPathComponent];
        BOOL unzipSucceeded = [SSZipArchive unzipFileAtPath:tempFilePath toDestination:destinationDir overwrite:NO password:nil error:&localError];
        [fileManager removeItemAtPath:tempFilePath error:NULL];
        
        if (completion) completion(unzipSucceeded ? nil : localError);
    }];
}

- (void)uploadLocalFile:(NSString *)fromPath toPath:(NSString *)toPath completion:(CDECompletionBlock)completion
{
    NSString *tempFilePath = [self tempFilePath];
    [SSZipArchive createZipFileAtPath:tempFilePath withFilesAtPaths:@[fromPath]];
    NSString *zippedPath = [toPath stringByAppendingPathExtension:CDEZipFilePathExtension];
    [cloudFileSystem uploadLocalFile:tempFilePath toPath:zippedPath completion:^(NSError *error) {
        [fileManager removeItemAtPath:tempFilePath error:NULL];
        if (completion) completion(error);
    }];
}

@end
