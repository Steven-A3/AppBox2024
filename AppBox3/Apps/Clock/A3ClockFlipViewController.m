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
#import "NSDateFormatter+A3Addition.h"

#define kColorClockFlipLabel [UIColor colorWithRed:142.f/255.f green:142.f/255.f blue:147.f/255.f alpha:1.f]

@interface A3ClockFlipViewController ()

@property (nonatomic, strong) A3SBTickerView *hourView;
@property (nonatomic, strong) A3SBTickerView *minuteView;
@property (nonatomic, strong) A3SBTickerView *secondView;

@property (nonatomic, strong) UILabel* lbAMPM;

@property (nonatomic, strong) UILabel*weekdayMonthDay;
@property (nonatomic, strong) UILabel*weatherCondition;
@property (nonatomic, strong) UILabel*temperature;

@property (nonatomic, strong) UILabel*weatherHumidity;
@property (nonatomic, strong) UILabel*weatherTemperatureHigh;
@property (nonatomic, strong) UILabel*weatherTemperatureLow;

@property (nonatomic, strong) UILabel*weatherHumidityTitle;
@property (nonatomic, strong) UILabel*weatherTemperatureHighTitle;
@property (nonatomic, strong) UILabel*weatherTemperatureLowTitle;

@property (nonatomic, strong) NSMutableArray *weatherConstraints;
@property (nonatomic, strong) MASConstraint *weekdayMonthDayBaseline;

@property (nonatomic, strong) NSMutableArray *timeViewConstraints;

@property (nonatomic, strong) UIView *centerLineView;
@property (nonatomic, strong) NSString *dateFormat;

@end

@implementation A3ClockFlipViewController {
	BOOL _iPADLayoutInitialized;
	BOOL _layoutInitialized;
}

- (instancetype)initWithClockDataManager:(A3ClockDataManager *)clockDataManager style:(A3ClockFlipViewStyle) style {
	self = [super initWithClockDataManager:clockDataManager];
	if (self) {
		[self setStyle:style];
		[clockDataManager.clockInfo.dateFormatter setDateStyle:NSDateFormatterFullStyle];
		_dateFormat = [clockDataManager.clockInfo.dateFormatter formatStringByRemovingYearComponent:clockDataManager.clockInfo.dateFormatter.dateFormat];
	}

	return self;
}

- (void)setStyle:(A3ClockFlipViewStyle)style {
	_style = style;
	if (style == A3ClockFlipViewStyleDark) {
		[self.view setBackgroundColor:[UIColor colorWithRed:23.f / 255.f green:23.f / 255.f blue:24.f / 255.f alpha:1.f]];
	} else {
		[self.view setBackgroundColor:[UIColor colorWithRed:239.f / 255.f green:239.f / 255.f blue:244.f / 255.f alpha:1.f]];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];

	_lbAMPM = [[UILabel alloc] init];
	_lbAMPM.textAlignment = NSTextAlignmentLeft;
	[_lbAMPM setFont:[UIFont systemFontOfSize:IS_IPHONE ? 14 : 18]];
	[_lbAMPM setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_lbAMPM];

	_weekdayMonthDay = [[UILabel alloc] init];
	[_weekdayMonthDay setFont:[UIFont systemFontOfSize:18]];
	[_weekdayMonthDay setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_weekdayMonthDay];
	[_weekdayMonthDay makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		_weekdayMonthDayBaseline = make.baseline.equalTo(self.view.top).with.offset(IS_IPHONE && IS_LANDSCAPE ? 27 : 50);
	}];

	_weatherCondition = [[UILabel alloc] init];
	[_weatherCondition setFont:[UIFont systemFontOfSize:16]];
	[_weatherCondition setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_weatherCondition];

	_temperature = [[UILabel alloc] init];
	[_temperature setFont:[UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:IS_IPHONE ? 64 : 88]];
	[_temperature setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_temperature];

	_weatherHumidity = [[UILabel alloc] init];
	_weatherHumidity.textAlignment = NSTextAlignmentLeft;
	[_weatherHumidity setFont:[UIFont systemFontOfSize:IS_IPHONE ? 12 : 15]];
	[_weatherHumidity setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_weatherHumidity];

	_weatherTemperatureHigh = [[UILabel alloc] init];
	_weatherTemperatureHigh.textAlignment = NSTextAlignmentLeft;
	[_weatherTemperatureHigh setFont:[UIFont systemFontOfSize:IS_IPHONE ? 12 : 15]];
	[_weatherTemperatureHigh setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_weatherTemperatureHigh];

	_weatherTemperatureLow = [[UILabel alloc] init];
	_weatherTemperatureLow.textAlignment = NSTextAlignmentLeft;
	[_weatherTemperatureLow setFont:[UIFont systemFontOfSize:IS_IPHONE ? 12 : 15]];
	[_weatherTemperatureLow setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_weatherTemperatureLow];

	_weatherHumidityTitle = [[UILabel alloc] init];
	_weatherHumidityTitle.text = @"Humidity";
	_weatherHumidityTitle.textAlignment = NSTextAlignmentLeft;
	[_weatherHumidityTitle setFont:[UIFont systemFontOfSize:IS_IPHONE ? 12 : 15]];
	[_weatherHumidityTitle setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_weatherHumidityTitle];

	_weatherTemperatureHighTitle = [[UILabel alloc] init];
	_weatherTemperatureHighTitle.text = @"High";
	_weatherTemperatureHighTitle.textAlignment = NSTextAlignmentLeft;
	[_weatherTemperatureHighTitle setFont:[UIFont systemFontOfSize:IS_IPHONE ? 12 : 15]];
	[_weatherTemperatureHighTitle setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_weatherTemperatureHighTitle];

	_weatherTemperatureLowTitle = [[UILabel alloc] init];
	_weatherTemperatureLowTitle.text = @"Low";
	_weatherTemperatureLowTitle.textAlignment = NSTextAlignmentLeft;
	[_weatherTemperatureLowTitle setFont:[UIFont systemFontOfSize:IS_IPHONE ? 12 : 15]];
	[_weatherTemperatureLowTitle setTextColor:kColorClockFlipLabel];
	[self.view addSubview:_weatherTemperatureLowTitle];

	_centerLineView = [UIView new];
	[self.view addSubview:_centerLineView];
	[_centerLineView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		make.centerY.equalTo(self.view.centerY);
		make.height.equalTo(IS_IPHONE ? @2 : @4);
	}];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (!_layoutInitialized) {
		_layoutInitialized = YES;
		[self layoutSubviews];
	}
}

- (void)layoutSubviews {

	_weekdayMonthDayBaseline.offset(IS_IPHONE && IS_LANDSCAPE ? 27 : 50);

	[self setWeatherHidden:![[NSUserDefaults standardUserDefaults] clockShowWeather] ];
	[self layoutWeather];

	if (!_timeViewConstraints) {
		_timeViewConstraints = [NSMutableArray new];
	} else {
		for (MASConstraint *constraint in _timeViewConstraints) {
			[constraint uninstall];
		}
		[_timeViewConstraints removeAllObjects];
	}

    [self.view addSubview:self.hourView];
    [self.view addSubview:self.minuteView];
	if ([[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds]) {
		[self.view addSubview:self.secondView];
	} else if (_secondView) {
		[_secondView removeFromSuperview];
		_secondView = nil;
	}

	CGFloat boxSize, interimSpace;
	BOOL showSeconds = [[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds];
	if (IS_IPHONE) {
		if (IS_PORTRAIT) {
			boxSize = showSeconds ? 90 : 140;
		} else {
			boxSize = showSeconds ? 140 : [self showWeather] ? 171 : 195;
		}
		interimSpace = 10;
	} else {
		if (IS_PORTRAIT) {
			boxSize = showSeconds ? 200 : 284;
			interimSpace = 20;
		} else {
			boxSize = showSeconds ? 284 : 360;
			interimSpace = showSeconds ? 20 : 30;
		}
	}

	if(showSeconds)
	{
		[_minuteView makeConstraints:^(MASConstraintMaker *make) {
			[_timeViewConstraints addObject:make.centerX.equalTo(self.view.centerX)];
			[_timeViewConstraints addObject:make.centerY.equalTo(self.view.centerY)];
			[_timeViewConstraints addObject:make.width.equalTo(@(boxSize))];
			[_timeViewConstraints addObject:make.height.equalTo(@(boxSize))];
		}];

		[_hourView makeConstraints:^(MASConstraintMaker *make) {
			[_timeViewConstraints addObject:make.centerY.equalTo(_minuteView.centerY)];
			[_timeViewConstraints addObject:make.right.equalTo(_minuteView.left).with.offset(-1 * interimSpace)];
			[_timeViewConstraints addObject:make.width.equalTo(@(boxSize))];
			[_timeViewConstraints addObject:make.height.equalTo(@(boxSize))];
		}];

		[_secondView makeConstraints:^(MASConstraintMaker *make) {
			[_timeViewConstraints addObject:make.centerY.equalTo(_minuteView.centerY)];
			[_timeViewConstraints addObject:make.left.equalTo(_minuteView.right).with.offset(interimSpace)];
			[_timeViewConstraints addObject:make.width.equalTo(@(boxSize))];
			[_timeViewConstraints addObject:make.height.equalTo(@(boxSize))];
		}];
		[self setTimeFont:_hourView isForSecond:NO];
		[self setTimeFont:_minuteView isForSecond:NO];
		[self setTimeFont:_secondView isForSecond:YES];
	}
	else
	{
		[_hourView makeConstraints:^(MASConstraintMaker *make) {
			[_timeViewConstraints addObject:make.centerY.equalTo(self.view.centerY)];
			[_timeViewConstraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(-1 * (boxSize/2 + interimSpace / 2))];
			[_timeViewConstraints addObject:make.width.equalTo(@(boxSize))];
			[_timeViewConstraints addObject:make.height.equalTo(@(boxSize))];
		}];

		[_minuteView makeConstraints:^(MASConstraintMaker *make) {
			[_timeViewConstraints addObject:make.centerY.equalTo(self.view.centerY)];
			[_timeViewConstraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(boxSize/2 + interimSpace / 2)];
			[_timeViewConstraints addObject:make.width.equalTo(@(boxSize))];
			[_timeViewConstraints addObject:make.height.equalTo(@(boxSize))];
		}];
		[self setTimeFont:_hourView isForSecond:NO];
		[self setTimeFont:_minuteView isForSecond:NO];
	}

	[_lbAMPM makeConstraints:^(MASConstraintMaker *make) {
		[_timeViewConstraints addObject:make.left.equalTo(_hourView.left).with.offset(10)];
		[_timeViewConstraints addObject:make.bottom.equalTo(_hourView.top).with.offset(-8)];
	}];

	[_lbAMPM setHidden:![[NSUserDefaults standardUserDefaults] clockShowAMPM]];

	_centerLineView.backgroundColor = self.view.backgroundColor;
	[self.view bringSubviewToFront:_centerLineView];
	[self.view layoutIfNeeded];
}

- (void)updateLayout {
	[self layoutSubviews];
	[self refreshWholeClock:self.clockDataManager.clockInfo animated:NO];
}

- (void)layoutWeather {
	BOOL isPortrait = IS_PORTRAIT;

	if (IS_IPHONE) {
		for (MASConstraint *constraint in _weatherConstraints) {
			[constraint uninstall];
		}
		[_weatherConstraints removeAllObjects];

		if (!_weatherConstraints) {
			_weatherConstraints = [NSMutableArray new];
		}

		CGFloat offsetValue = isPortrait ? 15 : 125;
		CGFloat offsetTitle = isPortrait ? 52 : 161;

		if (isPortrait) {
			[_weatherCondition makeConstraints:^(MASConstraintMaker *make) {
				[_weatherConstraints addObject:make.centerX.equalTo(self.view.centerX)];
				[_weatherConstraints addObject:make.baseline.equalTo(self.view.top).with.offset(76)];
			}];
			[_temperature makeConstraints:^(MASConstraintMaker *make) {
				[_weatherConstraints addObject:make.centerX.equalTo(self.view.centerX)];
				[_weatherConstraints addObject:make.baseline.equalTo(self.view.top).with.offset(132)];
			}];
		} else {
			[_weatherCondition makeConstraints:^(MASConstraintMaker *make) {
				[_weatherConstraints addObject:make.left.equalTo(self.view.left).with.offset(15)];
				[_weatherConstraints addObject:make.baseline.equalTo(self.view.bottom).with.offset(-67)];
			}];
			[_temperature makeConstraints:^(MASConstraintMaker *make) {
				[_weatherConstraints addObject:make.left.equalTo(self.view.left).with.offset(15)];
				[_weatherConstraints addObject:make.baseline.equalTo(self.view.bottom).with.offset(-11)];
			}];
		}

		[_weatherHumidity makeConstraints:^(MASConstraintMaker *make) {
			[_weatherConstraints addObject:make.left.equalTo(self.view.left).with.offset(offsetValue)];
			[_weatherConstraints addObject:make.baseline.equalTo(self.view.bottom).with.offset(isPortrait ? -50 : -45)];
		}];
		[_weatherHumidityTitle makeConstraints:^(MASConstraintMaker *make) {
			[_weatherConstraints addObject:make.left.equalTo(self.view.left).with.offset(offsetTitle)];
			[_weatherConstraints addObject:make.baseline.equalTo(self.view.bottom).with.offset(isPortrait ? -50 : -45)];
		}];
		[_weatherTemperatureHigh makeConstraints:^(MASConstraintMaker *make) {
			[_weatherConstraints addObject:make.left.equalTo(self.view.left).with.offset(offsetValue)];
			[_weatherConstraints addObject:make.baseline.equalTo(self.view.bottom).with.offset(isPortrait ? -32 : -28)];
		}];
		[_weatherTemperatureHighTitle makeConstraints:^(MASConstraintMaker *make) {
			[_weatherConstraints addObject:make.left.equalTo(self.view.left).with.offset(offsetTitle)];
			[_weatherConstraints addObject:make.baseline.equalTo(self.view.bottom).with.offset(isPortrait ? -32 : -28)];
		}];
		[_weatherTemperatureLow makeConstraints:^(MASConstraintMaker *make) {
			[_weatherConstraints addObject:make.left.equalTo(self.view.left).with.offset(offsetValue)];
			[_weatherConstraints addObject:make.baseline.equalTo(self.view.bottom).with.offset(isPortrait ? -14 : -11)];
		}];
		[_weatherTemperatureLowTitle makeConstraints:^(MASConstraintMaker *make) {
			[_weatherConstraints addObject:make.left.equalTo(self.view.left).with.offset(offsetTitle)];
			[_weatherConstraints addObject:make.baseline.equalTo(self.view.bottom).with.offset(isPortrait ? -14 : -11)];
		}];
	} else if (!_iPADLayoutInitialized) {
		_iPADLayoutInitialized = YES;

		CGFloat offsetValue = 28;
		CGFloat offsetTitle = 72;

		[_weatherCondition makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.view.centerX);
			make.baseline.equalTo(self.view.top).with.offset(76);
		}];
		[_temperature makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.view.centerX);
			make.baseline.equalTo(self.view.top).with.offset(151);
		}];

		[_weatherHumidity makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view.left).with.offset(offsetValue);
			make.baseline.equalTo(self.view.bottom).with.offset(-64);
		}];
		[_weatherHumidityTitle makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view.left).with.offset(offsetTitle);
			make.baseline.equalTo(self.view.bottom).with.offset(-64);
		}];
		[_weatherTemperatureHigh makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view.left).with.offset(offsetValue);
			make.baseline.equalTo(self.view.bottom).with.offset(-46);
		}];
		[_weatherTemperatureHighTitle makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view.left).with.offset(offsetTitle);
			make.baseline.equalTo(self.view.bottom).with.offset(-46);
		}];
		[_weatherTemperatureLow makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view.left).with.offset(offsetValue);
			make.baseline.equalTo(self.view.bottom).with.offset(-28);
		}];
		[_weatherTemperatureLowTitle makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view.left).with.offset(offsetTitle);
			make.baseline.equalTo(self.view.bottom).with.offset(-28);
		}];
	}
}

- (void)setWeatherHidden:(BOOL)hidden {
	_weatherCondition.hidden = hidden;
	_temperature.hidden = hidden;

	_weatherHumidity.hidden = hidden;
	_weatherTemperatureHigh.hidden = hidden;
	_weatherTemperatureLow.hidden = hidden;
	_weatherHumidityTitle.hidden = hidden;
	_weatherTemperatureHighTitle.hidden = hidden;
	_weatherTemperatureLowTitle.hidden = hidden;
}

- (void)setTimeFont:(SBTickerView *)tickerView isForSecond:(BOOL)isForSecond {
	UILabel *frontView = (UILabel *)tickerView.frontView;
	UILabel *backView = (UILabel *)tickerView.backView;
	CGFloat fontSize;
	BOOL showSeconds = [[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds];
	if (IS_IPHONE) {
		if (IS_PORTRAIT) {
			fontSize = showSeconds ? 64 : 112;
			frontView.layer.cornerRadius = 5;
			backView.layer.cornerRadius = 5;
		} else {
			fontSize = showSeconds ? 112 : [self showWeather] ? 133 : 156;
			frontView.layer.cornerRadius = showSeconds ? 5 : 8;
			backView.layer.cornerRadius = showSeconds ? 5 : 8;
		}
	} else {
		if (IS_PORTRAIT) {
			fontSize = showSeconds ? 150 : 214;
			frontView.layer.cornerRadius = showSeconds ? 11 : 16;
			backView.layer.cornerRadius = showSeconds ? 11 : 16;
		} else {
			fontSize = showSeconds ? 214 : 284;
			frontView.layer.cornerRadius = showSeconds ? 16 : 20;
			backView.layer.cornerRadius = showSeconds ? 16 : 20;
		}
	}
	UIFont *font = isForSecond ? [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:fontSize] : [UIFont boldSystemFontOfSize:fontSize];
	frontView.font = font;
	backView.font = font;

	if (self.style == A3ClockFlipViewStyleDark) {
		UIColor *textColor = [[NSUserDefaults standardUserDefaults] clockFlipDarkColorIndex] == 13 ? [UIColor blackColor] : [UIColor whiteColor];
		UIColor *color = isForSecond ? [UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0] : textColor;
		frontView.textColor = color;
		backView.textColor = color;
		UIColor *backgroundColor = [[NSUserDefaults standardUserDefaults] clockFlipDarkColor];
		frontView.backgroundColor = backgroundColor;
		backView.backgroundColor = backgroundColor;
	} else {
		UIColor *textColor = [[NSUserDefaults standardUserDefaults] clockFlipLightColorIndex] == 12 ? [UIColor whiteColor] : [UIColor blackColor];
		UIColor *color = isForSecond ? [UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0] : textColor;
		frontView.textColor = color;
		backView.textColor = color;
		UIColor *backgroundColor = [[NSUserDefaults standardUserDefaults] clockFlipLightColor];
		frontView.backgroundColor = backgroundColor;
		backView.backgroundColor = backgroundColor;
	}
}

- (UILabel *)foldingLabel {
	UILabel *foldingLabel = [UILabel new];
	foldingLabel.textAlignment = NSTextAlignmentCenter;
	return foldingLabel;
}

- (A3SBTickerView *)tickerView {
	A3SBTickerView *tickerView = [A3SBTickerView new];
	[tickerView setDuration:0.4];
	[tickerView setFrontView:[self foldingLabel]];
	[tickerView setBackView:[self foldingLabel]];

	return tickerView;
}

- (A3SBTickerView *)hourView {
	if (!_hourView) {
		_hourView = [self tickerView];
	}
	return _hourView;
}

- (A3SBTickerView *)minuteView {
	if (!_minuteView) {
		_minuteView = [self tickerView];
	}
	return _minuteView;
}

- (A3SBTickerView *)secondView {
	if (!_secondView) {
		_secondView = [self tickerView];
	}
	return _secondView;
}

- (void)tickTime:(SBTickerView *)tickerView withText:(NSString *)text animated:(BOOL)animated {
	UILabel *backView = (UILabel *) tickerView.backView;
	backView.text = text;
	[tickerView tick:SBTickerViewTickDirectionDown animated:animated completion:nil];
}

- (void)refreshSecond:(A3ClockInfo *)clockInfo {
	[self tickTime:_secondView withText:[NSString stringWithFormat:@"%02ld", (long)clockInfo.dateComponents.second] animated:YES ];
}

- (void)refreshWholeClock:(A3ClockInfo *)clockInfo animated:(BOOL)animated {
	[self tickTime:_hourView withText:[NSString stringWithFormat:@"%02ld", clockInfo.hour] animated:animated ];
	[self tickTime:_minuteView withText:[NSString stringWithFormat:@"%02ld", (long)clockInfo.dateComponents.minute] animated:animated ];
	[self tickTime:_secondView withText:[NSString stringWithFormat:@"%02ld", (long)clockInfo.dateComponents.second] animated:animated ];

	_weekdayMonthDay.text = clockInfo.dateStringConsideringOptions;

	_lbAMPM.text = clockInfo.AMPM;

	if (_weatherInfoAvailable) {
		[self refreshWeather:clockInfo];
	} else {
		[self setWeatherHidden:YES];
	}
}

- (void)refreshWholeClock:(A3ClockInfo *)clockInfo {
	[self refreshWholeClock:clockInfo animated:YES];
}

- (void)refreshWeather:(A3ClockInfo *)clockInfo {
	_weatherInfoAvailable = YES;

	if (![self showWeather]) {
		[self setWeatherHidden:YES];
		return;
	}
	[self setWeatherHidden:NO];

	if (clockInfo.currentWeather.unit == SCWeatherUnitFahrenheit && ![[NSUserDefaults standardUserDefaults] clockUsesFahrenheit]) {
		// convert fahrenheit to celsius
		clockInfo.currentWeather.unit = SCWeatherUnitCelsius;
	} else if (clockInfo.currentWeather.unit == SCWeatherUnitCelsius && [[NSUserDefaults standardUserDefaults] clockUsesFahrenheit]) {
		// convert celsius to fahrenheit
		clockInfo.currentWeather.unit = SCWeatherUnitFahrenheit;
	}

	_weatherCondition.text = clockInfo.currentWeather.representation;
	_temperature.text = [NSString stringWithFormat:@"%ld°", (long)clockInfo.currentWeather.currentTemperature];

	_weatherHumidity.text = [NSString stringWithFormat:@"%@%%", [self.clockDataManager.clockInfo.weatherAtmosphere objectForKey:@"humidity"]];
	_weatherTemperatureHigh.text = [NSString stringWithFormat:@"%ld", (long)clockInfo.currentWeather.highTemperature];
	_weatherTemperatureLow.text = [NSString stringWithFormat:@"%ld", (long)clockInfo.currentWeather.lowTemperature];
}


- (void)setTime:(SBTickerView *)tickerView withText:(NSString *)text {
	UILabel *frontView = (UILabel *) tickerView.frontView;
	frontView.text = text;
	UILabel *backView = (UILabel *) tickerView.backView;
	backView.text = text;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self layoutSubviews];
}

- (void)changeColor:(UIColor *)color {
	[self setTimeFont:_hourView isForSecond:NO];
	[self setTimeFont:_minuteView isForSecond:NO];
	if (_secondView) {
		[self setTimeFont:_secondView isForSecond:YES];
	}
}

@end
