//
//  A3CurrencyDataManager.m
//  AppBox3
//
//  Created by A3 on 12/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyDataManager.h"
#import "NSMutableArray+MoveObject.h"
#import "AFHTTPRequestOperation.h"
#import "A3YahooCurrency.h"
#import "Reachability.h"
#import "A3UserDefaultsKeys.h"
#import "CurrencyFavorite.h"
#import "NSString+conversion.h"
#import "A3UserDefaults.h"

NSString *const A3KeyCurrencyCode = @"currencyCode";
NSString *const A3NotificationCurrencyRatesUpdated = @"A3NotificationCurrencyRatesUdpated";
NSString *const A3NotificationCurrencyRatesUpdateFailed = @"A3NotificationCurrencyRatesUpdateFailed";
NSString *const A3CurrencyRatesDataFilename = @"currencyRates";
NSString *const A3CurrencyUpdateDate = @"A3CurrencyUpdateDate";
NSString *const kA3CurrencyDataFlagName = @"flagName";
NSString *const kA3CurrencyDataSymbol = @"symbol";

@interface A3CurrencyDataManager ()

@property (nonatomic, strong) NSDictionary *currencyInfoDictionary;

@end

@implementation A3CurrencyDataManager {
	BOOL _updating;
}

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
			FNLOG(@"Failed to find the name.");
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
	if (userCurrencyCode) {
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

- (void)updateCurrencyRatesOnSuccess:(void (^)())success failure:(void (^)())failure {
	if (_updating) return;
	_updating = YES;
	
	if (![[self class] yahooNetworkAvailable]) return;

	NSURLRequest *request = [[self class] yahooAllCurrenciesURLRequest];

	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	if ([operation respondsToSelector:@selector(setQualityOfService:)]) {
		[operation setQualityOfService:NSQualityOfServiceUserInteractive];
	}
	operation.responseSerializer = [AFJSONResponseSerializer serializer];

	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *requestOperation, id JSON) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[[A3UserDefaults standardUserDefaults] setObject:[NSDate date] forKey:A3CurrencyUpdateDate];
					[[A3UserDefaults standardUserDefaults] synchronize];

					[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

					NSDictionary *list = JSON[@"list"];
					NSArray *yahooArray = list[@"resources"];

					NSString *path = [A3CurrencyRatesDataFilename pathInCachesDataDirectory];
					[yahooArray writeToFile:path atomically:YES];

					[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCurrencyRatesUpdated object:nil];

					_dataArray = nil;

					if (success) {
						success();
					}

					FNLOG(@"Update currency rate done successfully.");
					_updating = NO;
				});
			}
			failure:^(AFHTTPRequestOperation *requestOperation, NSError *error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

					if (failure) {
						failure();
					}
					FNLOG(@"Update currency rate failed.");
					[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCurrencyRatesUpdateFailed object:nil];
					_updating = NO;
				});
			}
	 ];

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[operation start];
}

- (NSArray *)dataArray {
	if (!_dataArray) {
		NSString *path = [A3CurrencyRatesDataFilename pathInCachesDataDirectory];
		if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
			path = [[NSBundle mainBundle] pathForResource:A3CurrencyRatesDataFilename ofType:nil];
		}
		_dataArray = [NSArray arrayWithContentsOfFile:path];
	}
	return _dataArray;
}

- (A3YahooCurrency *)dataForCurrencyCode:(NSString *)code {
	__block A3YahooCurrency *result = nil;
	[self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		A3YahooCurrency *currencyData = [[A3YahooCurrency alloc] initWithObject:obj];
		if ([currencyData.currencyCode isEqualToString:code]) {
			result = currencyData;
			*stop = YES;
		}
	}];
	return result;
}

- (NSString *)stringFromNumber:(NSNumber *)value withCurrencyCode:(NSString *)currencyCode isShare:(BOOL)isShare {
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setCurrencyCode:currencyCode];

	if (!isShare && IS_IPHONE) {
		[formatter setCurrencySymbol:@""];
	}

	NSString *string = [formatter stringFromNumber:value];
	return [string stringByTrimmingSpaceCharacters];
}

- (NSDictionary *)currencyInfoDictionary
{
	if (!_currencyInfoDictionary){
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CurrencyInfo" ofType:@"dictionary"];
		_currencyInfoDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
	}
	return _currencyInfoDictionary;
}

- (NSString *)flagImageNameForCode:(NSString *)currencyCode {
	return self.currencyInfoDictionary[currencyCode][kA3CurrencyDataFlagName];
}

- (NSString *)symbolForCode:(NSString *)currencyCode {
	return self.currencyInfoDictionary[currencyCode][kA3CurrencyDataFlagName];
}

- (void)purgeRetainingObjects {
	_dataArray = nil;
	_currencyInfoDictionary = nil;
}

@end
