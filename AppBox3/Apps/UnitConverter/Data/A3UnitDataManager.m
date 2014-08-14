//
//  A3UnitDataManager.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitDataManager.h"
#import "A3UserDefaults.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

BOOL validUnit(NSNumber *value) {
	return [value integerValue] != -1;
}

@implementation A3UnitDataManager

const int numOfUnitType = 17;

const int numberOfUnits[] = {16, 19, 14, 31, 21, 24, 27, 12, 7, 32, 23, 34, 23, 5, 23, 31, 17 };

const char *unitTypes[] = {
    "Angle",
    "Area",
    "Bits",
    "Cooking",
    "Density",
    "Electric Current",
    "Energy",
    "Force",
    "Fuel Consumption",
    "Length",
    "Power",
    "Pressure",
    "Speed",
    "Temperature",
    "Time",
    "Volume",
    "Weight"
};


const char *unitNames[][34] = {
    // Angle, 16
    {
        "arcminute",		// 0
        "arcsecond",		// 1
        "circle",			// 2
        "degree",			// 3
        "gon",				// 4
        "grad",				// 5
        "mil(Nato)",		// 6
        "mil(Soviet Union)",// 7
        "mil(Sweden)",		// 8
        "octant",			// 9
        "quadrant",			// 10
        "radian",			// 11
        "revolution",		// 12
        "sextant",			// 13
        "sign",				// 14
        "turn"				// 15
    },
    
    // Area, 19
    {
        "acres",				// 0
        "ares",					// 1
        "circular inches",		// 2
        "hectares",				// 3
        "hides",				// 4
        "roods",				// 5
        "cm²",					// 6
        "feet²(US&UK)",			// 7
        "feet²(US Survey)",		// 8
        "inches²",				// 9
        "km²",					// 10
        "m²",					// 11
        "miles²",				// 12
        "mm²",					// 13
        "squares(of timber)",	// 14
        "rods²(or poles²)",		// 15
        "yards²",				// 16
        "townships",			// 17
        "pyung"					// 18
    },
    
    // Bits and bytes, 14
    {
        "bits",					// 0
        "bytes",				// 1
        "kilobits",				// 2
        "kilobytes",			// 3
        "megabits",				// 4
        "megabytes",			// 5
        "gigabits",				// 6
        "gigabytes",			// 7
        "terabits",				// 8
        "terabytes",			// 9
        "petabits",				// 10
        "petabytes",			// 11
        "exabits",				// 12
        "exabytes"				// 13
    },
    
    // Cooking, 31
    {
        "cup [US]",				// 0
        "cup [metric]",			// 1
        "dash",					// 2
        "demi",					// 3
        "dessertspoon",			// 4
        "dram",					// 5
        "drop",					// 6
        "gallon [US]",			// 7
        "gallon [UK]",			// 8
        "jigger",				// 9
        "kiloliter",			// 10
        "liter",				// 11
        "milliliter",			// 12
        "ounce [US]",			// 13
        "ounce [UK]",			// 14
        "peck [US]",			// 15
        "peck [UK]",			// 16
        "pinch",				// 17
        "pint [US]",			// 18
        "pint [UK]",			// 19
        "pony",					// 20
        "quart [US]",			// 21
        "quart [UK]",			// 22
        "shot",					// 23
        "tablespoon[US]",		// 24
        "tablespoon[UK]",		// 25
        "tablespoon[metric]",	// 26
        "teaspoon[US]",			// 27
        "teaspoon[UK]",			// 28
        "teaspoon[metric]",		// 29
        "teacup[UK]",			// 30
    },
    
    // Density, 21
    {
        "grains/gallon(UK)",	// 0
        "grains/gallon(US)",	// 1
        "grams/cm³",			// 2
        "grams/liter",			// 3
        "grams/mm",				// 4
        "kilograms/m³",			// 5
        "kilograms/liter",		// 6
        "megagrams/m³",			// 7
        "milligrams/mm",		// 8
        "milligrams/liter",		// 9
        "ounces/inch³",			// 10
        "ounces/gallon(UK)",	// 11
        "ounces/gallon(US)",	// 12
        "pounds/inch³",			// 13
        "pounds/foot³",			// 14
        "pounds/gallon(UK)",	// 15
        "pounds/gallon(US)",	// 16
        "slugs/foot³",			// 17
        "tonnes/m³",			// 18
        "tons(UK)/yard³",		// 19
        "tons(US)/yard³"		// 20
    },
    
    // Electric Current, 24
    {
        "abampere [abA]",	// 0
        "ampere [A]",		// 1
        "biot [Bi]",		// 2
        "centiampere",		// 3
        "coulomb/second",	// 4
        "EMU of current",	// 5
        "ESU of current",	// 6
        "franklin/second",	// 7
        "Gaussian",			// 8
        "gigaampere",		// 9
        "gilbert [Gi]",		// 10
        "kiloampere [kA]",	// 11
        "megaampere",		// 12
        "microampere",		// 13
        "milliampere",		// 14
        "milliamp",			// 15
        "nanoampere",		// 16
        "picoampere",		// 17
        "siemens volt",		// 18
        "statampere [stA]",	// 19
        "teraampere",		// 20
        "volt/ohm",			// 21
        "watt/volt",		// 22
        "weber/henry"		// 23
    },
    
    // Energy, 27
    {
        "Btu(th)",					// 0
        "Btu(mean)",				// 1
        "calories(IT)",				// 2
        "calories(th)",				// 3
        "calories(mean)",			// 4
        "calories(15C)",			// 5
        "calories(20C)",			// 6
        "calories(food)",			// 7
        "centigrade heat units",	// 8
        "electron volts",			// 9
        "ergs",						// 10
        "foot-pound force",			// 11
        "foot poundals",			// 12
        "gigajoules",				// 13
        "horsepower hours",			// 14
        "inch-pound force",			// 15
        "joules",					// 16
        "kilocalories(IT)",			// 17
        "kilocalories(th)",			// 18
        "kg-force meters",			// 19
        "kilojoules",				// 20
        "kilowatt hours",			// 21
        "megajoules",				// 22
        "newton meters",			// 23
        "therms",					// 24
        "watt seconds",				// 25
        "watt hours"				// 26
    },
    
    // Force, 12
    {
        "dynes",					// 0
        "kilograms force",			// 1
        "kilonewtons",				// 2
        "kips",						// 3
        "meganewtons",				// 4
        "newtons",					// 5
        "pounds force",				// 6
        "poundals",					// 7
        "sthenes(=kN)",				// 8
        "tonnes force",				// 9
        "tons force(UK)",			// 10
        "tons force(US)"			// 11
    },
    
    // Fuel Consumption, 7
    {
        "gal(UK)/100miles",         // 0
        "gal(US)/100miles",         // 1
        "kilometer/liter",          // 2
        "liters/100km",             // 3
        "liters/meter",             // 4
        "miles/gal(UK)",            // 5
        "miles/gal(US)"             // 6
    },
    
    // Length, 32
    {
        "ångströms Å",				// 0
        "astronomical units",		// 1
        "barleycorns",				// 2
        "cables",					// 3
        "centimeters",				// 4
        "chains(surveyors')",		// 5
        "decimeters",				// 6
        "ells(UK)",					// 7
        "ems(pica)",				// 8
        "fathoms",					// 9
        "feet(UK&US)",				// 10
        "feet(US survey)",			// 11
        "furlongs",					// 12
        "hands",					// 13
        "hectometers",				// 14
        "inches",					// 15
        "kilometers",				// 16
        "light years",				// 17
        "meters",					// 18
        "micrometers",				// 19
        "mil",						// 20
        "miles(UK&US)",				// 21
        "miles(nautical,intl)",		// 22
        "miles(nautical,UK)",		// 23
        "millimeters",				// 24
        "nanometers",				// 25
        "parsecs",					// 26
        "picometers",				// 27
        "Scandinavian mile",		// 28
        "thou",						// 29
        "yards",					// 30
        "feet inches"				// 31
    },
    
    // Power, 23
    {
        "Btu/hour",					// 0
        "Btu/minute",				// 1
        "Btu/second",				// 2
        "cal(th)/hour",				// 3
        "cal(th)/minute",			// 4
        "cal(th)/second",			// 5
        "fpf/minute",				// 6
        "fpf/second",				// 7
        "gigawatts",				// 8
        "horsepowers(elec.)",		// 9
        "horsepowers(intl)",		// 10
        "horsepowers(water)",		// 11
        "horsepowers(metric)",		// 12
        "watts",					// 13
        "joules/hour",				// 14
        "joules/minute",			// 15
        "joules/second",			// 16
        "kcal(th)/hour",			// 17
        "kcal(th)/minute",			// 18
        "kgf meters/hour",			// 19
        "kgf meters/minute",		// 20
        "kilowatts",				// 21
        "megawatts"					// 22
    },
    
    // Pressure, 34
    {
        "atmospheres",			// 0
        "bars",					// 1
        "cm Hg",				// 2
        "cm H₂O",				// 3
        "feet H₂O",				// 4
        "hectopascals",			// 5
        "inches H₂O",			// 6
        "inches Hg",			// 7
        "kgf/cm²",				// 8
        "kgf/m²",				// 9
        "kilonewtons/m²",		// 10
        "kilonewtons/mm²",		// 11
        "kilopascals",			// 12
        "kips/inch²",			// 13
        "meganewtons/m²",		// 14
        "meganewtons/mm²",		// 15
        "meters H₂O",			// 16
        "millibars",			// 17
        "mm Hg",				// 18
        "mm H₂O",				// 19
        "newtons/cm²",			// 20
        "newtons/m²",			// 21
        "newtons/mm²",			// 22
        "pascals",				// 23
        "lbf/foot²",			// 24
        "lbf/inch² psi",		// 25
        "poundals/foot²",		// 26
        "tons(UK)-f/foot²",		// 27
        "tons(UK)-f/inch²",		// 28
        "tons(US)-f/foot²",		// 29
        "tons(US)-f/inch²",		// 30
        "tonnes-f/cm²",			// 31
        "tonnes-f/meter²",		// 32
        "torr(mm Hg 0°C)"		// 33
    },
    
    // Speed, 23
    {
        "cm/minute",			// 0
        "cm/second",			// 1
        "feet/hour",			// 2
        "feet/minute",			// 3
        "feet/second",			// 4
        "inches/minute",		// 5
        "inches/second",		// 6
        "km/hour",				// 7
        "km/second",			// 8
        "knots",				// 9
        "Mach number(ISA)",		// 10
        "meters/hour",			// 11
        "meters/minute",		// 12
        "meters/second",		// 13
        "miles/hour",			// 14
        "miles/minute",			// 15
        "miles/second",			// 16
        "nautical miles/hour",	// 17
        "Nm/24hr(Volvo)",		// 18
        "speed of light",		// 19
        "yards/hour",			// 20
        "yards/minute",			// 21
        "yards/second"			// 22
    },
    
    // Temperature, 5
    {
		"celsius",        //        "°C",
		"fahrenheit",        //        "°F",
        "kelvin",   //        "kelvin",
        "rankine",  //        "rankine",
        "réaumure"  //        "réaumure"
    },
    
    // Time, 23
    {
        "centuries",			// 0
        "days",					// 1
        "decades",				// 2
        "femtoseconds",			// 3
        "fortnights",			// 4
        "hours",				// 5
        "microseconds",			// 6
        "millennia",				// 7
        "milliseconds",			// 8
        "minutes",				// 9
        "months(Common)",		// 10
        "months(Synodic)",		// 11
        "nanoseconds",			// 12
        "picoseconds",			// 13
        "quarters(Common)",		// 14
        "seconds",				// 15
        "shakes",				// 16
        "weeks",				// 17
        "years(Common)",		// 18
        "years(Avg Gregorian)",	// 19
        "years(Julian)",		// 20
        "years(Leap)",			// 21
        "years(Tropical)"		// 22
    },
    
    // Volume, 31
    {
        "acre foot",		// 0
        "barrels(oil)",		// 1
        "bushels(UK)",		// 2
        "bushels(US)",		// 3
        "centiliters",		// 4
        "cm³",				// 5
        "decimeters³",		// 6
        "decameters³",		// 7
        "feet³",			// 8
        "inches³",			// 9
        "meters³",			// 10
        "millimeters³",		// 11
        "yards³",			// 12
        "cups",				// 13
        "deciliters",		// 14
        "fluid ounces(UK)",	// 15
        "fluid ounces(US)",	// 16
        "gallons(UK)",		// 17
        "gallons,dry(US)",	// 18
        "gallons,liquid(US)",// 19
        "liters",			// 20
        "liters(1901-1964)",// 21
        "milliliters",		// 22
        "pints(UK)",		// 23
        "pints,dry(US)",	// 24
        "pints,liquid(US)",	// 25
        "quarts(UK)",		// 26
        "quarts,dry(US)",	// 27
        "quarts,liquid(US)",// 28
        "table spoons",		// 29
        "tea spoons"		// 30
    },
    
    // Weight, 17
    {
        "carats(metric)",	// 0
        "cental",			// 1
        "Earth masses",		// 2
        "grains",			// 3
        "grams",			// 4
        "hundredweights",	// 5
        "kilograms",		// 6
        "ounces(US & UK)",	// 7
        "ounces(troy)",		// 8
        "pounds(US & UK)",	// 9
        "pounds(troy)",		// 10
        "Solar masses",		// 11
        "slugs(g-pounds)",	// 12
        "stones",			// 13
        "tons(UK or long)",	// 14
        "tons(US or short)",// 15
        "tonnes"			// 16
    }
};

const char *unitShortNames[][34] = {
    // Angle, 16
    {
        "′",
        "″",
        "circle",
        "°",
        "gon",
        "grad",
        "mil",
        "mil",
        "mil",
        "octant",
        "quadrant",
        "radian",
        "revolution",
        "sextant",
        "sign",
        "turn"
    },
    
    // Area, 19
    {
        "acres",
        "ares",
        "cir in",
        "ha",
        "hides",
        "roods",
        "cm²",
        "ft²",
        "ft²",
        "in²",
        "km²",
        "m²",
        "miles²",
        "mm²",
        "squares",
        "rods²",
        "yards²",
        "townships",
        "pyung"
    },
    
    // Bits and bytes
    {
        "bits",
        "bytes",
        "kilobits",
        "kilobytes",
        "megabits",
        "megabytes",
        "gigabits",
        "gigabytes",
        "terabits",
        "terabytes",
        "petabits",
        "petabytes",
        "exabits",
        "exabytes"
    },
    
    // Cooking
    {
        "cup",
        "cup",
        "dash",
        "demi",
        "spoon",
        "dram",
        "drop",
        "gallon",
        "gallon",
        "jigger",
        "kl",
        "liter",
        "ml",
        "ounce",
        "ounce",
        "peck",
        "peck",
        "pinch",
        "pint",
        "pint",
        "pony",
        "quart",
        "quart",
        "shot",
        "spoon",
        "spoon",
        "spoon",
        "spoon",
        "spoon",
        "spoon",
        "teacup",
    },
    
    // Density, 21
    {
        "grains/gal",
        "grains/gal",
        "g/cm³",
        "g/l",
        "g/mm",
        "kg/m³",
        "kg/l",
        "megag/m³",
        "mg/mm",
        "mg/l",
        "oz/inch³",
        "oz/gal",
        "oz/gal",
        "lbs/inch³",
        "lbs/ft³",
        "lbs/gal",
        "lbs/gal",
        "slugs/ft³",
        "tonnes/m³",
        "tons/y³",
        "tons/y³"
    },
    
    // Electric Current, 24
    {
        "abA",
        "A",
        "Bi",
        "ca",
        "coulomb/s",
        "EMU",
        "ESU",
        "franklin/s",
        "gause",
        "ga",
        "Gi",
        "kA",
        "megaA",
        "µA",
        "mA",
        "mA",
        "nanoA",
        "picoA",
        "volt",
        "stA",
        "teraA",
        "volt/ohm",
        "watt/volt",
        "w/h"
    },
    
    // Energy, 27
    {
        "Btu",
        "Btu",
        "cal",
        "cal",
        "cal",
        "cal",
        "cal",
        "cal",
        "cen",
        "eV",
        "ergs",
        "ft lbf",
        "fp",
        "GJ",
        "hp h",
        "in lbf",
        "j",
        "kcal",
        "kcal",
        "kgf m",
        "kJ",
        "kWh",
        "MJ",
        "Nm",
        "therms",
        "Ws",
        "Wh"
    },
    
    // Force, 12
    {
        "dynes",
        "kgf",
        "kN",
        "kips",
        "MN",
        "N",
        "pf",
        "p",
        "sthenes",
        "tf",
        "tf",
        "tf"
    },
    
    // Fuel Comsumption, 7
    {
        "gal/100mi",
        "gal/100mi",
        "km/l",
        "l/100km",
        "l/m",
        "mpg",
        "mpg"
    },
    
    // Length, 32
    {
        "Å",
        "AU",
        "barleycorns",
        "cables",
        "cm",
        "chains",
        "decimeters",
        "ells",
        "ems",
        "fathoms",
        "feet",
        "feet",
        "furlongs",
        "hands",
        "hm",
        "in",
        "km",
        "light years",
        "m",
        "µm",
        "mil",
        "miles",
        "miles",
        "miles",
        "mm",
        "nm",
        "parsecs",
        "picometers",
        "mile",
        "thou",
        "yards",
        "ft in"
    },
    
    // Power, 23
    {
        "Btu/h",
        "Btu/m",
        "Btu/s",
        "cal/h",
        "cal/m",
        "cal/s",
        "fpf/m",
        "fpf/s",
        "GW",
        "hp",
        "hp",
        "hp",
        "hp",
        "W",
        "joules/h",
        "joules/m",
        "joules/s",
        "kcal/h",
        "kcal/m",
        "kgf/h",
        "kgf/m",
        "kW",
        "MW"
    },
    
    // Pressure, 34
    {
        "atm",
        "bars",
        "cmHg",
        "cmH₂O",
        "fH₂O",
        "hPa",
        "inH₂O",
        "inHg",
        "kgf/cm²",
        "kgf/m²",
        "kn/m²",
        "kn/mm²",
        "kPa",
        "kips/in²",
        "mn/m²",
        "mn/mm²",
        "m",
        "mbars",
        "mmHg",
        "mmH₂O",
        "N/cm²",
        "N/m²",
        "N/mm²",
        "Pa",
        "pf/ft²",
        "psi",
        "poundals/ft²",
        "tf/ft²",
        "tf/in²",
        "tf/ft²",
        "tf/in²",
        "tf/cm²",
        "tf/m²",
        "torr"
    },
    
    // Speed, 23
    {
        "cm/m",
        "cm/s",
        "f/h",
        "f/m",
        "f/s",
        "in/m",
        "in/s",
        "km/h",
        "km/s",
        "knots",
        "Mach",
        "m/h",
        "m/m",
        "m/s",
        "mi/h",
        "mi/m",
        "mi/s",
        "nm/h",
        "Nm/24hr",
        "light",
        "y/h",
        "y/m",
        "y/s"
    },
    
    // Temperature, 3
    {
		"°C",       //      celsius
		"°F",       //      fahrenheit
        "K",
        "°R",
        "°Ré"
    },
    
    // Time, 23
    {
        "century",
        "days",
        "decades",
        "fs",
        "fortnights",
        "hours",
        "μs",
        "millennia",
        "ms",
        "minutes",
        "months",
        "months",
        "ns",
        "ps",
        "quarters",
        "seconds",
        "shakes",
        "weeks",
        "years",
        "years",
        "years",
        "years",
        "years"
    },
    
    // Volume, 31
    {
        "acre foot",
        "barrels",
        "bushels",
        "bushels",
        "cl",
        "cm³",
        "dm³",
        "dam³",
        "ft³",
        "in³",
        "m³",
        "mm³",
        "yd³",
        "cups",
        "dL",
        "fluid oz",
        "fluid oz",
        "gallons",
        "gallons",
        "gallons",
        "liters",
        "liters",
        "ml",
        "pints",
        "pints",
        "pints",
        "quarts",
        "quarts",
        "quarts",
        "spoon",
        "spoon"
    },
    
    // Weight, 17
    {
        "carats",
        "cental",
        "em",
        "grains",
        "g",
        "hw",
        "kg",
        "oz",
        "oz",
        "lbs",
        "lbs",
        "sm",
        "slugs",
        "stones",
        "tons",
        "tons",
        "tonnes"
    }
};

const double conversionTable[][34] = {
    // Angle, 16
    {
        1.0/(360.0*60.0),						// arcminute, value / 360*60
        1.0/(360.0*3600.0),						// arcsecond, value / (360*3600)
        1.0,									// circle
        1.0/360.0,								// degree, value/360
        1.0/400.0,								// gon, value / 400
        1.0/400.0,								// grad, value/400
        1.0/6400.0,								// mil (Nato), value / 6400
        1.0/6000.0,								// mil (Soviet Union), value / 6000
        1.0/6300.0,								// mil (Sweden), value/6300
        0.125,									// octant
        0.25,									// quadrant
        1.0/(2.0*M_PI),							// radian, value / (2*PI)
        1.0,									// revolution
        1.0/6.0,								// sextant, value / 6
        1.0/12.0,								// sign, value / 12
        1.0										// turn
    },
    
    // Area, 19
    {
        4046.8564224,							// "acres"
        100,									// "ares"
        0.000506707479,							// "circular inches"
        1e4,									// "hectares"
        485000,  								// "hides"
        1011.7141056,							// "roods"
        1e-4,									// "square centimeters"
        0.09290304,								// "square feet (US &amp; UK)"
        0.092903411613,							// "square feet (US survey)"
        0.00064516,								// "square inches"
        1e6,									// "square kilometers"
        1,										// "square meters"
        2589988.110336,							// "square miles"
        1e-6,									// "square millimeters"
        9.290304,								// "squares (of timber)"
        25.29285264,							// "square rods (or poles)",
        0.83612736,								// "square yards",
        93239571.972,							// "townships"
        3.30578512								// "Pyeong"
    },
    
    // Bits and bytes, 14
    {
        0.125,							// bits
        1,								// bytes
        128,							// kilobits
        1024,							// kilobytes
        131072,							// megabits
        1048576,						// megabytes
        134217728,						// gigabits
        1073741824,						// gigabytes
        137438953472,					// terabits
        1099511627776,					// terabytes
        140737488355328,				// petabits
        1125899906842624,				// petabytes
        144115188075855872,				// exabits
        1152921504606846976				// exabytes
    },
    
    // Cooking
    {
        4.2267528377303747,				// cup [US]
        4,								// cup [metric]
        1623.0730828,					// dash
        4,								// demi
        100,							// dessertspoon
        270.5121805,					// dram
        19476.8769939,					// drop
        0.2641720523581484,				// gallon [US]
        0.21996924829908778,			// gallon [UK]
        22.542681801,					// jigger
        0.001,							// kiloliter
        1,								// liter
        1000,							// milliliter
        33.814022701843,				// ounce [US]
        35.19507972785405,				// ounce [UK]
        0.1135104,						// peck [US]
        0.1099846,						// peck [UK]
        3246.1461657,					// pinch
        2.1133764188651873,				// pint [US]
        1.7597539863927022,				// pint [UK]
        33.8140226,						// pony
        1.0566882094325937,				// quart [US]
        0.8798769931963511,				// quart [UK]
        33.814022702,					// shot
        67.628045403685994,				// tablespoon [US]
        70.3901595,						// tablespoon [UK]
        66.666,							// tablespoon [metric]
        202.884136211058,				// teaspoon [US]
        281.560637,						// teaspoon [UK]
        200,							// teaspoon [metric]
        5.279262,						// teacup [UK]
    },
    
    // Density, 21
    {
        0.000014253948343691203,		// grains/gallon (UK)
        0.000017118011571775823,		// grains/gallon (US)
        1,								// grams/cubic centimeters
        1e-3,							// grams/liter
        1,								// grams/milliliters
        1e-3,							// kilograms/cubic meters
        1,								// kilograms/liter
        1,								// megagrams/cubic meter
        1e-3,							// milligrams/millimeter
        1e-6,							// milligrams/liter
        1.729994044,					// ounces/cubic inch
        0.006236023,					// ounces/gallon (UK)
        0.007489152,					// ounces/gallon (US)
        27.679904,						// pounds/cubic inch
        0.016018463,					// pounds/cubic foot
        0.099776373,					// pounds/gallon (UK)
        0.119826427,					// pounds/gallon (US)
        0.51531788206,					// slugs/cubic foot
        1,								// tonnes/cubic meter
        1.328939184,					// tons (UK)/cubic yard
        1.186552843						// tons (US)/cubic yard
    },
    
    
    // Electric Current, 24
    {
        10,								// abampere [abA]
        1,								// ampere [A]
        10,								// biot [Bi]
        0.01,							// centiampere
        1,								// coulomb/second
        10,								// EMU of current
        3.335641e-10,					// ESU of current
        3.335641e-10,					// franklin/second
        3.335641e-10,					// gaussian electric current
        1e+9,							// gigaampere
        0.79577472,						// gilbert [Gi]
        1e3,							// kiloampere [kA]
        1e6,							// megaampere
        1e-6,							// microampere
        1e-3,							// milliampere
        1e-3,							// milliamp
        1e-9,							// nanoampere
        1e-12,							// picoampere
        1,								// siemens volt
        3.335641e-10,					// statampere [stA]
        1e+12,							// teraampere
        1,								// volt/ohm
        1,								// watt/volt
        1								// weber/henry
    },
    
    // Energy, 27
    {
        1054.350,					// Btu (th)
        1055.87,					// Btu (mean)
        4.1868,						// calories (IT)
        4.184,						// calories (th)
        4.19002,					// calories (mean)
        4.18580,					// calories (15C)
        4.18190,					// calories (20C)
        4186,						// calories (food)
        1900.4,						// centigrade heat units
        1.60219e-19,				// electron volts [eV]
        1e-7,						// ergs
        1.3558179483314004,			// foot-pound force [ft lbf]
        0.042140,					// foot poundals
        1e9,						// gigajoules [GJ]
        2684520,					// horsepower hours
        0.11298482902761668,		// inch-pound force [in lbf]
        1,							// joules [j]
        4186.8,						// kilocalories (IT)
        4184,						// kilocalories (th)
        9.80665,					// killogram-force meters
        1e3,						// kilojoules [kJ]
        3600000,					// kilowatt hours [kWh]
        1e6,						// megajoules [MJ]
        1,							// newton meters [Nm]
        105505585.257348,			// therms
        1,							// watt seconds [Ws]
        3600						// watt hours [Wh]
    },
    
    // Force, 12
    {
        1e-5,						// dynes
        9.80665,					// kilograms force
        1000,						// kilonewtons [kN]
        4448.222,					// kips
        1e6,						// meganewtons [MN]
        1,							// newtons [N]
        4.4482216152605,			// pounds force
        0.138255,					// poundals
        1000,						// sthenes (=kN)
        9806.65,					// tonnes force
        9964.01641818352,			// tons force (UK)
        8896.443230521				// tons force (US)
    },
    
    // Fuel Comsumption, 7
    {
        2.8248093633182215859381213711925e-5,	// gallons (UK)/100 miles
        2.3521458333333333333333333333333e-5,	// gallons (US)/100 miles
        0.001,									// kilometer/liter (km/l)
        0.00001,								// liters/100 kilometer
        1.0,									// liters/meter
        2.8248093633182215859381213711925e-3,	// miles/gallon (UK)(mpg)
        2.3521458333333333333333333333333e-3	// miles/gallon (US)(mpg)
    },
    
    // Length, 32
    {
        1e-10,									// "ångströms Å"
        149598550000,							// "astronomical units AU"
        0.008467,								// "barleycorns"
        182.88,									// "cables"
        0.01,									// "centimeters cm"
        20.116840233680467360934721869444,		// "chains (surveyors')"
        0.1,									// "decimeters"
        0.875,									// "ells (UK)"
        0.0042333,								// "ems (pica)"
        1.8288,									// "fathoms"
        0.3048,									// "feet (UK and US)"
        0.30480060960121920243840487680975,		// "feet (US survey)"
        201.168,								// "furlongs"
        0.1016,									// "hands"
        100,									// "hectometers hm"
        0.0254,									// "inches in"
        1000,									// "kilometers km"
        9.460528405e15,							// "light years"
        1,										// "meters m",
        1e-6,									// "micrometers µm",
        0.0000254,								// "mil",
        1609.344,								// "miles (UK and US)",
        1852,									// "miles (nautical, international)",
        1853.184,								// "miles (nautical, UK)",
        0.001,									// "millimeters mm",
        1e-9,									// "nanometers nm",
        3.0856776e16,							// "parsecs",
        1e-12,									// "picometers",
        10000,									// "Scandinavian mile",
        0.0000254,								// "thou",
        0.9144,									// "yards",
        0.3048,                                 // "feet inch",
    },
    
    // Power, 23
    {
        0.293071,								// "Btu/hour"
        17.584267,								// "Btu/minute"
        1055.056,								// "Btu/second"
        0.001162222222222222,					// "calories(th)/hour"
        0.069733333333333333,					// "calories(th)/minute"
        4.184,									// "calories(th)/second"
        0.022597,								// "foot pounds-force/minute"
        1.35582,								// "foot pounds-force/second"
        1e9,									// "gigawatts GW"
        746,									// "horsepowers (electric)"
        745.69987158227022,						// "horsepowers (international)"
        746.043,								// "horsepowers (water)"
        735.4988,								// "horsepowers (metric)"
        1,										// "watts W"
        0.0002777777777777778,					// "joules/hour"
        0.016666666666666666,					// "joules/minute"
        1,										// "joules/second"
        1.162222222222222222,					// "kilocalories(th)/hour"
        69.73333333333333333,					// "kilocalories(th)/minute"
        0.002724,								// "kilogram-force meters/hour"
        0.163444,								// "kilogram-force meters/minute"
        1e3,									// "kilowatts kW"
        1e6										// "megawatts MW"
    },
    
    // Pressure, 34
    {
        101325,									// "atmospheres"
        1e5,									// "bars"
        1333.22,								// "centimeters mercury"
        98.0665,								// "centimeters water"
        2989.06692,								// "feet of water"
        100,									// "hectopascals hPa"
        249.08891,								// "inches of water"
        3386.388,								// "inches of mercury"
        98066.5,								// "kilogram-forces/sq.centimeter"
        9.80665,								// "kilogram-forces/sq.meter"
        1e3,									// "kilonewtons/sq.meter"
        1e9,									// "kilonewtons/sq.millimeter"
        1000,									// "kilopascals kPa"
        6894760,								// "kips/sq.inch"
        1e6,									// "meganewtons/sq.meter"
        1e12,									// "meganewtons/sq.millimeter"
        9806.65,								// "meters of water"
        100,									// "millibars"
        133.322,								// "millimeters of mercury"
        9.80665,								// "millimeters of water"
        1e4,									// "newtons/sq.centimeter"
        1,										// "newtons/sq.meter"
        1e6,									// "newtons/sq.millimeter"
        1,										// "pascals Pa"
        47.880,									// "pounds-force/sq.foot"
        6894.757,								// "pounds-force/sq.inch psi"
        1.44816,								// "poundals/sq.foot"
        107251,									// "tons (UK)-force/sq.foot"
        15444300,								// "tons (UK)-force/sq.inch"
        95760,									// "tons (US)-force/sq.foot"
        13789500,								// "tons (US)-force/sq.inch"
        98066500,								// "tonnes-force/sq.cm"
        9806.65,								// "tonnes-force/sq.meter"
        133.322									// "torr (mm Hg 0°C)"
    },
    
    // Speed, 23
    {
        0.00016666666666666666,					// "centimeters/minute"
        0.01,									// "centimeters/second"
        0.00008466683600033866,					// "feet/hour"
        0.00508,								// "feet/minute"
        0.3048,									// "feet/second"
        0.0004233341800016934,					// "inches/minute"
        0.0254,									// "inches/second"
        0.2777777777777778,						// "kilometers/hour"
        1000,									// "kilometers/second"
        0.5144444444444444444,					// "knots"
        340.2933,								// "Mach number (ISA/Sea level)"
        0.0002777777777777778,					// "meters/hour"
        0.016666666666666666,					// "meters/minute"
        1,										// "meters/second m/s"
        0.44704,								// "miles/hour"
        26.8224,								// "miles/minute"
        1609.344,								// "miles/second"
        0.5144444444444444444,					// "nautical miles/hour"
        0.0214351851851851851,					// "Nm/24hr (Volvo Ocean Race)"
        2.9979e8,								// "speed of light"
        0.000254000508001016,					// "yards/hour"
        0.01524,								// "yards/minute"
        0.9144									// "yards/second"
    },
    
    // Temperature, 3
    {
        1.0,									// C
        1.0,									// F
        1.0,									// K
        1.0,
        1.0
    },
    
    // Time, 23
    {
        3153600000,								// "centuries"
        86400,									// "days d"
        315360000,								// "decades"
        1e-15,									// "femtoseconds fs"
        1209600,								// "fortnights"
        3600,									// "hours h"
        1e-6,									// "microseconds μs"
        31536000000,							// "millennia"
        1e-3,									// "milliseconds ms"
        60,										// "minutes min"
        2628000,								// "months (Common)"
        2551442.8896,							// "months (Synodic)"
        1e-9,									// "nanoseconds ns"
        1e-12,									// "picoseconds ps"
        7884000,								// "quarters (Common)"
        1,										// "seconds s"
        1e-8,									// "shakes"
        604800,									// "weeks"
        31536000,								// "years (Common) y"
        31556952,								// "years (Average Gregorian)"
        31557600,								// "years (Julian)"
        31622400,								// "years (Leap)"
        31556925.216							// "years (Tropical)"
    },
    
    // Volume, 31
    {
        1233481.83754752,						// "acre foot"
        158.987294928,							// "barrels (oil)"
        36.36872,								// "bushels (UK)"
        35.23907016688,							// "bushels (US)"
        0.01,									// "centiliters"
        1e-3,									// "cubic centimeters"
        1,										// "cubic decimeters"
        1e6,									// "cubic decameters"
        28.316846592,							// "cubic feet"
        0.016387064,							// "cubic inches"
        1e3,									// "cubic meters"
        1e-6,									// "cubic millimeters"
        764.554857984,							// "cubic yards"
        0.2365882365,							// "cups"
        0.1,									// "deciliters"
        0.0284130625,							// "fluid ounces (UK)"
        0.0295735295625,						// "fluid ounces (US)"
        4.54609,								// "gallons (UK)"
        4.40488377086,							// "gallons, dry (US)"
        3.785411784,							// "gallons, liquid (US)"
        1,										// "liters l or L"
        1.000028,								// "liters (1901-1964)"
        1e-3,									// "milliliters"
        0.56826125,								// "pints (UK)"
        0.5506104713575,						// "pints, dry (US)"
        0.473176473,							// "pints, liquid (US)"
        1.1365225,								// "quarts (UK)"
        1.101220942715,							// "quarts, dry (US)"
        0.946352946,							// "quarts, liquid (US)"
        0.01478676478125,						// "table spoons"
        0.00492892159375						// "tea spoons"
    },
    
    // Weight, 17
    {
        0.0002,									// "carats (metric)"
        45.359237,								// "cental"
        5.980e24,								// "Earth masses"
        0.00006479891,							// "grains"
        1e-3,									// "grams"
        50.80234544,							// "hundredweights"
        1,										// "kilograms kg"
        0.028349523125,							// "ounces (US &amp; UK)"
        0.0311034768,							// "ounces (troy, precious metals)"
        0.45359237,								// "pounds lbs (US &amp; UK)"
        0.3732417216,							// "pounds (troy, precious metals)"
        1.989e30,								// "Solar masses"
        14.593903,								// "slugs (g-pounds)"
        6.35029318,								// "stones"
        1016.0469088,							// "tons (UK or long)"
        907.18474,								// "tons (US or short)"
        1000									// "tonnes"
    }
};

/*!
 * \param
 * \returns NSArray of NSDictionary having ID_KEY and NAME_KEY
 */
- (NSArray *)allCategories {
	NSArray *categories = [[A3SyncManager sharedSyncManager] dataObjectForFilename:A3UnitConverterDataEntityUnitCategories];
	if (!categories) {
		NSMutableArray *categoriesBeforeSort = [NSMutableArray new];

		for (NSInteger idx = 0; idx < numOfUnitType; idx++) {
			[categoriesBeforeSort addObject:@{ ID_KEY : @(idx), NAME_KEY : [self localizedCategoryNameForID:idx] } ];
		}
		NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:NAME_KEY ascending:YES];
		[categoriesBeforeSort sortUsingDescriptors:@[descriptor]];
		categories = categoriesBeforeSort;

		[[A3SyncManager sharedSyncManager] saveDataObject:categories forFilename:A3UnitConverterDataEntityUnitCategories state:A3DataObjectStateInitialized];
		[[A3SyncManager sharedSyncManager] addTransaction:A3UnitConverterDataEntityUnitCategories
													 type:A3DictionaryDBTransactionTypeSetBaseline
												   object:categories];
	}
	return categories;
}

/*!
 * \param
 * \returns Localized name of unit category for ID
 */
- (NSString *)localizedCategoryNameForID:(NSInteger)index {
	return NSLocalizedStringFromTable([self categoryNameForID:index], @"unit", nil);
}

- (NSString *)categoryNameForID:(NSInteger)index {
	return [NSString stringWithCString:unitTypes[index] encoding:NSUTF8StringEncoding];
}

/*!
 * \param
 * \returns Array of Dictionary contains ID_KEY, NAME_KEY
 */
- (NSMutableArray *)allUnitsSortedByLocalizedNameForCategoryID:(NSUInteger)categoryID {
	NSMutableArray *allUnits = [NSMutableArray new];
	for (NSUInteger idx = 0; idx < numberOfUnits[categoryID]; idx++) {
		[allUnits addObject:@{ID_KEY : @(idx), NAME_KEY : [self localizedUnitNameForUnitID:idx categoryID:categoryID]}];
	}
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NAME_KEY ascending:YES];
	[allUnits sortUsingDescriptors:@[sortDescriptor]];
	return allUnits;
}

/*!
 * \param
 * \returns Localized name of unit category for ID
 */
- (NSString *)localizedUnitNameForUnitID:(NSInteger)unitID categoryID:(NSInteger)categoryID {
	return NSLocalizedStringFromTable([self unitNameForUnitID:unitID categoryID:categoryID], @"unit", nil);
}

- (NSString *)unitNameForUnitID:(NSInteger)unitID categoryID:(NSInteger)categoryID {
	return [NSString stringWithCString:unitNames[categoryID][unitID] encoding:NSUTF8StringEncoding];
}

- (NSString *)iconNameForID:(NSUInteger)index
{
	NSArray *iconNames = @[
			@"unit_angle",
			@"unit_area",
			@"unit_bits",
			@"unit_cooking",
			@"unit_density",
			@"unit_electric",
			@"unit_energy",
			@"unit_force",
			@"unit_fuel",
			@"unit_length",
			@"unit_power",
			@"unit_pressure",
			@"unit_speed",
			@"unit_temperature",
			@"unit_time",
			@"unit_volume",
			@"unit_weight"
	];
	if (index >= [iconNames count]) return @"";
	NSAssert(index < [iconNames count], @"Invalid range of index");
	return iconNames[index];
}

- (NSString *)selectedIconNameForID:(NSUInteger)index
{
	NSArray *iconNames = @[
			@"unit_angle_on",
			@"unit_area_on",
			@"unit_bits_on",
			@"unit_cooking_on",
			@"unit_density_on",
			@"unit_electric_on",
			@"unit_energy_on",
			@"unit_force_on",
			@"unit_fuel_on",
			@"unit_length_on",
			@"unit_power_on",
			@"unit_pressure_on",
			@"unit_speed_on",
			@"unit_temperature_on",
			@"unit_time_on",
			@"unit_volume_on",
			@"unit_weight_on"
	];
	if (index >= [iconNames count]) return @"";
	NSAssert(index < [iconNames count], @"Invalid range of index");
	return iconNames[index];
}

- (NSArray *)unitConvertItems {
	NSArray *unitConvertItemsFromUserDefaults = [[A3SyncManager sharedSyncManager] dataObjectForFilename:A3UnitConverterDataEntityConvertItems];
	if (unitConvertItemsFromUserDefaults) {
		return unitConvertItemsFromUserDefaults;
	}

	NSMutableArray *unitConvertItems = [[NSMutableArray alloc] init];
	NSArray *item;

	// Angle
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:14],
			nil];
	[unitConvertItems addObject:item];

	// Area
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:9],
			nil];
	[unitConvertItems addObject:item];

	// Bits
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			nil];
	[unitConvertItems addObject:item];

	// Cooking
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:24],
			[NSNumber numberWithInt:25],
			[NSNumber numberWithInt:27],
			[NSNumber numberWithInt:28],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:12],
			nil];
	[unitConvertItems addObject:item];

	// Density
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			nil];
	[unitConvertItems addObject:item];

	// Electric Currents
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			nil];
	[unitConvertItems addObject:item];

	// Energy
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:26],
			nil];
	[unitConvertItems addObject:item];

	// Force
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			nil];
	[unitConvertItems addObject:item];

	// Fuel Consumption
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			nil];
	[unitConvertItems addObject:item];

	// Length
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:24],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			[NSNumber numberWithInt:30],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:15],
			nil];
	[unitConvertItems addObject:item];

	// Power
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			nil];
	[unitConvertItems addObject:item];

	// Pressure
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:23],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:33],
			[NSNumber numberWithInt:25],
			nil];
	[unitConvertItems addObject:item];

	// Speed
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:9],
			nil];
	[unitConvertItems addObject:item];

	// Temperature
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			nil];
	[unitConvertItems addObject:item];

	// Time
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:0],
			nil];
	[unitConvertItems addObject:item];

	// Volume
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:28],
			[NSNumber numberWithInt:25],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:29],
			[NSNumber numberWithInt:30],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:20],
			[NSNumber numberWithInt:22],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:26],
			[NSNumber numberWithInt:23],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:9],
			nil];
	[unitConvertItems addObject:item];

	// Weight
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:7],
			nil];
	[unitConvertItems addObject:item];

	return unitConvertItems;
}

- (NSArray *)unitConvertItemsForCategoryID:(NSUInteger)categoryID {
	return [self unitConvertItems][categoryID];
}

- (void)addUnitToConvertItemForUnit:(NSUInteger)unitID categoryID:(NSUInteger)categoryID {
	NSMutableArray *newData = [NSMutableArray arrayWithArray:[self unitConvertItems]];
	NSMutableArray *newConvertItems = [NSMutableArray arrayWithArray:newData[categoryID]];
	if ([newConvertItems containsObject:@(unitID)]) return;

	[newConvertItems addObject:@(unitID)];
	newData[categoryID] = newConvertItems;

	[self saveUnitData:newData forKey:A3UnitConverterDataEntityConvertItems];
}

- (void)replaceConvertItems:(NSArray *)newConvertItems forCategory:(NSUInteger)categoryID {
	NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:newConvertItems];
	NSUInteger nonMemberIndex;
	do {
		nonMemberIndex = [filteredArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
			return ![obj isKindOfClass:[NSNumber class]];
		}];
		if (nonMemberIndex != NSNotFound)
			[filteredArray removeObjectAtIndex:nonMemberIndex];
	} while (nonMemberIndex != NSNotFound);

	NSMutableArray *newData = [NSMutableArray arrayWithArray:[self unitConvertItems]];
	newData[categoryID] = filteredArray;

	[self saveUnitData:newData forKey:A3UnitConverterDataEntityConvertItems];
}

#pragma mark - Unit Favorites

- (NSArray *)allFavorites {
	NSArray *favoritesInDefaults = [[A3SyncManager sharedSyncManager] dataObjectForFilename:A3UnitConverterDataEntityFavorites];
	if (favoritesInDefaults) return favoritesInDefaults;

	NSMutableArray *unitFavorites = [[NSMutableArray alloc] init];
	NSArray *item;

// Angle
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:14],
			nil];
	[unitFavorites addObject:item];

// Area
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:16],
			nil];
	[unitFavorites addObject:item];

// Bits
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:7],
			nil];
	[unitFavorites addObject:item];

// Cooking
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:24],
			[NSNumber numberWithInt:25],
			[NSNumber numberWithInt:26],
			[NSNumber numberWithInt:27],
			[NSNumber numberWithInt:28],
			[NSNumber numberWithInt:29],
			[NSNumber numberWithInt:30],
			nil];
	[unitFavorites addObject:item];

// Density
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			nil];
	[unitFavorites addObject:item];

// Electric Currents
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			nil];
	[unitFavorites addObject:item];

// Energy
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:26],
			nil];
	[unitFavorites addObject:item];

// Force
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			nil];
	[unitFavorites addObject:item];

// Fuel Consumption
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			nil];
	[unitFavorites addObject:item];

// Length
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			[NSNumber numberWithInt:23],
			[NSNumber numberWithInt:24],
			[NSNumber numberWithInt:30],
			nil];
	[unitFavorites addObject:item];

// Power
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			nil];
	[unitFavorites addObject:item];

// Pressure
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:23],
			[NSNumber numberWithInt:33],
			nil];
	[unitFavorites addObject:item];

// Speed
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:20],
			[NSNumber numberWithInt:21],
			nil];
	[unitFavorites addObject:item];

// Temperature
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:4],
			nil];
	[unitFavorites addObject:item];

// Time
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:19],
			nil];
	[unitFavorites addObject:item];

// Volume
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:20],
			[NSNumber numberWithInt:23],
			[NSNumber numberWithInt:24],
			[NSNumber numberWithInt:25],
			[NSNumber numberWithInt:26],
			[NSNumber numberWithInt:27],
			[NSNumber numberWithInt:28],
			nil];
	[unitFavorites addObject:item];

// Weight
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			nil];
	[unitFavorites addObject:item];
	return unitFavorites;
}

- (NSArray *)favoritesForCategoryID:(NSInteger)categoryID {
	return [self allFavorites][categoryID];
}

- (void)saveFavorites:(NSArray *)favorites categoryID:(NSUInteger)categoryID {
	NSMutableArray *allFavorites = [NSMutableArray arrayWithArray:[self allFavorites]];
	allFavorites[categoryID] = favorites;

	[self saveUnitData:allFavorites forKey:A3UnitConverterDataEntityFavorites];
}

- (BOOL)isFavoriteForUnitID:(NSUInteger)unitID categoryID:(NSUInteger)categoryID {
	return [[self favoritesForCategoryID:categoryID] containsObject:@(unitID)];
}

#pragma mark - Save Unit Data

- (void)saveUnitData:(id)data forKey:(NSString *)key {
	[[A3SyncManager sharedSyncManager] saveDataObject:data forFilename:key state:A3DataObjectStateModified];
	[[A3SyncManager sharedSyncManager] addTransaction:key
												 type:A3DictionaryDBTransactionTypeSetBaseline
											   object:data];
}

#pragma mark - Unit Price Favorites

- (NSMutableArray *)allUnitPriceFavorites {
	id favoriteData = [[A3SyncManager sharedSyncManager] dataObjectForFilename:A3UnitPriceUserDataEntityPriceFavorites];
	if (favoriteData) {
		return [NSMutableArray arrayWithArray:favoriteData];
	}

	NSMutableArray *unitFavorites;
	unitFavorites = [[NSMutableArray alloc] init];
	NSArray *item;

	// Angle
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:14],
			nil];
	[unitFavorites addObject:item];

	// Area
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:9],
			nil];
	[unitFavorites addObject:item];

	// Bits
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			nil];
	[unitFavorites addObject:item];

	// Cooking
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:24],
			[NSNumber numberWithInt:25],
			[NSNumber numberWithInt:27],
			[NSNumber numberWithInt:28],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:12],
			nil];
	[unitFavorites addObject:item];

	// Density
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			nil];
	[unitFavorites addObject:item];

	// Electric Currents
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			nil];
	[unitFavorites addObject:item];

	// Energy
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:26],
			nil];
	[unitFavorites addObject:item];

	// Force
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			nil];
	[unitFavorites addObject:item];

	// Fuel Consumption
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			nil];
	[unitFavorites addObject:item];

	// Length
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:24],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			[NSNumber numberWithInt:30],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:15],
			nil];
	[unitFavorites addObject:item];

	// Power
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			nil];
	[unitFavorites addObject:item];

	// Pressure
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:23],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:33],
			[NSNumber numberWithInt:25],
			nil];
	[unitFavorites addObject:item];

	// Speed
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:9],
			nil];
	[unitFavorites addObject:item];

	// Temperature
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			nil];
	[unitFavorites addObject:item];

	// Time
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:0],
			nil];
	[unitFavorites addObject:item];

	// Volume
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:28],
			[NSNumber numberWithInt:25],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:29],
			[NSNumber numberWithInt:30],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:20],
			[NSNumber numberWithInt:22],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:26],
			[NSNumber numberWithInt:23],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:9],
			nil];
	[unitFavorites addObject:item];

	// Weight
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:7],
			nil];
	[unitFavorites addObject:item];

	return unitFavorites;
}

- (NSMutableArray *)unitPriceFavoriteForCategoryID:(NSUInteger)categoryID {
	NSMutableArray *favorites = [NSMutableArray arrayWithArray:[self allUnitPriceFavorites][categoryID]];
	[favorites sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [NSLocalizedStringFromTable([NSString stringWithCString:unitNames[categoryID][[obj1 integerValue]] encoding:NSUTF8StringEncoding], @"unit", nil) compare:
				NSLocalizedStringFromTable([NSString stringWithCString:unitNames[categoryID][[obj2 integerValue]] encoding:NSUTF8StringEncoding], @"unit", nil)];
	}];
	return favorites;
}

- (void)saveUnitPriceFavorites:(NSArray *)favorites categoryID:(NSUInteger)categoryID {
	NSMutableArray *allFavorites = [self allUnitPriceFavorites];
	allFavorites[categoryID] = favorites;

	[self saveUnitPriceData:allFavorites forKey:A3UnitPriceUserDataEntityPriceFavorites];
}

#pragma mark - Save Unit Price Data

- (void)saveUnitPriceData:(id)data forKey:(NSString *)key {
	[[A3SyncManager sharedSyncManager] saveDataObject:data forFilename:key state:A3DataObjectStateModified];
	[[A3SyncManager sharedSyncManager] addTransaction:key
												 type:A3DictionaryDBTransactionTypeSetBaseline
											   object:data];
}


@end
