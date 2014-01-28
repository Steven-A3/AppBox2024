//
//  A3ClockDataManager.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3Weather.h"

#define kClockFontNameRegular       @"HelveticaNeue"
#define kClockFontNameMedium        @"HelveticaNeue-Medium"
#define kClockFontNameUltraLight    @"HelveticaNeue-UltraLight"
#define kClockFontNameDigit         @"01 Digit"
#define kClockSecondOfDay           86400.0

typedef NS_ENUM(NSUInteger, A3ClockWaveCircleTypes) {
	A3ClockWaveCircleTypeTime = 1,
	A3ClockWaveCircleTypeWeather,
	A3ClockWaveCircleTypeDate,
	A3ClockWaveCircleTypeWeekday,
};

@class A3ClockInfo;
@class A3ClockDataManager;

@protocol A3ClockDataManagerDelegate <NSObject>
@optional
- (void)refreshSecond:(A3ClockInfo *)clockInfo;
- (void)refreshWholeClock:(A3ClockInfo *)clockInfo;
- (void)refreshWeather:(A3ClockInfo *)clockInfo;

@end

@class A3ClockWaveCircleView;

@interface A3ClockDataManager : NSObject

@property (nonatomic, strong) id<A3ClockDataManagerDelegate> delegate;
@property (nonatomic, strong) NSDictionary* weatherAtmosphere;//"for humidity"

@property (nonatomic, strong) A3ClockInfo *clockInfo;

- (void)enableWeatherCircle:(BOOL)enable;

- (void)enableDateCircle:(BOOL)enable;

- (void)enableWeekdayCircle:(BOOL)enable;

- (NSMutableArray *)waveCirclesArray;

- (void)startTimer;
- (void)stopTimer;

- (void)onTimerDateTimeTick;

- (NSArray *)waveColors;

- (NSArray*)flipColors;
- (NSArray*)ledColors;

- (UIImage*)imageForWeatherCondition:(A3WeatherCondition)aCon;

@end
