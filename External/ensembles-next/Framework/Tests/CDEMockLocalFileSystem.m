//
//  CDEMockLocalFileSystem.m
//  Ensembles
//
//  Created by Drew McCormack on 15/11/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import "CDEMockLocalFileSystem.h"

@implementation CDEMockLocalFileSystem {
    id <NSObject, NSCopying, NSCoding> _identityToken;
}

- (id <NSObject, NSCopying, NSCoding>)identityToken
{
    return _identityToken;
}

- (void)setIdentityToken:(id <NSObject, NSCopying, NSCoding>)newToken
{
    _identityToken = newToken;
}

- (void)fetchUserIdentityWithCompletion:(CDEFetchUserIdentityCallback)completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) completion(_identityToken, nil);
    });
}

@end
