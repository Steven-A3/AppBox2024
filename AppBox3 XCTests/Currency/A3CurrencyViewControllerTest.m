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

#import "A3CurrencyViewController.h"

@interface A3CurrencyViewControllerTest : XCTestCase

@end

@implementation A3CurrencyViewControllerTest {
    A3CurrencyViewController *viewController;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.

	viewController = [[A3CurrencyViewController alloc] init];
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
	expect([viewController class]).to.beSubclassOf([UITableViewController class]);
    expect([viewController numberOfSectionsInTableView:viewController.tableView]).to.equal(1);
    expect([viewController tableView:viewController.tableView numberOfRowsInSection:0]).beGreaterThan(1);
}



@end
