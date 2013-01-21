//
//  A3CurrencyList.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyList.h"
#import "AFNetworking.h"
#import "Reachability.h"

@implementation A3CurrencyList

- (id)init {
	self = [super init];
	if (self) {

	}

	return self;
}

- (void)startYahooCurrencyUpdate {
	if (![[Reachability reachabilityWithHostname:@"finance.yahoo.com"] isReachable]) {
		NSLog(@"Faild to download Yahoo currency rates, reason: Network is not available.");
		return;
	}

	NSURL *requestURL = [NSURL URLWithString:@"http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"];
	NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {

	}];

	[operation start];
}

@end
