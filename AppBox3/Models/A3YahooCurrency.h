//
//  A3YahooCurrency.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/12/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//



@interface A3YahooCurrency : NSObject

- (id)initWithObject:(id)object;

- (NSString *)name;

- (NSString *)currencyCode;

- (NSNumber *)rateToUSD;

- (NSDate *)updated;
@end
