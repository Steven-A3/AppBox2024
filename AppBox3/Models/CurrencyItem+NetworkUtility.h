//
//  CurrencyItem+NetworkUtility.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "CurrencyItem.h"

#define A3NotificationCurrencyRatesUpdated	@"A3NotificationCurrencyRatesUdpated"

@interface CurrencyItem (NetworkUtility)

+ (void)updateCurrencyRates;

+ (void)resetCurrencyLists;
@end
