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
#define kClockFontNameLight         @"HelveticaNeue-Light"
#define kClockFontNameMedium        @"HelveticaNeue-Medium"
#define kClockFontNameUltraLight    @"HelveticaNeue-UltraLight"
#define kClockFontNameTimesNewRoman @"Times New Roman"
#define kClockFontNameDigit         @"01 Digit"
#define kClockSecondOfDay           86400.0

//#define kClockLEDfontwidthChracter  41.736000f
//#define kClockLEDfontwidthSpace     20.572001f

@class A3ClockInfo;
@class A3ClockDataManager;

@protocol A3ClockDataManagerDelegate <NSObject>
@optional
- (void)refreshSecond:(A3ClockInfo *)clockInfo;
- (void)refreshWholeClock:(A3ClockInfo *)clockInfo;
- (void)refreshWeather:(A3ClockInfo *)clockInfo;

@end

//하나:41.736000, 둘:83.472000, 스페이스:20.572001, 1:26.048000

@class A3ClockWaveCircleView;

@interface A3ClockDataManager : NSObject

@property (nonatomic, weak) A3ClockWaveCircleView * bigCircle;
@property (nonatomic, strong) id<A3ClockDataManagerDelegate> delegate;
@property (nonatomic, strong) NSDictionary* weatherAtmosphere;//"for humidity"

@property (nonatomic, strong) A3ClockInfo *clockInfo;

- (void)startTimer;
- (void)stopTimer;

- (void)onTimerDateTimeTick;

- (NSArray *)waveColors;

- (NSArray*)flipColors;
- (NSArray*)ledColors;

- (UIImage*)imageForWeatherCondition:(A3WeatherCondition)aCon;

@end
