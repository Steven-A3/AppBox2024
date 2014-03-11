//
//  NSManagedObject+Identify.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 1..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "NSManagedObject+Identify.h"

@implementation NSManagedObject (Identify)

- (NSString *)uriKey
{
    NSManagedObjectID *oid = self.objectID;
    NSString *key = oid.URIRepresentation.absoluteString;
    
    return key;
}

@end
