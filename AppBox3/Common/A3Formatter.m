//
//  A3Formatter.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/2/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3Formatter.h"

@implementation A3Formatter

+ (NSString *)shortStyleDateTimeStringFromDate:(NSDate *)date {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterShortStyle];
	[df setTimeStyle:NSDateFormatterShortStyle];
	NSString *result = [df stringFromDate:date];

	return result;
}

+ (NSString *)mediumStyleDateStringFromDate:(NSDate *)date {
	if (nil == date) {
		return @"";
	}
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	return [dateFormatter stringFromDate:date];
}

+ (NSString *)fullStyleMonthSymbolFromDate:(NSDate *)date {
	if (nil == date) {
		return @"";
	}
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMMM"];
	return [dateFormatter stringFromDate:date];
}

+ (NSString *)fullStyleYearMonthStringFromDate:(NSDate *)date {
	if (nil == date) {
		return @"";
	}
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMMM, y"];
	return [dateFormatter stringFromDate:date];
}

+ (NSString *)stringWithCurrencyFormatFromNumber:(NSNumber *)number {
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	return [currencyFormatter stringFromNumber:number];
}

+ (NSString *)stringWithPercentFormatFromNumber:(NSNumber *)number {
	NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
	[percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
	return [percentFormatter stringFromNumber:number];
}

@end
