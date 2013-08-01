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
#import "CurrencyItem+NetworkUtility.h"
#import "CurrencyFavorite+initialize.h"

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

- (void)testResetCurrencyItem
{
    [CurrencyItem resetCurrencyLists];
    currencyArray = [CurrencyItem MR_findAll];
    NSLog(@"%@", currencyArray);
    
    expect([currencyArray count]).to.equal(@166);
}

- (void)testResetCurrencyFavorite {
    [CurrencyFavorite reset];
    NSArray *array = [CurrencyFavorite MR_findAll];
    NSLog(@"%@", array);
    
    expect([array count]).to.equal(@9);
}

@end
