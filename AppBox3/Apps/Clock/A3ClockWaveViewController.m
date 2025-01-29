//
//  A3ClockWaveViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "A3ClockInfo.h"
#import "A3ClockDataManager.h"
#import "A3ClockWaveViewController.h"
#import "A3UserDefaults+A3Defaults.h"
#import "A3UserDefaultsKeys.h"
#import "A3UIDevice.h"
#import "A3AppDelegate.h"
#import "Reachability.h"
#import "UIViewController+A3Addition.h"
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
@property (nonatomic, strong) MASConstraint *clockIconBottom;
@property (nonatomic, strong) MASConstraint *clockIconCenterX;
@property (nonatomic, strong) MASConstraint *clockIconRight;
@property (nonatomic, strong) MASConstraint *clockIconCenterY;

// Date Circle Label constraints
@property (nonatomic, strong) MASConstraint *dateBottomLabelX;
@property (nonatomic, strong) MASConstraint *dateBottomLabelY;

@end


@implementation A3ClockWaveViewController {
	BOOL _showTimeSeparator;
	BOOL _needToShowWeatherView;
	NSUInteger _weatherCircleIndex;
	BOOL _layoutInitialized;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	NSData *backgroundColorData = [[A3UserDefaults standardUserDefaults] objectForKey:A3ClockWaveClockColor];
	if (backgroundColorData) {
        NSError *error = nil;
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:backgroundColorData error:&error];

        if (error) {
            FNLOG(@"Error unarchiving color data: %@", error.localizedDescription);
        } else {
            unarchiver.requiresSecureCoding = NO; // Set this to YES if your object conforms to NSSecureCoding
            UIColor *color = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
            [unarchiver finishDecoding];
            [self.view setBackgroundColor:color];
        }
	} else {
		[self.view setBackgroundColor:self.clockDataManager.waveColors[7]];
	}

	[self addTimeView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (!_layoutInitialized) {
		_layoutInitialized = YES;
		[self updateLayout];
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)updateLayout {
	[self prepareOptionalSubviews];
	[self layoutSubviews];

	[self.clockDataManager refreshWholeClockInfo:[NSDate date]];
	[self refreshWholeClock:self.clockDataManager.clockInfo];
}

- (void)layoutSubviews
{
	self.view.frame = [self screenBoundsAdjustedWithOrientation];

	if (IS_IPHONE) {
		[self layoutSubViewsIPHONE];
	} else {
		[self layoutSubviewIPAD];
	}
	[self adjustFontWhenWeatherIsNotAvailable];
}

- (void)layoutSubViewsIPHONE {
	NSArray *boundsArray;
	NSArray *centerArray;
	NSUInteger numberOfViews = [_circleArray count];
	CGRect bounds = self.view.bounds;
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
    BOOL isPortrait = [UIWindow interfaceOrientationIsPortrait];
	CGFloat radiusBase = isPortrait ? bounds.size.width : bounds.size.height;

	switch (numberOfViews) {
		case 1:
		case 2:
			boundsArray = @[
					[NSValue valueWithCGRect:CGRectMake(0, 0, radiusBase * 0.84375, radiusBase * 0.84375)],
					[NSValue valueWithCGRect:CGRectMake(0, 0, radiusBase * 0.19375, radiusBase * 0.19375)],
			];
			break;
		case 3:
			boundsArray = @[
							[NSValue valueWithCGRect:CGRectMake(0, 0, radiusBase * 0.84375, radiusBase * 0.84375)],
							[NSValue valueWithCGRect:CGRectMake(0, 0, radiusBase * 0.19375, radiusBase * 0.19375)],
							[NSValue valueWithCGRect:CGRectMake(0, 0, radiusBase * 0.19375, radiusBase * 0.19375)],
			];
			break;
		case 4:
			boundsArray = @[
							[NSValue valueWithCGRect:CGRectMake(0, 0, radiusBase * 0.84375, radiusBase * 0.84375)],
							[NSValue valueWithCGRect:CGRectMake(0, 0, radiusBase * 0.19375, radiusBase * 0.19375)],
							[NSValue valueWithCGRect:CGRectMake(0, 0, radiusBase * 0.19375, radiusBase * 0.19375)],
							[NSValue valueWithCGRect:CGRectMake(0, 0, radiusBase * 0.19375, radiusBase * 0.19375)],
			];
			break;
	}
	if (isPortrait) {
		if (screenBounds.size.height != 480) {
			switch (numberOfViews) {
				case 1:
					centerArray = @[
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height / 2)],
					];
					break;
				case 2:
					centerArray = @[
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height * 0.4)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.8)],
					];
					break;
				case 3:
					centerArray = @[
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height * 0.43)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.25, bounds.size.height * 0.8)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.75, bounds.size.height * 0.8)],
					];
					break;
				case 4:
					centerArray = @[
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.4)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.20, bounds.size.height * 0.75)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.8)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.80, bounds.size.height * 0.75)],
					];
					break;
			}
		} else {
			// Portrait 480 (3.5")
			switch (numberOfViews) {
				case 1:
					centerArray = @[
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height / 2)],
					];
					break;
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
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, 204)],
							[NSValue valueWithCGPoint:CGPointMake(46, 360)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.5, 400)],
							[NSValue valueWithCGPoint:CGPointMake(274, 360)],
					];
					break;
			}
		}
		[self removeClockIconConstraints];
		[self.clockIcon updateConstraints:^(MASConstraintMaker *make) {
            self->_clockIconBottom = make.bottom.equalTo(self.timeCircle.top).with.offset(-22);
            self->_clockIconCenterX =  make.centerX.equalTo(self.view.centerX);
		}];
	} else {
		if (screenBounds.size.height != 480) {
			switch (numberOfViews) {
				case 1:
					centerArray = @[
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height / 2)],
					];
					break;
				case 2:
					centerArray = @[
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.4, bounds.size.height / 2)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.8, bounds.size.height / 2)],
					];
					break;
				case 3:
					centerArray = @[
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.43, bounds.size.height / 2)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.8, bounds.size.height * 0.25)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.8, bounds.size.height * 0.75)],
					];
					break;
				case 4:
					centerArray = @[
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.4, bounds.size.height / 2)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.75, bounds.size.height * 0.2)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.8, bounds.size.height * 0.5)],
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.75, bounds.size.height * 0.8)],
					];
					break;
			}
		} else {
			// Landscape 480 (3.5")
			switch (numberOfViews) {
				case 1:
					centerArray = @[
							[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height / 2)],
					];
					break;
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
            self->_clockIconRight = make.right.equalTo(self.timeCircle.left).with.offset(-22);
            self->_clockIconCenterY = make.centerY.equalTo(self.view.centerY);
		}];
	}

	NSUInteger idx = 0;
	for (NSNumber *typeObj in _circleArray) {
		A3ClockWaveCircleTypes type = (A3ClockWaveCircleTypes) [typeObj unsignedIntegerValue];
		A3ClockWaveCircleView *circleView = [self circleViewForType:type];
		circleView.tag = idx;
		circleView.position = (idx == 0) ? ClockWaveLocationBig : ClockWaveLocationSmall;
		circleView.lineWidth = (idx == 0) ? 2 : 1;
		[self animateMove:circleView
				   bounds:[boundsArray[idx] CGRectValue]
				   center:[centerArray[idx] CGPointValue]];
		idx++;
	}

	[self.clockIcon setHidden:([_circleArray[0] unsignedIntegerValue] != A3ClockWaveCircleTypeTime)];

	if (IS_IPHONE && screenBounds.size.height == 480) {
		if (isPortrait) {
			A3ClockWaveCircleTypes type = (A3ClockWaveCircleTypes) [_circleArray[0] unsignedIntegerValue];
			if (type == A3ClockWaveCircleTypeDate) {
				[_dateTopLabel setHidden:YES];
				[_dateBottomLabelY uninstall];
				[_dateBottomLabel makeConstraints:^(MASConstraintMaker *make) {
                    self->_dateBottomLabelY = make.bottom.equalTo(self.dateCircle.top).with.offset(-5);
				}];
			} else {
				[_dateTopLabel setHidden:NO];
				[_dateBottomLabelY uninstall];
				[_dateBottomLabel makeConstraints:^(MASConstraintMaker *make) {
                    self->_dateBottomLabelY = make.top.equalTo(self.dateCircle.bottom).with.offset(5);
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
                self->_dateBottomLabelY = make.top.equalTo(self.dateCircle.bottom).with.offset(5);
			}];
		}
	}
}

- (void)layoutSubviewIPAD {
	NSArray *boundsArray;
	NSArray *centerArray;
	NSUInteger numberOfViews = [_circleArray count];
	CGRect bounds = self.view.bounds;
	CGFloat diameterBase = MIN(bounds.size.width, bounds.size.height);
	CGFloat bigCircleDiameter = diameterBase * 0.703125;
	CGFloat smallCircleDiameter = diameterBase * 0.1614583;

	switch (numberOfViews) {
		case 1:
		case 2:
			boundsArray = @[
					[NSValue valueWithCGRect:CGRectMake(0, 0, bigCircleDiameter, bigCircleDiameter)],
					[NSValue valueWithCGRect:CGRectMake(0, 0, smallCircleDiameter, smallCircleDiameter)],
			];
			break;
		case 3:
			boundsArray = @[
							[NSValue valueWithCGRect:CGRectMake(0, 0, bigCircleDiameter, bigCircleDiameter)],
							[NSValue valueWithCGRect:CGRectMake(0, 0, smallCircleDiameter, smallCircleDiameter)],
							[NSValue valueWithCGRect:CGRectMake(0, 0, smallCircleDiameter, smallCircleDiameter)],
			];
			break;
		case 4:
			boundsArray = @[
							[NSValue valueWithCGRect:CGRectMake(0, 0, bigCircleDiameter, bigCircleDiameter)],
							[NSValue valueWithCGRect:CGRectMake(0, 0, smallCircleDiameter, smallCircleDiameter)],
							[NSValue valueWithCGRect:CGRectMake(0, 0, smallCircleDiameter, smallCircleDiameter)],
							[NSValue valueWithCGRect:CGRectMake(0, 0, smallCircleDiameter, smallCircleDiameter)],
			];
			break;
	}
	if ([UIWindow interfaceOrientationIsPortrait]) {
		switch (numberOfViews) {
			case 1:
				centerArray = @[
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height / 2)],
				];
				break;
			case 2:
				centerArray = @[
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height * 0.4189453125)],
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height * 0.8505859375)],
				];
				break;
			case 3:
				centerArray = @[
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height * 0.4189453125)],
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.26302083, bounds.size.height * 0.8505859375)],
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.73697916, bounds.size.height * 0.8505859375)],
				];
				break;
			case 4:
				centerArray = @[
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height * 0.4589453125)],
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.1953125, bounds.size.height * 0.7724609375)],
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height * 0.8505859375)],
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.8040364583, bounds.size.height * 0.7724609375)],
				];
				break;
		}
		[self removeClockIconConstraints];
		[self.clockIcon updateConstraints:^(MASConstraintMaker *make) {
            self->_clockIconBottom = make.bottom.equalTo(self.timeCircle.top).with.offset(-47);
            self->_clockIconCenterX =  make.centerX.equalTo(self.view.centerX);
		}];
	} else {
		switch (numberOfViews) {
			case 1:
				centerArray = @[
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width / 2, bounds.size.height / 2)],
				];
				break;
			case 2:
				centerArray = @[
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.431640625, bounds.size.height / 2)],
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.8642578125, bounds.size.height / 2)],
				];
				break;
			case 3:
				centerArray = @[
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.431640625, bounds.size.height / 2)],
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.7861328125, bounds.size.height * 0.26302083)],
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.7861328125, bounds.size.height * 0.73697916)],
				];
				break;
			case 4:
				centerArray = @[
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.431640625, bounds.size.height / 2)],
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.7861328125, bounds.size.height * 0.1953125)],
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.8642578125, bounds.size.height / 2)],
						[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.7861328125, bounds.size.height * 0.8046875)],
				];
				break;
		}
		[self removeClockIconConstraints];
		[self.clockIcon makeConstraints:^(MASConstraintMaker *make) {
			self.clockIconRight = make.right.equalTo(self.timeCircle.left).with.offset(-47);
			self.clockIconCenterY = make.centerY.equalTo(self.view.centerY);
		}];
	}

	NSUInteger idx = 0;
	for (NSNumber *typeObj in _circleArray) {
		A3ClockWaveCircleTypes type = (A3ClockWaveCircleTypes) [typeObj unsignedIntegerValue];
		A3ClockWaveCircleView *circleView = [self circleViewForType:type];
		circleView.tag = idx;
		circleView.position = (idx == 0) ? ClockWaveLocationBig : ClockWaveLocationSmall;
		circleView.lineWidth = IS_IPHONE ? ( idx == 0 ? 2 : 1 ) : ( idx == 0 ? 4 : 2);
		[self animateMove:circleView
				   bounds:[boundsArray[idx] CGRectValue]
				   center:[centerArray[idx] CGPointValue]];
		idx++;
	}

	[self.clockIcon setHidden:([_circleArray[0] unsignedIntegerValue] != A3ClockWaveCircleTypeTime)];
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

	// It will remove existing one if it exists and add new colon view conditionally based on settings.
	[self.timeCircle addColonView];

	_circleArray = [self.clockDataManager waveCirclesArray];

	NSUInteger idx = 0;
	for (NSNumber *type in _circleArray) {
		switch ((A3ClockWaveCircleTypes)[type unsignedIntegerValue]) {
			case A3ClockWaveCircleTypeTime:
				break;
			case A3ClockWaveCircleTypeWeather:
				_needToShowWeatherView = YES;
				[self addTemperatureView];
				if (_weatherInfoAvailable) {
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
}

- (void)addTimeView {
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	UIImage *imgHistory = IS_IPHONE ? [UIImage imageNamed:@"history"] : [UIImage imageNamed:@"history_p"];
	imgHistory = [imgHistory imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	self.clockIcon = [[UIImageView alloc] initWithImage:imgHistory];
	[_clockIcon sizeToFit];
	[self.clockIcon setTintColor:[UIColor whiteColor]];
	[self.view addSubview:self.clockIcon];

	self.am_pm24Label = [[UILabel alloc] init];
	[self.am_pm24Label setFont:[UIFont systemFontOfSize:(IS_IPHONE ? 14 : 24) * scale]];
	[self.am_pm24Label setTextAlignment:NSTextAlignmentCenter];
	[self.am_pm24Label setTextColor:[UIColor whiteColor]];
	[self.view addSubview:self.am_pm24Label];

	self.timeCircle = [[A3ClockWaveCircleTimeView alloc] initWithFrame:CGRectMake(0.f, 0.f, 270.f, 270.f)];
	self.timeCircle.delegate = self;
	self.timeCircle.isShowWave = YES;

	[self.view addSubview:self.timeCircle];
	[self.timeCircle addColonView];

	[self.am_pm24Label makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(self.timeCircle.top).with.offset(IS_IPHONE ? -4 : -10);
		make.centerX.equalTo(self.timeCircle.centerX).with.offset(0);
	}];
}

- (void)addDateView {
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	self.dateTopLabel = [[UILabel alloc] init];
	[self.dateTopLabel setFont:[UIFont systemFontOfSize:(IS_IPHONE ? 14 : 24) * scale]];
	[self.dateTopLabel setTextColor:[UIColor whiteColor]];
	[self.view addSubview:self.dateTopLabel];

	self.dateCircle = [[A3ClockWaveCircleMiddleView alloc] initWithFrame:CGRectMake(0.f, 0.f, 62.f, 62.f)];
	self.dateCircle.delegate = self;
	self.dateCircle.isShowWave = YES;
	[self.view addSubview:self.dateCircle];

	self.dateBottomLabel = [[UILabel alloc] init];
	[self.dateBottomLabel setFont:[UIFont systemFontOfSize:(IS_IPHONE ? 14 : 15) * scale]];
	[self.dateBottomLabel setTextColor:[UIColor whiteColor]];
	[self.view addSubview:self.dateBottomLabel];

	[self.dateTopLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.dateCircle.centerX).with.offset(0);
		make.bottom.equalTo(self.dateCircle.top).with.offset(IS_IPHONE ? -5 : -10);
	}];
	[self.dateBottomLabel makeConstraints:^(MASConstraintMaker *make) {
        self->_dateBottomLabelX = make.centerX.equalTo(self.dateCircle.centerX).with.offset(0);
        self->_dateBottomLabelY = make.top.equalTo(self.dateCircle.bottom).with.offset(IS_IPHONE ? 5 : 10);
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
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	self.weekTopLabel = [[UILabel alloc] init];
	[self.weekTopLabel setFont:[UIFont systemFontOfSize:(IS_IPHONE ? 14 : 15) * scale]];
	[self.weekTopLabel setTextColor:[UIColor whiteColor]];
	[self.view addSubview:self.weekTopLabel];

	self.weekCircle = [[A3ClockWaveCircleMiddleView alloc] initWithFrame:CGRectMake(0.f, 0.f, 62.f, 62.f)];
	if (IS_IPAD) {
		self.weekCircle.smallFont = [UIFont systemFontOfSize:17 * scale];
	}
	self.weekCircle.delegate = self;
	self.weekCircle.isShowWave = YES;
	self.weekCircle.bigFont = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:88 * scale];
	self.weekCircle.smallFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:18 * scale];
	[self.view addSubview:self.weekCircle];

	self.weekBottomLabel = [[UILabel alloc] init];
	[self.weekBottomLabel setFont:[UIFont systemFontOfSize:(IS_IPHONE ? 14 : 15) * scale]];
	[self.weekBottomLabel setTextColor:[UIColor whiteColor]];
	[self.view addSubview:self.weekBottomLabel];

	[self.weekTopLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.weekCircle.centerX).with.offset(0);
		make.bottom.equalTo(self.weekCircle.top).with.offset(IS_IPHONE ? -5 : -10);
	}];
	[self.weekBottomLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.weekCircle.centerX).with.offset(0);
		make.top.equalTo(self.weekCircle.bottom).with.offset(IS_IPHONE ? 5 : 10);
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
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	
	self.temperatureTopLabel = [[UILabel alloc] init];
	[self.temperatureTopLabel setFont:[UIFont systemFontOfSize:(IS_IPHONE ? 14 : 24) * scale]];
	[self.temperatureTopLabel setTextColor:[UIColor whiteColor]];
	[self.view addSubview:self.temperatureTopLabel];

	self.temperatureCircle = [[A3ClockWaveCircleMiddleView alloc] initWithFrame:CGRectMake(0.f, 0.f, 62.f, 62.f)];
	self.temperatureCircle.delegate = self;
	self.temperatureCircle.isShowWave = YES;
	self.temperatureCircle.fillPercent = 1.0;
	self.temperatureCircle.textLabel.text = NSLocalizedString(@"Weather", @"Weather");
	[self.view addSubview:self.temperatureCircle];

	self.temperatureBottomLabel = [[UILabel alloc] init];
	[self.temperatureBottomLabel setFont:[UIFont systemFontOfSize:(IS_IPHONE ? 14 : 24) * scale]];
	[self.temperatureBottomLabel setTextColor:[UIColor whiteColor]];
	[self.view addSubview:self.temperatureBottomLabel];

	[self.temperatureTopLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.temperatureCircle.centerX).with.offset(0);
		make.bottom.equalTo(self.temperatureCircle.top).with.offset(IS_IPHONE ? -5 : -10);
	}];
	[self.temperatureBottomLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.temperatureCircle.centerX);
		make.top.equalTo(self.temperatureCircle.bottom).with.offset(IS_IPHONE ? 5 : 10);
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
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	_weatherImageView = [UIImageView new];
	[self.view addSubview:_weatherImageView];

	self.weatherLabel = [UILabel new];
	[self.weatherLabel setTextColor:[UIColor whiteColor]];
	self.weatherLabel.textAlignment = NSTextAlignmentLeft;
	self.weatherLabel.font = [UIFont systemFontOfSize:(IS_IPHONE ? 13 : 15) * scale];
	[self.view addSubview:self.weatherLabel];

    CGFloat verticalOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] myKeyWindow] safeAreaInsets];
    verticalOffset = -safeAreaInsets.bottom;
    
	[self.weatherImageView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(IS_IPHONE ? 12 : 25);
		make.bottom.equalTo(self.view.bottom).with.offset((IS_IPHONE ? -8 : -25) + verticalOffset);
	}];

	[self.weatherLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.weatherImageView.right).with.offset(2);
		make.baseline.equalTo(self.view.bottom).with.offset((IS_IPHONE ? -14 : -32) + verticalOffset);
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
	if (circleView == _temperatureCircle && !_weatherInfoAvailable) {
		if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] <= kCLAuthorizationStatusDenied) {
			[self alertLocationDisabled];
		}
	}
	circleView.isMustChange = YES;
	A3ClockWaveCircleView *oldBigCircle = [self circleViewForType:(A3ClockWaveCircleTypes) [_circleArray[0] unsignedIntegerValue]];
	oldBigCircle.isMustChange = YES;

	[_circleArray exchangeObjectAtIndex:(NSUInteger) circleView.tag withObjectAtIndex:0];

	NSMutableArray *circleArrayToSave = [_circleArray mutableCopy];
	if (_needToShowWeatherView && !_weatherInfoAvailable) {
		NSUInteger idx = [circleArrayToSave indexOfObjectIdenticalTo:@(A3ClockWaveCircleTypeWeather) inRange:NSMakeRange(0, [circleArrayToSave count])];
		if (idx == NSNotFound) {
			[circleArrayToSave insertObject:@(A3ClockWaveCircleTypeWeather) atIndex:_weatherCircleIndex];
		}
	}
	[[A3UserDefaults standardUserDefaults] setObject:circleArrayToSave forKey:A3ClockWaveCircleLayout];
	[[A3UserDefaults standardUserDefaults] synchronize];

	[self.clockDataManager stopTimer];

	oldBigCircle.position = ClockWaveLocationSmall;
	circleView.position = ClockWaveLocationBig;

	if (circleView == self.timeCircle || oldBigCircle == self.timeCircle) {
		[self.timeCircle setNeedsUpdateConstraints];
		[self.timeCircle updateConstraintsIfNeeded];
		[self.timeCircle layoutIfNeeded];
	}
	[self layoutSubviews];

	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self.clockDataManager startTimer];
	});
}

- (void)refreshSecond:(A3ClockInfo *)clockInfo {
	NSString *timeString;
	if ([self showSeconds]) {
		timeString = [NSString stringWithFormat:@"%02ld %02ld %02ld", clockInfo.hour, (long) clockInfo.dateComponents.minute, (long) clockInfo.dateComponents.second];
	} else {
		timeString = [NSString stringWithFormat:@"%02ld %02ld", clockInfo.hour, (long) clockInfo.dateComponents.minute];
	}
	if ([[A3UserDefaults standardUserDefaults] clockFlashTheTimeSeparators]) {
		[self.timeCircle.colonView setHidden:_showTimeSeparator];
		_showTimeSeparator = !_showTimeSeparator;
	} else {
		[self.timeCircle.colonView setHidden:NO];
	}

	self.timeCircle.textLabel.text = timeString;
}

- (void)refreshWholeClock:(A3ClockInfo *)clockInfo {
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] myKeyWindow] safeAreaInsets];
    if (safeAreaInsets.top > 20) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        scale = MIN(screenBounds.size.width, screenBounds.size.height) / 320;
    }
	if([[A3UserDefaults standardUserDefaults] clockUse24hourClock])
		self.am_pm24Label.text = @"24";
	else
		self.am_pm24Label.text = @"12";

	if([[A3UserDefaults standardUserDefaults] clockShowAMPM])
	{
		self.am_pm24Label.text = [NSString stringWithFormat:@"%@ %@", self.am_pm24Label.text, clockInfo.AMPM];
	}

	UIFont *timeFont;
	NSString *letterFontName = @"HelveticaNeue-UltraLight";
	NSString *smallFontName = @"HelveticaNeue-Light";
	if(self.showSeconds) {
		if (self.timeCircle.position == ClockWaveLocationBig) {
			// Big Circle and big font
			timeFont = [UIFont fontWithName:letterFontName size:(IS_IPHONE ? 64 : 128) * scale];
			self.timeCircle.bigFont = timeFont;
		} else {
			timeFont = [UIFont fontWithName:smallFontName size:(IS_IPHONE ? 13 : 24) * scale];
			self.timeCircle.smallFont = timeFont;
		}
	}
	else
	{
		if (self.timeCircle.position == ClockWaveLocationBig) {
			// Big Circle and big font
			timeFont = [UIFont fontWithName:letterFontName size:(IS_IPHONE ? 88 : 176) * scale];
			self.timeCircle.bigFont = timeFont;
		} else {
			timeFont = [UIFont fontWithName:smallFontName size:(IS_IPHONE ? 20 : 30) * scale];
			self.timeCircle.smallFont = timeFont;
		}
	}
	if ([[A3UserDefaults standardUserDefaults] clockFlashTheTimeSeparators]) {
		[self.timeCircle.colonView setHidden:_showTimeSeparator];
		_showTimeSeparator = !_showTimeSeparator;
	} else {
		[self.timeCircle.colonView setHidden:NO];
	}

	self.timeCircle.textLabel.font = timeFont;
	[self refreshSecond:clockInfo];

	self.timeCircle.fillPercent = ((clockInfo.dateComponents.hour * 60 * 60) + (clockInfo.dateComponents.minute * 60) + 60) / kClockSecondOfDay;

	self.dateTopLabel.text = clockInfo.maxDay;
	[self.dateCircle setDay:[clockInfo.day intValue]];
	self.dateBottomLabel.text = IS_IPHONE ? [clockInfo.shortMonth uppercaseString] : [clockInfo.month uppercaseString];
	self.dateCircle.fillPercent = clockInfo.dateComponents.day / [clockInfo.maxDay floatValue];

	NSArray *weekdaySymbols;
	if (IS_IPHONE) {
		weekdaySymbols = [self.clockDataManager.clockInfo.dateFormatter shortWeekdaySymbols];
	} else {
		weekdaySymbols = [self.clockDataManager.clockInfo.dateFormatter weekdaySymbols];
	}

	self.weekTopLabel.text = [[weekdaySymbols lastObject] uppercaseString];
	self.weekBottomLabel.text = [[weekdaySymbols firstObject] uppercaseString];
	self.weekCircle.textLabel.text = IS_IPHONE ? [clockInfo.shortWeekday uppercaseString] : [clockInfo.weekday uppercaseString];
	self.weekCircle.fillPercent = (float) clockInfo.dateComponents.weekday / 7.0;

	if (_weatherInfoAvailable) {
		[self refreshWeather:clockInfo];
	}
	[self adjustFontWhenWeatherIsNotAvailable];
}

- (void)adjustFontWhenWeatherIsNotAvailable {
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
	
	if (!_weatherInfoAvailable) {
		if (ClockWaveLocationBig == _temperatureCircle.position) {
			_temperatureCircle.textLabel.font = [UIFont systemFontOfSize:(IS_IPHONE ? 60 : 110) * scale];
		} else {
			_temperatureCircle.textLabel.font = [UIFont systemFontOfSize:(IS_IPHONE ? 14 : 18) * scale];
		}
	}
}

- (void)refreshWeather:(A3ClockInfo *)clockInfo {
	if (!_weatherInfoAvailable) {
		_weatherInfoAvailable = YES;

		if ([self showWeather]) {
			[self addWeatherView];
			[self layoutSubviews];
		}
	}
	if (![self showWeather]) {
		return;
	}

	if (!clockInfo.currentWeather) {
		_weatherInfoAvailable = NO;
		return;
	}

	if (clockInfo.currentWeather.unit == SCWeatherUnitFahrenheit && ![[A3UserDefaults standardUserDefaults] clockUsesFahrenheit]) {
		// convert fahrenheit to celsius
		clockInfo.currentWeather.unit = SCWeatherUnitCelsius;
	} else if (clockInfo.currentWeather.unit == SCWeatherUnitCelsius && [[A3UserDefaults standardUserDefaults] clockUsesFahrenheit]) {
		// convert celsius to fahrenheit
		clockInfo.currentWeather.unit = SCWeatherUnitFahrenheit;
	}

	self.temperatureTopLabel.text = [NSString stringWithFormat:@"%ld°", (long)clockInfo.currentWeather.highTemperature];
	[self.temperatureCircle setTemperature:clockInfo.currentWeather.currentTemperature];
	self.temperatureBottomLabel.text = [NSString stringWithFormat:@"%ld°", (long)clockInfo.currentWeather.lowTemperature];
	if (clockInfo.currentWeather.highTemperature - clockInfo.currentWeather.lowTemperature > 0) {
		self.temperatureCircle.fillPercent = (float)(clockInfo.currentWeather.currentTemperature - clockInfo.currentWeather.lowTemperature) / (float)(clockInfo.currentWeather.highTemperature - clockInfo.currentWeather.lowTemperature);
	}

	[self.weatherImageView setImage:[self.clockDataManager imageForWeatherCondition:clockInfo.currentWeather.condition]];
	self.weatherLabel.text = clockInfo.currentWeather.representation;
}

- (void)changeColor:(UIColor *)color {
	self.view.backgroundColor = color;
	for (NSNumber *typeObject in _circleArray) {
		A3ClockWaveCircleView *view = [self circleViewForType:(A3ClockWaveCircleTypes) typeObject.unsignedIntegerValue];
		[view setFillPercent:view.fillPercent];
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
