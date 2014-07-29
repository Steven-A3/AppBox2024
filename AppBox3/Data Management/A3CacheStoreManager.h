//
//  A3CacheStoreManager.h
//  AppBox3
//
//  Created by A3 on 12/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CurrencyRateItem;

@interface A3CacheStoreManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;

- (void)save;
- (float)rateForCurrencyCode:(NSString *)currency;

- (NSString *)symbolForCurrencyCode:(NSString *)code;

- (CurrencyRateItem *)currencyInfoWithCode:(NSString *)code;
@end
