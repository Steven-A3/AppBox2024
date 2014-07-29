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
#import "A3UserDefaults.h"
#import "A3SyncManager.h"

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
	NSArray *currencyFavorites = [[NSUserDefaults standardUserDefaults] objectForKey:A3CurrencyUserDefaultsFavorites];
	if ([currencyFavorites count]) {
		return;
	}

	NSMutableArray *favorites = [@[@"USD", @"EUR", @"GBP", @"JPY"] mutableCopy];

	NSString *userCurrencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	NSInteger idx = [favorites indexOfObject:userCurrencyCode];
	if (idx == NSNotFound) {
		[favorites insertObject:userCurrencyCode atIndex:1];
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
	[[NSUserDefaults standardUserDefaults] setObject:favorites forKey:A3CurrencyUserDefaultsFavorites];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveFavorites:(NSArray *)favorites {
	NSMutableArray *savingFavorites = [NSMutableArray new];
	for (id item in favorites) {
		if ([item isKindOfClass:[NSString class]] && [item length] == 3) {
			[savingFavorites addObject:item];
		}
	}
	[A3CurrencyDataManager saveCurrencyObject:savingFavorites forKey:A3CurrencyUserDefaultsFavorites];
}

+ (void)saveCurrencyObject:(id)object forKey:(NSString *)key {
	NSDate *updateDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
	[[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:A3CurrencyUserDefaultsUpdateDate];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([[A3SyncManager sharedSyncManager] isCloudEnabled]) {
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		[store setObject:object forKey:key];
		[store setObject:updateDate forKey:A3CurrencyUserDefaultsCloudUpdateDate];
		[store synchronize];
	}
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
			entity.updated = yahoo.updated;
		}];

		[context MR_saveToPersistentStoreAndWait];

		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCurrencyRatesUpdated object:nil];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		FNLOG(@"AFJSONRequestOperation failed getting Yahoo all currency list.");
	}];

	[operation start];
}

@end
