//
//  A3ClockFlipViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockInfo.h"
#import "A3ClockDataManager.h"
#import "A3ClockFlipViewController.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3UIDevice.h"

#define kColorClockFlipLabel [UIColor colorWithRed:142.f/255.f green:142.f/255.f blue:147.f/255.f alpha:1.f]

@interface A3ClockFlipViewController ()
@property (nonatomic, strong) A3ClockFoldingView * foldHour;
@property (nonatomic, strong) A3ClockFoldingView * foldMinute;
@property (nonatomic, strong) A3ClockFoldingView * foldSecond;
@property (nonatomic, strong) UILabel* lbAMPM;

@property (nonatomic, strong) 	UILabel* lbWeekMonthDay;
@property (nonatomic, strong) 	UILabel* lbWeather;
@property (nonatomic, strong) 	UILabel* lbTemperature;

@property (nonatomic, strong) 	UILabel* lbWeatherRainRst;
@property (nonatomic, strong) 	UILabel* lbWeatherHumidityRst;
@property (nonatomic, strong) 	UILabel* lbWeatherHighRst;
@property (nonatomic, strong) 	UILabel* lbWeatherLowRst;

@property (nonatomic, strong) 	UILabel* lbWeatherRain;
@property (nonatomic, strong) 	UILabel* lbWeatherHumidity;
@property (nonatomic, strong) 	UILabel* lbWeatherHigh;
@property (nonatomic, strong) 	UILabel* lbWeatherLow;

@end

@implementation A3ClockFlipViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	_foldHour = [[A3ClockFoldingView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
	[self.view addSubview:_foldHour];
	[_foldHour setCenter:self.view.center];

	_foldMinute = [[A3ClockFoldingView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
	[self.view addSubview:_foldMinute];
	[_foldMinute setCenter:self.view.center];

	_foldSecond = [[A3ClockFoldingView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
	[self.view addSubview:_foldSecond];
	[_foldSecond setCenter:self.view.center];

	_lbAMPM = [[UILabel alloc] init];
	_lbAMPM.text = @"다다다";
	_lbAMPM.textAlignment = NSTextAlignmentLeft;
	[_lbAMPM setFont:[UIFont fontWithName:kClockFontNameRegular size:14]];
	[_lbAMPM setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbAMPM];


	_lbWeekMonthDay = [[UILabel alloc] init];
	[_lbWeekMonthDay setFont:[UIFont fontWithName:kClockFontNameRegular size:18]];
	[_lbWeekMonthDay setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbWeekMonthDay];
	[_lbWeekMonthDay makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX).with.offset(0);
		make.top.equalTo(self.view.top).with.offset(36);
	}];

	_lbWeather = [[UILabel alloc] init];

	[_lbWeather setFont:[UIFont fontWithName:kClockFontNameRegular size:16]];
	[_lbWeather setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbWeather];
	[_lbWeather makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX).with.offset(0);
		make.top.equalTo(self.view.top).with.offset(64);
	}];

	_lbTemperature = [[UILabel alloc] init];
	[_lbTemperature setFont:[UIFont fontWithName:kClockFontNameUltraLight size:64]];
	[_lbTemperature setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbTemperature];
	[_lbTemperature makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX).with.offset(0);
		make.top.equalTo(self.view.top).with.offset(86);
	}];


	_lbWeatherRainRst = [[UILabel alloc] init];
	_lbWeatherRainRst.textAlignment = NSTextAlignmentLeft;
	[_lbWeatherRainRst setFont:[UIFont fontWithName:kClockFontNameRegular size:12]];
	[_lbWeatherRainRst setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbWeatherRainRst];
	[_lbWeatherRainRst makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(16);
		make.bottom.equalTo(self.view.bottom).with.offset(-66);
	}];

	_lbWeatherHumidityRst = [[UILabel alloc] init];
	_lbWeatherHumidityRst.textAlignment = NSTextAlignmentLeft;
	[_lbWeatherHumidityRst setFont:[UIFont fontWithName:kClockFontNameRegular size:12]];
	[_lbWeatherHumidityRst setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbWeatherHumidityRst];
	[_lbWeatherHumidityRst makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(16);
		make.bottom.equalTo(self.view.bottom).with.offset(-48);
	}];

	_lbWeatherHighRst= [[UILabel alloc] init];
	_lbWeatherHighRst.textAlignment = NSTextAlignmentLeft;
	[_lbWeatherHighRst setFont:[UIFont fontWithName:kClockFontNameRegular size:12]];
	[_lbWeatherHighRst setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbWeatherHighRst];
	[_lbWeatherHighRst makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(16);
		make.bottom.equalTo(self.view.bottom).with.offset(-32);
	}];

	_lbWeatherLowRst= [[UILabel alloc] init];
	_lbWeatherLowRst.textAlignment = NSTextAlignmentLeft;
	[_lbWeatherLowRst setFont:[UIFont fontWithName:kClockFontNameRegular size:12]];
	[_lbWeatherLowRst setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbWeatherLowRst];
	[_lbWeatherLowRst makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(16);
		make.bottom.equalTo(self.view.bottom).with.offset(-14);
	}];

	_lbWeatherRain= [[UILabel alloc] init];
	_lbWeatherRain.textAlignment = NSTextAlignmentLeft;
	[_lbWeatherRain setFont:[UIFont fontWithName:kClockFontNameRegular size:12]];
	[_lbWeatherRain setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbWeatherRain];
	[_lbWeatherRain makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(52);
		make.bottom.equalTo(self.view.bottom).with.offset(-66);
	}];

	_lbWeatherHumidity= [[UILabel alloc] init];
	_lbWeatherHumidity.textAlignment = NSTextAlignmentLeft;
	[_lbWeatherHumidity setFont:[UIFont fontWithName:kClockFontNameRegular size:12]];
	[_lbWeatherHumidity setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbWeatherHumidity];
	[_lbWeatherHumidity makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(52);
		make.bottom.equalTo(self.view.bottom).with.offset(-48);
	}];

	_lbWeatherHigh= [[UILabel alloc] init];
	_lbWeatherHigh.textAlignment = NSTextAlignmentLeft;
	[_lbWeatherHigh setFont:[UIFont fontWithName:kClockFontNameRegular size:12]];
	[_lbWeatherHigh setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbWeatherHigh];
	[_lbWeatherHigh makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(52);
		make.bottom.equalTo(self.view.bottom).with.offset(-32);
	}];

	_lbWeatherLow = [[UILabel alloc] init];
	_lbWeatherLow.textAlignment = NSTextAlignmentLeft;
	[_lbWeatherLow setFont:[UIFont fontWithName:kClockFontNameRegular size:12]];
	[_lbWeatherLow setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbWeatherLow];
	[_lbWeatherLow makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(52);
		make.bottom.equalTo(self.view.bottom).with.offset(-14);
	}];

	[self setupSubviews];
}

#pragma mark public
- (void)setupSubviews {
    if([[NSUserDefaults standardUserDefaults] clockShowWeather])
    {
        _lbWeather.hidden = NO;
        _lbTemperature.hidden = NO;
        
        _lbWeatherRainRst.hidden = NO;
        _lbWeatherHumidityRst.hidden = NO;
        _lbWeatherHighRst.hidden = NO;
        _lbWeatherLowRst.hidden = NO;
        _lbWeatherRain.hidden = NO;
        _lbWeatherHumidity.hidden = NO;
        _lbWeatherHigh.hidden = NO;
        _lbWeatherLow.hidden = NO;
    }
    else
    {
        _lbWeather.hidden = YES;
        _lbTemperature.hidden = YES;
        
        _lbWeatherRainRst.hidden = YES;
        _lbWeatherHumidityRst.hidden = YES;
        _lbWeatherHighRst.hidden = YES;
        _lbWeatherLowRst.hidden = YES;
        _lbWeatherRain.hidden = YES;
        _lbWeatherHumidity.hidden = YES;
        _lbWeatherHigh.hidden = YES;
        _lbWeatherLow.hidden = YES;
    }
    
    
//    CGRect rctPre = self.frame;
    [_foldHour removeConstraints:_foldHour.constraints];
    [_foldMinute removeConstraints:_foldMinute.constraints];
    [_foldSecond removeConstraints:_foldSecond.constraints];
    
    [_foldHour removeFromSuperview];
    [_foldMinute removeFromSuperview];
    [_foldSecond removeFromSuperview];
    [self.view addSubview:_foldHour];
    [self.view addSubview:_foldMinute];
    [self.view addSubview:_foldSecond];
    
    if(IS_IPHONE)
    {
        if([[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds])
        {
            [_foldHour setFrame:CGRectMake(0, 0, 90, 90)];
            [_foldMinute setFrame:CGRectMake(0, 0, 90, 90)];
            [_foldHour setFrame:CGRectMake(0, 0, 90, 90)];
            
            [_foldMinute makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view.centerX).with.offset(0);
                make.centerY.equalTo(self.view.centerY).with.offset(0);
                make.width.equalTo(@90);
                make.height.equalTo(@90);
            }];
            
            [_foldHour makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_foldMinute.centerY).with.offset(0);
                make.right.equalTo(_foldMinute.left).with.offset(-10);
                make.width.equalTo(@90);
                make.height.equalTo(@90);
            }];
            
            [_foldSecond makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_foldMinute.centerY).with.offset(0);
                make.left.equalTo(_foldMinute.right).with.offset(10);
                make.width.equalTo(@90);
                make.height.equalTo(@90);
            }];
        }
        else
        {// 크기가 안변한다.... 변한다.
            [_foldHour setFrame:CGRectMake(0, 0, 140, 140)];
            [_foldMinute setFrame:CGRectMake(0, 0, 140, 140)];
            
            [_foldHour makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view.centerY).with.offset(0);
                make.left.equalTo(self.view.left).with.offset(16);
                make.width.equalTo(@140);
                make.height.equalTo(@140);
            }];
            
            [_foldMinute makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view.centerY).with.offset(0);
                make.right.equalTo(self.view.right).with.offset(-16);
                make.width.equalTo(@140);
                make.height.equalTo(@140);
            }];
        }
        
        [_lbAMPM makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_foldHour.left).with.offset(10);
            make.bottom.equalTo(_foldHour.top).with.offset(-8);
        }];
    }
    
    if([[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds])
    {
        [_foldSecond setHidden:NO];
    }
    else
    {
        [_foldSecond setHidden:YES];
    }
}

- (void)refreshSecond:(A3ClockInfo *)clockInfo {

}

- (void)refreshWholeClock:(A3ClockInfo *)clockInfo {
	[_foldHour foldingWithText:clockInfo.hour];
	[_foldMinute foldingWithText:clockInfo.minute];
	[_foldSecond foldingWithText:clockInfo.second];

	if([[NSUserDefaults standardUserDefaults] clockShowTheDayOfTheWeek] && [[NSUserDefaults standardUserDefaults] clockShowDate])
	{
		_lbWeekMonthDay.text = [NSString stringWithFormat:@"%@, %@ %@", clockInfo.weekday, clockInfo.month, clockInfo.day];
	}
	else if([[NSUserDefaults standardUserDefaults] clockShowTheDayOfTheWeek])
	{

		_lbWeekMonthDay.text = [NSString stringWithFormat:@"%@", clockInfo.weekday];
	}
	else if([[NSUserDefaults standardUserDefaults] clockShowDate])
	{
		_lbWeekMonthDay.text = [NSString stringWithFormat:@"%@ %@", clockInfo.month, clockInfo.day];
	}
	else
		_lbWeekMonthDay.text = @"";

	_lbAMPM.text = clockInfo.AMPM;
	_lbWeather.text = clockInfo.currentWeather.description;
	_lbTemperature.text = [NSString stringWithFormat:@"%dº", clockInfo.currentWeather.currentTemperature];


	_lbWeatherRainRst.text = @"12%";
	_lbWeatherRain.text = @"Chance of rain";

	_lbWeatherHumidityRst.text = [self.clockDataManager.weatherAtmosphere objectForKey:@"humidity"];
	_lbWeatherHumidity.text = @"Humidity";

	_lbWeatherHighRst.text = [NSString stringWithFormat:@"%d", clockInfo.currentWeather.highTemperature];
	_lbWeatherHigh.text = @"High";

	_lbWeatherLowRst.text = [NSString stringWithFormat:@"%d", clockInfo.currentWeather.lowTemperature];
	_lbWeatherLow.text = @"Low";
}


@end
