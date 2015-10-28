//
//  AppBox3UITests.swift
//  AppBox3UITests
//
//  Created by Byeong Kwon Kwak on 10/17/15.
//  Copyright © 2015 ALLABOUTAPPS. All rights reserved.
//

import XCTest

class AppBox3UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
		
		let app = XCUIApplication()
		let button = app.buttons["Close Advertisement"]
		if button.exists {
			button.tap()
		}
		
		app.navigationBars.matchingPredicate(NSPredicate(format: "NOT (title BEGINSWITH 'AppBox')")).buttons["Apps"].tap()
		
		let table = app.tables.matchingIdentifier("MainMenuTable")
		let currencyCell = table.cells.matchingPredicate(NSPredicate(format: "title BEGINSWITH 'Currency'"))
		let firstCurrencyCell = currencyCell.elementBoundByIndex(0)
//		let currencyText = firstCurrencyCell
		firstCurrencyCell.staticTexts.elementBoundByIndex(0).tap()
		

		self.waitForExpectationsWithTimeout(10, handler: nil)
		// Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
