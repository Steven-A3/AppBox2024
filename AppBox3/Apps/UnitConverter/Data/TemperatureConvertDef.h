//
//  TemperatureConvertDef.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 10. 28..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#ifndef A3TeamWork_TemperatureConvertDef_h
#define A3TeamWork_TemperatureConvertDef_h

#define TemperUnit_C2F(value)           value * 1.8 + 32
#define TemperUnit_C2Kelvin(value)      value + 273.15
#define TemperUnit_C2Rankine(value)     value * 1.8 + 491.67
#define TemperUnit_C2Reaumure(value)    value * 0.8

#define TemperUnit_F2C(value)           (value - 32) / 1.8
#define TemperUnit_Kelvin2C(value)      value - 273.15
#define TemperUnit_Rankine2C(value)     (value - 491.67) / 1.8
#define TemperUnit_Reaumure2C(value)    value / 0.8

#endif
