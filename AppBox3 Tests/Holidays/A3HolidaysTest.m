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
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDataForAllCountry
{
    NSArray *allCountry = [_holidayData supportedCountries];
    
}

@end
