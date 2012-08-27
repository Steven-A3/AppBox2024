//
//  A3CalendarPreferences
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 8/7/12 7:38 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarPreferences.h"


@implementation A3CalendarPreferences {

}

+ (NSString *)currentUserCalendarType {
	NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:A3CalendarUserCurrentCalendarType];
	if (nil == type) {
		type = @"Month";
	}
	return type;
}

+ (void)setCurrentUserCalendarType:(NSString *)type {
	[[NSUserDefaults standardUserDefaults] setObject:type forKey:A3CalendarUserCurrentCalendarType];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end