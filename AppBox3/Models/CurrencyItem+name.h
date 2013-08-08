//
//  CurrencyItem+name.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "CurrencyItem.h"

extern NSString *const A3KeyCurrencyCode;

@interface CurrencyItem (name)
+ (void)updateNames;

- (NSString *)localizedName;

@end
