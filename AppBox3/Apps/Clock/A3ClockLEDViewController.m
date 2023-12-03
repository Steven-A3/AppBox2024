//
//  A3ClockLEDViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "A3ClockInfo.h"
#import "A3ClockDataManager.h"
#import "A3ClockLEDViewController.h"
#import "A3UserDefaults+A3Defaults.h"

@interface A3ClockLEDViewController ()

@property (nonatomic, strong) UILabel *AMPM;
@property (nonatomic, strong) UILabel *weather;
@property (nonatomic, strong) UILabel *date;
@property (nonatomic, strong) UILabel *zeroLabel;
@property (nonatomic, strong) UILabel *hour1;
@property (nonatomic, strong) UILabel *hour2;
@property (nonatomic, strong) UILabel *minute1;
@property (nonatomic, strong) UILabel *minute2;
@property (nonatomic, strong) UILabel *second1;
@property (nonatomic, strong) UILabel *second2;
@property (nonatomic, strong) UILabel *colon1;
@property (nonatomic, strong) UILabel *colon2;
@property (nonatomic, strong) NSMutableArray *constraints;
@property (nonatomic, strong) UIView *gradientView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation A3ClockLEDViewController {
	BOOL _colonHidden;
	BOOL _layoutInitialized;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:IS_IPHONE ? @"LED_bg" : @"LED_bg_p"]]];

	[self prepareSubviews];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (!_layoutInitialized) {
		_layoutInitialized = YES;
		[self layoutSubviews];
	}
	[self refreshWholeClock:self.clockDataManager.clockInfo];
}

- (void)updateLayout {
	[self layoutSubviews];
	[self refreshWholeClock:self.clockDataManager.clockInfo];
}

- (void)changeColor:(UIColor *)color {
	[self setupTextColor];
	[self setGradientColor];
}

- (void)layoutSubviews {
	[self removeConstraints];

	[self setupSecondsLabel];
	[self setupAMPM];
	[self setupWeatherLabel];
	[self setupDateLabel];
	[self setupColon2];

	[self setupTextColor];

	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	
	CGFloat timeFontSize;
    BOOL isPortrait = [UIWindow interfaceOrientationIsPortrait];
	if (IS_IPHONE) {
		if (self.showSeconds) {
			timeFontSize = isPortrait ? 74 : 116;
		} else {
			timeFontSize = isPortrait ? 116 : 162;
		}
	} else {
		if (self.showSeconds) {
			timeFontSize = isPortrait ? 165 : 231;
		} else {
			timeFontSize = isPortrait ? 231 : 304;
		}
	}
	timeFontSize *= scale;

	CGFloat otherFontSize;
	if (IS_IPHONE) {
		otherFontSize = isPortrait ? 15 : 20.5;
	} else {
		otherFontSize = 26;
	}
	otherFontSize *= scale;
	UIFont *otherFont = [UIFont fontWithName:@"Register" size:otherFontSize];

	_zeroLabel.text = self.showSeconds ? @"00 00 00" : @"00 00";
	_zeroLabel.font = [UIFont fontWithName:@"01 Digit" size:timeFontSize];
	_hour1.font = _zeroLabel.font; _hour2.font = _zeroLabel.font;
	_minute1.font = _zeroLabel.font; _minute2.font = _zeroLabel.font;

	CGSize zeroSize = [@"0" sizeWithAttributes:@{NSFontAttributeName : _zeroLabel.font, NSForegroundColorAttributeName:[UIColor blackColor]}];
	CGSize spaceSize = [@" " sizeWithAttributes:@{NSFontAttributeName : _zeroLabel.font, NSForegroundColorAttributeName:[UIColor blackColor]}];

	CGFloat timeVerticalOffset = [self timeVerticalOffset];
	CGFloat colonOffset;

	if (self.showSeconds) {
		CGFloat colonSize;
		if (IS_IPHONE) {
			colonSize = isPortrait ? 70 : 90;
			colonOffset = isPortrait ? -7 : -7;
		} else {
			colonSize = isPortrait ? 140 : 180;
			colonOffset = isPortrait ? -7 : -7;
		}
		colonSize *= scale;
		colonOffset *= scale;
		
		CGFloat timeHalfHeightUp;
		CGFloat timeHalfHeightDown;
		if (IS_IPHONE) {
			timeHalfHeightUp = isPortrait ? 80 / 2 : 108 / 2;
			timeHalfHeightDown = isPortrait ? 80 / 2 : 108 / 2;
		} else {
			timeHalfHeightUp = isPortrait ? 142 / 2: 182 / 2;
			timeHalfHeightDown = isPortrait ? 142 / 2: 182 / 2;
		}
		timeHalfHeightUp *= scale;
		timeHalfHeightDown *= scale;
		
		_second1.font = _zeroLabel.font; _second2.font = _zeroLabel.font;

		[self setGradientColor];
		CGRect frame = self.view.bounds;
		frame.origin.y = self.view.center.y - timeHalfHeightUp - 30;
		frame.size.height = timeHalfHeightUp * 2 + 60;
		_gradientView.frame = frame;
		_gradientLayer.frame = _gradientView.bounds;

		[_hour1 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(-(zeroSize.width * 2 + spaceSize.width + zeroSize.width / 2))];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(timeVerticalOffset)];
		}];
		[_hour2 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(-(zeroSize.width + spaceSize.width + zeroSize.width / 2))];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(timeVerticalOffset)];
		}];

		[_minute1 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(-zeroSize.width / 2)];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(timeVerticalOffset)];
		}];
		[_minute2 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(zeroSize.width / 2)];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(timeVerticalOffset)];
		}];

		[_second1 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(spaceSize.width + zeroSize.width + zeroSize.width / 2)];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(timeVerticalOffset)];
		}];
		[_second2 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(spaceSize.width + zeroSize.width * 2 + zeroSize.width / 2)];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(timeVerticalOffset)];
		}];

		[_colon1 setFont:[UIFont fontWithName:@"Helvetica" size:colonSize]];
		[_colon2 setFont:[UIFont fontWithName:@"Helvetica" size:colonSize]];
		[_colon1 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(-(zeroSize.width + spaceSize.width / 2))];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(colonOffset)];
		}];
		[_colon2 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(zeroSize.width + spaceSize.width / 2)];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(colonOffset)];
		}];

		if (self.showAMPM) {
			[_AMPM setFont:otherFont];
			[_AMPM makeConstraints:^(MASConstraintMaker *make) {
				[self.constraints addObject:make.left.equalTo(self.view.centerX).with.offset(-(zeroSize.width * 3 + spaceSize.width) + 8)];
				[self.constraints addObject:make.bottom.equalTo(self.view.centerY).with.offset(-timeHalfHeightUp)];
			}];
		}
		if (self.showWeather) {
			[_weather setFont:otherFont];
			[_weather makeConstraints:^(MASConstraintMaker *make) {
				[self.constraints addObject:make.right.equalTo(self.view.centerX).with.offset(zeroSize.width * 3 + spaceSize.width - 8)];
				[self.constraints addObject:make.bottom.equalTo(self.view.centerY).with.offset(-timeHalfHeightUp)];
			}];
		}
		if (self.showDate || self.showTheDayOfTheWeek) {
			[_date setFont:otherFont];
			[_date makeConstraints:^(MASConstraintMaker *make) {
				[self.constraints addObject:make.right.equalTo(self.view.centerX).with.offset(zeroSize.width * 3 + spaceSize.width - 8)];
				[self.constraints addObject:make.top.equalTo(self.view.centerY).with.offset(timeHalfHeightDown)];
			}];
		}
	} else {
		CGFloat colonSize;
		if (IS_IPHONE) {
			colonSize = isPortrait ? 90 : 126;
			colonOffset = isPortrait ? -7 : -7;
		} else {
			colonSize = isPortrait ? 180 : 234;
			colonOffset = isPortrait ? -7 : -7;
		}
		colonSize *= scale;
		colonOffset *= scale;
		
		CGFloat timeHalfHeightUp;
		CGFloat timeHalfHeightDown;
		if (IS_IPHONE) {
			timeHalfHeightUp = isPortrait ? 108 / 2 : 140 / 2;
			timeHalfHeightDown = isPortrait ? 108 / 2 : 140 / 2;
		} else { // iPAD
			timeHalfHeightUp = isPortrait ? 188 / 2 - 2: 236 / 2 - 1;
			timeHalfHeightDown = isPortrait ? 188 / 2 - 2: 236 / 2 - 3;
		}
		timeHalfHeightUp *= scale;
		timeHalfHeightDown *= scale;

		[self setGradientColor];
		CGRect frame = self.view.bounds;
		frame.origin.y = self.view.center.y - timeHalfHeightUp - 30;
		frame.size.height = timeHalfHeightUp * 2 + 60;
		_gradientView.frame = frame;
		_gradientLayer.frame = _gradientView.bounds;

		_second1.font = _zeroLabel.font; _second2.font = _zeroLabel.font;

		[_hour1 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(-(zeroSize.width + spaceSize.width / 2 + zeroSize.width / 2))];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(timeVerticalOffset)];
		}];
		[_hour2 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(-(spaceSize.width / 2 + zeroSize.width / 2))];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(timeVerticalOffset)];
		}];

		[_minute1 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(spaceSize.width / 2 + zeroSize.width / 2)];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(timeVerticalOffset)];
		}];
		[_minute2 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX).with.offset(spaceSize.width / 2 + zeroSize.width + zeroSize.width / 2)];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(timeVerticalOffset)];
		}];

		[_colon1 setFont:[UIFont fontWithName:@"Helvetica" size:colonSize]];
		[_colon1 makeConstraints:^(MASConstraintMaker *make) {
			[self.constraints addObject:make.centerX.equalTo(self.view.centerX)];
			[self.constraints addObject:make.centerY.equalTo(self.view.centerY).with.offset(colonOffset)];
		}];

		if (self.showAMPM) {
			[_AMPM setFont:otherFont];
			[_AMPM makeConstraints:^(MASConstraintMaker *make) {
				[self.constraints addObject:make.left.equalTo(self.view.centerX).with.offset(-(zeroSize.width * 2 + spaceSize.width / 2) + 8)];
				[self.constraints addObject:make.bottom.equalTo(self.view.centerY).with.offset(-(timeHalfHeightUp))];
			}];
		}
		if (self.showWeather) {
			[_weather setFont:otherFont];
			[_weather makeConstraints:^(MASConstraintMaker *make) {
				[self.constraints addObject:make.right.equalTo(self.view.centerX).with.offset(zeroSize.width * 2 + spaceSize.width / 2 - 8)];
				[self.constraints addObject:make.bottom.equalTo(self.view.centerY).with.offset(-(timeHalfHeightUp))];
			}];
		}
		if (self.showDate || self.showTheDayOfTheWeek) {
			[_date setFont:otherFont];
			[_date makeConstraints:^(MASConstraintMaker *make) {
				[self.constraints addObject:make.right.equalTo(self.view.centerX).with.offset(zeroSize.width * 2 + spaceSize.width / 2 - 8)];
				[self.constraints addObject:make.top.equalTo(self.view.centerY).with.offset(timeHalfHeightDown)];
			}];
		}
	}
	_colonHidden = NO;
	[_colon1 setHidden:NO];
	[_colon2 setHidden:NO];

	[self.view layoutIfNeeded];


}

- (void)setupTextColor {
	UIColor *textColor = [[A3UserDefaults standardUserDefaults] clockLEDColor];
	for (UILabel *label in self.view.subviews) {
		if ([label isKindOfClass:[UILabel class]]) {
			label.textColor = textColor;
		}
	}
	_zeroLabel.alpha = 0.05;
	_colon1.alpha = 0.5;
	_colon2.alpha = 0.5;
}

- (NSMutableArray *)constraints {
	if (!_constraints) {
		_constraints = [NSMutableArray new];
	}
	return _constraints;
}

- (void)removeConstraints {
	for (MASConstraint *constraint in _constraints) {
		[constraint uninstall];
	}
}

- (void)setupColon2 {
	if (self.showSeconds) {
		if (!_colon2) {
			_colon2 = [self makeLabel];
			_colon2.text = @":";
		}
		[self.view addSubview:_colon2];
	} else {
		[_colon2 removeFromSuperview];
		_colon2 = nil;
	}
}

- (void)prepareSubviews {
	[self addZeroTimeLabel];
	[self addGradientView];
	[self addTimeLabels];
	[self addColon1];
}

- (void)setGradientColor {
	NSUInteger colorIndex = [[A3UserDefaults standardUserDefaults] clockLEDColorIndex];
	_gradientLayer.colors = @[
			(id)[UIColor clearColor].CGColor,
			(id) [self.clockDataManager LEDColorAtIndex:colorIndex alpha:0.05].CGColor,
			(id)[UIColor clearColor].CGColor
	];
}

- (void)addGradientView {
	_gradientView = [UIView new];
	_gradientLayer = [CAGradientLayer layer];
	_gradientLayer.position = CGPointMake(0,0);
	_gradientLayer.anchorPoint = CGPointMake(0,0);
	_gradientLayer.locations = @[@0, @0.5, @1];
	[self setGradientColor];
	[_gradientView.layer addSublayer:_gradientLayer];

	[self.view addSubview:_gradientView];
}

- (void)addColon1 {
	_colon1 = [self makeLabel];
	_colon1.text = @":";
	[self.view addSubview:_colon1];
}

- (void)setupAMPM {
	if (self.showAMPM) {
		if (!_AMPM) {
			_AMPM = [self makeLabel];
		}
		[self.view addSubview:_AMPM];
	} else {
		[_AMPM removeFromSuperview];
		_AMPM = nil;
	}
}

- (CGFloat)timeVerticalOffset {
	CGFloat verticalOffset;
    BOOL isPortrait = [UIWindow interfaceOrientationIsPortrait];
	if (self.showSeconds) {
		if (IS_IPHONE) {
			verticalOffset = isPortrait ? 0 : 0;
		} else {
			verticalOffset = isPortrait ? 0 : -6;
		}
	} else {
		if (IS_IPHONE) {
			verticalOffset = isPortrait ? 0 : 0;
		} else {
			verticalOffset = isPortrait ? -4 : -9;
		}
	}
	return verticalOffset;
}

- (void)addZeroTimeLabel {
	_zeroLabel = [self makeLabel];
	_zeroLabel.alpha = 0.05;
	[self.view addSubview:_zeroLabel];

	CGFloat verticalOffset = [self timeVerticalOffset];

	[_zeroLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		make.centerY.equalTo(self.view.centerY).with.offset(verticalOffset);
	}];
}


- (void)addTimeLabels {
	_hour1 = [self makeLabel];
	[self.view addSubview:_hour1];
	_hour2 = [self makeLabel];
	[self.view addSubview:_hour2];

	_minute1 = [self makeLabel];
	[self.view addSubview:_minute1];
	_minute2 = [self makeLabel];
	[self.view addSubview:_minute2];

	// Seconds labels depends on settings
}

- (void)setupSecondsLabel {
	if (self.showSeconds) {
		if (!_second1) {
			_second1 = [self makeLabel];
		}
		if (!_second2) {
			_second2 = [self makeLabel];
		}
		[self.view addSubview:_second1];
		[self.view addSubview:_second2];
	} else {
		[_second1 removeFromSuperview];
		_second1 = nil;
		[_second2 removeFromSuperview];
		_second2 = nil;
	}
}

- (void)setupWeatherLabel {
	if (self.showWeather) {
		if (!_weather) {
			_weather = [self makeLabel];
		}
		[self.view addSubview:_weather];
	} else {
		[_weather removeFromSuperview];
		_weather = nil;
	}
}

- (void)setupDateLabel {
	if (self.showDate || self.showTheDayOfTheWeek) {
		if (!_date) {
			_date = [self makeLabel];
			_date.textAlignment = NSTextAlignmentRight;
			[self.view addSubview:_date];
		}
	} else {
		[_date removeFromSuperview];
		_date = nil;
	}
}

- (UILabel *)makeLabel {
	UILabel *label = [UILabel new];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [[A3UserDefaults standardUserDefaults] clockLEDColor];
	return label;
}

- (void)refreshSecond:(A3ClockInfo *)clockInfo {
	NSString *timeString;
	if ([self showSeconds]) {
		timeString = [NSString stringWithFormat:@"%02ld%02ld%02ld", clockInfo.hour, (long) clockInfo.dateComponents.minute, (long) clockInfo.dateComponents.second];
	} else {
		timeString = [NSString stringWithFormat:@"%02ld%02ld", clockInfo.hour, (long) clockInfo.dateComponents.minute];
	}

	_hour1.text = [timeString substringWithRange:NSMakeRange(0, 1)];
	_hour2.text = [timeString substringWithRange:NSMakeRange(1, 1)];
	_minute1.text = [timeString substringWithRange:NSMakeRange(2, 1)];
	_minute2.text = [timeString substringWithRange:NSMakeRange(3, 1)];

	if ([self showSeconds]) {
		_second1.text = [timeString substringWithRange:NSMakeRange(4, 1)];
		_second2.text = [timeString substringWithRange:NSMakeRange(5, 1)];
	}

	if (self.flashSeparator) {
		_colonHidden = !_colonHidden;
		[_colon1 setHidden:_colonHidden];
		[_colon2 setHidden:_colonHidden];
	}
}

- (void)refreshWholeClock:(A3ClockInfo *)clockInfo {
	[self refreshSecond:clockInfo];

	if (self.showAMPM) {
		_AMPM.text = clockInfo.AMPM;
	}
	if (self.showDate || self.showTheDayOfTheWeek) {
		_date.text = clockInfo.dateStringConsideringOptions;
	}

	if (_weatherInfoAvailable && self.showWeather) {
		[self refreshWeather:clockInfo];
	}
	return;
}

- (void)refreshWeather:(A3ClockInfo *)clockInfo {
	if (!_weatherInfoAvailable) {
		_weatherInfoAvailable = YES;
	}

	if (![self showWeather]) return;

	_weather.text = [NSString stringWithFormat:@"%ld° %@", (long) clockInfo.currentWeather.currentTemperature, clockInfo.currentWeather.representation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self layoutSubviews];
}

@end
