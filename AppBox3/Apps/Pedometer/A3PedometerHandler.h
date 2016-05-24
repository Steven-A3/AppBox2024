//
//  A3PedometerHandler.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/16/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const A3PedometerSettingsUsesMetricSystem;
extern NSString *const A3PedometerSettingsNumberOfGoalSteps;

@interface A3PedometerHandler : NSObject

@property (nonatomic, strong) NSNumberFormatter *integerFormatter;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

- (UIColor *)colorForPercent:(double)barPercent;
- (UIColor *)colorForLessThan50Percent;
- (UIColor *)colorForLessThan100Percent;
- (UIColor *)colorForMoreThan100Percent;

- (NSString *)stringFromDistance:(NSNumber *)distance;

- (BOOL)usesMetricSystem;

- (NSDictionary *)distanceValueForMeasurementSystemFromDistance:(NSNumber *)distance;
@end
