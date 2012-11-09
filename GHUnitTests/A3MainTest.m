//
//  A3MainTest.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/30/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

@interface A3MainTest : GHTestCase {}
@end

@implementation A3MainTest

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

- (void)testFoo {
    NSString *a = @"foo";
    GHTestLog(@"I can log to the GHUnit test console: %@", a);
    
    // Assert a is not NULL, with no custom error description
    GHAssertNotNil(a, nil);
    
    // Assert equal objects, add custom error description
    NSString *b = @"foo";
    GHAssertEqualObjects(a, b, @"A custom error message. a should be equal to: %@.", b);
}

@end
