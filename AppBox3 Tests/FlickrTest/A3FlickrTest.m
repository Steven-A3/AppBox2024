//
//  A3FlickrTest.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjectiveFlickr.h"

#import "FlickrAPIKey.h"

@interface A3FlickrTest : XCTestCase <OFFlickrAPIRequestDelegate>

@end

@implementation A3FlickrTest

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
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testLocation {
}

@end
