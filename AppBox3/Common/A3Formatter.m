//
//  A3Formatter.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/2/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3Formatter.h"

@implementation A3Formatter

+ (NSString *)mediumStyleDateStringFromDate:(NSDate *)date {
	if (nil == date) {
		return @"";
	}
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	return [dateFormatter stringFromDate:date];
}

@end
