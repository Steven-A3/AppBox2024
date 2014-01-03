//
//  common.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 6/4/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#ifndef AppBox3_common_h
#define AppBox3_common_h

#ifdef DEBUG
#define FNLOG(p,...)		NSLog(@"%s line %d, "p, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define FNLOGRECT(rect)		NSLog(@"%s line %d, (%.1fx%.1f)-(%.1fx%.1f)", __FUNCTION__, __LINE__, rect.origin.x, rect.origin.y, \
 rect.size.width, rect.size.height)
#else
#define FNLOG(p,...)
#define FNLOGRECT(rect)
#endif

#define DegreesToRadians(degrees)	((degrees) * M_PI / 180.0)
#define RadiansToDegrees(radians)	((radians) * 180.0/M_PI)

#endif
