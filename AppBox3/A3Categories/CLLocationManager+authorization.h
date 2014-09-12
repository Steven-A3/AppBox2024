//
//  CLLocationManager+authorization.h
//  AppBox3
//
//  Created by kimjeonghwan on 9/12/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocationManager (authorization)

+ (BOOL)hasAuthorization;

@end
