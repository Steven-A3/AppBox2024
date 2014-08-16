//
//  A3CurrencyDataManager.m
//  AppBox3
//
//  Created by A3 on 12/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyDataManager.h"
#import "NSMutableArray+MoveObject.h"
#import "CurrencyRateItem.h"
#import "AFHTTPRequestOperation.h"
#import "A3YahooCurrency.h"
#import "Reachability.h"
#import "A3UserDefaultsKeys.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "CurrencyFavorite.h"
#import "NSString+conversion.h"

NSString *const A3KeyCurrencyCode = @"currencyCode";
NSString *const A3NotificationCurrencyRatesUpdated = @"A3NotificationCurrencyRatesUdpated";

@implementation A3CurrencyDataManager

- (NSString *)localizedNameForCode:(NSString *)currencyCode {
	NSLocale *locale = [NSLocale currentLocale];
	NSString *name = [locale displayNameForKey:NSLocaleCurrencyCode value:currencyCode];
	if ((nil == name) || ![name length]) {
		NSArray *knownSymbols = @[@"XCP", @"ZMW", @"CNH", @"XDR", @"CLF"];
		NSUInteger index = [knownSymbols indexOfObject:currencyCode];
		if (index != NSNotFound) {
			NSArray *knownNames = @[@"Copper Highgrade", @"Zambian kwacha", @"Offshore Renminbi", @"Special Drawing Rights", @"Unidad de Fomento"];
			name = [knownNames objectAtIndex:index];
		} else {
			FNLOG(@"Failed to name resolution.");
		}
	}
	return name;
}

+ (void)setupFavorites {
	if ([CurrencyFavorite MR_countOfEntities] > 0) {
		return;
	}

	NSMutableArray *favorites = [
			@[
					@{ID_KEY : @"USD"},
					@{ID_KEY : @"EUR"},
					@{ID_KEY : @"GBP"},
					@{ID_KEY : @"JPY"}
			] mutableCopy];

	NSString *userCurrencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	NSInteger idx = [favorites indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
		return [obj[ID_KEY] isEqualToString:userCurrencyCode];
	}];
	if (idx == NSNotFound) {
		[favorites insertObject:@{ID_KEY : userCurrencyCode} atIndex:1];
		[favorites removeLastObject];
	} else {
		if (   [userCurrencyCode isEqualToString:@"EUR"]
				|| [userCurrencyCode isEqualToString:@"GBP"])
		{
			[favorites moveObjectFromIndex:idx toIndex:0];
		} else {
			[favorites moveObjectFromIndex:idx toIndex:1];
		}
	}
	NSInteger order = 1000000;
	NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
	for (NSDictionary *favorite in favorites) {
		CurrencyFavorite *newFavorite = [CurrencyFavorite MR_createEntityInContext:savingContext];
		newFavorite.uniqueID = favorite[ID_KEY];
		newFavorite.order = [NSString orderStringWithOrder:order];
		order += 1000000;
	}
	[savingContext MR_saveToPersistentStoreAndWait];
}

+ (BOOL)yahooNetworkAvailable {
	if (![[Reachability reachabilityWithHostname:@"finance.yahoo.com"] isReachable]) {
		FNLOG(@"Faild to download Yahoo currency rates, reason: Network is not available.");
		return NO;
	}
	return YES;
}

+ (NSURLRequest *)yahooAllCurrenciesURLRequest {
	NSURL *requestURL = [NSURL URLWithString:@"http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"];
	return [NSURLRequest requestWithURL:requestURL];
}

+ (void)updateCurrencyRatesInContext:(NSManagedObjectContext *)context {
	if (![[self class] yahooNetworkAvailable]) return;

	NSURLRequest *request = [[self class] yahooAllCurrenciesURLRequest];

	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];

	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
		NSDictionary *list = JSON[@"list"];
		NSArray *yahooArray = list[@"resources"];
		[yahooArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			A3YahooCurrency *yahoo = [[A3YahooCurrency alloc] initWithObject:obj];

			CurrencyRateItem *entity = [CurrencyRateItem MR_findFirstByAttribute:A3KeyCurrencyCode withValue:yahoo.currencyCode inContext:context];

			if (!entity) {
				entity = [CurrencyRateItem MR_createEntityInContext:context];
				entity.currencyCode = yahoo.currencyCode;
				entity.name = yahoo.name;
			}
			entity.rateToUSD = yahoo.rateToUSD;
			entity.updateDate = yahoo.updated;
		}];

		[context MR_saveToPersistentStoreAndWait];

		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCurrencyRatesUpdated object:nil];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		FNLOG(@"AFJSONRequestOperation failed getting Yahoo all currency list.");
	}];

	[operation start];
}

@end
