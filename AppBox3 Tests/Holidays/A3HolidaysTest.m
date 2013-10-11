//
//  A3HolidaysTest.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HolidayData.h"
#import "HolidayData+Country.h"
#define EXP_SHORTHAND
#import "Expecta.h"

@interface A3HolidaysTest : XCTestCase

@end

@implementation A3HolidaysTest {
    HolidayData *_holidayData;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _holidayData = [HolidayData new];
    _holidayData.year = 2014;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDataForAllCountry
{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSArray *allCountry = [HolidayData supportedCountries];
    NSLog(@"%d", [allCountry count]);
	[allCountry enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *keyPath = [NSString stringWithFormat:@"%@_HolidaysInYear", obj[kHolidayCountryCode]];
		NSMutableArray *holidays = [_holidayData valueForKeyPath:keyPath];
		expect([holidays isMemberOfClass:[NSMutableArray class]]).beTruthy;
		[holidays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *name = [obj objectForKey:kHolidayName];
            expect([name isMemberOfClass:[NSString class]]).beTruthy;
            expect([name length]).beGreaterThan(1);
            
            NSDate *date = [obj objectForKey:kHolidayDate];
			expect(date).notTo.beNil;
			expect([date isMemberOfClass:[NSDate class]]).beTruthy;

			NSDateComponents *components = [calendar components:NSYearCalendarUnit fromDate:date];
			expect(components.year).to.equal(2014);

			id public = [obj objectForKey:kHolidayIsPublic];
			expect(public).notTo.beNil;
			expect([public isMemberOfClass:[NSNumber class]]).beTruthy;

			id duration = [obj objectForKey:kHolidayDuration];
			expect(duration).notTo.beNil;
			expect([duration isMemberOfClass:[NSNumber class]]).beTruthy;
		}];
	}];
}

- (void)testLunar {
	NSDateComponents *components = [[NSDateComponents alloc] init];
	NSDate *resultDate;
	
	components.year = 2013;
	components.month = 9;
	components.day = 10;
	
	resultDate = [HolidayData lunarCalcWithComponents:components gregorianToLunar:NO leapMonth:YES korean:NO];
	NSLog(@"%@", resultDate);

	resultDate = [HolidayData lunarCalcWithComponents:components gregorianToLunar:NO leapMonth:NO korean:NO];
	NSLog(@"%@", resultDate);

	components.year = 2014;
	components.month = 9;
	components.day = 10;
	
	resultDate = [HolidayData lunarCalcWithComponents:components gregorianToLunar:NO leapMonth:YES korean:NO];
	NSLog(@"%@", resultDate);
	
	resultDate = [HolidayData lunarCalcWithComponents:components gregorianToLunar:NO leapMonth:NO korean:NO];
	NSLog(@"%@", resultDate);
}

- (void)testFonts {
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    NSLog(@"%@", [font description]);
    
    font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    NSLog(@"%@", [font description]);

    font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSLog(@"%@", [font description]);
    
    font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    NSLog(@"%@", [font description]);
    
    font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    NSLog(@"%@", [font description]);

    font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    NSLog(@"%@", [font description]);
}

- (void)testTimeZone {
	NSArray *allCountries = [HolidayData supportedCountries];
	expect(@([allCountries count])).equal(@98);
    NSLog(@"%d", [allCountries count]);
	[allCountries enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {

		expect(@([[obj allKeys] count])).equal(@2);

		NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:obj[kA3TimeZoneName]];
		expect(timeZone).notTo.beNil;
        
        NSLog(@"%@, %@, UTC%+d", [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:obj[kHolidayCountryCode]], timeZone, (int)[timeZone secondsFromGMT] / (60 * 60));
	}];
}

@end
