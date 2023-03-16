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
#import "A3NumberFormatter.h"
#import "NSMutableArray+A3Sort.h"
#import "A3AppDelegate.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"

NSString *const A3KeyCurrencyCode = @"currencyCode";
NSString *const A3NotificationCurrencyRatesUpdated = @"A3NotificationCurrencyRatesUdpated";
NSString *const A3NotificationCurrencyRatesUpdateFailed = @"A3NotificationCurrencyRatesUpdateFailed";
NSString *const A3CurrencyRatesDataFilename = @"currencyRates.plist";
NSString *const A3CurrencyUpdateDate = @"A3CurrencyUpdateDate";
NSString *const kA3CurrencyDataFlagName = @"flagName";
NSString *const kA3CurrencyDataSymbol = @"symbol";

@interface A3CurrencyDataManager ()

@property (nonatomic, strong) NSDictionary *currencyInfoDictionary;
@property (nonatomic, strong) NSMutableArray *updateCandidates;
@property (nonatomic, strong) void (^APIUpdateCompletionBlock)(BOOL);
@property (nonatomic, assign) BOOL updating;

@end

@implementation A3CurrencyDataManager

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
												  @{@"ZAC" : @"South African Cent Spot"},
                                                  @{@"BTC" : @"Bitcoin"}
                                                  ];
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
	if ([CurrencyFavorite countOfEntities] > 0) {
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
	NSManagedObjectContext *context = [[A3AppDelegate instance] managedObjectContext];
	for (NSDictionary *favorite in favorites) {
        CurrencyFavorite *newFavorite = [[CurrencyFavorite alloc] initWithContext:context];
		newFavorite.uniqueID = favorite[ID_KEY];
		newFavorite.order = [NSString orderStringWithOrder:order];
		order += 1000000;
	}
    [context saveContext];
}

+ (BOOL)yahooNetworkAvailable {
	if (![[Reachability reachabilityWithHostname:@"finance.yahoo.com"] isReachable]) {
		FNLOG(@"Faild to download Yahoo currency rates, reason: Network is not available.");
		return NO;
	}
	return YES;
}

- (NSURLRequest *)coinbaseExchangeRatesURLRequest {
    NSURL *requestURL = [NSURL URLWithString:@"https://api.coinbase.com/v2/exchange-rates"];
    return [NSURLRequest requestWithURL:requestURL];
}

- (NSDictionary *)bitcoinItemWithRate:(NSNumber *)rate withTemplate:(NSDictionary *)template {
    NSMutableDictionary *fields = [[NSMutableDictionary alloc] initWithDictionary:template[@"resource"][@"fields"]];
    fields[@"price"] = rate;
    fields[@"name"] = @"USD/BTC";
    fields[@"symbol"] = @"BTC=X";
    return @{@"resource": @{
                     @"classname" : @"Quote",
                     @"fields" : fields
                     }};
}

- (void)updateCoinbaseExchangeRatesOnCompletion:(void (^)(BOOL success))completion {
    NSURLRequest *request = [self coinbaseExchangeRatesURLRequest];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    if ([operation respondsToSelector:@selector(setQualityOfService:)]) {
        [operation setQualityOfService:NSQualityOfServiceUserInteractive];
    }
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *requestOperation, id JSON) {
        NSDictionary *ratesDictionary = JSON[@"data"][@"rates"];
        if (ratesDictionary[@"BTC"]) {
            NSMutableArray *storedData = [[self ratesFromStoredFile] mutableCopy];
            NSInteger indexOfBitcoinInStoredData = [storedData indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                A3YahooCurrency *currency = [[A3YahooCurrency alloc] initWithObject:obj];
                return [currency.currencyCode isEqualToString:@"BTC"];
            }];
            NSDictionary *bitcoinItem = [self bitcoinItemWithRate:ratesDictionary[@"BTC"] withTemplate:storedData[0]];
            if (indexOfBitcoinInStoredData != NSNotFound) {
                FNLOG(@"%@", storedData[indexOfBitcoinInStoredData]);
                storedData[indexOfBitcoinInStoredData] = bitcoinItem;
            } else {
                [storedData addObject:bitcoinItem];
            }
            NSString *path = [A3CurrencyRatesDataFilename pathInCachesDataDirectory];
            if (![storedData writeToFile:path atomically:YES]) {
                FNLOG(@"Fail to write updated contents");
            }
        }
        if (completion) {
            completion(YES);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
                                     failure:^(AFHTTPRequestOperation *requestOperation, NSError *error) {
                                         if (completion) {
                                             completion(NO);
                                         }
                                     }];
    [operation start];
}

- (NSURLRequest *)yahooAllCurrenciesURLRequest {
	NSURL *requestURL = [NSURL URLWithString:@"https://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"];
	return [NSURLRequest requestWithURL:requestURL];
}

- (void)updateCurrencyRatesOnSuccess:(void (^)(void))success failure:(void (^)(void))failure {
	if (_updating) return;
	_updating = YES;
	
	if (![[self class] yahooNetworkAvailable]) return;

	NSURLRequest *request = [self yahooAllCurrenciesURLRequest];

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
					
					if ([yahooArray count] > 10) {
                        NSArray *verifiedArray = [self verifiedArray:yahooArray];
						NSString *path = [A3CurrencyRatesDataFilename pathInCachesDataDirectory];
						[verifiedArray writeToFile:path atomically:YES];
                        
                        [self updateCoinbaseExchangeRatesOnCompletion:^(BOOL successUpdate) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCurrencyRatesUpdated object:nil];
                            
                            self.dataArray = nil;
                            
                            if (success) {
                                success();
                            }
                        }];
					} else {
						if (failure) {
							failure();
						}
						FNLOG(@"Update currency rate failed.");
						[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCurrencyRatesUpdateFailed object:nil];
					}

					FNLOG(@"Update currency rate done successfully.");
					self.updating = NO;
                    
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
					self.updating = NO;
				});
			}
	 ];

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[operation start];
}

- (NSString *)bundlePath {
    return [[NSBundle mainBundle] pathForResource:A3CurrencyRatesDataFilename ofType:nil];
}

- (NSArray *)ratesFromStoredFile {
    return [NSArray arrayWithContentsOfFile:[A3CurrencyRatesDataFilename pathInCachesDataDirectory]];
}

- (NSArray *)verifiedArray:(NSArray *)sourceArray {
    // Find missing currency
    // If found one, fill from the previous list or from the bundle list.
	NSMutableArray *verifiedArray = [NSMutableArray new];
    NSArray *bundleData = [NSArray arrayWithContentsOfFile:[self bundlePath]];
    NSArray *previousData = [self ratesFromStoredFile];
    
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
	
	for (NSDictionary *currencyInBundleDictionary in bundleData) {
        A3YahooCurrency *currencyInBundleObj = [[A3YahooCurrency alloc] initWithObject:currencyInBundleDictionary];
        NSString *code = currencyInBundleObj.currencyCode;
		if ([self dataInArray:sourceArray currencyCode:code] == nil) {
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
			path = [self bundlePath];
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
	A3NumberFormatter *formatter = [A3NumberFormatter new];
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

// http://apilayer.net/api/live?access_key=e2834bb6da9ca145c7b276f5aa522022&currencies=EUR,GBP,CAD,PLN&source=USD&format=1
//
//{
//    "success":true,
//    "terms":"https:\/\/currencylayer.com\/terms",
//    "privacy":"https:\/\/currencylayer.com\/privacy",
//    "timestamp":1550154246,
//    "source":"USD",
//    "quotes":{
//        "USDEUR":0.885035,
//        "USDGBP":0.780315,
//        "USDCAD":1.33205,
//        "USDPLN":3.84073
//    }
//}

- (void)updateCurrencyRatesFromCurrencyLayerOnCompletion:(void (^)(BOOL))completion {
    NSArray *targetCurrencies = [CurrencyFavorite findAllSortedBy:A3CommonPropertyOrder ascending:YES];
    NSMutableString *currenciesString = [NSMutableString new];
    for (CurrencyFavorite *favorite in targetCurrencies) {
        [currenciesString appendFormat:@"%@,", favorite.uniqueID];
    }
    [currenciesString deleteCharactersInRange:NSMakeRange([currenciesString length]-1, 1)];
    NSString *URLString = [NSString stringWithFormat:@"https://apilayer.net/api/live?access_key=e2834bb6da9ca145c7b276f5aa522022&currencies=%@&source=USD&format=1", currenciesString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    if ([operation respondsToSelector:@selector(setQualityOfService:)]) {
        [operation setQualityOfService:NSQualityOfServiceUserInteractive];
    }
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *requestOperation, id JSON)
     {
         NSDictionary *quotes = JSON[@"quotes"];
         for (NSString *key in [quotes allKeys]) {
             [self updateRateForCurrency:[key substringFromIndex:3] value:quotes[key]];
         }
         [[A3UserDefaults standardUserDefaults] setObject:[NSDate date] forKey:A3CurrencyUpdateDate];
         [[A3UserDefaults standardUserDefaults] synchronize];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationCurrencyRatesUpdated object:nil];
         
         self.dataArray = nil;
         
         completion(YES);
     }
                                     failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             completion(NO);
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         });
     }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [operation start];
}

- (void)updateRateForCurrency:(NSString *)code value:(id)value {
    NSMutableArray *storedData = [[self ratesFromStoredFile] mutableCopy];
    if (storedData == nil) {
        storedData = [[NSArray arrayWithContentsOfFile:[self bundlePath]] mutableCopy];
    }
    NSInteger indexOfCurrency = [storedData indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        A3YahooCurrency *currency = [[A3YahooCurrency alloc] initWithObject:obj];
        return [currency.currencyCode isEqualToString:code];
    }];
    if (indexOfCurrency != NSNotFound) {
        NSDictionary *newInfo = [self currencyInfoWithExistingInfo:storedData[indexOfCurrency] code:code withValue:value];
        storedData[indexOfCurrency] = newInfo;
    } else {
        NSDictionary *newInfo = [self currencyInfoWithExistingInfo:nil code:code withValue:value];
        [storedData addObject:newInfo];
    }
    NSString *path = [A3CurrencyRatesDataFilename pathInCachesDataDirectory];
    if (![storedData writeToFile:path atomically:YES]) {
        FNLOG(@"Fail to write updated contents");
    }
}

- (NSDictionary *)currencyInfoWithExistingInfo:(NSDictionary *)currencyInfo code:(id) code withValue:(id)value {
    FNLOG(@"%@", currencyInfo);
    
    NSMutableDictionary *newFields;
    if (currencyInfo) {
        newFields = [[NSMutableDictionary alloc] initWithDictionary:currencyInfo[@"resource"][@"fields"]];
    } else {
        newFields = [[NSMutableDictionary alloc] init];
        newFields[@"name"] = [NSString stringWithFormat:@"USD/%@", code];
        newFields[@"symbol"] = [NSString stringWithFormat:@"%@=X", code];
    }
    newFields[@"price"] = value;
    newFields[@"ts"] = [NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]];
    NSISO8601DateFormatter *df = [NSISO8601DateFormatter new];
    newFields[@"utctime"] = [df stringFromDate:[NSDate date]];
    return @{@"resource":@{
                     @"classname" : @"Quote",
                     @"fields" : newFields,
                     }
             };
}

- (void)buildBaseFile {
    NSMutableArray *storedData = [[self ratesFromStoredFile] mutableCopy];
    if (storedData == nil) {
        storedData = [[NSArray arrayWithContentsOfFile:[self bundlePath]] mutableCopy];
    }
    NSMutableString *currenciesString = [NSMutableString new];
    for (NSDictionary *item in storedData) {
        [currenciesString appendFormat:@"%@,", [item[@"resource"][@"fields"][@"symbol"] substringToIndex:3]];
    }
    [currenciesString deleteCharactersInRange:NSMakeRange([currenciesString length]-1, 1)];
    NSString *URLString = [NSString stringWithFormat:@"https://apilayer.net/api/live?access_key=e2834bb6da9ca145c7b276f5aa522022&currencies=%@&source=USD&format=1", currenciesString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    if ([operation respondsToSelector:@selector(setQualityOfService:)]) {
        [operation setQualityOfService:NSQualityOfServiceUserInteractive];
    }
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *requestOperation, id JSON)
     {
         NSDictionary *quotes = JSON[@"quotes"];
         for (NSString *key in [quotes allKeys]) {
             [self updateRateForCurrency:[key substringFromIndex:3] value:quotes[key]];
         }
     }
                                     failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error)
     {
        FNLOG(@"%@", error.localizedDescription);
     }];
    [operation start];
}

@end
