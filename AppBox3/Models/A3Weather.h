//
//  A3Weather.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/16/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, A3WeatherUnit) {
	SCWeatherUnitNone = 0,
	SCWeatherUnitCelsius = 1,
	SCWeatherUnitFahrenheit,
};

typedef enum {
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
} A3WeatherCondition;

@interface A3Weather : NSObject

@property (nonatomic, strong)	NSString *WOEID;
@property (nonatomic, assign)	A3WeatherUnit unit;
@property (nonatomic, assign)	A3WeatherCondition condition;
@property (nonatomic, assign)	NSInteger currentTemperature;
@property (nonatomic, assign)	NSInteger highTemperature;
@property (nonatomic, assign)	NSInteger lowTemperature;
@property (nonatomic, strong)	NSString *description;

@end
