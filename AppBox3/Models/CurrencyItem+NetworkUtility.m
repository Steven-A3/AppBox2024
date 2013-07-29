//
//  CurrencyItem+NetworkUtility.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "CurrencyItem+NetworkUtility.h"
#import "Reachability.h"
#import "AFJSONRequestOperation.h"
#import "NSManagedObject+MagicalFinders.h"
#import "NSManagedObject+MagicalRecord.h"
#import "A3YahooCurrency.h"
#import "NSManagedObject+MagicalAggregation.h"
#import "CPTPlatformSpecificCategories.h"
#import "CurrencyFavorite.h"
#import "common.h"
#import "NSManagedObjectContext+MagicalThreading.h"
#import "NSManagedObjectContext+MagicalSaves.h"

@implementation CurrencyItem (NetworkUtility)

+ (BOOL)yahooNetworkAvailable {
	if (![[Reachability reachabilityWithHostname:@"finance.yahoo.com"] isReachable]) {
		NSLog(@"Faild to download Yahoo currency rates, reason: Network is not available.");
		return NO;
	}
	return YES;
}

+ (NSURLRequest *)yahooAllCurrenciesURLRequest {
	NSURL *requestURL = [NSURL URLWithString:@"http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"];
	return [NSURLRequest requestWithURL:requestURL];
}

+ (void)updateCurrencyRates {
	if (![[self class] yahooNetworkAvailable]) return;

	NSURLRequest *request = [[self class] yahooAllCurrenciesURLRequest];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		NSDictionary *list = JSON[@"list"];
		NSArray *yahooArray = list[@"resources"];
		[yahooArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			A3YahooCurrency *yahoo = [[A3YahooCurrency alloc] initWithObject:obj];

			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"currencyCode like %@", yahoo.currencyCode];
			NSArray *array = [CurrencyItem MR_findAllWithPredicate:predicate];

			CurrencyItem *entity;
			if ([array count]) {
				entity = array[0];
			} else {
				entity = [CurrencyItem MR_createEntity];
				entity.currencyCode = yahoo.currencyCode;
				entity.name = yahoo.name;
			}
			entity.rateToUSD = yahoo.rateToUSD;
			entity.updated = yahoo.updated;
		}];
		[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCurrencyRatesUpdated object:nil];
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
		FNLOG(@"AFJSONRequestOperation failed getting Yahoo all currency list.");
	}];

	[operation start];
	do { sleep(1); }
	while (![operation isFinished]);
}

+ (void)resetCurrencyLists {
	if (![[self class] yahooNetworkAvailable]) return;

	if ([[CurrencyItem MR_numberOfEntities] isGreaterThan: @0 ]) {
		[CurrencyItem MR_truncateAll];
	}

	NSURLRequest *request = [[self class] yahooAllCurrenciesURLRequest];
	NSURLResponse *response;
	NSData *yahooData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
	if (!yahooData) {
		FNLOG(@"Fail to download Yahoo currency data!");
		return;
	}
	NSError *error;
	id JSON = [NSJSONSerialization JSONObjectWithData:yahooData options:NSJSONReadingMutableContainers error:&error];

	NSDate *updated = nil;
	NSArray *yahooArray = JSON[@"list"][@"resources"];
	for (id obj in yahooArray) {
		A3YahooCurrency *yahooCurrency = [[A3YahooCurrency alloc] initWithObject:obj];
		CurrencyItem *entity = [CurrencyItem MR_createEntity];
		entity.currencyCode = yahooCurrency.currencyCode;
		entity.name = yahooCurrency.name;
		entity.rateToUSD = yahooCurrency.rateToUSD;
		entity.updated = yahooCurrency.updated;
		updated = [yahooCurrency.updated laterDate:updated];
	}

	// Add special currency which does not exist in the yahoo data source.
	CurrencyItem *usd = [CurrencyItem MR_createEntity];
	usd.currencyCode = @"USD";
	usd.name = @"USD";
	usd.rateToUSD = @1.0;
	usd.updated = updated;

	/*
	NSURLRequest *request = [[self class] yahooAllCurrenciesURLRequest];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		NSArray *yahooArray = JSON[@"list"][@"resources"];
		[yahooArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            A3YahooCurrency *yahooCurrency = [[A3YahooCurrency alloc] initWithObject:obj];
			CurrencyItem *entity = [CurrencyItem MR_createEntity];
			entity.currencyCode = yahooCurrency.currencyCode;
			entity.name = yahooCurrency.name;
			entity.rateToUSD = yahooCurrency.rateToUSD;
			entity.updated = yahooCurrency.updated;
		}];
		FNLOG(@"Operation completed.");
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
		FNLOG(@"AFJSONRequestOperation failed getting Yahoo all currency list.");
	}];

	[operation start];
*/
}

@end
