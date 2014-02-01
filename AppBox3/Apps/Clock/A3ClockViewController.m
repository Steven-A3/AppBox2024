//
//  A3ClockViewController.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockDataManager.h"
#import "A3ClockWaveViewController.h"

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

@end
