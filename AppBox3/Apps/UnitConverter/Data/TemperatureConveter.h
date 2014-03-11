//
//  TemperatureConveter.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 10. 28..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemperatureConveter : NSObject

+ (float)convertToCelsiusFromUnit:(NSString *)unitName andTemperature:(float)value;
+ (float)convertCelsius:(float)value toUnit:(NSString *)unitName;
+ (NSString *)rateStringFromTemperUnit:(NSString *)fromUnitName toTemperUnit:(NSString *)toUnitName;

@end
