//
//  A3DateLunarTest.m
//  AppBox3
//
//  Created by dotnetguy83 on 4/29/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+LunarConverter.h"
#import "A3DateHelper.h"

@interface A3DateLunarTest : XCTestCase

@end

@implementation A3DateLunarTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    BOOL isResultLeapMonth = NO;
//    NSDateComponents *comp = [NSDateComponents new];
//    comp.year = 2013;
//    comp.month = 7;
//    comp.day = 31;
//    NSDate *solarDate = [NSDate dateOfSolarFromLunarDate:[[NSCalendar currentCalendar] dateFromComponents:comp] leapMonth:NO korean:[A3DateHelper isCurrentLocaleIsKorea] resultLeapMonth:&isResultLeapMonth];
//    NSLog(@"solarDate: %@", solarDate);
}

@end
