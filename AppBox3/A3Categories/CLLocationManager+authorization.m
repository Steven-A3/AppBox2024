//
//  CLLocationManager+authorization.m
//  AppBox3
//
//  Created by kimjeonghwan on 9/12/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "CLLocationManager+authorization.h"

@implementation CLLocationManager (authorization)

+ (BOOL)hasAuthorization
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return NO;
    }
    
    return YES;
}

@end
