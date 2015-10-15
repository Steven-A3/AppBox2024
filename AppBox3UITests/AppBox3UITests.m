//
//  AppBox3UITests.m
//  AppBox3UITests
//
//  Created by Byeong Kwon Kwak on 10/15/15.
//  Copyright © 2015 ALLABOUTAPPS. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface AppBox3UITests : XCTestCase

@end

@implementation AppBox3UITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
	
	XCUIApplication *app = [[XCUIApplication alloc] init];
	[app.buttons[@"Close Advertisement"] tap];
	[[[app.tables.cells containingType:XCUIElementTypeStaticText identifier:@"KRW"] childrenMatchingType:XCUIElementTypeTextField].element swipeRight];
	[app.navigationBars[@"Select Currency"].buttons[@"Back"] tap];
	[app.navigationBars[@"Currency Converter"].buttons[@"Apps"] tap];
	[[[[[[[[[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:1] childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:0].tables childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:1].staticTexts[@"Calculator"] tap];
	[app.staticTexts[@"0"] tap];
	[app.navigationBars[@"Calculator"].buttons[@"Apps"] tap];
	[app.navigationBars[@"AppBox Pro"] doubleTap];
	
	XCUIApplication *app2 = [[XCUIApplication alloc] init];
	[app2.buttons[@"Close Advertisement"] tap];
	
	XCUIElementQuery *tablesQuery = app2.tables;
	[tablesQuery.otherElements[@"A"] swipeLeft];
	[app2.navigationBars[@"Select Currency"].buttons[@"Back"] tap];
	
	XCUIElement *textField = [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"KRW"] childrenMatchingType:XCUIElementTypeTextField].element;
	[textField tap];
	
	XCUIElement *tableIndexTable = [app2.tables containingType:XCUIElementTypeOther identifier:@"table index"].element;
	[tableIndexTable tap];
	[tableIndexTable tap];
	[textField tap];
	[textField swipeLeft];
	[textField swipeRight];
	
}

@end
