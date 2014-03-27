//
//  A3Weather.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/16/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3Weather.h"

@implementation A3Weather


NSInteger fahrenheitToCelsius(NSInteger celsius) {
	return (NSInteger) roundf((celsius - 32) * 5.0 / 9.0);
}

NSInteger celsiusToFahrenheit(NSInteger fahrenheit) {
	return (NSInteger) roundf((fahrenheit * 9.0 / 5.0) + 32);
}

- (void)setUnit:(A3WeatherUnit)unit {
	if (_unit == SCWeatherUnitNone || unit == SCWeatherUnitNone) {
		_unit = unit;
		return;
	}
	if (unit != _unit) {
		if (_unit == SCWeatherUnitCelsius) {
			_currentTemperature = celsiusToFahrenheit(_currentTemperature);
			_highTemperature = celsiusToFahrenheit(_highTemperature);
			_lowTemperature = celsiusToFahrenheit(_lowTemperature);
		} else if (_unit == SCWeatherUnitFahrenheit) {
			_currentTemperature = fahrenheitToCelsius(_currentTemperature);
			_highTemperature = fahrenheitToCelsius(_highTemperature);
			_lowTemperature = fahrenheitToCelsius(_lowTemperature);
		}
		_unit = unit;
	}
}

NSString *const A3WeatherEncodingKeyWOEID = @"WODID";
NSString *const A3WeatherEncodingKeyUnit = @"unit";
NSString *const A3WeatherEncodingKeyCondition = @"condition";
NSString *const A3WeatherEncodingKeyCurrentTemperature = @"currentTemperature";
NSString *const A3WeatherEncodingKeyHighTemperature = @"highTemperature";
NSString *const A3WeatherEncodingKeyLowTemperature = @"lowTemperature";
NSString *const A3WeatherEncodingKeyRepresentation = @"representation";

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:_WOEID forKey:A3WeatherEncodingKeyWOEID];
	[coder encodeObject:@(_unit) forKey:A3WeatherEncodingKeyUnit];
	[coder encodeObject:@(_condition) forKey:A3WeatherEncodingKeyCondition];
	[coder encodeObject:@(_currentTemperature) forKey:A3WeatherEncodingKeyCurrentTemperature];
	[coder encodeObject:@(_highTemperature) forKey:A3WeatherEncodingKeyHighTemperature];
	[coder encodeObject:@(_lowTemperature) forKey:A3WeatherEncodingKeyLowTemperature];
	[coder encodeObject:_representation forKey:A3WeatherEncodingKeyRepresentation];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self) {
		_WOEID = [coder decodeObjectForKey:A3WeatherEncodingKeyWOEID];
		_unit = (A3WeatherUnit) [[coder decodeObjectForKey:A3WeatherEncodingKeyUnit] integerValue];
		_condition = (A3WeatherCondition) [[coder decodeObjectForKey:A3WeatherEncodingKeyCondition] integerValue];
		_currentTemperature = [[coder decodeObjectForKey:A3WeatherEncodingKeyCurrentTemperature] integerValue];
		_highTemperature = [[coder decodeObjectForKey:A3WeatherEncodingKeyHighTemperature] integerValue];
		_lowTemperature = [[coder decodeObjectForKey:A3WeatherEncodingKeyLowTemperature] integerValue];
		_representation = [coder decodeObjectForKey:A3WeatherEncodingKeyRepresentation];
	}
	return nil;
}

@end
