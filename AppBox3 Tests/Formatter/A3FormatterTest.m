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
	for (NSString *localeID in [NSLocale availableLocaleIdentifiers]) {
		NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeID];
		[df setLocale:locale];
		[df setDateStyle:NSDateFormatterFullStyle];
		NSString *originalFormat = df.dateFormat;
		[log appendFormat:@"%@\t[ %@ ]\t[ %@ ]\n", localeID,  originalFormat, [df stringFromDate:today]];
		
		NSString *convertedFormat = [df formatStringByRemovingYearComponent:originalFormat];
		[df setDateFormat:convertedFormat];
		[log appendFormat:@"%@\t[ %@ ]\t[ %@ ]\n", localeID,  convertedFormat, [df stringFromDate:today]];
	}
	NSLog(@"\n%@\n", log);
}


@end
