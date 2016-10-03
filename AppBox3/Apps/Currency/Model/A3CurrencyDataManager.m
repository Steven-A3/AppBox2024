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
		NSArray<NSDictionary *> *knownSymbols = @[@{@"XCP" : @"Copper Highgrade"},
												  @{@"ZMW" : @"Zambian kwacha"},
												  @{@"CNH" : @"Offshore Renminbi"},
												  @{@"XDR" : @"Special Drawing Rights"},
												  @{@"CLF" : @"Chilean Unidad de Fomento"},
												  @{@"BRX" : @"Brixmor Property Group Inc"},
												  @{@"BYN" : @"New Belarusian ruble"},
												  @{@"CAX" : @"Canadian Dollar Reference Rate Spot"},
												  @{@"CZX" : @"Czech koruna"},
												  @{@"DKX" : @"Danish krone"},
												  @{@"HRX" : @"Croatian Kuna Reference Rate Spot"},
												  @{@"HUX" : @"Hungary Forint Reference Rate Spot"},
												  @{@"ILA" : @"Israeli Share Price"},
												  @{@"INX" : @"INX"},
												  @{@"ISX" : @"Iceland Krona Reference Rate Spot"},
												  @{@"MYX" : @"Malaysia Ringgit Reference Rate Spot"},
												  @{@"PLX" : @"Poland Zloty Reference Rate Spot"},
												  @{@"XCU" : @"Wocu Spot"},
												  @{@"ZAC" : @"South African Cent Spot"} ];
		NSUInteger index = [knownSymbols indexOfObjectPassingTest:^BOOL(NSDictionary* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			return [obj.allKeys[0] isEqualToString:currencyCode];
		}];
		if (index != NSNotFound) {
			name = NSLocalizedString(knownSymbols[index][currencyCode], nil);
		} else {
			name = currencyCode;
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
	NSURL *requestURL = [NSURL URLWithString:@"https://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"];
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

					// 중복된 목록은 삭제한다.
					// 주요 Currency가 누락된 경우, 이전 파일에서 추가한다.
					// 이전 파일에 없으면, 배포 파일에서 추가한다.
					
					if ([yahooArray count] > 100) {
						
						NSArray *verifiedArray = [self verifiedArray:yahooArray];
						
						NSString *path = [A3CurrencyRatesDataFilename pathInCachesDataDirectory];
						[verifiedArray writeToFile:path atomically:YES];
						
						[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCurrencyRatesUpdated object:nil];
						
						_dataArray = nil;
						
						if (success) {
							success();
						}
					} else {
						if (failure) {
							failure();
						}
						FNLOG(@"Update currency rate failed.");
						[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCurrencyRatesUpdateFailed object:nil];
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

- (NSArray *)verifiedArray:(NSArray *)sourceArray {
	NSString *bundlePath = [[NSBundle mainBundle] pathForResource:A3CurrencyRatesDataFilename ofType:nil];
	NSArray *bundleData = [NSArray arrayWithContentsOfFile:bundlePath];
	NSArray *previousData = [NSArray arrayWithContentsOfFile:[A3CurrencyRatesDataFilename pathInCachesDataDirectory]];
	NSMutableArray *verifiedArray = [NSMutableArray new];
	
	for (NSDictionary *data in sourceArray) {
		A3YahooCurrency *newData = [[A3YahooCurrency alloc] initWithObject:data];
		NSInteger indexOfObject = [verifiedArray indexOfObjectPassingTest:^BOOL(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			A3YahooCurrency *data = [[A3YahooCurrency alloc] initWithObject:obj];
			return [data.currencyCode isEqualToString:newData.currencyCode];
		}];
		if (indexOfObject == NSNotFound) {
			[verifiedArray addObject:data];
		} else {
			FNLOG(@"%@ duplicated data.", newData.currencyCode);
		}
	}
	
	NSArray<NSString *> *majorArray = @[@"HKD", @"USD", @"EUR", @"GBP", @"JPY", @"CNY",
										@"AUD", @"NZD", @"CAD", @"SEK", @"CHF", @"HUF",
										@"SGD", @"KRW", @"INR", @"MXN", @"PHP", @"THB",
										@"MYR", @"ZAR", @"RUB", @"AED", @"IDR", @"SAR",
										@"BRL", @"TRY", @"KES", @"EGP", @"NOK", @"KWD",
										@"DKK", @"PKR", @"ILS", @"PLN", @"QAR"];
	
	for (NSString *code in majorArray) {
		NSInteger indexOfObject = [verifiedArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			A3YahooCurrency *data = [[A3YahooCurrency alloc] initWithObject:obj];
			return [data.currencyCode isEqualToString:code];
		}];
		if (indexOfObject == NSNotFound) {
			id data = [self dataInArray:previousData currencyCode:code];
			if (data) {
				FNLOG(@"%@ added from previous data.", code);
				[verifiedArray addObject:data];
			} else {
				data = [self dataInArray:bundleData currencyCode:code];
				if (data) {
					FNLOG(@"%@ added from bundle data.", code);
					[verifiedArray addObject:data];
				} else {
					FNLOG(@"%@ data is missing.", code);
				}
			}
		}
	}
	return verifiedArray;
}

- (id)dataInArray:(NSArray *)array currencyCode:(NSString *)code {
	if (!array) return nil;
	NSInteger idxOfCode = [array indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		A3YahooCurrency *data = [[A3YahooCurrency alloc] initWithObject:obj];
		return [data.currencyCode isEqualToString:code];
	}];
	if (idxOfCode != NSNotFound) {
		return array[idxOfCode];
	}
	return nil;
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
	return self.currencyInfoDictionary[currencyCode][kA3CurrencyDataSymbol];
}

- (void)purgeRetainingObjects {
	_dataArray = nil;
	_currencyInfoDictionary = nil;
}

@end
