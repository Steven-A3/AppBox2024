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

    NSArray *localesArray = [NSLocale availableLocaleIdentifiers];
	NSMutableArray *validLocales = [[NSMutableArray alloc] initWithCapacity:[localesArray count]];
	for (id localeid in localesArray) {
		NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeid];
		if ([[locale objectForKey:NSLocaleCurrencyCode] length]) {
			[validLocales addObject:@{
                                      NSLocaleCurrencyCode : [locale objectForKey:NSLocaleCurrencyCode],
                                      NSLocaleIdentifier : localeid,
                                      NSLocaleCurrencySymbol : [locale objectForKey:NSLocaleCurrencySymbol]
                                      }];
		}
	}
	NSComparator comparator = ^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
		return [obj1[NSLocaleCurrencyCode] compare:obj2[NSLocaleCurrencyCode]];
	};
	[validLocales sortUsingComparator:comparator];

    NSString *prevCode = nil;
    for (NSDictionary *object in validLocales) {
        if ([object[NSLocaleCurrencyCode] isEqualToString:prevCode]) continue;

		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSLocaleCurrencyCode, object[NSLocaleCurrencyCode]];
        NSArray *array = [validLocales filteredArrayUsingPredicate:predicate];
		if ([array count] > 1) {
            NSString *symbol = array[0][NSLocaleCurrencySymbol];
            NSArray *result = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K != %@", NSLocaleCurrencySymbol, symbol]];
            if ([result count])
                NSLog(@"%@", array);
		}
        prevCode = object[NSLocaleCurrencyCode];
    }
}

- (void)testResetCurrencyFavorite {
    [CurrencyFavorite reset];
    NSArray *array = [CurrencyFavorite MR_findAll];
    NSLog(@"%@", array);
    
    expect([array count]).to.equal(@9);
}

@end
