//
//  A3UserDefaults+A3Defaults.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3UserDefaults+A3Defaults.h"
#import "A3UserDefaultsKeys.h"

@implementation A3UserDefaults (A3Defaults)

- (BOOL)currencyAutoUpdate {
	NSNumber *object;
	object = [self objectForKey:A3CurrencyUserDefaultsAutoUpdate];
	if (object) {
		return [object boolValue];
	}
	return YES;
}

- (void)setCurrencyAutoUpdate:(BOOL)boolValue {
	[self setBool:boolValue forKey:A3CurrencyUserDefaultsAutoUpdate];
	[self synchronize];
}

- (BOOL)currencyUseCellularData {
	NSNumber *object;
	object = [self objectForKey:A3CurrencyUserDefaultsUseCellularData];
	if (object) {
		return [object boolValue];
	}
	return NO;
}

- (void)setCurrencyUseCellularData:(BOOL)boolValue {
	[self setBool:boolValue forKey:A3CurrencyUserDefaultsUseCellularData];
	[self synchronize];
}

- (BOOL)currencyShowNationalFlag {
	NSNumber *object;
	object = [self objectForKey:A3CurrencyUserDefaultsShowNationalFlag];
	if (object) {
		return [object boolValue];
	}
	return YES;
}

- (void)setCurrencyShowNationalFlag:(BOOL)boolValue {
	[self setBool:boolValue forKey:A3CurrencyUserDefaultsShowNationalFlag];
	[self synchronize];
}

#pragma mark - clock

- (BOOL)clockTheTimeWithSeconds
{
	NSNumber *object;
	object = [self objectForKey:A3ClockTheTimeWithSeconds];
	if (object) {
		return [object boolValue];
	}
	return YES;
}

- (void)setClockTheTimeWithSeconds:(BOOL)boolValue
{
	[self setBool:boolValue forKey:A3ClockTheTimeWithSeconds];
	[self synchronize];
}

- (BOOL)clockFlashTheTimeSeparators
{
	NSNumber *object;
	object = [self objectForKey:A3ClockFlashTheTimeSeparators];
	if (object) {
		return [object boolValue];
	}
	return NO;
}

- (void)setClockFlashTheTimeSeparators:(BOOL)boolValue
{
	[self setBool:boolValue forKey:A3ClockFlashTheTimeSeparators];
	[self synchronize];
}

- (BOOL)clockUse24hourClock
{
	NSNumber *object;
	object = [self objectForKey:A3ClockUse24hourClock];
	if (object) {
		return [object boolValue];
	}
	return YES;
}

- (void)setClockUse24hourClock:(BOOL)boolValue
{
	[self setBool:boolValue forKey:A3ClockUse24hourClock];
	[self synchronize];
}

- (BOOL)clockShowAMPM
{
	if ([self clockUse24hourClock]) return NO;

	NSNumber *object;
	object = [self objectForKey:A3ClockShowAMPM];
	if (object) {
		return [object boolValue];
	}
	return NO;
}

- (void)setClockShowAMPM:(BOOL)boolValue
{
	[self setBool:boolValue forKey:A3ClockShowAMPM];
	[self synchronize];
}

- (BOOL)clockShowTheDayOfTheWeek
{
	NSNumber *object;
	object = [self objectForKey:A3ClockShowTheDayOfTheWeek];
	if (object) {
		return [object boolValue];
	}
	return YES;
}

- (void)setClockShowTheDayOfTheWeek:(BOOL)boolValue
{
	[self setBool:boolValue forKey:A3ClockShowTheDayOfTheWeek];
	[self synchronize];
}

- (BOOL)clockShowDate
{
	NSNumber *object;
	object = [self objectForKey:A3ClockShowDate];
	if (object) {
		return [object boolValue];
	}
	return YES;
}

- (void)setClockShowDate:(BOOL)boolValue
{
	[self setBool:boolValue forKey:A3ClockShowDate];
	[self synchronize];
}

- (BOOL)clockShowWeather
{
	NSNumber *object;
	object = [self objectForKey:A3ClockShowWeather];
	if (object) {
		return [object boolValue];
	}
	return YES;
}

- (BOOL)clockUseAutoLock {
    NSNumber *object;
    object = [self objectForKey:A3ClockUseAutoLock];
    if (object) {
        return [object boolValue];
    }
    return YES;
}

- (void)setClockShowWeather:(BOOL)boolValue
{
	[self setBool:boolValue forKey:A3ClockShowWeather];
	[self synchronize];
}

- (BOOL)clockUsesFahrenheit
{
	NSNumber *object;
	object = [self objectForKey:A3ClockUsesFahrenheit];
	if (object) {
		return [object boolValue];
	}
	return (![[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue]);
}

- (void)setClockUsesFahrenheit:(BOOL)boolValue
{
	[self setBool:boolValue forKey:A3ClockUsesFahrenheit];
	[self synchronize];
}

- (UIColor *)clockWaveColor {
	NSData *data = [self objectForKey:A3ClockWaveClockColor];
	if (data) {
        NSError *error;
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
        UIColor *decodedObject = nil;
        if (error) {
            FNLOG(@"Error unarchiving NSDateComponents data: %@", error.localizedDescription);
        } else {
            unarchiver.requiresSecureCoding = NO; // Set this to YES if your object conforms to NSSecureCoding
            decodedObject = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
            [unarchiver finishDecoding];
        }

        return decodedObject;
	}
	return [UIColor colorWithRed:63.0/255.0 green:156.0/255.0 blue:250.0/255.0 alpha:1.0];
}

- (NSUInteger)clockWaveColorIndex {
	NSNumber *number = [self objectForKey:A3ClockWaveClockColorIndex];
	if (number) {
		return [number unsignedIntegerValue];
	}
	return 7;
}

- (UIColor *)clockFlipDarkColor {
	NSData *data = [self objectForKey:A3ClockFlipDarkColor];
	if (data) {
        NSError *error;
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
        UIColor *decodedObject = nil;
        if (error) {
            FNLOG(@"Error unarchiving NSDateComponents data: %@", error.localizedDescription);
        } else {
            unarchiver.requiresSecureCoding = NO; // Set this to YES if your object conforms to NSSecureCoding
            decodedObject = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
            [unarchiver finishDecoding];
        }

        return decodedObject;
	}
	return [UIColor blackColor];
}

- (NSUInteger)clockFlipDarkColorIndex {
	NSNumber *number = [self objectForKey:A3ClockFlipDarkColorIndex];
	if (number) {
		return [number unsignedIntegerValue];
	}
	return 12;
}

- (UIColor *)clockFlipLightColor {
	NSData *data = [self objectForKey:A3ClockFlipLightColor];
	if (data) {
        NSError *error;
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
        UIColor *decodedObject = nil;
        if (error) {
            FNLOG(@"Error unarchiving NSDateComponents data: %@", error.localizedDescription);
        } else {
            unarchiver.requiresSecureCoding = NO; // Set this to YES if your object conforms to NSSecureCoding
            decodedObject = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
            [unarchiver finishDecoding];
        }

        return decodedObject;
	}
	return [UIColor whiteColor];
}

- (NSUInteger)clockFlipLightColorIndex {
	NSNumber *number = [self objectForKey:A3ClockFlipLightColorIndex];
	if (number) {
		return [number unsignedIntegerValue];
	}
	return 13;
}

- (UIColor *)clockLEDColor {
	NSData *data = [self objectForKey:A3ClockLEDColor];
	if (data) {
        NSError *error;
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
        UIColor *decodedObject = nil;
        if (error) {
            FNLOG(@"Error unarchiving NSDateComponents data: %@", error.localizedDescription);
        } else {
            unarchiver.requiresSecureCoding = NO; // Set this to YES if your object conforms to NSSecureCoding
            decodedObject = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
            [unarchiver finishDecoding];
        }

        return decodedObject;
	}
	return [UIColor whiteColor];
}

- (NSUInteger)clockLEDColorIndex {
	NSNumber *number = [self objectForKey:A3ClockLEDColorIndex];
	if (number) {
		return [number unsignedIntegerValue];
	}
	return 12;
}

@end
