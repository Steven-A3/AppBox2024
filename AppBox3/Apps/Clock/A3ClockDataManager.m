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

@interface A3ClockDataManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDictionary *weatherCurrentCondition;
@property (nonatomic, strong) NSMutableArray *weatherForecast;
@property (nonatomic, strong) NSTimer *clockTickTimer;
@property (nonatomic, strong) NSTimer *weatherTimer;
@property (nonatomic, strong) NSMutableArray *addressCandidates;

@end


@implementation A3ClockDataManager {
	BOOL _refreshWholeClock;
}

- (id)init {
	self = [super init];
	if (self) {
		if ([[A3AppDelegate instance].reachability isReachable]) {
			[self.locationManager startUpdatingLocation];
		}

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
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
	_clockInfo.dateComponents = [self.clockInfo.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:currentTime];
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

	NSRange days = [self.clockInfo.calendar rangeOfUnit:NSDayCalendarUnit
									   inUnit:NSMonthCalendarUnit
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
        return [UIImage imageNamed:nil];
    else
        return [UIImage imageNamed:[NSString stringWithFormat:@"weather_%02ld", (long)idx]];
}

#pragma mark - weather

#define YAHOO_APP_ID	@"YPTRvJjV34GJKXl3pY2LuRNpwY4w2Rv.GpYI9vbPWz_Yk0hgFZUrDIeibzpbg__AKg--"
#define kA3YahooWeatherXMLKeyConditionTag   @"yweather:condition"
#define kA3YahooWeatherXMLKeyForecastTag	@"yweather:forecast"
#define kA3YahooWeatherXMLKeyAtmosphere     @"yweather:atmosphere"
#define kA3YahooWeatherXMLKeyTemp           @"temp"
#define kA3YahooWeatherXMLKeyText           @"text"
#define kA3YahooWeatherXMLKeyCondition      @"code"
#define	kA3YahooWeatherXMLKeyLow			@"low"
#define kA3YahooWeatherXMLKeyHigh			@"high"


- (void)getWeatherInfoWithWOEID:(NSString *)WOEID {
	NSString *weatherUnit = [[A3UserDefaults standardUserDefaults] clockUsesFahrenheit] ? @"f" : @"c";
	NSURL *weatherURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%@&u=%@&language=", WOEID, weatherUnit]];

	NSURLRequest *weatherRequest = [NSURLRequest requestWithURL:weatherURL];
	AFHTTPRequestOperation *weatherOperation = [[AFHTTPRequestOperation alloc] initWithRequest:weatherRequest];
    
	[weatherOperation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *response) {
		NSXMLParser *XMLParser = [[NSXMLParser alloc] initWithData:response];
		XMLParser.delegate = self;

		_weatherForecast = nil;
		_weatherCurrentCondition = nil;

		self.clockInfo.currentWeather = [A3Weather new];
		if ([XMLParser parse]) {
			if (!_weatherForecast || !_weatherCurrentCondition || !self.clockInfo.weatherAtmosphere) {
				self.clockInfo = nil;
				FNLOG(@"Failed to load weather with :%@", [_addressCandidates lastObject]);
				[_addressCandidates removeLastObject];
				[self getWOEIDWithCandidates];
				return;
			}

//#define LOG_WEATHER	0
#ifdef LOG_WEATHER
			NSMutableString *log = [NSMutableString new];
			[log appendString:[NSString stringWithFormat:@"%@\n", _weatherForecast]];
			[log appendString:[NSString stringWithFormat:@"%@\n", _weatherCurrentCondition]];
			[log appendString:[NSString stringWithFormat:@"%@\n", self.clockInfo.weatherAtmosphere]];
			FNLOG(@"%@", log);
#endif

			self.clockInfo.currentWeather.unit = [[A3UserDefaults standardUserDefaults] clockUsesFahrenheit] ? SCWeatherUnitFahrenheit : SCWeatherUnitCelsius;
			self.clockInfo.currentWeather.representation = [self.weatherCurrentCondition objectForKey:kA3YahooWeatherXMLKeyText];
			self.clockInfo.currentWeather.currentTemperature = [[self.weatherCurrentCondition objectForKey:kA3YahooWeatherXMLKeyTemp] intValue];
			self.clockInfo.currentWeather.condition = (A3WeatherCondition) [[self.weatherCurrentCondition objectForKey:kA3YahooWeatherXMLKeyCondition] intValue];

			if ([_weatherForecast count]) {
				NSDictionary *todayForecast = [self.weatherForecast objectAtIndex:0];
				self.clockInfo.currentWeather.highTemperature = [[todayForecast objectForKey:kA3YahooWeatherXMLKeyHigh] intValue];
				self.clockInfo.currentWeather.lowTemperature = [[todayForecast objectForKey:kA3YahooWeatherXMLKeyLow] intValue];
			}

			NSAssert(!(self.clockInfo.currentWeather.currentTemperature == 0 &&
					self.clockInfo.currentWeather.lowTemperature == 0 &&
					self.clockInfo.currentWeather.highTemperature == 0), @"Weather current,low,high must not be all ZERO");

			if ([_delegate respondsToSelector:@selector(refreshWeather:)]) {
				[_delegate refreshWeather:self.clockInfo];
			}
		}

		_weatherForecast = nil;
		_weatherCurrentCondition = nil;

		_addressCandidates = nil;
		_locationManager = nil;

		// TODO: 날씨 업데이트 시점 최종 조정 필요. 디버깅 위해서 10초로 설정
//		_weatherTimer = [NSTimer scheduledTimerWithTimeInterval:60 * 15 target:self selector:@selector(updateWeather) userInfo:nil repeats:NO];
		if (!_weatherTimer) {
			_weatherTimer = [NSTimer scheduledTimerWithTimeInterval:60 * 60 target:self selector:@selector(updateWeather) userInfo:nil repeats:NO];
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self.locationManager startUpdatingLocation];
	}];
	[weatherOperation start];
}

- (void)getWOEIDWithCandidates {
	if (![_addressCandidates count]) {
		[_locationManager startUpdatingLocation];
		return;
	}

	NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://where.yahooapis.com/v1/places.q(%@)?appid=%@&format=json", [_addressCandidates lastObject], YAHOO_APP_ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

	NSURLRequest *request = [NSURLRequest requestWithURL:url];

	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
		NSString *WOEID = [[[[[JSON objectForKey:@"places"] objectForKey:@"place"] objectAtIndex:0] objectForKey:@"locality1 attrs"] objectForKey:@"woeid"];
		if (WOEID) {
			[self getWeatherInfoWithWOEID:WOEID];
		} else {
			[_addressCandidates removeLastObject];
			[self getWOEIDWithCandidates];
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[_addressCandidates removeLastObject];
		[self getWOEIDWithCandidates];
	}];

	[operation start];

	return;
}

- (void)updateWeather {
	_weatherTimer = nil;

	if ([[A3AppDelegate instance].reachability isReachable]) {
		[self.locationManager startUpdatingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	[manager stopMonitoringSignificantLocationChanges];

	CLGeocoder *geoCoder = [[CLGeocoder alloc] init];

#ifdef  ALERT_LOCATION
		CLLocation *location = locations[0];
		NSString *log = [NSString stringWithFormat:@"latitude = %f, longitude = %f", location.coordinate.latitude, location.coordinate.longitude];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location" message:log delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
#endif

	[geoCoder reverseGeocodeLocation:locations[0] completionHandler:^(NSArray *placeMarks, NSError *error) {
		if (error) {
#ifdef        ALERT_LOCATION
			CLLocation *location = locations[0];
			NSString *log = [NSString stringWithFormat:@"%@\n%f, %f", error.localizedDescription, location.coordinate.latitude, location.coordinate.longitude];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location" message:log delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
#endif
			return;
		}
		for (CLPlacemark *placeMark in placeMarks) {

			NSMutableString *log = [NSMutableString new];

			[log appendString:[NSString stringWithFormat:@"Description:%@\n", [placeMarks description]]];
			[log appendString:[NSString stringWithFormat:@"addressDictionary:%@\n", placeMark.addressDictionary]];
			[log appendString:[NSString stringWithFormat:@"administrativeArea:%@\n", placeMark.administrativeArea]];
			[log appendString:[NSString stringWithFormat:@"areaOfInterest:%@\n", placeMark.areasOfInterest]];
			[log appendString:[NSString stringWithFormat:@"locality:%@\n", placeMark.locality]];
			[log appendString:[NSString stringWithFormat:@"name:%@\n", placeMark.name]];
			[log appendString:[NSString stringWithFormat:@"subLocality:%@\n", placeMark.subLocality]];

#ifdef  ALERT_LOCATION
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location" message:log delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
#endif

			if (!_addressCandidates) _addressCandidates = [NSMutableArray new];
			if ([placeMark.subLocality length]) [_addressCandidates addObject:placeMark.subLocality];
			if ([placeMark.administrativeArea length]) [_addressCandidates addObject:placeMark.administrativeArea];
			if ([placeMark.locality length]) [_addressCandidates addObject:placeMark.locality];
		}

		if ([_addressCandidates count]) {
			[self getWOEIDWithCandidates];
		} else {
			[manager startUpdatingLocation];
		}
	}];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if([elementName isEqualToString:kA3YahooWeatherXMLKeyConditionTag]) {
		_weatherCurrentCondition = [attributeDict copy];
	} else if ([elementName isEqualToString:kA3YahooWeatherXMLKeyForecastTag]) {
		if (!_weatherForecast) {
			_weatherForecast = [NSMutableArray new];
		}
		[_weatherForecast addObject:attributeDict];
	}
    else if([elementName isEqualToString:kA3YahooWeatherXMLKeyAtmosphere])
    {
        self.clockInfo.weatherAtmosphere = [attributeDict copy];
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
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld hours", @"stringsDict", nil), 1];
    }
    return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld minutes", @"stringsDict", nil), autoDimValue];
}

@end
