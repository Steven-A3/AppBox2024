//
//  CDEDropboxV2CloudFileSystem.m
//
//  Created by Drew McCormack on 12/09/16.
//  Copyright (c) 2016 The Mental Faculty B.V. All rights reserved.
//

#import "CDEDropboxV2CloudFileSystem.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

#pragma mark - Main Class

@interface CDEDropboxV2CloudFileSystem ()
@end


@implementation CDEDropboxV2CloudFileSystem

@synthesize client;

- (instancetype)init
{
    if ((self = [super init])) {
        client = [DropboxClientsManager authorizedClient];
    }
    return self;
}

- (nullable DropboxClient *)authorizedClient
{
    // Always fallback to the most recently authorized client
    return client ?: [DropboxClientsManager authorizedClient];
}

+ (NSError *)genericAuthorizationError
{
    return [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeAuthenticationFailure userInfo:nil];
}

#pragma mark Paths

- (void)setRelativePathToRootInDropbox:(NSString *)newPath
{
    if ([newPath hasPrefix:@"/"]) {
        _relativePathToRootInDropbox = newPath;
    }
    else {
        _relativePathToRootInDropbox = [@"/" stringByAppendingString:newPath];
    }
}

- (NSString *)pathIncludingSubfolderForFilePath:(NSString *)path
{
    NSString *newPath = path;

    // Check if path ends with a GUID (32 characters) and located under the 'data' folder
    NSString *dirName = [[path stringByDeletingLastPathComponent] lastPathComponent];
    BOOL isInData = [dirName isEqualToString:@"data"];
    if (path.lastPathComponent.length == 32 && isInData) {
        NSString *guid = path.lastPathComponent;
        NSString *dataSubFolder = [guid substringToIndex:2];
        NSString *dataDir = [path stringByDeletingLastPathComponent];
        NSString *subDir = [dataDir stringByAppendingPathComponent:dataSubFolder];
        newPath = [subDir stringByAppendingPathComponent:guid];
    }

    return newPath;
}

- (NSString *)fullDropboxPathForPath:(NSString *)path
{
    if (self.relativePathToRootInDropbox) {
        path = [self.relativePathToRootInDropbox stringByAppendingPathComponent:path];
    }

    if (self.partitionDataFilesBetweenSubdirectories) {
        path = [self pathIncludingSubfolderForFilePath:path];
    }
    
    if ([path isEqualToString:@"/"]) {
        path = @""; // API expects empty string here
    }

    return path;
}

- (NSArray *)fullDropboxPathsForPaths:(NSArray *)paths
{
    if (self.relativePathToRootInDropbox) {
        paths = [paths cde_arrayByTransformingObjectsWithBlock:^(NSString *path) {
            return [self fullDropboxPathForPath:path];
        }];
    }
    return paths;
}


#pragma mark Connecting

- (BOOL)isConnected
{
    return [self authorizedClient] != nil;
}

- (void)connect:(CDECompletionBlock)completion
{
    if (self.isConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(nil);
        });
    }
    else if ([self.delegate respondsToSelector:@selector(linkSessionForDropboxCloudFileSystem:completion:)]) {
        [self.delegate linkSessionForDropboxCloudFileSystem:self completion:completion];
    }
    else {
        NSError *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeConnectionError userInfo:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(error);
        });
    }
}


#pragma mark User Identity

- (void)fetchUserIdentityWithCompletion:(CDEFetchUserIdentityCallback)completion
{
    DropboxClient *authorizedClient = [self authorizedClient];
    if (!authorizedClient) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(nil, [[self class] genericAuthorizationError]);
        });
        return;
    }
    
    [[authorizedClient.usersRoutes getCurrentAccount] response:^(DBUSERSFullAccount * _Nullable result, DBNilObject * _Nullable _, DBRequestError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                if (completion) completion(result.accountId, nil);
            } else {
                if (completion) completion(nil, error.nsError);
            }
        });
    }];
}


#pragma mark Checking File Existence

- (void)fileExistsAtPath:(NSString *)path completion:(CDEFileExistenceCallback)block
{
    DropboxClient *authorizedClient = [self authorizedClient];
    if (!authorizedClient) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(NO, NO, [[self class] genericAuthorizationError]);
        });
        return;
    }
    
    [[authorizedClient.filesRoutes getMetadata:[self fullDropboxPathForPath:path]] response:^(DBFILESMetadata * _Nullable metadata, DBFILESGetMetadataError * _Nullable routeError, DBRequestError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (metadata) {
                if ([metadata isKindOfClass:[DBFILESFileMetadata class]]) {
                    if (block) block(/*exist*/YES, /*isDirectory*/NO, /*error*/nil);
                } else if ([metadata isKindOfClass:[DBFILESFolderMetadata class]]) {
                    if (block) block(/*exist*/YES, /*isDirectory*/YES, /*error*/nil);
                } else if ([metadata isKindOfClass:[DBFILESDeletedMetadata class]]) {
                    if (block) block(/*exist*/NO, /*isDirectory*/NO, /*error*/nil);
                }
            } else {
                if ([routeError isPath] && routeError.path.isNotFound) {
                    if (block) block(/*exist*/NO, /*isDirectory*/NO, /*error*/nil);
                } else {
                    if (block) block(/*exist*/NO, /*isDirectory*/NO, /*error*/error.nsError);
                }
            }
        });
    }];
}


#pragma mark Getting Directory Contents

- (void)contentsOfDirectoryAtPath:(NSString *)path completion:(CDEDirectoryContentsCallback)block
{
    DropboxClient *authorizedClient = [self authorizedClient];
    if (!authorizedClient) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(nil, [[self class] genericAuthorizationError]);
        });
        return;
    }
    BOOL recursive = self.partitionDataFilesBetweenSubdirectories;
    [[authorizedClient.filesRoutes listFolder:[self fullDropboxPathForPath:path]
                                    recursive:@(recursive) includeMediaInfo:@(NO)
                               includeDeleted:@(NO) includeHasExplicitSharedMembers:@(NO)]
     response:^(DBFILESListFolderResult * _Nullable result, DBFILESListFolderError * _Nullable routeError, DBRequestError * _Nullable error) {
         if (!result) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (block) block(nil, error.nsError);
             });
             return;
         }
         CDECloudDirectory *directory = [CDECloudDirectory new];
         directory.contents = (NSArray <CDECloudItem> *)@[];

         for (DBFILESMetadata *child in result.entries) {
             // Dropbox inserts parenthesized indexes when two files with
             // same name are uploaded. Ignore these files.
             if ([child.name rangeOfString:@")"].location != NSNotFound) continue;

             id <CDECloudItem> item = nil;
             if ([child isKindOfClass:[DBFILESFolderMetadata class]]) {
                 CDECloudDirectory *subdir = [CDECloudDirectory new];
                 subdir.name = child.name;
                 subdir.path = child.pathDisplay;
                 item = subdir;
             } else if ([child isKindOfClass:[DBFILESFileMetadata class]]) {
                 CDECloudFile *file = [CDECloudFile new];
                 file.name = child.name;
                 file.path = child.pathDisplay;
                 file.size = ((DBFILESFileMetadata *)child).size.unsignedLongLongValue;
                 item = file;
             } else {
                 NSAssert(NO, @"We shouldn't have received DBFILESDeletedMetadata since includeDeleted is NO");
             }
             // Detect the topmost directory
             if ([item.path isEqualToString:path]) {
                 directory.name = item.name;
                 directory.path = item.path;
                 continue;
             }
             directory.contents = (NSArray<CDECloudItem> *)[directory.contents arrayByAddingObject:item];
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             if (block) block(directory.contents, nil);
         });
     }];
}


#pragma mark Creating Directories

- (void)createDirectoryAtPath:(NSString *)path completion:(CDECompletionBlock)block
{
    DropboxClient *authorizedClient = [self authorizedClient];
    if (!authorizedClient) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block([[self class] genericAuthorizationError]);
        });
        return;
    }
    [[authorizedClient.filesRoutes createFolder:[self fullDropboxPathForPath:path]] response:^(DBFILESFolderMetadata * _Nullable metadata, DBFILESCreateFolderError * _Nullable routeError, DBRequestError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(error.nsError);
        });
    }];
}


#pragma mark Deleting

- (void)removeItemsAtPaths:(NSArray *)paths completion:(CDECompletionBlock)block
{
    DropboxClient *authorizedClient = [self authorizedClient];
    if (!authorizedClient) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block([[self class] genericAuthorizationError]);
        });
        return;
    }
    if (paths.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil);
        });
    }
    __block NSError *lastError = nil;
    dispatch_group_t group = dispatch_group_create();

    for (__unused id job in [self fullDropboxPathsForPaths:paths]) {
        dispatch_group_enter(group);
    }
    for (NSString *path in [self fullDropboxPathsForPaths:paths]) {
        [[authorizedClient.filesRoutes delete_:path] response:^(DBFILESMetadata * _Nullable metadata, DBFILESDeleteError * _Nullable routeError, DBRequestError * _Nullable error) {
            if (error) lastError = [error.nsError copy];
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (block) block(lastError);
    });
}

- (void)removeItemAtPath:(NSString *)path completion:(CDECompletionBlock)block
{
    return [self removeItemsAtPaths:@[path] completion:block];
}


#pragma mark Uploading and Downloading

- (void)uploadLocalFiles:(NSArray *)fromPaths toPaths:(NSArray *)toPaths completion:(CDECompletionBlock)block
{
    DropboxClient *authorizedClient = [self authorizedClient];
    if (!authorizedClient) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block([[self class] genericAuthorizationError]);
        });
        return;
    }
    if (fromPaths.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil);
        });
    }
    NSArray <NSURL *> *inputs = [fromPaths cde_arrayByTransformingObjectsWithBlock:^id(NSString *path) {
        return [NSURL fileURLWithPath:path];
    }];
    NSDictionary *routes = [NSDictionary dictionaryWithObjects:[self fullDropboxPathsForPaths:toPaths]
                                                       forKeys:inputs];
    __block NSError *lastError = nil;
    dispatch_group_t group = dispatch_group_create();

    for (__unused id job in routes) {
        dispatch_group_enter(group);
    }
    [routes enumerateKeysAndObjectsUsingBlock:^(NSURL *localURL, NSString *dropboxURL, BOOL * _Nonnull stop) {
        DBUploadTask *task = [authorizedClient.filesRoutes uploadUrl:dropboxURL mode:nil autorename:nil clientModified:nil mute:@(YES) inputUrl:localURL];
        [task response:^(DBFILESFileMetadata * _Nullable metadata, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable error) {
            if (error) lastError = [error.nsError copy];
            dispatch_group_leave(group);
        }];
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (block) block(lastError);
    });
}

- (void)uploadLocalFile:(NSString *)fromPath toPath:(NSString *)toPath completion:(CDECompletionBlock)block
{
    return [self uploadLocalFiles:@[fromPath] toPaths:@[toPath] completion:block];
}

- (void)downloadFromPaths:(NSArray *)fromPaths toLocalFiles:(NSArray *)toPaths completion:(CDECompletionBlock)block
{
    DropboxClient *authorizedClient = [self authorizedClient];
    if (!authorizedClient) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block([[self class] genericAuthorizationError]);
        });
        return;
    }
    NSArray <NSString *> *dropboxURLs = [self fullDropboxPathsForPaths:fromPaths];
    NSArray <NSURL *> *localURLs = [toPaths cde_arrayByTransformingObjectsWithBlock:^id(NSString *path) {
        return [NSURL fileURLWithPath:path];
    }];
    NSDictionary *routes = [NSDictionary dictionaryWithObjects:localURLs forKeys:dropboxURLs];

    __block NSError *lastError = nil;
    dispatch_group_t group = dispatch_group_create();

    for (__unused id job in routes) {
        dispatch_group_enter(group);
    }
    [routes enumerateKeysAndObjectsUsingBlock:^(NSString *dropboxURL, NSURL *localURL, BOOL * _Nonnull stop) {
        DBDownloadUrlTask *task = [authorizedClient.filesRoutes downloadUrl:dropboxURL overwrite:YES destination:localURL];
        [task response:^(DBFILESFileMetadata * _Nullable metadata, DBFILESDownloadError * _Nullable routeError, DBRequestError * _Nullable error, NSURL * _Nonnull actualLocalURL) {
            if (error) lastError = [error.nsError copy];
            dispatch_group_leave(group);
        }];
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (block) block(lastError);
    });
}

- (void)downloadFromPath:(NSString *)fromPath toLocalFile:(NSString *)toPath completion:(CDECompletionBlock)block
{
    return [self downloadFromPaths:@[fromPath] toLocalFiles:@[toPath] completion:block];
}

@end
