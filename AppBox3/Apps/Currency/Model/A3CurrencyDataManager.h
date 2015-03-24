//
//  A3CurrencyDataManager.h
//  AppBox3
//
//  Created by A3 on 12/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CurrencyRateItem;
@class A3YahooCurrency;

extern NSString *const A3NotificationCurrencyRatesUpdated;
extern NSString *const A3NotificationCurrencyRatesUpdateFailed;
extern NSString *const A3KeyCurrencyCode;

@interface A3CurrencyDataManager : NSObject

+ (void)setupFavorites;
- (void)updateCurrencyRatesInContext:(NSManagedObjectContext *)context;

- (A3YahooCurrency *)dataForCurrencyCode:(NSString *)code;

- (NSString *)localizedNameForCode:(NSString *)currencyCode;

@end
