//
//  NSUserDefaults+A3Defaults.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSUserDefaults+A3Defaults.h"
#import "A3UserDefaults.h"

@implementation NSUserDefaults (A3Defaults)

- (BOOL)currencyAutoUpdate {
	@autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3CurrencyAutoUpdate];
		if (object) {
			return [object boolValue];
		}
		return YES;
	}
}

- (void)setCurrencyAutoUpdate:(BOOL)boolValue {
	@autoreleasepool {
		[self setBool:boolValue forKey:A3CurrencyAutoUpdate];
		[self synchronize];
	}
}

- (BOOL)currencyUseCellularData {
	@autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3CurrencyUseCellularData];
		if (object) {
			return [object boolValue];
		}
		return NO;
	}
}

- (void)setCurrencyUseCellularData:(BOOL)boolValue {
	@autoreleasepool {
		[self setBool:boolValue forKey:A3CurrencyUseCellularData];
		[self synchronize];
	}
}

- (BOOL)currencyShowNationalFlag {
	@autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3CurrencyShowNationalFlag];
		if (object) {
			return [object boolValue];
		}
		return YES;
	}
}

- (void)setCurrencyShowNationalFlag:(BOOL)boolValue {
	@autoreleasepool {
		[self setBool:boolValue forKey:A3CurrencyShowNationalFlag];
		[self synchronize];
	}
}



- (BOOL)tipCalcTax
{
    @autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3TipCalcTax];
		if (object) {
			return [object boolValue];
		}
        else
        {
            [self setTipCalcTax:NO];
            return NO;
        }
        
		return YES;
	}
}
- (void)setTipCalcTax:(BOOL)boolValue
{
    @autoreleasepool {
		[self setBool:boolValue forKey:A3TipCalcTax];
		[self synchronize];
	}
}

#pragma mark - tipcalc
- (BOOL)tipCalcSplit
{
    @autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3TipCalcSplit];
		if (object) {
			return [object boolValue];
		}
		return YES;
	}
}
- (void)setTipCalcSplit:(BOOL)boolValue
{
    @autoreleasepool {
		[self setBool:boolValue forKey:A3TipCalcSplit];
		[self synchronize];
	}
}

- (BOOL)tipCalcRoundingMethod
{
    @autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3TipCalcRoundingMethod];
		if (object) {
			return [object boolValue];
		}
		return YES;
	}
}
- (void)setTipCalcRoundingMethod:(BOOL)boolValue
{
    @autoreleasepool {
		[self setBool:boolValue forKey:A3TipCalcRoundingMethod];
		[self synchronize];
	}
}

#pragma mark - clock
- (BOOL)clockTheTimeWithSeconds
{
    @autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3ClockTheTimeWithSeconds];
		if (object) {
			return [object boolValue];
		}
		return YES;
	}
}
- (void)setClockTheTimeWithSeconds:(BOOL)boolValue
{
    @autoreleasepool {
		[self setBool:boolValue forKey:A3ClockTheTimeWithSeconds];
		[self synchronize];
	}
}

- (BOOL)clockFlashTheTimeSeparators
{
    @autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3ClockFlashTheTimeSeparators];
		if (object) {
			return [object boolValue];
		}
		return NO;
    }
}
- (void)setClockFlashTheTimeSeparators:(BOOL)boolValue
{
    @autoreleasepool {
		[self setBool:boolValue forKey:A3ClockFlashTheTimeSeparators];
		[self synchronize];
	}
}

- (BOOL)clockUse24hourClock
{
    @autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3ClockUse24hourClock];
		if (object) {
			return [object boolValue];
		}
		return YES;
    }
}
- (void)setClockUse24hourClock:(BOOL)boolValue
{
    @autoreleasepool {
		[self setBool:boolValue forKey:A3ClockUse24hourClock];
		[self synchronize];
	}
}

- (BOOL)clockShowAMPM
{
    @autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3ClockShowAMPM];
		if (object) {
			return [object boolValue];
		}
		return NO;
    }
}
- (void)setClockShowAMPM:(BOOL)boolValue
{
    @autoreleasepool {
		[self setBool:boolValue forKey:A3ClockShowAMPM];
		[self synchronize];
	}
}

- (BOOL)clockShowTheDayOfTheWeek
{
    @autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3ClockShowTheDayOfTheWeek];
		if (object) {
			return [object boolValue];
		}
		return YES;
    }
}
- (void)setClockShowTheDayOfTheWeek:(BOOL)boolValue
{
    @autoreleasepool {
		[self setBool:boolValue forKey:A3ClockShowTheDayOfTheWeek];
		[self synchronize];
	}
}

- (BOOL)clockShowDate
{
    @autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3ClockShowDate];
		if (object) {
			return [object boolValue];
		}
		return YES;
    }
}
- (void)setClockShowDate:(BOOL)boolValue
{
    @autoreleasepool {
		[self setBool:boolValue forKey:A3ClockShowDate];
		[self synchronize];
	}
}

- (BOOL)clockShowWeather
{
    @autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3ClockShowWeather];
		if (object) {
			return [object boolValue];
		}
		return YES;
    }
}

- (void)setClockShowWeather:(BOOL)boolValue
{
    @autoreleasepool {
		[self setBool:boolValue forKey:A3ClockShowWeather];
		[self synchronize];
	}
}

- (BOOL)clockUsesFahrenheit
{
    @autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3ClockUsesFahrenheit];
		if (object) {
			return [object boolValue];
		}
		return (![[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue]);
    }
}
- (void)setClockUsesFahrenheit:(BOOL)boolValue
{
    @autoreleasepool {
		[self setBool:boolValue forKey:A3ClockUsesFahrenheit];
		[self synchronize];
	}
}

- (UIColor *)clockFlipDarkColor {
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:A3ClockFlipDarkColor];
	if (data) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	}
	return [UIColor blackColor];
}

- (UIColor *)clockFlipLightColor {
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:A3ClockFlipLightColor];
	if (data) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	}
	return [UIColor whiteColor];
}

@end
