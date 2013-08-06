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
	NSLog(@"%@", validLocales);

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
		NSUInteger index = [validLocales indexOfObject:@{NSLocaleCurrencyCode:yahooCurrency.currencyCode} inSortedRange:NSMakeRange(0, [validLocales count]) options:NSBinarySearchingFirstEqual usingComparator:comparator];
		if (index != NSNotFound) {
			entity.currencySymbol = validLocales[index][NSLocaleCurrencySymbol];
		}
	}

	// Add special currency which does not exist in the yahoo data source.
	CurrencyItem *usd = [CurrencyItem MR_createEntity];
	usd.currencyCode = @"USD";
	usd.name = @"USD";
	usd.rateToUSD = @1.0;
	usd.updated = updated;
    usd.currencySymbol = @"$";

	NSArray *exceptionList = @[
			@{NSLocaleCurrencyCode:@"ALL", NSLocaleCurrencySymbol:@"Lek"},
			@{NSLocaleCurrencyCode:@"AZN", NSLocaleCurrencySymbol:@"\u043c\u0430\u043d."},
			@{NSLocaleCurrencyCode:@"BAM", NSLocaleCurrencySymbol:@"KM"},
			@{NSLocaleCurrencyCode:@"DKK", NSLocaleCurrencySymbol:@"kr"},
			@{NSLocaleCurrencyCode:@"HRK", NSLocaleCurrencySymbol:@"kn"},
			@{NSLocaleCurrencyCode:@"LKR", NSLocaleCurrencySymbol:@"Rs."},
			@{NSLocaleCurrencyCode:@"MAD", NSLocaleCurrencySymbol:@"\u062f.\u0645.\u200f"},
			@{NSLocaleCurrencyCode:@"RUB", NSLocaleCurrencySymbol:@"\u0440\u0443\u0431."},
			@{NSLocaleCurrencyCode:@"SEK", NSLocaleCurrencySymbol:@"kr"},
			@{NSLocaleCurrencyCode:@"TND", NSLocaleCurrencySymbol:@"\u062f.\u062a.\u200f"},
			@{NSLocaleCurrencyCode:@"TRY", NSLocaleCurrencySymbol:@"\u20ba"}
	];

	[exceptionList enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger idx, BOOL *stop) {
		NSArray *fetched = [CurrencyItem MR_findByAttribute:@"currencyCode" withValue:object[NSLocaleCurrencyCode]];
		if ([fetched count]) {
			CurrencyItem *item = fetched[0];
			item.currencySymbol = object[NSLocaleCurrencySymbol];
		}
	}];

	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

@end
