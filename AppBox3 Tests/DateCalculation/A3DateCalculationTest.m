//
//  A3DateCalculationTest.m
//  AppBox3
//
//  Created by A3 on 8/18/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface A3DateCalculationTest : XCTestCase

@end

@implementation A3DateCalculationTest {
	NSCalendar *_gregorian;
	NSDate *_olderDate;
	NSDate *_futureDate;
}

- (void)setUp {
    [super setUp];
	
    // Put setup code here. This method is called before the invocation of each test method in the class.
	_gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *components = [NSDateComponents new];
	components.month = -2;
	_olderDate = [_gregorian dateByAddingComponents:components toDate:[NSDate date] options:0];
	components.month = 2;
	_futureDate = [_gregorian dateByAddingComponents:components toDate:[NSDate date] options:0];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
	
	NSDateComponents *resultComponents = [_gregorian components:NSWeekOfMonthCalendarUnit fromDate:[NSDate date] toDate:_olderDate options:0];
	NSLog(@"%ld", (long)resultComponents.weekOfMonth);
	resultComponents = [_gregorian components:NSWeekOfMonthCalendarUnit fromDate:[NSDate date] toDate:_futureDate options:0];
	NSLog(@"%ld", (long)resultComponents.weekOfMonth);

	resultComponents = [_gregorian components:NSWeekOfYearCalendarUnit fromDate:[NSDate date] toDate:_olderDate options:0];
	NSLog(@"%ld", (long)resultComponents.weekOfYear);
	resultComponents = [_gregorian components:NSWeekOfYearCalendarUnit fromDate:[NSDate date] toDate:_futureDate options:0];
	NSLog(@"%ld", (long)resultComponents.weekOfYear);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	resultComponents = [_gregorian components:NSWeekCalendarUnit fromDate:[NSDate date] toDate:_olderDate options:0];
	NSLog(@"%ld, %ld, %ld", (long)resultComponents.week, (long)resultComponents.weekOfMonth, (long)resultComponents.weekOfYear);
	resultComponents = [_gregorian components:NSWeekCalendarUnit fromDate:[NSDate date] toDate:_futureDate options:0];
	NSLog(@"%ld, %ld, %ld", (long)resultComponents.week, (long)resultComponents.weekOfMonth, (long)resultComponents.weekOfYear);
	
	NSDateComponents *addingComponents = [NSDateComponents new];
	addingComponents.weekOfYear = 8;
	NSDate *resultDate = [_gregorian dateByAddingComponents:addingComponents toDate:[NSDate date] options:0];
	NSLog(@"%@, %@, %@", resultDate, _olderDate, _futureDate);

	addingComponents.weekOfYear = 0;
	addingComponents.weekOfMonth = 8;
	resultDate = [_gregorian dateByAddingComponents:addingComponents toDate:[NSDate date] options:0];
	NSLog(@"%@, %@, %@", resultDate, _olderDate, _futureDate);

	addingComponents.weekOfYear = 0;
	addingComponents.weekOfMonth = 0;
	addingComponents.week = 8;
	resultDate = [_gregorian dateByAddingComponents:addingComponents toDate:[NSDate date] options:0];
	NSLog(@"%@, %@, %@", resultDate, _olderDate, _futureDate);
	XCTAssert(YES, @"Pass");
#pragma clang diagnostic pop
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
}

@end
