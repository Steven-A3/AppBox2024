//
//  A3CalendarPreferences
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 8/7/12 7:38 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

#define A3CalendarUserCurrentCalendarType		@"A3CalendarUserCurrentCalendarType"	// "Day","Week","Month","Year" or "List"

@interface A3CalendarPreferences : NSObject
+ (NSString *)currentUserCalendarType;
+ (void)setCurrentUserCalendarType:(NSString *)type;

@end