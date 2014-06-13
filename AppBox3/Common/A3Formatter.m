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

// 오영택 add
+ (NSString *)customFullStyleStringFromDate:(NSDate *)date {
	NSDateFormatter *df = [NSDateFormatter new];
	[df setDateStyle:NSDateFormatterFullStyle];
	NSString *dateFormat = [df dateFormat];
	dateFormat = [dateFormat stringByReplacingOccurrencesOfString:@"EEEE" withString:@"E" options:0 range:NSMakeRange(0, [dateFormat length])];
	dateFormat = [dateFormat stringByReplacingOccurrencesOfString:@"MMMM" withString:@"MMM" options:0 range:NSMakeRange(0, [dateFormat length])];
	[df setDateFormat:dateFormat];
	return [df stringFromDate:date];
}

+ (NSString *)fullStyleDateStringFromDate:(NSDate *)date {
	NSDateFormatter *df = [NSDateFormatter new];
	[df setDateStyle:NSDateFormatterFullStyle];
	NSString *dateFormat = [df dateFormat];
	[df setDateFormat:dateFormat];
	return [df stringFromDate:date];
}

/*! Returns custom style with date
 * \param NSDate *date
 * \returns
 * en_US: Sat, Jan 4, 2014
 * ko_KR: 2014년 1월 4일 토
 */
+ (NSString *)fullStyleStringFromDate:(NSDate *)date {
	NSDateFormatter *df = [NSDateFormatter new];
	[df setDateStyle:NSDateFormatterFullStyle];
	NSString *format = [df dateFormat];
	format = [format stringByReplacingOccurrencesOfString:@"EEEE" withString:@"EEE"];
	format = [format stringByReplacingOccurrencesOfString:@"MMMM" withString:@"MMM"];
	[df setDateFormat:format];

	return [df stringFromDate:date];
}

@end
