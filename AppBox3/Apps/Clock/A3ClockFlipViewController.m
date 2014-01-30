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
#import "A3ClockFoldPaperView.h"

#define kColorClockFlipLabel [UIColor colorWithRed:142.f/255.f green:142.f/255.f blue:147.f/255.f alpha:1.f]

@interface A3ClockFlipViewController ()

@property (nonatomic, strong) A3SBTickerView *hourView;
@property (nonatomic, strong) A3SBTickerView *minuteView;
@property (nonatomic, strong) A3SBTickerView *secondView;

@property (nonatomic, strong) UILabel* lbAMPM;

@property (nonatomic, strong) UILabel* lbWeekMonthDay;
@property (nonatomic, strong) UILabel* lbWeather;
@property (nonatomic, strong) UILabel* lbTemperature;

@property (nonatomic, strong) UILabel* lbWeatherRainRst;
@property (nonatomic, strong) UILabel* lbWeatherHumidityRst;
@property (nonatomic, strong) UILabel* lbWeatherHighRst;
@property (nonatomic, strong) UILabel* lbWeatherLowRst;

@property (nonatomic, strong) UILabel* lbWeatherRain;
@property (nonatomic, strong) UILabel* lbWeatherHumidity;
@property (nonatomic, strong) UILabel* lbWeatherHigh;
@property (nonatomic, strong) UILabel* lbWeatherLow;

@end

@implementation A3ClockFlipViewController

- (instancetype)initWithClockDataManager:(A3ClockDataManager *)clockDataManager style:(A3ClockFlipViewStyle) style {
	self = [super initWithClockDataManager:clockDataManager];
	if (self) {
		[self setStyle:style];
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

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self layoutSubviews];
}

#pragma mark public
- (void)layoutSubviews {
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

    [self.view addSubview:self.hourView];
    [self.view addSubview:self.minuteView];
	if ([[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds]) {
		[self.view addSubview:self.secondView];
	} else if (_secondView) {
		[_secondView removeFromSuperview];
		_secondView = nil;
	}
	[_hourView removeConstraints:_hourView.constraints];
	[_minuteView removeConstraints:_minuteView.constraints];
	[_secondView removeConstraints:_secondView.constraints];

	CGFloat boxSize, interimSpace;
	BOOL showSeconds = [[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds];
	if (IS_IPHONE) {
		if (IS_PORTRAIT) {
			boxSize = showSeconds ? 90 : 140;
		} else {
			boxSize = showSeconds ? 140 : 195;
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
			make.centerX.equalTo(self.view.centerX);
			make.centerY.equalTo(self.view.centerY);
			make.width.equalTo(@(boxSize));
			make.height.equalTo(@(boxSize));
		}];

		[_hourView makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(_minuteView.centerY);
			make.right.equalTo(_minuteView.left).with.offset(-1 * interimSpace);
			make.width.equalTo(@(boxSize));
			make.height.equalTo(@(boxSize));
		}];

		[_secondView makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(_minuteView.centerY);
			make.left.equalTo(_minuteView.right).with.offset(interimSpace);
			make.width.equalTo(@(boxSize));
			make.height.equalTo(@(boxSize));
		}];
		[self setTimeFont:_hourView isForSecond:NO];
		[self setTimeFont:_minuteView isForSecond:NO];
		[self setTimeFont:_secondView isForSecond:YES];
	}
	else
	{
		[_hourView makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(self.view.centerY);
			make.centerX.equalTo(self.view.centerX).with.offset(-1 * (boxSize + interimSpace / 2));
			make.width.equalTo(@(boxSize));
			make.height.equalTo(@(boxSize));
		}];

		[_minuteView makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(self.view.centerY);
			make.centerX.equalTo(self.view.centerX).with.offset(boxSize + interimSpace / 2);
			make.width.equalTo(@(boxSize));
			make.height.equalTo(@(boxSize));
		}];
		[self setTimeFont:_hourView isForSecond:NO];
		[self setTimeFont:_minuteView isForSecond:NO];
	}

	[_lbAMPM makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_hourView.left).with.offset(10);
		make.bottom.equalTo(_hourView.top).with.offset(-8);
	}];

	[self.view layoutIfNeeded];
}

- (void)setTimeFont:(SBTickerView *)tickerView isForSecond:(BOOL)isForSecond {
	A3ClockFoldPaperView *frontView = (A3ClockFoldPaperView *)tickerView.frontView;
	A3ClockFoldPaperView *backView = (A3ClockFoldPaperView *)tickerView.backView;
	CGFloat fontSize;
	BOOL showSeconds = [[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds];
	if (IS_IPHONE) {
		if (IS_PORTRAIT) {
			fontSize = showSeconds ? 64 : 112;
			frontView.layer.cornerRadius = 5;
		} else {
			fontSize = showSeconds ? 112 : 156;
			frontView.layer.cornerRadius = showSeconds ? 5 : 8;
		}
	} else {
		if (IS_PORTRAIT) {
			fontSize = showSeconds ? 64 : 112;
			frontView.layer.cornerRadius = showSeconds ? 11 : 16;
		} else {
			fontSize = showSeconds ? 150 : 214;
			frontView.layer.cornerRadius = showSeconds ? 16 : 20;
		}
	}
	UIFont *font = isForSecond ? [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:fontSize] : [UIFont boldSystemFontOfSize:fontSize];
	frontView.textLabel.font = font;
	backView.textLabel.font = font;

	if (self.style == A3ClockFlipViewStyleDark) {
		UIColor *color = isForSecond ? [UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0] : [UIColor whiteColor];
		frontView.textLabel.textColor = color;
		backView.textLabel.textColor = color;
		UIColor *backgroundColor = [[NSUserDefaults standardUserDefaults] clockFlipDarkColor];
		frontView.backgroundColor = backgroundColor;
		backView.backgroundColor = backgroundColor;
	} else {
		UIColor *color = isForSecond ? [UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0] : [UIColor blackColor];
		frontView.textLabel.textColor = color;
		backView.textLabel.textColor = color;
		UIColor *backgroundColor = [[NSUserDefaults standardUserDefaults] clockFlipLightColor];
		frontView.backgroundColor = backgroundColor;
		backView.backgroundColor = backgroundColor;
	}
}

- (A3ClockFoldPaperView *)foldingLabel {
	A3ClockFoldPaperView *foldingLabel = [A3ClockFoldPaperView new];
	foldingLabel.viewCenter.backgroundColor = self.view.backgroundColor;
	return foldingLabel;
}

- (A3SBTickerView *)tickerView {
	A3SBTickerView *tickerView = [A3SBTickerView new];
	[tickerView setDuration:0.4];
	[tickerView setFrontView:[self foldingLabel]];
	[tickerView setBackView:[self foldingLabel]];

	return tickerView;
}

- (SBTickerView *)hourView {
	if (!_hourView) {
		_hourView = [self tickerView];
	}
	return _hourView;
}

- (SBTickerView *)minuteView {
	if (!_minuteView) {
		_minuteView = [self tickerView];
	}
	return _minuteView;
}

- (SBTickerView *)secondView {
	if (!_secondView) {
		_secondView = [self tickerView];
	}
	return _secondView;
}

- (void)tickTime:(SBTickerView *)tickerView withText:(NSString *)text animated:(BOOL)animated {
	A3ClockFoldPaperView *backView = (A3ClockFoldPaperView *) tickerView.backView;
	backView.textLabel.text = text;
	[tickerView tick:SBTickerViewTickDirectionDown animated:animated completion:nil];
}

- (void)refreshSecond:(A3ClockInfo *)clockInfo {
	[self tickTime:_secondView withText:[NSString stringWithFormat:@"%02d", self.clockDataManager.clockInfo.dateComponents.second] animated:YES ];
}

- (void)refreshWholeClock:(A3ClockInfo *)clockInfo {
	[self tickTime:_hourView withText:[NSString stringWithFormat:@"%02d", self.clockDataManager.clockInfo.dateComponents.hour] animated:YES ];
	[self tickTime:_minuteView withText:[NSString stringWithFormat:@"%02d", self.clockDataManager.clockInfo.dateComponents.minute] animated:YES ];
	[self tickTime:_secondView withText:[NSString stringWithFormat:@"%02d", self.clockDataManager.clockInfo.dateComponents.second] animated:YES ];

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

- (void)setTime:(SBTickerView *)tickerView withText:(NSString *)text {
	A3ClockFoldPaperView *frontView = (A3ClockFoldPaperView *) tickerView.frontView;
	frontView.textLabel.text = text;
	A3ClockFoldPaperView *backView = (A3ClockFoldPaperView *) tickerView.backView;
	backView.textLabel.text = text;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self.clockDataManager stopTimer];

	[self setTime:_hourView withText:@""];
	[self setTime:_minuteView withText:@""];
	[self setTime:_secondView withText:@""];

	[self layoutSubviews];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	[self.clockDataManager startTimer];
}


@end
