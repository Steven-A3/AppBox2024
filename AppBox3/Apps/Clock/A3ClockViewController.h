//
//  A3ClockViewController.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3ClockInfo;
@class A3ClockDataManager;
@protocol A3ClockDataManagerDelegate;

@interface A3ClockViewController : UIViewController <A3ClockDataManagerDelegate> {
	BOOL _weatherInfoAvailable;
}

@property (nonatomic, assign) BOOL showSeconds;
@property (nonatomic, assign) BOOL showWeather;
@property (nonatomic, assign) BOOL flashSeparator;
@property (nonatomic, assign) BOOL use24hourClock;
@property (nonatomic, assign) BOOL showAMPM;
@property (nonatomic, assign) BOOL showDate;
@property (nonatomic, assign) BOOL showTheDayOfTheWeek;

@property (nonatomic, weak) A3ClockDataManager *clockDataManager;

- (instancetype)initWithClockDataManager:(A3ClockDataManager *)clockDataManager;

- (void)layoutSubviews;

- (void)updateLayout;

- (void)changeColor:(UIColor *)color;

@end
