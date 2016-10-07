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
#import "AFNetworking.h"

NSString *const A3CurrencyRatesDataFilename = @"currencyRates";

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

- (void)testDownloadCurrencyDates {
	XCTestExpectation* expectation = [self expectationWithDescription:@"Download datafile"];
	
	NSURL *requestURL = [NSURL URLWithString:@"https://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"];

	NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];

	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
		NSDictionary *list = JSON[@"list"];
		NSArray *yahooArray = list[@"resources"];
		NSString *path = [A3CurrencyRatesDataFilename pathInDocumentDirectory];
		NSLog(@"%@", path);
		[yahooArray writeToFile:path atomically:YES];

		[expectation fulfill];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];

	[operation start];
	
	[self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testCrash {
	NSDictionary *attribute = @{
								NSFontAttributeName : [UIFont boldSystemFontOfSize:15],
								NSForegroundColorAttributeName:[UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0]
								};
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:nil attributes:attribute];
	NSLog(@"%@", attributedString);
}

@end
