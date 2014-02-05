//
//  A3ClockViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockDataManager.h"
#import "A3ClockLEDViewController.h"
#import "A3ClockDataManager.h"
#import "A3ClockWaveViewController.h"
#import "NSUserDefaults+A3Defaults.h"

@interface A3ClockViewController ()

@end

@implementation A3ClockViewController

- (instancetype)initWithClockDataManager:(A3ClockDataManager *)clockDataManager {
	self = [super init];
	if (self) {
		_clockDataManager = clockDataManager;
	}
	return self;
}

#pragma mark - Public

- (void)changeColor:(UIColor *)color {

}

- (void)layoutSubviews {

}

- (void)updateLayout {
}

- (BOOL)showSeconds {
	return [[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds];
}

- (BOOL)showWeather {
	return [[NSUserDefaults standardUserDefaults] clockShowWeather];
}

- (BOOL)flashSeparator {
	return [[NSUserDefaults standardUserDefaults] clockFlashTheTimeSeparators];
}

- (BOOL)use24hourClock {
	return [[NSUserDefaults standardUserDefaults] clockUse24hourClock];
}

- (BOOL)showAMPM {
	return [[NSUserDefaults standardUserDefaults] clockShowAMPM];
}

- (BOOL)showDate {
	return [[NSUserDefaults standardUserDefaults] clockShowDate];
}

- (BOOL)showTheDayOfTheWeek {
	return [[NSUserDefaults standardUserDefaults] clockShowTheDayOfTheWeek];
}

@end
