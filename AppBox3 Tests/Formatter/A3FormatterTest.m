//
//  A3FormatterTest.m
//  AppBox3
//
//  Created by A3 on 2/7/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDateFormatter+A3Addition.h"

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


@end
