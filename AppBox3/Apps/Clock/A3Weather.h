//
//  A3Weather.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/16/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

#define fahrenheitToCelsius(celsius) roundf((celsius - 32) * 5.0 / 9.0)
#define celsiusToFahrenheit(fahrenheit) roundf((fahrenheit * 9.0 / 5.0) + 32)

typedef NS_ENUM(NSUInteger, A3WeatherUnit) {
	SCWeatherUnitNone = 0,
	SCWeatherUnitCelsius = 1,
	SCWeatherUnitFahrenheit,
};

typedef NS_ENUM(NSUInteger, A3WeatherCondition) {
	SCWeatherConditionTornado = 0,
	SCWeatherConditionTropicalStorm,
	SCWeatherConditionHurricane,
	SCWeatherConditionSevereThunderstorms,
	SCWeatherConditionThunderstorms,
	SCWeatherConditionMixedRainAndSnow,
	SCWeatherConditionMixedRainAndSleet,
	SCWeatherConditionMixedSnowAndSleet,
	SCWeatherConditionFixingDrizzle,
	SCWeatherConditionDrizzle,
	SCWeatherConditionFreezingRain,
	SCWeatherConditionShowers,
	SCWeatherConditionShowers2,
	SCWeatherConditionSnowFlurries,
	SCWeatherConditionLightSnowShowers,
	SCWeatherConditionBlowingSnow,
	SCWeatherConditionSnow,
	SCWeatherConditionHail,
	SCWeatherConditionSleet,
	SCWeatherConditionDust,
	SCWeatherConditionFoggy,
	SCWeatherConditionHaze,
	SCWeatherConditionSmoky,
	SCWeatherConditionBlustery,
	SCWeatherConditionWindy,
	SCWeatherConditionCold,
	SCWeatherConditionCloudy,
	SCWeatherConditionMostlyCloudyNight,
	SCWeatherConditionMostlyCloudyDay,
	SCWeatherConditionPartlyCloudyNight,
	SCWeatherConditionPartlyCloudyDay,
	SCWeatherConditionClearNight,
	SCWeatherConditionSunny,
	SCWeatherConditionFairNight,
	SCWeatherConditionFairDay,
	SCWeatherConditionMixedRainAndHail,
	SCWeatherConditionHot,
	SCWeatherConditionIsolatedThunderstorms,
	SCWeatherConditionScatteredThunderstorms,
	SCWeatherConditionScatteredThunderstorms2,
	SCWeatherConditionScatteredShowers,
	SCWeatherConditionHeavySnow,
	SCWeatherConditionScatteredSnowShowers,
	SCWeatherConditionHeavySnow2,
	SCWeatherConditionPartlyCloudy,
	SCWeatherConditionThundershowers,
	SCWeatherConditionSnowShowers,
	SCWeatherConditionIsolatedThundershowers,
	SCWeatherConditionNotAvailable,
};

@interface A3Weather : NSObject <NSCoding>

@property (nonatomic, strong)	NSString *WOEID;
@property (nonatomic, assign)	A3WeatherUnit unit;
@property (nonatomic, assign)	A3WeatherCondition condition;
@property (nonatomic, assign)	double currentTemperature;
@property (nonatomic, assign)	double highTemperature;
@property (nonatomic, assign)	double lowTemperature;
@property (nonatomic, strong)	NSString *representation;
@property (nonatomic, strong)	NSDictionary *weatherAtmosphere;

- (void)setCurrentTemperature:(double)value fromUnit:(NSString *)fromUnit;

- (void)setHighTemperature:(double)value fromUnit:(NSString *)fromUnit;

- (void)setLowTemperature:(double)value fromUnit:(NSString *)fromUnit;
@end
