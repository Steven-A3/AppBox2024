//
//  A3MonthCalendarTest.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/14/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "A3CalendarMonthView.h"

@interface A3MonthCalendarTest : GHTestCase

@end

@implementation A3MonthCalendarTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES.
    // Also an async test that calls back on the main thread, you'll probably want to return YES.
    return YES;
}

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}

- (void)testMonthView {
	A3CalendarMonthView *monthView = [[A3CalendarMonthView alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSDate *date = [dateFormatter dateFromString:@"2012-01-01"];

	[monthView setCurrentDate:date];
	[monthView gotoPreviousMonth];
	GHAssertTrue((monthView.year == 2011) && (monthView.month = 12), @"");

	[monthView setCurrentDate:date];
    GHTestLog(@"%d, %d", monthView.year, monthView.month);
	[monthView gotoPreviousMonth];      // 12
	[monthView gotoPreviousMonth];      // 11
    [monthView gotoPreviousMonth];      // 10
	[monthView gotoPreviousMonth];      // 9
	[monthView gotoPreviousMonth];      // 8
	[monthView gotoPreviousMonth];      // 7
	[monthView gotoPreviousMonth];      // 6
	[monthView gotoPreviousMonth];      // 5
	[monthView gotoPreviousMonth];      // 4
	[monthView gotoPreviousMonth];      // 3
	[monthView gotoPreviousMonth];      // 2
	[monthView gotoPreviousMonth];      // 1
	GHAssertTrue((monthView.year == 2011) && (monthView.month = 1), @"");
	[monthView gotoPreviousMonth];      // 12
	[monthView gotoPreviousMonth];      // 11
    [monthView gotoPreviousMonth];      // 10
	[monthView gotoPreviousMonth];      // 9
	[monthView gotoPreviousMonth];      // 8
	[monthView gotoPreviousMonth];      // 7
	[monthView gotoPreviousMonth];      // 6
	[monthView gotoPreviousMonth];      // 5
	[monthView gotoPreviousMonth];      // 4
	[monthView gotoPreviousMonth];      // 3
	[monthView gotoPreviousMonth];      // 2
	[monthView gotoPreviousMonth];      // 1
	GHAssertTrue((monthView.year == 2010) && (monthView.month = 1), @"");

    [monthView setCurrentDate:date];    // 1
    [monthView gotoNextMonth];          // 2
    [monthView gotoNextMonth];          // 3
    [monthView gotoNextMonth];          // 4
    [monthView gotoNextMonth];          // 5
    [monthView gotoNextMonth];          // 6
    [monthView gotoNextMonth];          // 7
    [monthView gotoNextMonth];          // 8
    [monthView gotoNextMonth];          // 9
    [monthView gotoNextMonth];          // 10
    [monthView gotoNextMonth];          // 11
    [monthView gotoNextMonth];          // 12
    [monthView gotoNextMonth];          // 1
	GHAssertTrue((monthView.year == 2013) && (monthView.month = 1), @"");
    [monthView gotoNextMonth];          // 2
    [monthView gotoNextMonth];          // 3
    [monthView gotoNextMonth];          // 4
    [monthView gotoNextMonth];          // 5
    [monthView gotoNextMonth];          // 6
    [monthView gotoNextMonth];          // 7
    [monthView gotoNextMonth];          // 8
    [monthView gotoNextMonth];          // 9
    [monthView gotoNextMonth];          // 10
    [monthView gotoNextMonth];          // 11
    [monthView gotoNextMonth];          // 12
    [monthView gotoNextMonth];          // 1
	GHAssertTrue((monthView.year == 2014) && (monthView.month = 1), @"");

	[monthView setCurrentDate:date];    // 2012-01-01
	[monthView gotoMonthByOffset:-20];
    GHTestLog(@"%d, %d", monthView.year, monthView.month);
	GHAssertTrue((monthView.year == 2010) && (monthView.month = 4), @"");

	for (int offset = 1; offset < 30; offset++) {
		[monthView setCurrentDate:date];    // 2012-01-01
		[monthView gotoMonthByOffset:-offset];
		GHTestLog(@"offset = %d, %d, %d", -offset, monthView.year, monthView.month);
	}

	for (int offset = 1; offset < 30; offset++) {
		[monthView setCurrentDate:date];    // 2012-01-01
		[monthView gotoMonthByOffset:offset];
		GHTestLog(@"offset = %d, %d, %d", offset, monthView.year, monthView.month);
	}
}

@end
