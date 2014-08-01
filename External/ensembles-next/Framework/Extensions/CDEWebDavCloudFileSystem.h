//
//  CDEWebDavCloudFileSystem.h
//
//  Created by Drew McCormack on 2/17/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CDECloudFileSystem.h"

@class CDEWebDavCloudFileSystem;


@protocol CDEWebDavCloudFileSystemDelegate <NSObject>

@required
- (void)webDavCloudFileSystem:(CDEWebDavCloudFileSystem *)fileSystem updateLoginCredentialsWithCompletion:(CDECompletionBlock)completion;

@optional
-(void)webDavCloudFileSystemWillFormURLRequest:(CDEWebDavCloudFileSystem *)fileSystem;

@end


@interface CDEWebDavCloudFileSystem : NSObject <CDECloudFileSystem>

@property (nonatomic, readwrite, copy) NSString *username;
@property (nonatomic, readwrite, copy) NSString *password;
@property (nonatomic, readonly, assign, getter = isLoggedIn) BOOL loggedIn;
@property (nonatomic, readwrite, copy) NSURL *baseURL;

@property (nonatomic, readwrite, weak) id <CDEWebDavCloudFileSystemDelegate> delegate;

- (id)initWithBaseURL:(NSURL *)baseURL;

- (void)loginWithCompletion:(CDECompletionBlock)completion;

@end
