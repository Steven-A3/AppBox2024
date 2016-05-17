//
//  A3PedometerHandler.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/16/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3PedometerViewController.h"
#import "A3PedometerHandler.h"

/**
 *  km를 사용할지, mi을 사용할지 결정
 *  사용자 Locale에 따라 Default값을 결정한다.
 *  NSLocale, NSLocaleUsesMetricSystem
 */
NSString *const A3PedometerSettingsUsesMetricSystem = @"A3PedometerSettingsUsesMetricSystem";
/**
 *  Default 값은 10,000
 *  사용자가 설정한 목표 걸음의 수
 */
NSString *const A3PedometerSettingsNumberOfGoalSteps = @"A3PedometerSettingsNumberOfGoalSteps";

@interface A3PedometerHandler ()

@end

@implementation A3PedometerHandler

- (UIColor *)colorForPercent:(double)barPercent {
	if (barPercent < 0.5) {
		return [self colorForLessThan50Percent];
	} else if (barPercent < 1.0) {
		return [self colorForLessThan100Percent];
	} else {
		return [self colorForMoreThan100Percent];
	}
}

- (UIColor *)colorForLessThan50Percent {
	return [UIColor colorWithRed:252.0/255.0 green:82.0/255.0 blue:42.0/255.0 alpha:1.0];
}

- (UIColor *)colorForLessThan100Percent {
	return [UIColor colorWithRed:250.0/255.0 green:119.0/255.0 blue:47.0/255.0 alpha:1.0];
}

- (UIColor *)colorForMoreThan100Percent {
	return [UIColor colorWithRed:112.0/255.0 green:182.0/255.0 blue:45.0/255.0 alpha:1.0];
}

- (NSString *)stringFromDistance:(NSNumber *)distance {
	NSDictionary *result = [self distanceValueForMeasurementSystemFromDistance:distance];
	return [NSString stringWithFormat:@"%@ %@", result[@"value"], result[@"unit"]];
}

- (BOOL)usesMetricSystem {
	id userSetting = [[NSUserDefaults standardUserDefaults] objectForKey:A3PedometerSettingsUsesMetricSystem];
	BOOL usesMetricSystem;
	if (userSetting) {
		usesMetricSystem = [userSetting boolValue];
	} else {
		usesMetricSystem = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
	}
	return usesMetricSystem;
}

- (NSDictionary *)distanceValueForMeasurementSystemFromDistance:(NSNumber *)distance {
	if ([self usesMetricSystem]) {
		double kms = [distance doubleValue] / 1000;
		return @{@"unit":@"km", @"value": [self.numberFormatter stringFromNumber:@(kms)]};
	} else {
		double miles = [distance doubleValue] * 0.00062137119223733398438;
		return @{@"unit":@"mi", @"value": [self.numberFormatter stringFromNumber:@(miles)]};
	}
}

- (NSNumberFormatter *)numberFormatter {
	if (!_numberFormatter) {
		_numberFormatter = [NSNumberFormatter new];
		[_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		_numberFormatter.maximumFractionDigits = 1;
	}
	return _numberFormatter;
}

@end
