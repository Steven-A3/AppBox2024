//
//  A3CurrencyDataManager.h
//  AppBox3
//
//  Created by A3 on 12/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CurrencyFavorite;
@class CurrencyRateItem;

extern NSString *const A3NotificationCurrencyRatesUpdated;
extern NSString *const A3KeyCurrencyCode;

@interface A3CurrencyDataManager : NSObject

+ (void)setupFavorites;

+ (void)saveFavorites:(NSArray *)favorites;

+ (void)saveCurrencyObject:(id)object forKey:(NSString *)key;

+ (void)updateCurrencyRatesInContext:(NSManagedObjectContext *)context;

- (NSString *)localizedNameForCode:(NSString *)currencyCode;

@end
