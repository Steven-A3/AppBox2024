//
//  A3UnitNamesTest.m
//  AppBox3
//
//  Created by A3 on 7/21/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "A3UnitDataManager.h"

@interface A3UnitNamesTest : XCTestCase

@end

@implementation A3UnitNamesTest

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
	NSMutableString *output = [NSMutableString new];
    for (NSInteger unitCategoryIdx = 0; unitCategoryIdx < 17; unitCategoryIdx++) {
		for (NSInteger unitIdx = 0; unitIdx < numberOfUnits[unitCategoryIdx]; unitIdx++) {
			NSString *unitName = [NSString stringWithCString:unitNames[unitCategoryIdx][unitIdx] encoding:NSUTF8StringEncoding];
			NSString *shortName = [NSString stringWithCString:unitShortNames[unitCategoryIdx][unitIdx] encoding:NSUTF8StringEncoding];
			[output appendFormat:@"\"%@\" = \"%@\";\n", unitName, shortName];
		}
	}
	NSLog(@"%@", output);
}

@end
