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
		[df setDateStyle:NSDateFormatterMediumStyle];
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
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 60 * 24],
			 [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 60 * 12],
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
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 60 * 12],
			 [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 60 * 24],
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

- (void)testDateFormat {
	NSDateFormatter *formatter = [NSDateFormatter new];
	[formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"]];
	NSMutableString *log = [NSMutableString new];
	[formatter setDateStyle:NSDateFormatterFullStyle];
	[log appendFormat:@"%@\n", [formatter stringFromDate:[NSDate date] ] ];
	[formatter setDateStyle:NSDateFormatterLongStyle];
	[log appendFormat:@"%@\n", [formatter stringFromDate:[NSDate date] ] ];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[log appendFormat:@"%@\n", [formatter stringFromDate:[NSDate date] ] ];
	NSLog(@"%@", log);
}

- (void)testNumberFormat {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	NSMutableString *log = [NSMutableString new];
	[numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
	[log appendFormat:@"%@\n", [numberFormatter stringFromNumber:@123456789.123]];
	
	[numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"de_DE"]];
	[log appendFormat:@"%@\n", [numberFormatter stringFromNumber:@123456789.123]];
	
	[numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"fr_FR"]];
	[log appendFormat:@"%@\n", [numberFormatter stringFromNumber:@123456789.123]];
	
	NSLog(@"%@", log);
}

- (void)addTimeFormatString:(NSMutableString *)log withLocale:(NSString *)localeID {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:localeID]];
	
	NSDate *date = [NSDate date];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	[dateFormatter setTimeStyle:NSDateFormatterFullStyle];
	[log appendFormat:@"%@\n", [dateFormatter stringFromDate:date]];

	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterLongStyle];
	[log appendFormat:@"%@\n", [dateFormatter stringFromDate:date]];

	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	[log appendFormat:@"%@\n", [dateFormatter stringFromDate:date]];

	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[log appendFormat:@"%@\n", [dateFormatter stringFromDate:date]];
}

- (void)testTimeFormat {
	NSArray *locales = @[@"en_US", @"de_DE", @"ko_KR", @"ja_JP"];
	NSMutableString *log = [NSMutableString new];
	for (NSString *localeID in locales) {
		[self addTimeFormatString:log withLocale:localeID];
	}
	NSLog(@"%@", log);
}

- (void)testDateCalculation {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *fromComponents = [NSDateComponents new];
	fromComponents.year = 2013;
	fromComponents.month = 5;
	fromComponents.day = 30;
//	fromComponents.hour = 0;
	
	NSDate *fromDate = [calendar dateFromComponents:fromComponents];
	
	NSDateComponents *toComponents = [NSDateComponents new];
	toComponents.year = 2014;
	toComponents.month = 5;
	toComponents.day = 12;
//	toComponents.hour = 12;
	NSDate *toDate = [calendar dateFromComponents:toComponents];
	
	NSDateComponents *diffComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:fromDate toDate:toDate options:0];
	NSLog(@"%@", diffComponents);
	
	fromComponents.year = 2013;
	fromComponents.month = 5;
	fromComponents.day = 31;
//	fromComponents.hour = 12;
	fromDate = [calendar dateFromComponents:fromComponents];
	
	diffComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:fromDate toDate:toDate options:0];
	NSLog(@"%@", diffComponents);
}

- (void)testWeekdaySymbols {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
	NSArray *en_US = [dateFormatter shortWeekdaySymbols];
	[dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ko_KR"]];
	NSArray *ko_KR = [dateFormatter shortWeekdaySymbols];
	NSLog(@"\n%@, %@\n", en_US, ko_KR);
}

- (void)testCurrencyFormatter {
    NSNumberFormatter *nf = [NSNumberFormatter new];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setCurrencyCode:@"KRW"];
    
    NSLog(@"%@", [nf stringFromNumber:@(50000000000)]);
}

@end
