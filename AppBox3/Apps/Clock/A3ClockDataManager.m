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
#import "NSUserDefaults+A3Defaults.h"
#import "AFHTTPRequestOperation.h"
#import "A3UserDefaults.h"

@interface A3ClockDataManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) A3Weather *currentWeather;
@property (nonatomic, strong) NSDictionary *weatherCurrentCondition;
@property (nonatomic, strong) NSMutableArray *weatherForecast;
@property (nonatomic, strong) NSTimer *timer;

@end


@implementation A3ClockDataManager {
	BOOL _refreshWholeClock;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.locationManager = [[CLLocationManager alloc] init];
		[self.locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
		[self.locationManager setDelegate:self];
        [self.locationManager startUpdatingLocation];
    }
    
    return self;
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
	FNLOG(@"%@", waveCirclesArray);
	[[NSUserDefaults standardUserDefaults] setObject:waveCirclesArray forKey:A3ClockWaveCircleLayout];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableArray *)waveCirclesArray {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
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
	[_timer invalidate];

	_refreshWholeClock = YES;
	_timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(onTimerDateTimeTick) userInfo:nil repeats:YES];
	[_timer fire];
}

- (void)stopTimer {
	[_timer invalidate];
	_timer = nil;
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
    NSDate *currentTime = [NSDate date];
    
    self.clockInfo.date = currentTime;
	_clockInfo.dateComponents = [self.clockInfo.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:currentTime];
	if (_clockInfo.dateComponents.second == 0) _refreshWholeClock = YES;

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

	if([[NSUserDefaults standardUserDefaults] clockUse24hourClock])
		[formatter setDateFormat:@"HH"];
	else
		[formatter setDateFormat:@"hh"];

	self.clockInfo.strTimeHour = [formatter stringFromDate:currentTime];

	[formatter setDateFormat:@"mm"];
	_clockInfo.strTimeMinute = [formatter stringFromDate:currentTime];

	[formatter setDateFormat:@"ss"];
	_clockInfo.strTimeSecond = [formatter stringFromDate:currentTime];

	[formatter setDateFormat:@"a"];
	if(![[NSUserDefaults standardUserDefaults] clockUse24hourClock])
		_clockInfo.strTimeAMPM = [formatter stringFromDate:currentTime];
	else
		_clockInfo.strTimeAMPM = @"";

	[formatter setDateFormat:@"dd"];
	_clockInfo.strDateDay = [formatter stringFromDate:currentTime];

	NSRange days = [self.clockInfo.calendar rangeOfUnit:NSDayCalendarUnit
									   inUnit:NSMonthCalendarUnit
									  forDate:currentTime];
	_clockInfo.strDateMaxDay = [NSString stringWithFormat:@"%lu", (unsigned long)days.length];

	[formatter setDateFormat:@"MMMM"];
	_clockInfo.strDateMonth = [formatter stringFromDate:currentTime];

	[formatter setDateFormat:@"MMM"];
	_clockInfo.strDateMonthShort = [formatter stringFromDate:currentTime];

	[formatter setDateFormat:@"EEEE"];
	_clockInfo.strWeek = [formatter stringFromDate:currentTime];

	[formatter setDateFormat:@"EEE"];
	_clockInfo.strWeekShort = [formatter stringFromDate:currentTime];

	_clockInfo.currentWeather = self.currentWeather;
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
        arrColor = @[[self colorWidth255RGB:253 g:158 b:26],
                     [self colorWidth255RGB:250 g:207 b:37],
                     [self colorWidth255RGB:164 g:222 b:55],
                     [self colorWidth255RGB:76 g:217 b:76],
                     [self colorWidth255RGB:32 g:214 b:120],
                     [self colorWidth255RGB:64 g:224 b:208],
                     [self colorWidth255RGB:90 g:200 b:250],
                     [self colorWidth255RGB:63 g:156 b:250],
                     [self colorWidth255RGB:107 g:105 b:223],
                     [self colorWidth255RGB:204 g:115 b:225],
                     [self colorWidth255RGB:246 g:104 b:202],
                     [self colorWidth255RGB:198 g:156 b:109],
                     [self colorWidth255RGB:23 g:23 b:24],
                     [self colorWidth255RGB:255 g:255 b:255]];
    }
    
    return arrColor;
}

- (NSArray*)ledColors
{
    static NSArray* arrColor = nil;
    
    if(arrColor == nil)
    {
        arrColor = @[[self colorWidth255RGB:253 g:158 b:26],
                     [self colorWidth255RGB:250 g:207 b:37],
                     [self colorWidth255RGB:164 g:222 b:55],
                     [self colorWidth255RGB:76 g:217 b:76],
                     [self colorWidth255RGB:32 g:214 b:120],
                     [self colorWidth255RGB:64 g:224 b:208],
                     [self colorWidth255RGB:90 g:200 b:250],
                     [self colorWidth255RGB:63 g:156 b:250],
                     [self colorWidth255RGB:107 g:105 b:223],
                     [self colorWidth255RGB:204 g:115 b:225],
                     [self colorWidth255RGB:246 g:104 b:202],
                     [self colorWidth255RGB:198 g:156 b:109],
                     [self colorWidth255RGB:255 g:255 b:255]];
    }
    
    return arrColor;
}

- (UIImage*)imageForWeatherCondition:(A3WeatherCondition)aCon
{
    int nRst = 0;

    switch (aCon) {
        case SCWeatherConditionTornado: nRst = 21; break;
        case SCWeatherConditionThunderstorms: nRst = 1; break;
        case SCWeatherConditionMixedRaindAndSnow: nRst = 2; break;
        case SCWeatherConditionFreezingRain: nRst = 2; break;
        case SCWeatherConditionFexxingDrizzle: nRst = 4; break;
        case SCWeatherConditionDrizzle: nRst = 4; break;
        case SCWeatherConditionShowers: nRst = 5; break;
        case SCWeatherConditionShowers2: nRst = 5; break;
        case SCWeatherConditionScatteredShowers: nRst = 5; break;
        case SCWeatherConditionMixedSnowAndSleet: nRst = 6; break;
        case SCWeatherConditionSnowFlurries: nRst = 6; break;
        case SCWeatherConditionLightSnowShowers: nRst = 6; break;
        case SCWeatherConditionSnow: nRst = 6; break;
        case SCWeatherConditionCold: nRst = 6; break;
        case SCWeatherConditionScatteredSnowShowers: nRst = 6; break;
        case SCWeatherConditionSnowShowers: nRst = 6; break;
        case SCWeatherConditionBlowingSnow: nRst = 7; break;
        case SCWeatherConditionFoggy: nRst = 8; break;
        case SCWeatherConditionHaze: nRst = 9; break;
        case SCWeatherConditionSmoky: nRst = 10; break;
        case SCWeatherConditionBlustery: nRst = 11; break;
        case SCWeatherConditionWindy: nRst = 11; break;
        case SCWeatherConditionCloudy: nRst = 12; break;
        case SCWeatherConditionPartlyCloudy: nRst = 12; break;
        case SCWeatherConditionMostlyCloudyNight: nRst = 13; break;
        case SCWeatherConditionClearNight: nRst = 13; break;
        case SCWeatherConditionMostlyCloudyDay: nRst = 14; break;
        case SCWeatherConditionSunny: nRst = 14; break;
        case SCWeatherConditionHot: nRst = 14; break;
        case SCWeatherConditionPartlyCloudyNight: nRst = 15; break;
        case SCWeatherConditionPartlyCloudyDay: nRst = 16; break;
        case SCWeatherConditionFairNight: nRst = 13; break;
        case SCWeatherConditionFairDay: nRst = 14; break;
        case SCWeatherConditionIsolatedThunderstorms: nRst = 1; break;
        case SCWeatherConditionScatteredThunderstorms: nRst = 1; break;
        case SCWeatherConditionScatteredThunderstorms2: nRst = 1; break;
        case SCWeatherConditionHeavySnow: nRst = 2; break;
        case SCWeatherConditionHeavySnow2: nRst = 2; break;
        case SCWeatherConditionTropicalStrom: nRst = 22; break;
        case SCWeatherConditionHurricane: nRst = 23; break;
        case SCWeatherConditionSevereThunderstroms: nRst = 1; break;
        case SCWeatherConditionMixedRainAndSleet: nRst = 2; break;
        case SCWeatherConditionHail: nRst = 26; break;
        case SCWeatherConditionSleet: nRst = 2; break;
        case SCWeatherConditionDust: nRst = 28; break;
        case SCWeatherConditionMixedRainAndHail: nRst = 29; break;
        case SCWeatherConditionThundershowers: nRst = 30; break;
        case SCWeatherConditionIsolatedThundershowers: nRst = 30; break;
        default:
            nRst = -1;
            break;
    }
    
    if(nRst == -1)
        return [UIImage imageNamed:nil];
    else
        return [UIImage imageNamed:[NSString stringWithFormat:@"weather_%02d", nRst]];
}

#pragma mark - weather stuff

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

	NSURL *weatherURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%@&u=c", WOEID]];
    
	NSURLRequest *weatherRequest = [NSURLRequest requestWithURL:weatherURL];
	AFHTTPRequestOperation *weatherOperation = [[AFHTTPRequestOperation alloc] initWithRequest:weatherRequest];
    
	[weatherOperation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *response) {
        response = operation.responseData;
        
        FNLOG(@"%@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
		NSXMLParser *XMLParser = [[NSXMLParser alloc] initWithData:response];
		XMLParser.delegate = (id)self;

		self.weatherForecast = [NSMutableArray new];

		if ([XMLParser parse]) {
			self.currentWeather = [A3Weather new];
			self.currentWeather.description = [self.weatherCurrentCondition objectForKey:kA3YahooWeatherXMLKeyText];
			self.currentWeather.currentTemperature = [[self.weatherCurrentCondition objectForKey:kA3YahooWeatherXMLKeyTemp] intValue];
			self.currentWeather.condition = (A3WeatherCondition) [[self.weatherCurrentCondition objectForKey:kA3YahooWeatherXMLKeyCondition] intValue];

			if ([self.weatherForecast count]) {
				NSDictionary *todayForecast = [self.weatherForecast objectAtIndex:0];
				self.currentWeather.highTemperature = [[todayForecast objectForKey:kA3YahooWeatherXMLKeyHigh] intValue];
				self.currentWeather.lowTemperature = [[todayForecast objectForKey:kA3YahooWeatherXMLKeyLow] intValue];
			}

			self.clockInfo.currentWeather = self.currentWeather;

			if ([_delegate respondsToSelector:@selector(refreshWeather:)]) {
				[_delegate refreshWeather:self.clockInfo];
			}

			FNLOG(@"%@,%d,%d,%d", self.currentWeather.description, self.currentWeather.currentTemperature, self.currentWeather.highTemperature, self.currentWeather.lowTemperature);
		}

		FNLOG(@"self.weatherCurrentCondition:\r\n%@", self.weatherCurrentCondition);
		FNLOG(@"self.weatherForecast:\r\n%@", self.weatherForecast);
		FNLOG(@"self.weatherAtmosphere:\r\n%@", self.weatherAtmosphere);

	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
	[weatherOperation start];
}

- (void)getWOEIDWithCityName:(NSString *)theCityName {      // 문제되는곳
	NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://where.yahooapis.com/v1/places.q(%@)?appid=%@&format=json", theCityName, YAHOO_APP_ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

	NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
		NSString *WOEID = [ [ [ [ [ JSON objectForKey:@"places" ] objectForKey:@"place"] objectAtIndex:0] objectForKey:@"locality1 attrs"] objectForKey:@"woeid"];
		[self getWeatherInfoWithWOEID:WOEID ];
	} failure:NULL];
	
	[operation start];
    
	return;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	[manager stopUpdatingLocation];

	self.currentWeather = nil;
	self.weatherCurrentCondition = nil;
	self.weatherForecast = nil;
    
	// Update weather information
	CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
	[geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placeMarks, NSError *error) {
		NSString *theCityName = nil;
		for (CLPlacemark *placeMark in placeMarks) {
			/*
             FNLOG(@"%@", [placeMarks description]);
             FNLOG(@"address Dictionary: %@", placeMark.addressDictionary);
             FNLOG(@"Administrative Area: %@", placeMark.administrativeArea);
             FNLOG(@"areas of Interest: %@", placeMark.areasOfInterest);
             FNLOG(@"locality: %@", placeMark.locality);
             FNLOG(@"name: %@", placeMark.name);
             FNLOG(@"subLocality: %@", placeMark.subLocality);
             */
            
			theCityName = placeMark.locality;
		}
        
		if (theCityName) {
			[self getWOEIDWithCityName:theCityName];
		}
	}];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if([elementName isEqualToString:kA3YahooWeatherXMLKeyConditionTag]) {
		self.weatherCurrentCondition = attributeDict;
	} else if ([elementName isEqualToString:kA3YahooWeatherXMLKeyForecastTag]) {
		[self.weatherForecast addObject:attributeDict];
	}
    else if([elementName isEqualToString:kA3YahooWeatherXMLKeyAtmosphere])
    {
        self.weatherAtmosphere = attributeDict;
    }
}

//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
//
//}

@end
