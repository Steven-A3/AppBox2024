//
//  A3NSMutableArrayCategory.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/27/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <XCTest/XCTest.h>
#define EXP_SHORTHAND
#import "Expecta.h"
#import "NSMutableArray+MoveObject.h"

@interface A3NSMutableArrayCategoryTest : XCTestCase

@end

@implementation A3NSMutableArrayCategoryTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testMoveItem {
	NSMutableArray *testData = [NSMutableArray arrayWithArray:@[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i"]];
//	NSMutableArray *testData = [NSMutableArray arrayWithArray:@[@"a", @"c", @"d", @"e", @"f", @"g", @"h", @"i"]];
	[testData moveObjectFromIndex:1 toIndex:4];
	expect(testData[1]).to.equal(@"c");
	expect(testData[4]).to.equal(@"b");
}

- (void)testNSStringFromSelector {
    NSLog(@"%@", NSStringFromSelector(@selector(testMoveItem)));
}

@end
