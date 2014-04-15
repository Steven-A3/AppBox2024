//
//  A3FormatterTest.m
//  AppBox3
//
//  Created by A3 on 2/7/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDateFormatter+A3Addition.h"
#import "NSDateFormatter+LunarDate.h"
#import "NSDate+TimeAgo.h"

@interface A3FormatterTest : XCTestCase

@end

@implementation A3FormatterTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
	NSDateFormatter *df = [NSDateFormatter new];
	NSDate *today = [NSDate date];
	NSMutableString *log = [NSMutableString new];
	NSArray *localeIdentifiers = [[NSLocale availableLocaleIdentifiers] sortedArrayUsingSelector:@selector(compare:)];
	for (NSString *localeID in localeIdentifiers) {
		NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeID];
		[df setLocale:locale];
		[df setDateStyle:NSDateFormatterLongStyle];
		NSString *originalFormat = df.dateFormat;
		[log appendFormat:@"%@\t[ %@ ]\t[ %@ ]\n", localeID,  originalFormat, [df stringFromDate:today]];
		
		NSString *convertedFormat = [df formatStringByRemovingYearComponent:originalFormat];
		[df setDateFormat:convertedFormat];
		[log appendFormat:@"%@\t[ %@ ]\t[ %@ ]\n", localeID,  convertedFormat, [df stringFromDate:today]];
		
		convertedFormat = [df formatStringByRemovingDayComponent:originalFormat];
		[df setDateFormat:convertedFormat];
		[log appendFormat:@"%@\t[ %@ ]\t[ %@ ]\n", localeID,  convertedFormat, [df stringFromDate:today]];
		
		[log appendFormat:@"%@\n", [df localizedLongStyleYearMonthFromDate:today]];
		[log appendFormat:@"%@\n", [df localizedMediumStyleYearMonthFromDate:today]];
	}

	[df setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
	for (NSString *symbol in [df monthSymbols]) {
		[log appendFormat:@"%@\n", symbol];
	}
	for (NSString *symbol in [df shortMonthSymbols]) {
		[log appendFormat:@"%@\n", symbol];
	}
	for (NSString *symbol in [df veryShortMonthSymbols]) {
		[log appendFormat:@"%@\n", symbol];
	}

	[df setLocale:[NSLocale localeWithLocaleIdentifier:@"ko_KR"]];
	for (NSString *symbol in [df monthSymbols]) {
		[log appendFormat:@"%@\n", symbol];
	}
	for (NSString *symbol in [df shortMonthSymbols]) {
		[log appendFormat:@"%@\n", symbol];
	}
	for (NSString *symbol in [df veryShortMonthSymbols]) {
		[log appendFormat:@"%@\n", symbol];
	}

	NSLog(@"\n%@\n", log);
}

- (void)testStringFromDateComponents {
	NSDateFormatter *df = [NSDateFormatter new];
	NSDate *today = [NSDate date];
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
	
	NSMutableString *log = [NSMutableString new];
	NSArray *localeIdentifiers = [[NSLocale availableLocaleIdentifiers] sortedArrayUsingSelector:@selector(compare:)];
	for (NSString *localeID in localeIdentifiers) {
		NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeID];
		[df setLocale:locale];
		[df setDateStyle:NSDateFormatterLongStyle];
		NSString *originalFormat = df.dateFormat;
		[log appendFormat:@"%@\t[ %@ ]\t[ %@ ]\n", localeID,  originalFormat, [df stringFromDateComponents:dateComponents]];
		
		NSString *convertedFormat = [df formatStringByRemovingYearComponent:originalFormat];
		[df setDateFormat:convertedFormat];
		[log appendFormat:@"%@\t[ %@ ]\t[ %@ ]\n", localeID,  convertedFormat, [df stringFromDateComponents:dateComponents]];
		
		convertedFormat = [df formatStringByRemovingDayComponent:originalFormat];
		[df setDateFormat:convertedFormat];
		[log appendFormat:@"%@\t[ %@ ]\t[ %@ ]\n", localeID,  convertedFormat, [df stringFromDateComponents:dateComponents]];
		
		[log appendFormat:@"%@\n", [df localizedLongStyleYearMonthFromDate:today]];
		[log appendFormat:@"%@\n", [df localizedMediumStyleYearMonthFromDate:today]];
	}
	
	NSLog(@"\n%@\n", log);

	NSString *localeID = @"ca";
	NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeID];
	[df setLocale:locale];
	[df setDateStyle:NSDateFormatterLongStyle];
	NSString *originalFormat = df.dateFormat;
	[log appendFormat:@"%@\t[ %@ ]\t[ %@ ]\n", localeID,  originalFormat, [df stringFromDateComponents:dateComponents]];

}

- (NSArray *)timesArray {
	return @[
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 60],
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 30],
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 15],
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 14],
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 8],
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 7],
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 5],
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 4],
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 3],
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 2],
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 1],
			 [NSDate dateWithTimeIntervalSinceNow:0],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 1],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 2],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 3],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 4],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 5],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 7],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 8],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 14],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 15],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 30],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 31],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 60],
			 ];
}

- (void)testTimeAgo {
	NSMutableString *log = [NSMutableString new];
	[[self timesArray] enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL *stop) {
		[log appendString:[NSString stringWithFormat:@"%@\n", [date timeAgo]]];
	}];
	NSLog(@"%@", log);
}

- (void)testRelativeFormatting {
	NSMutableString *log = [NSMutableString new];
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDoesRelativeDateFormatting:YES];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	[[self timesArray] enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL *stop) {
		[log appendString:[NSString stringWithFormat:@"%@\n", [dateFormatter stringFromDate:date]]];
	}];
	NSLog(@"%@", log);
}

- (void)testStringWithFormat {
	NSLog(@"%@", [NSString stringWithFormat:@"%010lu", (unsigned long)123]);
}

@end
