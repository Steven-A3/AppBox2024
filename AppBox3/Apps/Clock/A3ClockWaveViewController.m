//
//  A3ClockWaveViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockInfo.h"
#import "A3ClockDataManager.h"
#import "A3ClockWaveViewController.h"
#import "NSUserDefaults+A3Defaults.h"
#import "A3UserDefaults.h"
#import "A3UIDevice.h"

@interface A3ClockWaveViewController () <A3ClockWaveCircleDelegate>

@property (nonatomic, strong) UIImageView *clockIcon;
@property (nonatomic, strong) UILabel *am_pm24Label;
@property (nonatomic, strong) A3ClockWaveCircleTimeView *timeCircle;

@property (nonatomic, strong) UILabel *temperatureTopLabel;
@property (nonatomic, strong) A3ClockWaveCircleMiddleView *temperatureCircle;
@property (nonatomic, strong) UILabel *temperatureBottomLabel;

@property (nonatomic, strong) UILabel *dateTopLabel;
@property (nonatomic, strong) A3ClockWaveCircleMiddleView *dateCircle;
@property (nonatomic, strong) UILabel *dateBottomLabel;

@property (nonatomic, strong) UILabel *weekTopLabel;
@property (nonatomic, strong) A3ClockWaveCircleMiddleView *weekCircle;
@property (nonatomic, strong) UILabel *weekBottomLabel;

@property (nonatomic, strong) UIImageView *weatherImageView;
@property (nonatomic, strong) UILabel *weatherLabel;

@property (nonatomic, strong) NSMutableArray *circleArray;

// clockIcon constraints
@property (nonatomic, strong) id<MASConstraint> clockIconBottom;
@property (nonatomic, strong) id<MASConstraint> clockIconCenterX;
@property (nonatomic, strong) id<MASConstraint> clockIconRight;
@property (nonatomic, strong) id<MASConstraint> clockIconCenterY;

// Date Circle Label constraints
@property (nonatomic, strong) id<MASConstraint> dateBottomLabelX;
@property (nonatomic, strong) id<MASConstraint> dateBottomLabelY;

@end

typedef NS_ENUM(NSUInteger, A3ClockWaveCircleTypes) {
	A3ClockWaveCircleTypeTime = 1,
	A3ClockWaveCircleTypeWeather,
	A3ClockWaveCircleTypeDate,
	A3ClockWaveCircleTypeWeekday,
};


@implementation A3ClockWaveViewController {
	BOOL _showTimeSeparator;
	BOOL _needToShowWeatherView;
	BOOL _weatherInfoAvailable;
	NSUInteger _weatherCircleIndex;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	NSData *backgroundColorData = [[NSUserDefaults standardUserDefaults] objectForKey:A3ClockWaveClockColor];
	if (backgroundColorData) {
		UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:backgroundColorData];
		[self.view setBackgroundColor:color];
	} else {
		[self.view setBackgroundColor:self.clockDataManager.waveColors[0]];
	}

	[self addTimeView];

	[self prepareOptionalSubviews];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	[self layoutSubviews];
}

- (void)layoutSubviews
{
	NSArray *boundsArray;
	NSArray *centerArray;
	NSUInteger numberOfViews = [_circleArray count];
	CGRect bounds = self.view.bounds;
	CGRect screenBounds = [[UIScreen mainScreen] bounds];

	if (IS_IPHONE) {
		switch (numberOfViews) {
			case 1:
			case 2:
				boundsArray = @[
						[NSValue valueWithCGRect:CGRectMake(0, 0, 270, 270)],
						[NSValue valueWithCGRect:CGRectMake(0, 0, 62, 62)],
				];
				break;
			case 3:
				boundsArray = @[
						[NSValue valueWithCGRect:CGRectMake(0, 0, 270, 270)],
						[NSValue valueWithCGRect:CGRectMake(0, 0, 62, 62)],
						[NSValue valueWithCGRect:CGRectMake(0, 0, 62, 62)],
				];
				break;
			case 4:
				boundsArray = @[
						[NSValue valueWithCGRect:CGRectMake(0, 0, 270, 270)],
						[NSValue valueWithCGRect:CGRectMake(0, 0, 62, 62)],
						[NSValue valueWithCGRect:CGRectMake(0, 0, 62, 62)],
						[NSValue valueWithCGRect:CGRectMake(0, 0, 62, 62)],
				];
				break;
		}
		if (IS_PORTRAIT) {
			if (screenBounds.size.height == 568) {
				switch (numberOfViews) {
					case 1:
					case 2:
						centerArray = @[
								[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, 110 + 270 / 2)],
								[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.5, 436 + 62 / 2)],
						];
						break;
					case 3:
						centerArray = @[
								[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, 110 + 270 / 2)],
								[NSValue valueWithCGPoint:CGPointMake(76, 428)],
								[NSValue valueWithCGPoint:CGPointMake(244, 428)],
						];
						break;
					case 4:
						centerArray = @[
								[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, 110 + 270 / 2)],
								[NSValue valueWithCGPoint:CGPointMake(46, 428)],
								[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.5, 436 + 62 / 2)],
								[NSValue valueWithCGPoint:CGPointMake(274, 428)],
						];
						break;
				}
			} else {
				// Portrait 480 (3.5")
				switch (numberOfViews) {
					case 1:
					case 2:
						centerArray = @[
								[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, 214)],
								[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.5, 410)],
						];
						break;
					case 3:
						centerArray = @[
								[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, 214)],
								[NSValue valueWithCGPoint:CGPointMake(76, 390)],
								[NSValue valueWithCGPoint:CGPointMake(244, 390)],
						];
						break;
					case 4:
						centerArray = @[
								[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, 214)],
								[NSValue valueWithCGPoint:CGPointMake(46, 370)],
								[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.5, 410)],
								[NSValue valueWithCGPoint:CGPointMake(274, 370)],
						];
						break;
				}
			}
			[self removeClockIconConstraints];
			[self.clockIcon updateConstraints:^(MASConstraintMaker *make) {
				_clockIconBottom = make.bottom.equalTo(self.timeCircle.top).with.offset(-22);
				_clockIconCenterX =  make.centerX.equalTo(self.view.centerX);
			}];
			FNLOG(@"%@", self.clockIcon.constraints);
		} else {
			if (screenBounds.size.height == 568) {
				switch (numberOfViews) {
					case 1:
					case 2:
						centerArray = @[
								[NSValue valueWithCGPoint:CGPointMake(250, bounds.size.height / 2)],
								[NSValue valueWithCGPoint:CGPointMake(471, 160)],
						];
						break;
					case 3:
						centerArray = @[
								[NSValue valueWithCGPoint:CGPointMake(250, bounds.size.height / 2)],
								[NSValue valueWithCGPoint:CGPointMake(431, 76)],
								[NSValue valueWithCGPoint:CGPointMake(431, 244)],
						];
						break;
					case 4:
						centerArray = @[
								[NSValue valueWithCGPoint:CGPointMake(250, bounds.size.height / 2)],
								[NSValue valueWithCGPoint:CGPointMake(431, 56)],
								[NSValue valueWithCGPoint:CGPointMake(471, 160)],
								[NSValue valueWithCGPoint:CGPointMake(431, 264)],
						];
						break;
				}
			} else {
				// Landscape 480 (3.5")
				switch (numberOfViews) {
					case 1:
					case 2:
						centerArray = @[
								[NSValue valueWithCGPoint:CGPointMake(206, bounds.size.height / 2)],
								[NSValue valueWithCGPoint:CGPointMake(427, 160)],
						];
						break;
					case 3:
						centerArray = @[
								[NSValue valueWithCGPoint:CGPointMake(206, bounds.size.height / 2)],
								[NSValue valueWithCGPoint:CGPointMake(387, 76)],
								[NSValue valueWithCGPoint:CGPointMake(387, 244)],
						];
						break;
					case 4:
						centerArray = @[
								[NSValue valueWithCGPoint:CGPointMake(206, bounds.size.height / 2)],
								[NSValue valueWithCGPoint:CGPointMake(387, 56)],
								[NSValue valueWithCGPoint:CGPointMake(427, 160)],
								[NSValue valueWithCGPoint:CGPointMake(387, 264)],
						];
						break;
				}
			}
			[self removeClockIconConstraints];
			[self.clockIcon makeConstraints:^(MASConstraintMaker *make) {
				_clockIconRight = make.right.equalTo(self.timeCircle.left).with.offset(-22);
				_clockIconCenterY = make.centerY.equalTo(self.view.centerY);
			}];

			FNLOG(@"%@", self.clockIcon.constraints);
		}
	}

	NSUInteger idx = 0;
	for (NSNumber *typeObj in _circleArray) {
		A3ClockWaveCircleTypes type = (A3ClockWaveCircleTypes) [typeObj unsignedIntegerValue];
		A3ClockWaveCircleView *circleView = [self circleViewForType:type];
		circleView.tag = idx;
		circleView.position = (idx == 0) ? ClockWaveLocationBig : ClockWaveLocationSmall;
		circleView.nLineWidth = (idx == 0) ? 2 : 1;
		[self animateMove:circleView
				   bounds:[boundsArray[idx] CGRectValue]
				   center:[centerArray[idx] CGPointValue]];
		idx++;
	}

	[self.clockIcon setHidden:([_circleArray[0] unsignedIntegerValue] != A3ClockWaveCircleTypeTime)];

	if (IS_IPHONE && screenBounds.size.height == 480) {
		if (IS_PORTRAIT) {
			A3ClockWaveCircleTypes type = [_circleArray[0] unsignedIntegerValue];
			if (type == A3ClockWaveCircleTypeDate) {
				[_dateTopLabel setHidden:YES];
				[_dateBottomLabelY uninstall];
				[_dateBottomLabel makeConstraints:^(MASConstraintMaker *make) {
					_dateBottomLabelY = make.bottom.equalTo(self.dateCircle.top).with.offset(-5);
				}];
			} else {
				[_dateTopLabel setHidden:NO];
				[_dateBottomLabelY uninstall];
				[_dateBottomLabel makeConstraints:^(MASConstraintMaker *make) {
					_dateBottomLabelY = make.top.equalTo(self.dateCircle.bottom).with.offset(5);
				}];
			}
			[_temperatureBottomLabel setHidden:type == A3ClockWaveCircleTypeWeather];
			[_weekBottomLabel setHidden:type == A3ClockWaveCircleTypeWeekday];
		} else {
			[_temperatureBottomLabel setHidden:NO];
			[_dateBottomLabel setHidden:NO];
			[_weekBottomLabel setHidden:NO];

			[_dateTopLabel setHidden:NO];
			[_dateBottomLabelY uninstall];
			[_dateBottomLabel makeConstraints:^(MASConstraintMaker *make) {
				_dateBottomLabelY = make.top.equalTo(self.dateCircle.bottom).with.offset(5);
			}];
		}
	}
}

- (void)removeClockIconConstraints {
	[_clockIconBottom uninstall]; _clockIconBottom = nil;
	[_clockIconCenterX uninstall]; _clockIconCenterX = nil;
	[_clockIconCenterY uninstall]; _clockIconCenterY = nil;
	[_clockIconRight uninstall]; _clockIconRight = nil;
}

- (void)prepareOptionalSubviews {
	[self removeTemperatureView];
	[self removeWeatherView];
	[self removeDateView];
	[self removeWeekdayView];

	_circleArray = [[[NSUserDefaults standardUserDefaults] objectForKey:A3ClockWaveCircleLayout] mutableCopy];
	if (!_circleArray) [self initCircleArray];

	NSUInteger idx = 0;
	for (NSNumber *type in _circleArray) {
		switch ((A3ClockWaveCircleTypes)[type unsignedIntegerValue]) {
			case A3ClockWaveCircleTypeTime:
				break;
			case A3ClockWaveCircleTypeWeather:
				_needToShowWeatherView = YES;
				if (_weatherInfoAvailable) {
					[self addTemperatureView];
					[self addWeatherView];
				} else {
					_weatherCircleIndex = idx;
				}
				break;
			case A3ClockWaveCircleTypeDate:
				[self addDateView];
				break;
			case A3ClockWaveCircleTypeWeekday:
				[self addWeekdayView];
				break;
		}
		idx++;
	}

	if (_needToShowWeatherView && !_weatherInfoAvailable) {
		[_circleArray removeObjectAtIndex:_weatherCircleIndex];
	}
	self.clockDataManager.bigCircle = self.timeCircle;
}

- (void)initCircleArray {
	_circleArray = [NSMutableArray new];
	[_circleArray addObject:@(A3ClockWaveCircleTypeTime)];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	_needToShowWeatherView = [userDefaults clockShowWeather];
	if (_needToShowWeatherView) {
		[_circleArray addObject:@(A3ClockWaveCircleTypeWeather)];
	}
	if ([userDefaults clockShowDate]) {
		[_circleArray addObject:@(A3ClockWaveCircleTypeDate)];
	}
	if ([userDefaults clockShowTheDayOfTheWeek]) {
		[_circleArray addObject:@(A3ClockWaveCircleTypeWeekday)];
	}
}

- (void)addTimeView {
	UIImage *imgHistory = [UIImage imageNamed:@"history"];
	imgHistory = [imgHistory imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	self.clockIcon = [[UIImageView alloc] initWithImage:imgHistory];
	[_clockIcon sizeToFit];
	[self.clockIcon setTintColor:[UIColor whiteColor]];
	[self.view addSubview:self.clockIcon];

	self.am_pm24Label = [[UILabel alloc] init];
	[self.am_pm24Label setFont:[UIFont fontWithName:kClockFontNameRegular size:14]];
	[self.am_pm24Label setTextAlignment:NSTextAlignmentCenter];
	[self.am_pm24Label setTextColor:[UIColor whiteColor]];
	[self.view addSubview:self.am_pm24Label];

	self.timeCircle = [[A3ClockWaveCircleTimeView alloc] initWithFrame:CGRectMake(0.f, 0.f, 270.f, 270.f)];
	self.timeCircle.delegate = self;
	self.timeCircle.smallFont = [UIFont fontWithName:kClockFontNameLight size:13];
	self.timeCircle.isShowWave = YES;

	self.clockDataManager.bigCircle = self.timeCircle;
	[self.view addSubview:self.timeCircle];

	[self.am_pm24Label makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(self.timeCircle.top).with.offset(-4);
		make.centerX.equalTo(self.timeCircle.centerX).with.offset(0);
	}];

}

- (void)addDateView {
	self.dateTopLabel = [[UILabel alloc] init];
	[self.dateTopLabel setFont:[UIFont fontWithName:kClockFontNameRegular size:14]];
	[self.dateTopLabel setTextColor:[UIColor whiteColor]];
	[self.view addSubview:self.dateTopLabel];

	self.dateCircle = [[A3ClockWaveCircleMiddleView alloc] initWithFrame:CGRectMake(0.f, 0.f, 62.f, 62.f)];
	self.dateCircle.delegate = self;
	self.dateCircle.isShowWave = YES;
	[self.view addSubview:self.dateCircle];

	self.dateBottomLabel = [[UILabel alloc] init];
	[self.dateBottomLabel setFont:[UIFont fontWithName:kClockFontNameLight size:14]];
	[self.dateBottomLabel setTextColor:[UIColor whiteColor]];
	[self.view addSubview:self.dateBottomLabel];

	[self.dateTopLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.dateCircle.centerX).with.offset(0);
		make.bottom.equalTo(self.dateCircle.top).with.offset(-5);
	}];
	[self.dateBottomLabel makeConstraints:^(MASConstraintMaker *make) {
		_dateBottomLabelX = make.centerX.equalTo(self.dateCircle.centerX).with.offset(0);
		_dateBottomLabelY = make.top.equalTo(self.dateCircle.bottom).with.offset(5);
	}];

}

- (void)removeDateView {
	[_dateTopLabel removeFromSuperview];
	_dateTopLabel = nil;
	[_dateBottomLabel removeFromSuperview];
	_dateBottomLabel = nil;
	[_dateCircle removeFromSuperview];
	_dateCircle = nil;
}

- (void)addWeekdayView {
	NSArray *shortWeekdaySymbols = [self.clockDataManager.clockInfo.dateFormatter shortWeekdaySymbols];

	self.weekTopLabel = [[UILabel alloc] init];
	[self.weekTopLabel setFont:[UIFont fontWithName:kClockFontNameLight size:14]];
	[self.weekTopLabel setTextColor:[UIColor whiteColor]];
	self.weekTopLabel.text = [shortWeekdaySymbols lastObject];
	[self.view addSubview:self.weekTopLabel];

	self.weekCircle = [[A3ClockWaveCircleMiddleView alloc] initWithFrame:CGRectMake(0.f, 0.f, 62.f, 62.f)];
	self.weekCircle.delegate = self;
	self.weekCircle.isShowWave = YES;
	[self.view addSubview:self.weekCircle];

	self.weekBottomLabel = [[UILabel alloc] init];
	[self.weekBottomLabel setFont:[UIFont fontWithName:kClockFontNameLight size:14]];
	[self.weekBottomLabel setTextColor:[UIColor whiteColor]];
	self.weekBottomLabel.text = [shortWeekdaySymbols firstObject];
	[self.view addSubview:self.weekBottomLabel];

	[self.weekTopLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.weekCircle.centerX).with.offset(0);
		make.bottom.equalTo(self.weekCircle.top).with.offset(-5);
	}];
	[self.weekBottomLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.weekCircle.centerX).with.offset(0);
		make.top.equalTo(self.weekCircle.bottom).with.offset(5);
	}];
}

- (void)removeWeekdayView {
	[_weekTopLabel removeFromSuperview];
	_weekTopLabel = nil;
	[_weekBottomLabel removeFromSuperview];
	_weekBottomLabel = nil;
	[_weekCircle removeFromSuperview];
	_weekCircle = nil;
}

- (void)addTemperatureView {
	self.temperatureTopLabel = [[UILabel alloc] init];
	[self.temperatureTopLabel setFont:[UIFont fontWithName:kClockFontNameRegular size:14]];
	[self.temperatureTopLabel setTextColor:[UIColor whiteColor]];
	[self.view addSubview:self.temperatureTopLabel];

	self.temperatureCircle = [[A3ClockWaveCircleMiddleView alloc] initWithFrame:CGRectMake(0.f, 0.f, 62.f, 62.f)];
	self.temperatureCircle.delegate = self;
	self.temperatureCircle.isShowWave = YES;
	[self.view addSubview:self.temperatureCircle];

	self.temperatureBottomLabel = [[UILabel alloc] init];
	[self.temperatureBottomLabel setFont:[UIFont fontWithName:kClockFontNameRegular size:14]];
	[self.temperatureBottomLabel setTextColor:[UIColor whiteColor]];
	[self.view addSubview:self.temperatureBottomLabel];

	[self.temperatureTopLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.temperatureCircle.centerX).with.offset(0);
		make.bottom.equalTo(self.temperatureCircle.top).with.offset(-5);
	}];
	[self.temperatureBottomLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.temperatureCircle.centerX).with.offset(0);
		make.top.equalTo(self.temperatureCircle.bottom).with.offset(5);
	}];
}

- (void)removeTemperatureView {
	[_temperatureTopLabel removeFromSuperview];
	_temperatureTopLabel = nil;
	[_temperatureBottomLabel removeFromSuperview];
	_temperatureBottomLabel = nil;
	[_temperatureCircle removeFromSuperview];
	_temperatureCircle = nil;
}

- (void)addWeatherView {
	_weatherImageView = [UIImageView new];
	[self.view addSubview:_weatherImageView];

	self.weatherLabel = [UILabel new];
	[self.weatherLabel setTextColor:[UIColor whiteColor]];
	self.weatherLabel.textAlignment = NSTextAlignmentLeft;
	self.weatherLabel.font = [UIFont fontWithName:kClockFontNameRegular size:13.f];
	[self.view addSubview:self.weatherLabel];

	[self.weatherImageView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(12);
		make.bottom.equalTo(self.view.bottom).with.offset(-8);
	}];

	[self.weatherLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.weatherImageView.right).with.offset(2);
		make.baseline.equalTo(self.view.bottom).with.offset(-14);
	}];
}

- (void)removeWeatherView {
	[_weatherImageView removeFromSuperview];
	_weatherImageView = nil;
	[_weatherLabel removeFromSuperview];
	_weatherLabel = nil;
}

- (A3ClockWaveCircleView *)circleViewForType:(A3ClockWaveCircleTypes)type {
	switch (type) {
		case A3ClockWaveCircleTypeTime:
			return _timeCircle;
		case A3ClockWaveCircleTypeWeather:
			return _temperatureCircle;
		case A3ClockWaveCircleTypeDate:
			return _dateCircle;
		case A3ClockWaveCircleTypeWeekday:
			return _weekCircle;
	}
	return nil;
}

- (void)animateMove:(A3ClockWaveCircleView *)circleView bounds:(CGRect)bounds center:(CGPoint)center {
	if (circleView.isMustChange) {
		[self addCircleAnimation:circleView.layer from:circleView.layer.cornerRadius to:bounds.size.height / 2];
		[UIView animateWithDuration:0.2
						 animations:^{
							 [circleView.textLabel setHidden:YES];
							 circleView.bounds = bounds;
							 circleView.center = center;
						 }
						 completion:^(BOOL finished) {
							 [circleView setNeedsDisplay];
							 [circleView.textLabel setHidden:NO];
							 [self removeCircleAnimation:circleView.layer];
						 }];
		circleView.isMustChange = NO;
	} else {
		circleView.bounds = bounds;
		circleView.center = center;
	}
}

- (void)addCircleAnimation:(CALayer *)layer from:(CGFloat)from to:(CGFloat)to {
	CGFloat animationDuration = 0.2; // Your duration

	CABasicAnimation *cornerRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
	[cornerRadiusAnimation setFromValue:[NSNumber numberWithFloat:from]]; // The current value
	[cornerRadiusAnimation setToValue:[NSNumber numberWithFloat:to]]; // The new value
	[cornerRadiusAnimation setDuration:animationDuration];
	[cornerRadiusAnimation setBeginTime:CACurrentMediaTime()];

	[cornerRadiusAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

// This will keep make the animation look as the "from" and "to" values before and after the animation
	[cornerRadiusAnimation setFillMode:kCAFillModeBoth];
	[layer addAnimation:cornerRadiusAnimation forKey:@"keepAsCircle"];
}

- (void)removeCircleAnimation:(CALayer *)layer {
	[layer removeAnimationForKey:@"keepAsCircle"];
}

- (void)clockWaveCircleTapped:(A3ClockWaveCircleView *)circleView {
	circleView.isMustChange = YES;
	A3ClockWaveCircleView *bigCircle = [self circleViewForType:(A3ClockWaveCircleTypes) [_circleArray[0] unsignedIntegerValue]];
	bigCircle.isMustChange = YES;

	[_circleArray exchangeObjectAtIndex:(NSUInteger) circleView.tag withObjectAtIndex:0];

	NSMutableArray *circleArrayToSave = [_circleArray copy];
	if (_needToShowWeatherView && !_weatherInfoAvailable) {
		NSUInteger idx = [circleArrayToSave indexOfObjectIdenticalTo:@(A3ClockWaveCircleTypeWeather) inRange:NSMakeRange(0, [circleArrayToSave count])];
		if (idx == NSNotFound) {
			[circleArrayToSave insertObject:@(A3ClockWaveCircleTypeWeather) atIndex:_weatherCircleIndex];
		}
	}
	[[NSUserDefaults standardUserDefaults] setObject:circleArrayToSave forKey:A3ClockWaveCircleLayout];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self.clockDataManager stopTimer];
	[self layoutSubviews];

	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self.clockDataManager startTimer];
	});
}

- (void)refreshSecond:(A3ClockInfo *)clockInfo {
	if([[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds]) {
		if ([[NSUserDefaults standardUserDefaults] clockFlashTheTimeSeparators]) {
			if (_showTimeSeparator) {
				[clockInfo.dateFormatter setDateFormat:@"hh:mm:ss"];
			} else {
				[clockInfo.dateFormatter setDateFormat:@"hh mm ss"];
			}
			_showTimeSeparator = !_showTimeSeparator;
		} else {
			[clockInfo.dateFormatter setDateFormat:@"hh:mm:ss"];
		}
		[self.timeCircle setTime:[clockInfo.dateFormatter stringFromDate:clockInfo.date]];
	}
	else
	{
		if ([[NSUserDefaults standardUserDefaults] clockFlashTheTimeSeparators]) {
			if (_showTimeSeparator) {
				[clockInfo.dateFormatter setDateFormat:@"hh:mm"];
			} else {
				[clockInfo.dateFormatter setDateFormat:@"hh mm"];
			}
			_showTimeSeparator = !_showTimeSeparator;
		} else {
			[clockInfo.dateFormatter setDateFormat:@"hh:mm"];
		}
		[self.timeCircle setTime:[clockInfo.dateFormatter stringFromDate:clockInfo.date]];
	}
}

- (void)refreshWholeClock:(A3ClockInfo *)clockInfo {
	if([[NSUserDefaults standardUserDefaults] clockUse24hourClock])
		self.am_pm24Label.text = @"24";
	else
		self.am_pm24Label.text = @"12";

	if([[NSUserDefaults standardUserDefaults] clockShowAMPM])
	{
		self.am_pm24Label.text = [NSString stringWithFormat:@"%@ %@", self.am_pm24Label.text, clockInfo.strTimeAMPM];
	}

	[self refreshSecond:clockInfo];

	self.timeCircle.fillPercent = ((clockInfo.dateComponents.hour * 60 * 60) + (clockInfo.dateComponents.minute * 60) + 60) / kClockSecondOfDay;
	[self.timeCircle setNeedsDisplay];

	self.dateTopLabel.text = clockInfo.strDateMaxDay;
	[self.dateCircle setDate:[clockInfo.strDateDay intValue]];
	self.dateBottomLabel.text = [clockInfo.strDateMonthShort uppercaseString];
	self.dateCircle.fillPercent = clockInfo.dateComponents.day / [clockInfo.strDateMaxDay floatValue];
	[self.dateCircle setNeedsDisplay];

	[self.weekCircle setWeek:[clockInfo.strWeekShort uppercaseString]];
	self.weekCircle.fillPercent = (float)clockInfo.dateComponents.weekday / 7.0;
	[self.weekCircle setNeedsDisplay];
}

- (void)refreshWeather:(A3ClockInfo *)clockInfo {
	if (![[NSUserDefaults standardUserDefaults] clockShowWeather]) {
		return;
	}
	if (!_weatherInfoAvailable) {
		_weatherInfoAvailable = YES;

		[_circleArray insertObject:@(A3ClockWaveCircleTypeWeather) atIndex:_weatherCircleIndex];

		[self addTemperatureView];
		[self addWeatherView];
	}

	self.temperatureTopLabel.text = [NSString stringWithFormat:@"%d", clockInfo.currentWeather.highTemperature];
	[self.temperatureCircle setTemperature:clockInfo.currentWeather.currentTemperature];
	self.temperatureBottomLabel.text = [NSString stringWithFormat:@"%d", clockInfo.currentWeather.lowTemperature];
	if (clockInfo.currentWeather.highTemperature - clockInfo.currentWeather.lowTemperature > 0) {
		self.temperatureCircle.fillPercent = (float)(clockInfo.currentWeather.currentTemperature - clockInfo.currentWeather.lowTemperature) / (float)(clockInfo.currentWeather.highTemperature - clockInfo.currentWeather.lowTemperature);
		[self.temperatureCircle setNeedsDisplay];
	}

	[self.weatherImageView setImage:[self.clockDataManager imageForWeatherCondition:clockInfo.currentWeather.condition]];
	self.weatherLabel.text = clockInfo.currentWeather.description;

	[self layoutSubviews];
}

- (void)changeColor:(UIColor *)color {
	self.view.backgroundColor = color;
	for (NSNumber *typeObject in _circleArray) {
		A3ClockWaveCircleView *view = [self circleViewForType:(A3ClockWaveCircleTypes) typeObject.unsignedIntegerValue];
		[view setFillPercent:view.fillPercent];
		[view setNeedsDisplay];
	}
}

- (NSUInteger)a3SupportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self layoutSubviews];
}

@end
