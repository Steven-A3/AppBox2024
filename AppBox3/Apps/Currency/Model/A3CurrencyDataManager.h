//
//  A3CurrencyDataManager.h
//  AppBox3
//
//  Created by A3 on 12/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class A3YahooCurrency;

extern NSString *const A3NotificationCurrencyRatesUpdated;
extern NSString *const A3NotificationCurrencyRatesUpdateFailed;
extern NSString *const A3KeyCurrencyCode;
extern NSString *const A3CurrencyUpdateDate;

@interface A3CurrencyDataManager : NSObject

@property (nonatomic, strong) NSArray *dataArray;

+ (void)setupFavorites;
- (NSString *)bundlePath;
- (void)updateCurrencyRatesOnSuccess:(void (^)())success failure:(void (^)())failure;
- (A3YahooCurrency *)dataForCurrencyCode:(NSString *)code;
- (NSString *)stringFromNumber:(NSNumber *)value withCurrencyCode:(NSString *)currencyCode isShare:(BOOL)isShare;
- (NSString *)localizedNameForCode:(NSString *)currencyCode;
- (NSString *)flagImageNameForCode:(NSString *)currencyCode;
- (NSString *)symbolForCode:(NSString *)currencyCode;
- (void)purgeRetainingObjects;

@end
