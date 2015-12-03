//
//  A3CurrencyViewControllerTest.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <XCTest/XCTest.h>
#define EXP_SHORTHAND
#import "Expecta.h"

#import "A3CurrencyTableViewController.h"

@interface A3CurrencyViewControllerTest : XCTestCase

@end

@implementation A3CurrencyViewControllerTest {
    A3CurrencyTableViewController *viewController;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.

	viewController = [[A3CurrencyTableViewController alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testCurrencyViewController {
    // Given
    
    // When
    
    // Then
//	expect([viewController class]).to.beSubclassOf([UITableViewController class]);
//    expect([viewController numberOfSectionsInTableView:viewController.tableView]).to.equal(1);
//    expect([viewController tableView:viewController.tableView numberOfRowsInSection:0]).beGreaterThan(1);
}

- (void)testMaximumFractionDigitsForCurrencyCodes {
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSMutableString *log = [NSMutableString new];
	static NSUInteger maximumFractionDigits = 0;
	[[NSLocale ISOCurrencyCodes] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[numberFormatter setCurrencyCode:obj];
		[log appendFormat:@"%@, %ld\n", obj, (unsigned long)numberFormatter.maximumFractionDigits];
		maximumFractionDigits = MAX(maximumFractionDigits, numberFormatter.maximumFractionDigits);
	}];
	NSLog(@"%@\n%ld", log, (unsigned long)maximumFractionDigits);
}

@end
