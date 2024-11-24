//
//  A3ClockDataManager.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockDataManager.h"
#import <CoreLocation/CoreLocation.h>
#import "A3ClockInfo.h"
#import "A3UserDefaults+A3Defaults.h"
#import "AFHTTPRequestOperation.h"
#import "A3UserDefaultsKeys.h"
#import "A3AppDelegate.h"
#import "Reachability.h"
#import "TDOAuth.h"

@interface A3ClockDataManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDictionary *weatherCurrentCondition;
@property (nonatomic, strong) NSMutableArray *weatherForecast;
@property (nonatomic, strong) NSTimer *clockTickTimer;
@property (nonatomic, strong) NSTimer *weatherTimer;
@property (nonatomic, assign) NSTimeInterval lastRequestTime;
@property (nonatomic, strong) AFHTTPRequestOperation *weatherOperation;

@end


@implementation A3ClockDataManager {
	BOOL _refreshWholeClock;
	BOOL _weatherUpdateInProgress;
}

- (id)init {
	self = [super init];
	if (self) {

//		if ([[A3AppDelegate instance].reachability isReachable]) {
//			[self.locationManager startUpdatingLocation];
//		}

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
		_lastRequestTime = 0;
	}

	return self;
}

- (void)reachabilityChanged:(NSNotification *)notification {
	Reachability *reachability = notification.object;
	if (reachability.isReachable) {
		[self updateWeather];
	}
}

- (void)applicationDidBecomeActive {
}

- (void)applicationWillEnterForeground {
	[self refreshClock:YES];
}

- (void)cleanUp {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
	
	[self stopTimer];
}

- (CLLocationManager *)locationManager {
	if (!_locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
		[_locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
		[_locationManager setDelegate:self];
#ifdef __IPHONE_8_0
		if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
			[_locationManager requestWhenInUseAuthorization];
		}
#endif
	}
	return _locationManager;
}

- (void)enableWeatherCircle:(BOOL)enable {
	[self enableWaveCircleType:A3ClockWaveCircleTypeWeather enable:enable];
}

- (void)enableDateCircle:(BOOL)enable {
	[self enableWaveCircleType:A3ClockWaveCircleTypeDate enable:enable];
}

- (void)enableWeekdayCircle:(BOOL)enable {
	[self enableWaveCircleType:A3ClockWaveCircleTypeWeekday enable:enable];
}

- (void)enableWaveCircleType:(A3ClockWaveCircleTypes)type enable:(BOOL)enable {
	NSMutableArray *waveCirclesArray = [self waveCirclesArray];
	if (enable) {
		NSUInteger idx = [waveCirclesArray indexOfObject:@(type)];
		if (idx == NSNotFound) {
			[waveCirclesArray addObject:@(type)];
		}
	} else {
		[waveCirclesArray removeObject:@(type)];
	}
	[[A3UserDefaults standardUserDefaults] setObject:waveCirclesArray forKey:A3ClockWaveCircleLayout];
	[[A3UserDefaults standardUserDefaults] synchronize];
}

- (NSMutableArray *)waveCirclesArray {
	A3UserDefaults *userDefaults = [A3UserDefaults standardUserDefaults];
	NSMutableArray *circleArray = [[userDefaults objectForKey:A3ClockWaveCircleLayout] mutableCopy];

	if (circleArray) return circleArray;

	circleArray = [NSMutableArray new];
	[circleArray addObject:@(A3ClockWaveCircleTypeTime)];

	if ([userDefaults clockShowWeather]) {
		[circleArray addObject:@(A3ClockWaveCircleTypeWeather)];
	}
	if ([userDefaults clockShowDate]) {
		[circleArray addObject:@(A3ClockWaveCircleTypeDate)];
	}
	if ([userDefaults clockShowTheDayOfTheWeek]) {
		[circleArray addObject:@(A3ClockWaveCircleTypeWeekday)];
	}
	[userDefaults setObject:circleArray forKey:A3ClockWaveCircleLayout];
	[userDefaults synchronize];
	return circleArray;
}

- (void)startTimer {
	[_clockTickTimer invalidate];

	_refreshWholeClock = YES;
	_clockTickTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(onTimerDateTimeTick) userInfo:nil repeats:YES];
	[_clockTickTimer fire];
}

- (void)stopTimer {
	[_clockTickTimer invalidate];
	_clockTickTimer = nil;
	[_weatherTimer invalidate];
	_weatherTimer = nil;
}

- (A3ClockInfo *)clockInfo {
	if (!_clockInfo) {
		_clockInfo = [A3ClockInfo new];
	}
	return _clockInfo;
}

#pragma mark - timer event

- (void)onTimerDateTimeTick
{
	[self refreshClock:NO ];
}

- (void)refreshClock:(BOOL)forceRefreshAll {
	NSDate *currentTime = [NSDate date];

	self.clockInfo.date = currentTime;
	_clockInfo.dateComponents = [self.clockInfo.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay | NSCalendarUnitWeekday |NSCalendarUnitHour |NSCalendarUnitMinute |NSCalendarUnitSecond fromDate:currentTime];
	if (_clockInfo.dateComponents.second == 0 || forceRefreshAll) _refreshWholeClock = YES;

	if (_refreshWholeClock) {
		_refreshWholeClock = NO;
		[self refreshWholeClockInfo:currentTime];
		if ([_delegate respondsToSelector:@selector(refreshWholeClock:)]) {
			[_delegate refreshWholeClock:_clockInfo];
		}
	} else {
		if ([_delegate respondsToSelector:@selector(refreshSecond:)]) {
			[_delegate refreshSecond:_clockInfo];
		}
	}
}

- (void)refreshWholeClockInfo:(NSDate *)currentTime {
	__weak NSDateFormatter *formatter = self.clockInfo.dateFormatter;

	[formatter setDateFormat:@"a"];
	_clockInfo.AMPM = [formatter stringFromDate:currentTime];

	[formatter setDateFormat:@"dd"];
	_clockInfo.day = [formatter stringFromDate:currentTime];

	NSRange days = [self.clockInfo.calendar rangeOfUnit:NSCalendarUnitDay
									   inUnit:NSCalendarUnitMonth
									  forDate:currentTime];
	_clockInfo.maxDay = [NSString stringWithFormat:@"%lu", (unsigned long)days.length];

	[formatter setDateFormat:@"MMMM"];
	_clockInfo.month = [formatter stringFromDate:currentTime];

	[formatter setDateFormat:@"MMM"];
	_clockInfo.shortMonth = [formatter stringFromDate:currentTime];

	[formatter setDateFormat:@"EEEE"];
	_clockInfo.weekday = [formatter stringFromDate:currentTime];

	[formatter setDateFormat:@"EEE"];
	_clockInfo.shortWeekday = [formatter stringFromDate:currentTime];
}

- (UIColor*)colorWidth255RGB:(float)aR g:(float)aG b:(float)aB
{
    return [UIColor colorWithRed:aR/255.f green:aG/255.f blue:aB/255.f alpha:1.f];
}

- (NSArray*)waveColors
{
	static NSArray* arrColor = nil;

	if(arrColor == nil)
	{
		arrColor = @[[self colorWidth255RGB:253 g:158 b:27],
				[self colorWidth255RGB:250 g:207 b:36],
				[self colorWidth255RGB:165 g:222 b:55],
				[self colorWidth255RGB:76 g:217 b:75],
				[self colorWidth255RGB:32 g:214 b:120],
				[self colorWidth255RGB:64 g:224 b:208],
				[self colorWidth255RGB:90 g:200 b:250],
				[self colorWidth255RGB:63 g:156 b:250],
				[self colorWidth255RGB:107 g:105 b:223],
				[self colorWidth255RGB:204 g:115 b:225],
				[self colorWidth255RGB:246 g:104 b:202],
				[self colorWidth255RGB:198 g:156 b:109]];
	}

	return arrColor;
}

- (NSArray*)flipColors
{
    static NSArray* arrColor = nil;
    
    if(arrColor == nil)
    {
        arrColor = @[[self colorWidth255RGB:253 g:158 b:27],
                     [self colorWidth255RGB:250 g:207 b:37],
                     [self colorWidth255RGB:164 g:222 b:54],
                     [self colorWidth255RGB:76 g:217 b:75],
                     [self colorWidth255RGB:32 g:214 b:120],
                     [self colorWidth255RGB:64 g:224 b:208],
                     [self colorWidth255RGB:90 g:200 b:250],
                     [self colorWidth255RGB:63 g:155 b:250],
                     [self colorWidth255RGB:107 g:105 b:223],
                     [self colorWidth255RGB:204 g:115 b:225],
                     [self colorWidth255RGB:246 g:104 b:202],
                     [self colorWidth255RGB:198 g:156 b:109],
                     [self colorWidth255RGB:0 g:0 b:0],
                     [self colorWidth255RGB:255 g:255 b:255]];
    }
    
    return arrColor;
}

- (NSArray*)ledColorComponents
{
    static NSArray* arrColor = nil;
    
    if(arrColor == nil)
    {
        arrColor = @[@[@253, @158, @26],
                     @[@250, @207, @37],
                     @[@164, @222, @55],
                     @[@76, @217, @76],
                     @[@32, @214, @120],
                     @[@64, @224, @208],
                     @[@90, @200, @250],
                     @[@63, @156, @250],
                     @[@107, @105, @223],
                     @[@204, @115, @225],
                     @[@246, @104, @202],
                     @[@198, @156, @109],
                     @[@255, @255, @255]
		];
    }
    
    return arrColor;
}

- (NSArray *)ledColors {
	NSArray *colorComponents = self.ledColorComponents;
	NSMutableArray *colors = [NSMutableArray new];
	for (NSArray *components in colorComponents) {
		[colors addObject:[UIColor colorWithRed:[components[0] floatValue] / 255.0 green:[components[1] floatValue] / 255.0 blue:[components[2] floatValue] / 255.0 alpha:1.0]];
	}
	return colors;
}

- (UIColor *)LEDColorAtIndex:(NSUInteger)idx alpha:(CGFloat)alpha {
	NSArray *components = self.ledColorComponents[idx];
	return [UIColor colorWithRed:[components[0] floatValue] / 255.0 green:[components[1] floatValue] / 255.0 blue:[components[2] floatValue] / 255.0 alpha:alpha];
}

- (UIImage*)imageForWeatherCondition:(A3WeatherCondition)condition
{
    NSInteger idx = 0;

    switch (condition) {
        case SCWeatherConditionTornado: idx = 21; break;
        case SCWeatherConditionThunderstorms: idx = 1; break;
        case SCWeatherConditionMixedRainAndSnow: idx = 2; break;
        case SCWeatherConditionFreezingRain: idx = 2; break;
        case SCWeatherConditionFixingDrizzle: idx = 4; break;
        case SCWeatherConditionDrizzle: idx = 4; break;
        case SCWeatherConditionShowers: idx = 5; break;
        case SCWeatherConditionShowers2: idx = 5; break;
        case SCWeatherConditionScatteredShowers: idx = 5; break;
        case SCWeatherConditionMixedSnowAndSleet: idx = 6; break;
        case SCWeatherConditionSnowFlurries: idx = 6; break;
        case SCWeatherConditionLightSnowShowers: idx = 6; break;
        case SCWeatherConditionSnow: idx = 6; break;
        case SCWeatherConditionCold: idx = 6; break;
        case SCWeatherConditionScatteredSnowShowers: idx = 6; break;
        case SCWeatherConditionSnowShowers: idx = 6; break;
        case SCWeatherConditionBlowingSnow: idx = 7; break;
        case SCWeatherConditionFoggy: idx = 8; break;
        case SCWeatherConditionHaze: idx = 9; break;
        case SCWeatherConditionSmoky: idx = 10; break;
        case SCWeatherConditionBlustery: idx = 11; break;
        case SCWeatherConditionWindy: idx = 11; break;
        case SCWeatherConditionCloudy: idx = 12; break;
        case SCWeatherConditionPartlyCloudy: idx = 12; break;
        case SCWeatherConditionMostlyCloudyNight: idx = 13; break;
        case SCWeatherConditionClearNight: idx = 13; break;
        case SCWeatherConditionMostlyCloudyDay: idx = 14; break;
        case SCWeatherConditionSunny: idx = 14; break;
        case SCWeatherConditionHot: idx = 14; break;
        case SCWeatherConditionPartlyCloudyNight: idx = 15; break;
        case SCWeatherConditionPartlyCloudyDay: idx = 16; break;
        case SCWeatherConditionFairNight: idx = 13; break;
        case SCWeatherConditionFairDay: idx = 14; break;
        case SCWeatherConditionIsolatedThunderstorms: idx = 1; break;
        case SCWeatherConditionScatteredThunderstorms: idx = 1; break;
        case SCWeatherConditionScatteredThunderstorms2: idx = 1; break;
        case SCWeatherConditionHeavySnow: idx = 2; break;
        case SCWeatherConditionHeavySnow2: idx = 2; break;
        case SCWeatherConditionTropicalStorm: idx = 22; break;
        case SCWeatherConditionHurricane: idx = 23; break;
        case SCWeatherConditionSevereThunderstorms: idx = 1; break;
        case SCWeatherConditionMixedRainAndSleet: idx = 2; break;
        case SCWeatherConditionHail: idx = 26; break;
        case SCWeatherConditionSleet: idx = 2; break;
        case SCWeatherConditionDust: idx = 28; break;
        case SCWeatherConditionMixedRainAndHail: idx = 29; break;
        case SCWeatherConditionThundershowers: idx = 30; break;
        case SCWeatherConditionIsolatedThundershowers: idx = 30; break;
        default:
            idx = -1;
            break;
    }
    
    if(idx == -1)
        return nil;
    else
        return [UIImage imageNamed:[NSString stringWithFormat:@"weather_%02ld", (long)idx]];
}

#pragma mark - weather

#define YAHOO_APP_ID	@"YPTRvJjV34GJKXl3pY2LuRNpwY4w2Rv.GpYI9vbPWz_Yk0hgFZUrDIeibzpbg__AKg--"

// select * from weather.forecast where woeid in (select woeid from geo.places(1) where text="nome, ak")
// https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22nome%2C%20ak%22)&format=json
- (void)getWeatherWithWOEID:(NSString *)WOEID {
	if (_weatherOperation) {
		return;
	}
	NSString *ydnQuery = [NSString stringWithFormat:@"select * from weather.forecast where woeid in (%@)", WOEID];
	NSString *urlString = [NSString stringWithFormat:@"https://query.yahooapis.com/v1/public/yql?q=%@&format=json", [ydnQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	FNLOG(@"%@", urlString);

	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

	_weatherOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	_weatherOperation.responseSerializer = [AFJSONResponseSerializer serializer];
	
	__typeof(self) __weak weakSelf = self;
	[_weatherOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
		/*
		 
		 2016-12-29 20:18:56.836 AppBox3[22466:2058763] -[A3ClockDataManager getWeatherWithWOEID:] line 374, https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(56684367)&format=json
		 2016-12-29 20:18:57.919 AppBox3[22466:2057852] __42-[A3ClockDataManager getWeatherWithWOEID:]_block_invoke line 381, {
		 query =     {
			count = 0;
			created = "2016-12-29T11:18:57Z";
			lang = "en-us";
			results = "<null>";
		 };
		 }
		 
		 */
		FNLOG(@"%@", JSON);

		if (JSON[@"query"] && ([JSON[@"query"][@"count"] integerValue] > 0) && [JSON[@"query"][@"results"] isKindOfClass:[NSDictionary class]]) {
			A3ClockInfo *clockInfo = weakSelf.clockInfo;
			clockInfo.currentWeather = [A3Weather new];
			clockInfo.currentWeather.unit = [[A3UserDefaults standardUserDefaults] clockUsesFahrenheit] ? SCWeatherUnitFahrenheit : SCWeatherUnitCelsius;
			// Results Unit
			NSDictionary *results = JSON[@"query"][@"results"][@"channel"];
			NSString *resultUnit = results[@"units"][@"temperature"];
			
			clockInfo.currentWeather.representation = results[@"item"][@"condition"][@"text"];
			[clockInfo.currentWeather setCurrentTemperature:[results[@"item"][@"condition"][@"temp"] doubleValue] fromUnit:resultUnit];
			clockInfo.currentWeather.condition = (A3WeatherCondition)[results[@"item"][@"condition"][@"code"] integerValue];
			
			NSDictionary *forecast = results[@"item"][@"forecast"][0];
			[clockInfo.currentWeather setHighTemperature:[forecast[@"high"] doubleValue] fromUnit:resultUnit];
			[clockInfo.currentWeather setLowTemperature:[forecast[@"low"] doubleValue] fromUnit:resultUnit];
			
			clockInfo.currentWeather.weatherAtmosphere = results[@"atmosphere"];
			
			
			if ([weakSelf.delegate respondsToSelector:@selector(refreshWeather:)]) {
				[weakSelf.delegate refreshWeather:clockInfo];
			}
			[weakSelf.weatherTimer invalidate];
			weakSelf.weatherTimer = [NSTimer scheduledTimerWithTimeInterval:60 * 60 target:weakSelf selector:@selector(updateWeather) userInfo:nil repeats:NO];
		} else {
			[weakSelf.weatherTimer invalidate];
			weakSelf.weatherTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:weakSelf selector:@selector(updateWeather) userInfo:nil repeats:NO];
		}

		weakSelf.locationManager = nil;
		
		weakSelf.weatherOperation = nil;
        self->_weatherUpdateInProgress = NO;
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[weakSelf.locationManager startUpdatingLocation];
		weakSelf.weatherOperation = nil;
        self->_weatherUpdateInProgress = NO;
	}];
	
	[_weatherOperation start];
}

- (void)getWOEIDWithLocation:(CLLocation *)location {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://query.yahooapis.com/v1/public/yql?q=select%%20woeid%%20from%%20geo.places%%20where%%20text%%3D%%22(%f,%f)%%22%%20limit%%201&diagnostics=false&format=json",
									   location.coordinate.latitude, location.coordinate.longitude]];

	FNLOG(@"%@", url.absoluteString);
	
	NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
	NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error) {
                self->_weatherUpdateInProgress = NO;
				return;
			}
			NSError *parseError;
			NSDictionary *woeidData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
			if (parseError) {
                self->_weatherUpdateInProgress = NO;
				return;
			}
			FNLOG(@"%@", woeidData);
			
			NSString *woeid = woeidData[@"query"][@"results"][@"place"][@"woeid"];
			if ([woeid length]) {
				[self getWeatherWithWOEID:woeid];
			}
		});
	}];
	[task resume];

	return;
}

- (void)getWeatherWithLocation:(CLLocation *)location {
    __typeof(self) __weak weakSelf = self;

    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"lat"] = [NSString stringWithFormat:@"%.4f", location.coordinate.latitude];
    parameters[@"lon"] = [NSString stringWithFormat:@"%.4f", location.coordinate.longitude];
    parameters[@"format"] = @"json";
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    headers[@"Yahoo-App-Id"] = @"B5tmZF36";
    
    NSURLRequest *request = [TDOAuth URLRequestForPath:@"/forecastrss"
                                            parameters:parameters
                                                  host:@"weather-ydn-yql.media.yahoo.com"
                                           consumerKey:@"dj0yJmk9Uk42dGdBRXYxeTdjJnM9Y29uc3VtZXJzZWNyZXQmc3Y9MCZ4PTdh"
                                        consumerSecret:@"b6682084548c87ae7bd157145bdcd8ec6c0ab102"
                                           accessToken:nil
                                           tokenSecret:nil
                                                scheme:@"https"
                                         requestMethod:@"GET"
                                          dataEncoding:TDOAuthContentTypeUrlEncodedForm
                                          headerValues:headers
                                       signatureMethod:TDOAuthSignatureMethodHmacSha1];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            FNLOG(@"%@", error.localizedDescription);
            
            return;
        }
        NSError *parseError;
        NSDictionary *weatherData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
        if (!parseError && [weatherData isKindOfClass:[NSDictionary class]] && weatherData[@"current_observation"] && weatherData[@"forecasts"]) {
            FNLOG(@"%@", weatherData);
            
            A3ClockInfo *clockInfo = weakSelf.clockInfo;
            clockInfo.currentWeather = [A3Weather new];
            clockInfo.currentWeather.unit = [[A3UserDefaults standardUserDefaults] clockUsesFahrenheit] ? SCWeatherUnitFahrenheit : SCWeatherUnitCelsius;
            // Results Unit
            NSString *resultUnit = @"f";
            
            clockInfo.currentWeather.representation = weatherData[@"current_observation"][@"condition"][@"text"];
            [clockInfo.currentWeather setCurrentTemperature:[weatherData[@"current_observation"][@"condition"][@"temperature"] doubleValue] fromUnit:resultUnit];
            clockInfo.currentWeather.condition = (A3WeatherCondition)[weatherData[@"current_observation"][@"condition"][@"code"] integerValue];
            
            NSDictionary *forecast = weatherData[@"forecasts"][0];
            [clockInfo.currentWeather setHighTemperature:[forecast[@"high"] doubleValue] fromUnit:resultUnit];
            [clockInfo.currentWeather setLowTemperature:[forecast[@"low"] doubleValue] fromUnit:resultUnit];
            
            clockInfo.currentWeather.weatherAtmosphere = weatherData[@"current_observation"][@"atmosphere"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(refreshWeather:)]) {
                    [weakSelf.delegate refreshWeather:clockInfo];
                }
            });

            [weakSelf.weatherTimer invalidate];
            weakSelf.weatherTimer = [NSTimer scheduledTimerWithTimeInterval:60 * 60 target:weakSelf selector:@selector(updateWeather) userInfo:nil repeats:NO];

        }
    }];
    [task resume];
    
    return;
}

- (void)updateWeather {
	[_weatherTimer invalidate];
	_weatherTimer = nil;

	if ([[A3AppDelegate instance].reachability isReachable]) {
		[self.locationManager startUpdatingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	[manager stopMonitoringSignificantLocationChanges];

	if (!_weatherUpdateInProgress) {
		_weatherUpdateInProgress = YES;
		[self getWeatherWithLocation:locations[0]];
	}
}

- (NSString *)autoDimString {
    NSInteger autoDimValue = [[A3UserDefaults standardUserDefaults] integerForKey:A3ClockAutoDim];
    return [self autoDimStringWithValue:autoDimValue];
}

- (NSString *)autoDimStringWithValue:(NSInteger)autoDimValue {
    if (autoDimValue == 0) {
        return NSLocalizedString(@"Never", @"Never");
    } else if (autoDimValue == 60) {
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld hours", @"StringsDict", nil), 1];
    }
    return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld minutes", @"StringsDict", nil), autoDimValue];
}

@end
