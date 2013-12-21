//
//  A3CurrencyItemTest.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/12/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <XCTest/XCTest.h>
#define EXP_SHORTHAND
#import "Expecta.h"
#import "NSString+conversion.h"

@interface A3CurrencyItemTest : XCTestCase

@end

@implementation A3CurrencyItemTest {
    NSArray *currencyArray;
}

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

- (void)testKorean {
    NSLog(@"%@", [@"초성분리" componentsSeparatedByKorean]);
}

@end
