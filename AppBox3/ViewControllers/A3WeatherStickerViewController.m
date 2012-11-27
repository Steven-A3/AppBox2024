//
//  A3WeatherStickerViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/22/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "A3WeatherStickerViewController.h"
#import "A3Weather.h"
#import "AFJSONRequestOperation.h"
#import "common.h"

@interface A3WeatherStickerViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *weatherCurrentConditionImageView;
@property (nonatomic, strong) IBOutlet UILabel *currentTemperatureLabel;
@property (nonatomic, strong) IBOutlet UILabel *todayHighLabel;
@property (nonatomic, strong) IBOutlet UILabel *todayLowLabel;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) A3Weather *currentWeather;
@property (nonatomic, strong) NSDictionary *weatherCurrentCondition;
@property (nonatomic, strong) NSMutableArray *weatherForecast;

@end

@implementation A3WeatherStickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self.view setHidden:YES];
	[self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CLLocationManagerDelegate

- (CLLocationManager *)locationManager {
	if (nil == _locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
		[_locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
		[_locationManager setDelegate:self];
	}
	return _locationManager;
}

#define YAHOO_APP_ID	@"YPTRvJjV34GJKXl3pY2LuRNpwY4w2Rv.GpYI9vbPWz_Yk0hgFZUrDIeibzpbg__AKg--"
#define kA3YahooWeatherXMLKeyConditionTag   @"yweather:condition"
#define kA3YahooWeatherXMLKeyForecastTag	@"yweather:forecast"
#define kA3YahooWeatherXMLKeyTemp           @"temp"
#define kA3YahooWeatherXMLKeyText           @"text"
#define kA3YahooWeatherXMLKeyCondition      @"code"
#define	kA3YahooWeatherXMLKeyLow			@"low"
#define kA3YahooWeatherXMLKeyHigh			@"high"

- (A3Weather *)currentWeather {
	if (nil == _currentWeather) {
		_currentWeather = [[A3Weather alloc] init];
	}
	return _currentWeather;
}

- (NSMutableArray *)weatherForecast {
	if (nil == _weatherForecast) {
		_weatherForecast = [[NSMutableArray alloc] initWithCapacity:2];
	}
	return _weatherForecast;
}

- (void)getWeatherInfoWithWOEID {
	NSURL *weatherURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%@&u=c", self.currentWeather.WOEID]];

	NSURLRequest *weatherRequest = [NSURLRequest requestWithURL:weatherURL];
	AFHTTPRequestOperation *weatherOperation = [[AFHTTPRequestOperation alloc] initWithRequest:weatherRequest];

	[weatherOperation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *response) {
		NSXMLParser *XMLParser = [[NSXMLParser alloc] initWithData:response];
		XMLParser.delegate = self;

//		FNLOG(@"%@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);

		if ([XMLParser parse]) {
			self.currentWeather.description = [self.weatherCurrentCondition objectForKey:kA3YahooWeatherXMLKeyText];
			self.currentWeather.currentTemperature = [[self.weatherCurrentCondition objectForKey:kA3YahooWeatherXMLKeyTemp] intValue];
			self.currentWeather.condition = [[self.weatherCurrentCondition objectForKey:kA3YahooWeatherXMLKeyCondition] intValue];

			if ([self.weatherForecast count]) {
				NSDictionary *todayForecast = [self.weatherForecast objectAtIndex:0];
				self.currentWeather.highTemperature = [[todayForecast objectForKey:kA3YahooWeatherXMLKeyHigh] intValue];
				self.currentWeather.lowTemperature = [[todayForecast objectForKey:kA3YahooWeatherXMLKeyLow] intValue];
			}
			self.currentTemperatureLabel.text = [NSString stringWithFormat:@"%d°", self.currentWeather.currentTemperature];
			self.todayHighLabel.text = [NSString stringWithFormat:@"H:%d°", self.currentWeather.highTemperature];
			self.todayLowLabel.text = [NSString stringWithFormat:@"L:%d°", self.currentWeather.lowTemperature];

			[self.view setHidden:NO];
//			FNLOG(@"Weather: %@", self.currentWeather.description);
		}

	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		FNLOG(@"%d, %@", error.code, [error localizedDescription]);
	}];
	[weatherOperation start];
}

- (void)getWOEIDWithCityName:(NSString *)theCityName {
	NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://where.yahooapis.com/v1/places.q(%@)?appid=%@&format=json", theCityName, YAHOO_APP_ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];

	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		[self.locationManager stopUpdatingLocation];
//		FNLOG(@"JSON Result: %@", JSON);
		self.currentWeather.WOEID = [ [ [ [ [ JSON objectForKey:@"places" ] objectForKey:@"place"] objectAtIndex:0] objectForKey:@"locality1 attrs"] objectForKey:@"woeid"];

		[self getWeatherInfoWithWOEID];
	} failure:nil];

	[operation start];

	return;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
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
			if (self.currentWeather.WOEID) {
				[self getWeatherInfoWithWOEID];
			}
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
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
}

@end
