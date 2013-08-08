//
//  NSUserDefaults+A3Defaults.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (A3Defaults)

- (BOOL)currencyAutoUpdate;

- (void)setCurrencyAutoUpdate:(BOOL)boolValue;

- (BOOL)currencyUseCellularData;

- (void)setCurrencyUseCellularData:(BOOL)boolValue;

- (BOOL)currencyShowNationalFlag;

- (void)setCurrencyShowNationalFlag:(BOOL)boolValue;
@end
