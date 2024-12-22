//
//  common.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 6/4/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#ifndef AppBox3_common_h
#define AppBox3_common_h

#import <CoreLocation/CoreLocation.h>

#ifdef DEBUG
#define FNLOG(p,...)		NSLog(@"%s line %d, " p, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define FNLOGRECT(rect)		NSLog(@"%s line %d, (%.1fx%.1f)-(%.1fx%.1f)", __FUNCTION__, __LINE__, rect.origin.x, rect.origin.y, \
 rect.size.width, rect.size.height)
#define FNLOGINSETS(insets)	NSLog(@"%s line %d, (top:%.1f, left:%.1f, bottom:%.1f, right:%.1f)", __FUNCTION__, __LINE__, insets.top, insets.left, insets.bottom, insets.right)
#define FNLOGPOINTS(point)  NSLog(@"%s line %d, (x:%.1f, y:%.1f)", __FUNCTION__, __LINE__, point.x, point.y)
#else
#define FNLOG(p,...)
#define FNLOGRECT(rect)
#define FNLOGINSETS(insets)
#define FNLOGPOINTS(point)
#endif

#define DegreesToRadians(degrees)	((degrees) * M_PI / 180.0)
#define RadiansToDegrees(radians)	((radians) * 180.0/M_PI)

#define SEGMENTED_CONTROL_DISABLED_TINT_COLOR	[UIColor colorWithRed:140.0/255.0 green:140.0/255.0 blue:140.0/255.0 alpha:1.0]
#define SEGMENTED_CONTROL_DISABLED_TINT_COLOR2	[UIColor colorWithRed:140.0/255.0 green:140.0/255.0 blue:140.0/255.0 alpha:1.0]

#ifndef __IPHONE_8_0

@interface NSURLSessionConfiguration (iOS8Edition)
+ (NSURLSessionConfiguration *)backgroundSessionConfigurationWithIdentifier:(NSString *)identifier;
@end

@interface CLLocationManager (iOS8Edition)
- (void)requestWhenInUseAuthorization;
@end

#endif

#endif
