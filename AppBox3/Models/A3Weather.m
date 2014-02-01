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

@end
