//
//  CDEDirectory.m
//  Ensembles
//
//  Created by Drew McCormack on 4/12/13.
//  Copyright (c) 2013 Drew McCormack. All rights reserved.
//

#import "CDECloudDirectory.h"

@implementation CDECloudDirectory

@synthesize path;
@synthesize name;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        path = [aDecoder decodeObjectForKey:@"path"];
        name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:path forKey:@"path"];
    [aCoder encodeObject:name forKey:@"name"];
}

- (BOOL)canContainChildren
{
    return YES;
}

- (NSString *)description
{
    NSMutableString *result = [NSMutableString string];
    [result appendFormat:@"%@\r", super.description];
    NSArray *keys = @[@"path", @"name"];
    for (NSString *key in keys) {
        [result appendFormat:@"%@: %@; \r", key, [[self valueForKey:key] description]];
    }
    return result;
}

@end
