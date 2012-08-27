//
//  common.h
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 6/4/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#ifndef AppBoxPro2_common_h
#define AppBoxPro2_common_h

#ifdef DEBUG
#define FNLOG(p,...)		NSLog(@"%s "p, __FUNCTION__, ##__VA_ARGS__)
#else
#define FNLOG(p,...)
#endif

#define DegreesToRadians(degrees)	(degrees * M_PI / 180.0)
#define RadiansToDegrees(radians)	(radians * 180.0/M_PI)

#endif
