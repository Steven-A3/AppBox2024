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

- (BOOL)clockTheTimeWithSeconds;
- (void)setClockTheTimeWithSeconds:(BOOL)boolValue;

- (BOOL)clockFlashTheTimeSeparators;
- (void)setClockFlashTheTimeSeparators:(BOOL)boolValue;

- (BOOL)clockUse24hourClock;
- (void)setClockUse24hourClock:(BOOL)boolValue;

- (BOOL)clockShowAMPM;
- (void)setClockShowAMPM:(BOOL)boolValue;

- (BOOL)clockShowTheDayOfTheWeek;
- (void)setClockShowTheDayOfTheWeek:(BOOL)boolValue;

- (BOOL)clockShowDate;
- (void)setClockShowDate:(BOOL)boolValue;

- (BOOL)clockShowWeather;
- (void)setClockShowWeather:(BOOL)boolValue;

- (BOOL)clockUsesFahrenheit;
- (void)setClockUsesFahrenheit:(BOOL)boolValue;

- (UIColor *)clockWaveColor;
- (NSUInteger)clockWaveColorIndex;

- (UIColor *)clockFlipDarkColor;

- (NSUInteger)clockFlipDarkColorIndex;

- (UIColor *)clockFlipLightColor;

- (NSUInteger)clockFlipLightColorIndex;

- (UIColor *)clockLEDColor;
- (NSUInteger)clockLEDColorIndex;

@end
