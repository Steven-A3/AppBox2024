//
//  AppTransactionManagerTest.swift
//  AppBox3 Tests
//
//  Created by BYEONG KWON KWAK on 12/23/23.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import XCTest
@testable import AppBox3

class AppTransactionManagerTests: XCTestCase {

    func testIsPaidAppVersion() {
        // Test case where original version is less than free version
        XCTAssertTrue(AppTransactionManager.isPaidAppVersion(originalAppVersion: "3.5", freeAppVersion: "3.6"))

        // Test case where original version is equal to free version
        XCTAssertFalse(AppTransactionManager.isPaidAppVersion(originalAppVersion: "3.6", freeAppVersion: "3.6"))

        // Test case where original version is greater than free version
        XCTAssertFalse(AppTransactionManager.isPaidAppVersion(originalAppVersion: "3.7", freeAppVersion: "3.6"))

        // Test case with more complex version numbers
        XCTAssertTrue(AppTransactionManager.isPaidAppVersion(originalAppVersion: "3.5.1", freeAppVersion: "3.6"))
        XCTAssertFalse(AppTransactionManager.isPaidAppVersion(originalAppVersion: "3.6.1", freeAppVersion: "3.6"))
    }
    
    // Additional test cases can be added here for different scenarios
}
