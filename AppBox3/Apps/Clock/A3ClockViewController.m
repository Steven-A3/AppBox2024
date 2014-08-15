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
#import "A3UserDefaults+A3Defaults.h"

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
	return [[A3UserDefaults standardUserDefaults] clockTheTimeWithSeconds];
}

- (BOOL)showWeather {
	return [[A3UserDefaults standardUserDefaults] clockShowWeather];
}

- (BOOL)flashSeparator {
	return [[A3UserDefaults standardUserDefaults] clockFlashTheTimeSeparators];
}

- (BOOL)use24hourClock {
	return [[A3UserDefaults standardUserDefaults] clockUse24hourClock];
}

- (BOOL)showAMPM {
	return [[A3UserDefaults standardUserDefaults] clockShowAMPM];
}

- (BOOL)showDate {
	return [[A3UserDefaults standardUserDefaults] clockShowDate];
}

- (BOOL)showTheDayOfTheWeek {
	return [[A3UserDefaults standardUserDefaults] clockShowTheDayOfTheWeek];
}

@end
