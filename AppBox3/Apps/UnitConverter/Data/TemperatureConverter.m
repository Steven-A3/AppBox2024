//
//  TemperatureConverter.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 10. 28..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "TemperatureConverter.h"
#import "TemperatureConvertDef.h"

static NSString *const celsius = @"celsius";
static NSString *const fahrenheit = @"fahrenheit";
static NSString *const kelvin = @"kelvin";
static NSString *const rankine = @"rankine";
static NSString *const reaumure = @"réaumure";

@implementation TemperatureConverter

/*
 "°C",
 "°F",
 "kelvin",
 "rankine",
 "réaumure"
 */

/*
 "°C",
 "°F",
 "K",
 "°R",
 "°Ré"
 */

+ (float)convertToCelsiusFromUnit:(NSString *)unitName andTemperature:(float)value
{
    if ([unitName isEqualToString:celsius]) {
        return value;
    }
    else if ([unitName isEqualToString:fahrenheit]) {
        return TemperUnit_F2C(value);
    }
    else if ([unitName isEqualToString:kelvin]) {
        return TemperUnit_Kelvin2C(value);
    }
    else if ([unitName isEqualToString:rankine]) {
        return TemperUnit_Rankine2C(value);
    }
    else if ([unitName isEqualToString:reaumure]) {
        return TemperUnit_Reaumure2C(value);
    }
    else return 0;
}

+ (float)convertCelsius:(float)value toUnit:(NSString *)unitName
{
    if ([unitName isEqualToString:celsius]) {
        return value;
    }
    else if ([unitName isEqualToString:fahrenheit]) {
        return TemperUnit_C2F(value);
    }
    else if ([unitName isEqualToString:kelvin]) {
        return TemperUnit_C2Kelvin(value);
    }
    else if ([unitName isEqualToString:rankine]) {
        return TemperUnit_C2Rankine(value);
    }
    else if ([unitName isEqualToString:reaumure]) {
        return TemperUnit_C2Reaumure(value);
    }
    else return 0;
}

/*
 "°C",
 "°F",
 "kelvin",
 "rankine",
 "réaumure"
 */

/*
 "°C",
 "°F",
 "K",
 "°R",
 "°Ré"
 */

+ (NSString *)rateStringFromTemperUnit:(NSString *)fromUnitName toTemperUnit:(NSString *)toUnitName
{
	NSString *fromUnit = [fromUnitName uppercaseString], *toUnit = [toUnitName uppercaseString];
    NSArray *temperUnitNames = @[
								 [celsius uppercaseString],
								 [fahrenheit uppercaseString],
								 [kelvin uppercaseString],
								 [rankine uppercaseString],
								 [reaumure uppercaseString]
								 ];
    if ([fromUnit isEqualToString:temperUnitNames[0]]) {
        if ([toUnit isEqualToString:temperUnitNames[1]]) {
            // °C -> °F
            return @"°F = °Cx1.8+32.00";
        }
        else if ([toUnit isEqualToString:temperUnitNames[2]]) {
            // °C -> K
            return @"K = °C+273.15";
        }
        else if ([toUnit isEqualToString:temperUnitNames[3]]) {
            // °C -> °R
            return @"°R = °Cx1.8+491.67";
        }
        else if ([toUnit isEqualToString:temperUnitNames[4]]) {
            // °C -> °Ré
            return @"°Ré = °Cx0.8";
        }
    }
    else if ([fromUnit isEqualToString:temperUnitNames[1]]) {
        if ([toUnit isEqualToString:temperUnitNames[0]]) {
            // °F -> °C
            return @"°C = (°F-32.00)/1.8";
        }
        else if ([toUnit isEqualToString:temperUnitNames[2]]) {
            // °F -> K
            return @"K = (°F-32.00)/1.8+273.15";
        }
        else if ([toUnit isEqualToString:temperUnitNames[3]]) {
            // °F -> °R
            return @"°R = (°F-32.00)+491.67";
        }
        else if ([toUnit isEqualToString:temperUnitNames[4]]) {
            // °F -> °Ré
            return @"°F = (°Ré-32.00)/2.25";
        }
    }
    else if ([fromUnit isEqualToString:temperUnitNames[2]]) {
        if ([toUnit isEqualToString:temperUnitNames[0]]) {
            // K -> °C
            return @"°C = K-273.15";
        }
        else if ([toUnit isEqualToString:temperUnitNames[1]]) {
            // K -> °F
            return @"°F = (K-273.15)x1.8+32.00";
        }
        else if ([toUnit isEqualToString:temperUnitNames[3]]) {
            // K -> °R
            return @"°R = (K-273.15)x1.8+491.67";
        }
        else if ([toUnit isEqualToString:temperUnitNames[4]]) {
            // K -> °Ré
            return @"°Ré = (K-273.15)x0.8";
        }
    }
    else if ([fromUnit isEqualToString:temperUnitNames[3]]) {
        if ([toUnit isEqualToString:temperUnitNames[0]]) {
            // °R -> °C
            return @"°C = (°R-491.67)/1.8";
        }
        else if ([toUnit isEqualToString:temperUnitNames[1]]) {
            // °R -> °F
            return @"°F = (°R-491.67)+32.00";
        }
        else if ([toUnit isEqualToString:temperUnitNames[2]]) {
            // °R -> K
            return @"K = (°R-491.67)/1.8+273.15";
        }
        else if ([toUnit isEqualToString:temperUnitNames[4]]) {
            // °R -> °Ré
            return @"°Ré = (°R-491.67)/2.25";
        }
    }
    else if ([fromUnit isEqualToString:temperUnitNames[4]]) {
        if ([toUnit isEqualToString:temperUnitNames[0]]) {
            // °Ré -> °C
            return @"°C = °Ré/0.8";
        }
        else if ([toUnit isEqualToString:temperUnitNames[1]]) {
            // °Ré -> °F
            return @"°F = °Réx2.25+32.00";
        }
        else if ([toUnit isEqualToString:temperUnitNames[2]]) {
            // °Ré -> K
            return @"K = °Réx1.25+273.15";
        }
        else if ([toUnit isEqualToString:temperUnitNames[3]]) {
            // °Ré -> °R
            return @"°R = °Réx2.25+491.67";
        }
    }
    
    return @"";
}

@end
