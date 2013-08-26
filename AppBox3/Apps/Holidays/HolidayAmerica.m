//
//  HolidayAmerica.m
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import "HolidayAmerica.h"
#import "HolidayData.h"

/* 5760, 1999-2000
 * Saturday, September 7 - Rosh HaShanah*
 * Monday, September 20 - Yom Kippur*
 * Saturday, September 25 - Sukkot*
 * Saturday, October 2 - Shemini Atzeret*
 * Sunday, October 3 - Simchat Torah*
 * Saturday, December 4 - Hanukkah
 
 * Saturday, January 22 - Tu Bishvat
 * Tuesday, March 21 - Purim
 * Thursday, April 20 - Pesach*
 * Tuesday, May 2 - Yom Ha'Shoah
 * Wednesday, May 10 - Yom Ha'atzmaut
 * Tuesday, May 23 - Lag Ba'omer
 * Friday, June 9 - Shavuot*
 * Thursday, August 10 - Tisha B'Av
 2009-01-05 18:40 +09:00 */



static NSInteger jewishTable[][14][2] = {
	/*2000*/{{1, 22}, {3, 21}, {4, 20}, {5,  2}, {5, 10}, {5, 23}, {6,  9}, {8, 10}, {9, 14}, {10,  9}, {10, 14}, {10, 21}, {10, 22}, {12, 22}},
	/*2001*/{{2,  8}, {3,  9}, {4,  8}, {4, 20}, {4, 26}, {5, 11}, {5, 28}, {6, 29}, {9, 11}, { 9, 27}, {10,  2}, {10,  9}, {10, 10}, {12, 10}},
	/*2002*/{{1, 28}, {2, 26}, {3, 28}, {4,  9}, {4, 17}, {4, 30}, {5, 17}, {7, 18}, {9,  7}, { 9, 16}, { 9, 21}, { 9, 28}, { 9, 29}, {11, 30}},
	/*2003*/{{1, 18}, {3, 18}, {4, 17}, {4, 29}, {5,  7}, {5, 20}, {6,  6}, {8,  7}, {9, 27}, {10,  6}, {10, 11}, {10, 18}, {10, 19}, {12, 20}},
	/*2004*/{{2,  7}, {3,  7}, {4,  6}, {4, 18}, {4, 27}, {5,  9}, {5, 26}, {7, 27}, {9, 16}, { 9, 25}, { 9, 30}, {10,  7}, {10,  8}, {12,  8}},
	/*2005*/{{1, 25}, {3, 25}, {4, 24}, {5,  6}, {5, 12}, {5, 27}, {6, 13}, {8, 14}, {10, 4}, {10, 13}, {10, 18}, {10, 25}, {10, 26}, {12, 26}},
	/*2006*/{{2, 13}, {3, 14}, {4, 13}, {4, 25}, {5,  3}, {5, 16}, {6,  2}, {8,  3}, {9, 23}, {10,  2}, {10,  7}, {10, 14}, {10, 15}, {12, 16}},
	/*2007*/{{2,  3}, {3,  4}, {4,  3}, {4, 15}, {4, 24}, {5,  6}, {5, 23}, {7, 24}, {9, 13}, { 9, 22}, { 9, 27}, {10,  4}, {10,  5}, {12,  5}},
	/*2008*/{{1, 22}, {3, 21}, {4, 20}, {5,  2}, {5,  8}, {5, 23}, {6,  9}, {8, 10}, {9, 30}, {10,  9}, {10, 14}, {10, 21}, {10, 22}, {12, 22}},
	/*2009*/{{2,  9}, {3, 10}, {4,  9}, {4, 21}, {4, 29}, {5, 12}, {5, 29}, {7, 30}, {9, 19}, { 9, 28}, {10,  3}, {10, 10}, {10, 11}, {12, 12}},
	/*2010*/{{1, 30}, {2, 28}, {3, 30}, {4, 11}, {4, 20}, {5,  2}, {5, 19}, {7, 20}, {9,  9}, { 9, 18}, { 9, 23}, { 9, 30}, {10,  1}, {12,  2}},
	/*2011*/{{1, 20}, {3, 20}, {4, 19}, {5,  1}, {5, 10}, {5, 22}, {6,  8}, {8,  9}, {9, 29}, {10,  8}, {10, 13}, {10, 20}, {10, 21}, {12, 21}},
	/*2012*/{{2,  8}, {3,  8}, {4,  7}, {4, 19}, {4, 26}, {5, 10}, {5, 27}, {7, 29}, {9, 17}, { 9, 26}, {10,  1}, {10,  8}, {10,  9}, {12,  9}},
	/*2013*/{{1, 26}, {2, 24}, {3, 26}, {4,  7}, {4, 16}, {4, 28}, {5, 15}, {7, 16}, {9,  5}, { 9, 14}, { 9, 19}, { 9, 26}, { 9, 27}, {11, 28}},
	/*2014*/{{1, 16}, {3, 16}, {4, 15}, {4, 27}, {5,  6}, {5, 18}, {6,  4}, {8,  5}, {9, 25}, {10,  4}, {10,  9}, {10, 16}, {10, 17}, {12, 17}},
	/*2015*/{{2,  4}, {3,  5}, {4,  4}, {4, 16}, {4, 23}, {5,  7}, {5, 24}, {7, 26}, {9, 14}, { 9, 23}, { 9, 28}, {10,  5}, {10,  6}, {12,  7}},
	/*2016*/{{1, 25}, {3, 24}, {4, 23}, {5,  5}, {5, 12}, {5, 26}, {6, 12}, {8, 14}, {10, 3}, {10, 12}, {10, 17}, {10, 24}, {10, 25}, {12, 25}},
	/*2017*/{{2, 11}, {3, 12}, {4, 11}, {4, 23}, {5,  2}, {5, 14}, {5, 31}, {8,  1}, {9, 21}, { 9, 30}, {10,  5}, {10, 12}, {10, 13}, {12, 13}},
	/*2018*/{{1, 31}, {3,  1}, {3, 31}, {4, 12}, {4, 19}, {5,  3}, {5, 20}, {7, 22}, {9, 10}, { 9, 19}, { 9, 24}, {10,  1}, {10,  2}, {12,  3}},
	/*2019*/{{1, 21}, {3, 21}, {4, 20}, {5,  2}, {5,  9}, {5, 23}, {6,  9}, {8, 11}, {9, 30}, {10,  9}, {10, 14}, {10, 21}, {10, 22}, {12, 23}},
	/*2020*/{{2, 10}, {3, 10}, {4,  9}, {4, 21}, {4, 29}, {5, 12}, {5, 29}, {7, 30}, {9, 19}, { 9, 28}, {10,  3}, {10, 10}, {10, 11}, {12, 11}},
	/*2021*/{{1, 28}, {2, 26}, {3, 28}, {4,  9}, {4, 15}, {4, 30}, {5, 17}, {7, 18}, {9,  7}, { 9, 16}, { 9, 21}, { 9, 28}, { 9, 29}, {11, 29}},
	/*2022*/{{1, 17}, {3, 17}, {4, 16}, {4, 28}, {5,  2}, {5, 19}, {6,  5}, {8,  7}, {9, 26}, {10,  5}, {10, 10}, {10, 17}, {10, 18}, {12, 19}},
	/*2023*/{{2,  6}, {3,  7}, {4,  6}, {4, 18}, {4, 26}, {5,  9}, {5, 26}, {7, 27}, {9, 16}, { 9, 25}, { 9, 30}, {10,  7}, {10,  8}, {12,  8}},
	/*2024*/{{1, 25}, {3, 24}, {4, 23}, {5,  5}, {5, 14}, {5, 26}, {6, 12}, {8, 13}, {10, 3}, {10, 12}, {10, 17}, {10, 24}, {10, 25}, {12, 26}},
	/*2025*/{{2, 13}, {3, 14}, {4, 13}, {4, 25}, {5,  1}, {5, 16}, {6,  2}, {8,  3}, {9, 23}, {10,  2}, {10,  7}, {10, 14}, {10, 15}, {12, 15}},
	/*2026*/{{2,  2}, {3,  3}, {4,  2}, {4, 14}, {4, 22}, {5,  5}, {5, 22}, {7, 23}, {9, 12}, {9,  21}, {9,  26}, {10,  3}, {10,  4}, {12,  5}},
	/*2027*/{{1, 23}, {3, 23}, {4, 22}, {5,  4}, {5, 12}, {5, 25}, {6, 11}, {8, 12}, {10, 2}, {10, 11}, {10, 16}, {10, 23}, {10, 24}, {12, 25}},
	/*2028*/{{2, 12}, {3, 12}, {4, 11}, {4, 23}, {5,  2}, {5, 14}, {5, 31}, {8,  1}, {9, 21}, {9,  30}, {10,  5}, {10, 12}, {10, 13}, {12, 13}},
	/*2029*/{{1, 31}, {3,  1}, {3, 31}, {4, 12}, {4, 19}, {5,  3}, {5, 20}, {7, 22}, {9, 10}, {9,  19}, {9,  24}, {10,  1}, {10,  2}, {12,  2}},
	/*2030*/{{1, 19}, {3, 19}, {4, 18}, {4, 30}, {5,  8}, {5, 21}, {6,  7}, {8,  8}, {9, 28}, {10,  7}, {10, 12}, {10, 19}, {10, 20}, {12, 21}},
	/*2031*/{{2,  8}, {3,  9}, {4,  8}, {4, 20}, {4, 29}, {5, 11}, {5, 28}, {7, 29}, {9, 18}, {9,  27}, {10,  2}, {10,  9}, {10, 10}, {12, 10}},
	/*2032*/{{1, 28}, {2, 26}, {3, 27}, {4,  8}, {4, 15}, {4, 29}, {5, 16}, {7, 18}, {9,  6}, {9,  15}, {9,  20}, {9,  27}, {9,  28}, {11, 28}},
	/*2033*/{{1, 15}, {3, 15}, {4, 14}, {4, 26}, {5,  4}, {5, 17}, {6,  3}, {8,  4}, {9, 24}, {10,  3}, {10,  8}, {10, 15}, {10, 16}, {12, 17}},
	/*2034*/{{2,  4}, {3,  5}, {4,  4}, {4, 16}, {4, 25}, {5,  7}, {5, 24}, {7, 25}, {9, 14}, {9,  23}, {9,  28}, {10,  5}, {10,  6}, {12,  7}},
	/*2035*/{{1, 25}, {3, 25}, {4, 24}, {5,  6}, {5, 15}, {5, 27}, {6, 13}, {8, 14}, {10, 4}, {10, 13}, {10, 18}, {10, 25}, {10, 26}, {12, 26}},
	/*2036*/{{2, 13}, {3, 13}, {4, 12}, {4, 24}, {5,  1}, {5, 15}, {6,  1}, {8,  3}, {9, 22}, {10,  1}, {10,  6}, {10, 13}, {10, 14}, {12, 14}},
	/*2037*/{{1, 31}, {3,  1}, {3, 31}, {4,  2}, {4, 21}, {5,  3}, {5, 20}, {7, 21}, {9, 10}, {9,  19}, {9,  24}, {10,  1}, {10,  2}, {12,  3}},
	/*2038*/{{1, 21}, {3, 21}, {4, 20}, {5,  2}, {5, 11}, {5, 23}, {6,  9}, {8, 10}, {9, 30}, {10,  9}, {10, 14}, {10, 21}, {10, 22}, {12, 22}},
	/*2039*/{{2,  9}, {3, 10}, {4,  9}, {4, 21}, {4, 28}, {5, 12}, {5, 29}, {7, 31}, {9, 19}, {9,  28}, {10,  3}, {10, 10}, {10, 11}, {12, 12}},
	/*2040*/{{1, 30}, {2, 28}, {3, 29}, {4, 10}, {4, 18}, {5,  1}, {5, 18}, {7, 19}, {9,  8}, {9,  17}, {9,  22}, {9,  29}, {9,  30}, {11, 30}},
	/*2041*/{{1, 17}, {3, 17}, {4, 16}, {4, 28}, {5,  7}, {5, 19}, {6,  5}, {8,  6}, {9, 26}, {10,  5}, {10, 10}, {10, 17}, {10, 18}, {12, 18}},
	/*2042*/{{2,  5}, {3,  6}, {4,  5}, {4, 17}, {4, 24}, {5,  8}, {5, 25}, {7, 27}, {9, 15}, {9,  24}, {9,  29}, {10,  6}, {10,  7}, {12,  8}},
	/*2043*/{{1, 26}, {3, 26}, {4, 25}, {5,  7}, {5, 14}, {5, 28}, {6, 14}, {8, 16}, {10, 5}, {10, 14}, {10, 19}, {10, 26}, {10, 27}, {12, 27}},
	/*2044*/{{2, 13}, {3, 13}, {4, 12}, {4, 24}, {5,  3}, {5, 15}, {6,  1}, {8,  2}, {9, 22}, {10,  1}, {10,  6}, {10, 13}, {10, 14}, {12, 15}},
	/*2045*/{{2,  2}, {3,  3}, {4,  2}, {4, 14}, {4, 20}, {5,  5}, {5, 22}, {7, 23}, {9, 12}, {9,  21}, {9,  26}, {10,  3}, {10,  4}, {12,  4}},
	/*2046*/{{1, 22}, {3, 22}, {4, 21}, {5,  3}, {5, 10}, {5, 24}, {6, 10}, {8, 12}, {10, 1}, {10, 10}, {10, 15}, {10, 22}, {10, 23}, {12, 24}},
	/*2047*/{{2, 11}, {3, 12}, {4, 11}, {4, 23}, {5,  1}, {5, 14}, {5, 31}, {8,  1}, {9, 21}, {9,  30}, {10,  5}, {10, 12}, {10, 13}, {12, 13}},
	/*2048*/{{1, 30}, {2, 28}, {3, 29}, {4, 10}, {4, 16}, {5,  1}, {5, 18}, {7, 19}, {9,  8}, {9,  17}, {9,  22}, {9,  29}, {9,  30}, {11, 30}},
	/*2049*/{{1, 18}, {3, 18}, {4, 17}, {4, 29}, {5,  6}, {5, 20}, {6,  6}, {8,  8}, {9, 27}, {10,  6}, {10, 11}, {10, 18}, {10, 19}, {12, 20}}
};

NSMutableArray *newJewishHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	if ((year < 2000) || (year > 2049)) {
		NSArray *holidayItem = [NSArray arrayWithObjects:@"Jewish Holidays (2000~2049 only)", nil];
		[holidays addObject:holidayItem];
		
		return holidays;
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	holidayName = @"Tu Bishvat";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][0][1] month:jewishTable[year - 2000][0][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Purim";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][1][1] month:jewishTable[year - 2000][1][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Pesach*";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][2][1] month:jewishTable[year - 2000][2][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Yom Ha'Shoah";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][3][1] month:jewishTable[year - 2000][3][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Yom Ha'atzmaut";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][4][1] month:jewishTable[year - 2000][4][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Lag Ba'omer";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][5][1] month:jewishTable[year - 2000][5][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Shavuot*";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][6][1] month:jewishTable[year - 2000][6][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Tisha B'Av";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][7][1] month:jewishTable[year - 2000][7][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = [@"Rosh HaShanah*" stringByAppendingString:[NSString stringWithFormat:@"(%d)", year + 3761]];
	date = [HolidayData dateWithDay:jewishTable[year - 2000][8][1] month:jewishTable[year - 2000][8][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Yom Kippur*";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][9][1] month:jewishTable[year - 2000][9][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Sukkot*";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][10][1] month:jewishTable[year - 2000][10][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Shemini Atzeret*";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][11][1] month:jewishTable[year - 2000][11][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Simchat Torah*";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][12][1] month:jewishTable[year - 2000][12][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Hanukkah";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][13][1] month:jewishTable[year - 2000][13][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}	

NSMutableArray *newDominicanRepublicHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date, *originalDate;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Catholic day of the Epiphany";
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:5];
	originalDate = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Dia de la Altagracia(Patroness Day)";
	date = [HolidayData dateWithDay:21 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Duarte's Day";
	date = [HolidayData dateWithDay:25 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:27 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Labor Day is the first Monday of September. 
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:5];
	originalDate = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	// Corpus Christi
	holidayName = @"Catholic Corpus Christi";
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Restoration Day";
	date = [HolidayData dateWithDay:16 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Virgen de las Mercedes(A Patroness Day)";
	date = [HolidayData dateWithDay:24 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Constitution Day";
	date = [HolidayData dateWithDay:6 month:11 year:year withCalendar:gregorian option:5];
	originalDate = [HolidayData dateWithDay:6 month:11 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newUSVirginIslandsHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Epiphany";
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Martin Luther King Day, Third Monday of January
	holidayName = @"Martin Luther King Day";
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:1 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Presidents' Day";
	date = [HolidayData dateWithDay:16 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Transfer Day";
	date = [HolidayData dateWithDay:31 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Maundy Thursday";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Easter Day 
	holidayName = @"Easter Day";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Monday";
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Children's Carnival Day";
	date = [HolidayData dateWithDay:24 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Grand Carnival Day";
	date = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Memorial Day is observed the last Monday of May.
	holidayName = @"Memorial Day";
	date = [HolidayData getLastWeekday:Monday OfMonth:5 forYear:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Organic Act Day";
	date = [HolidayData dateWithDay:15 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Emancipation Day";
	date = [HolidayData dateWithDay:3 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Independence Day is July 4th.
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:4 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Hurricane Supplication Day";
	date = [HolidayData dateWithDay:27 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Labor Day is the first Monday of September. 
	holidayName = @"Labor Day";
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:9 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Columbus Day is celebrated on the second Monday in October.
	holidayName = @"Columbus Day / PR Friendship Day";
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:10 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Hurricane Thanksgiving Day";
	date = [HolidayData dateWithDay:27 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Liberty Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Veterans Day is celebrated on November 11th.
	holidayName = @"Veterans Day";
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Thanksgiving Day is the fourth Thursday in November.
	holidayName = @"Thanksgiving Day";
	date = [HolidayData dateWithWeekday:Thursday ordinal:4 month:11 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Second Day of Christmas";
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}

NSMutableArray *newAmericanHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Martin Luther King Day, Third Monday of January
	holidayName = @"Martin Luther King Day";
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:1 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Groundhog Day";
	date = [HolidayData dateWithDay:2 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Lincoln's Birthday";
	date = [HolidayData dateWithDay:12 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Valentine's Day, is celebrated on February 14th. 
	holidayName = @"Valentine's Day";
	date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Washington's Birthday";
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:2 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Daylight Saving Time Begins";
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:3 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"St. Patrick's Day";
	date = [HolidayData dateWithDay:17 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"April Fool's Day";
	date = [HolidayData dateWithDay:1 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Tax Day";
	date = [HolidayData dateWithDay:15 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Earth Day";
	date = [HolidayData dateWithDay:22 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Easter Day 
	holidayName = @"Easter";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Cinco de Mayo";
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Mother's Day";
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:5 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"John F. Kennedy's Birthday";
	date = [HolidayData dateWithDay:29 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Memorial Day is observed the last Monday of May.
	holidayName = @"Memorial Day";
	date = [HolidayData getLastWeekday:Monday OfMonth:5 forYear:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Flag Day";
	date = [HolidayData dateWithDay:14 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Father's Day";
	date = [HolidayData dateWithWeekday:Sunday ordinal:3 month:6 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Independence Day is July 4th.
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:4 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Labor Day is the first Monday of September. 
	holidayName = @"Labor Day";
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:9 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Patriot Day";
	date = [HolidayData dateWithDay:11 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Columbus Day is celebrated on the second Monday in October.
	holidayName = @"Columbus Day";
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:10 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Halloween is celebrated on October 31. 
	holidayName = @"Halloween";
	date = [HolidayData dateWithDay:31 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Daylight Saving Time Ends";
	date = [HolidayData dateWithWeekday:Sunday ordinal:1 month:11 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = @"Election Day";
	date = [HolidayData dateWithWeekday:Tuesday ordinal:1 month:11 year:year withCalendar:gregorian];
	{
		NSDateComponents *dc = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
		if ([dc day] == 1) {
			[dc setDay:8];
			date = [gregorian dateFromComponents:dc];
		}
	}
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Veterans Day is celebrated on November 11th.
	holidayName = @"Veterans Day";
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Thanksgiving Day is the fourth Thursday in November.
	holidayName = @"Thanksgiving Day";
	date = [HolidayData dateWithWeekday:Thursday ordinal:4 month:11 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Eve";
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"New Year's Eve";
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = @"Hanukkah";
	date = [HolidayData dateWithDay:jewishTable[year - 2000][13][1] month:jewishTable[year - 2000][13][0] year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];


	
	return holidays;
}


NSMutableArray *newJamaicaHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Ash Wednesday";
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Day";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Monday";
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:23 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Labor Day(day in lieu)";
	date = [HolidayData dateWithDay:25 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Emancipation Day";
	date = [HolidayData dateWithDay:1 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:6 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"National Heroes' Day";
	date = [HolidayData dateWithDay:19 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Boxing Day";
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newNicaraguaHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Air Force Day";
	date = [HolidayData dateWithDay:1 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Holy Thursday";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Army Day";
	date = [HolidayData dateWithDay:27 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Liberation Day/FSLN Revolution Day";
	date = [HolidayData dateWithDay:19 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Fiesta de Santiago";
	date = [HolidayData dateWithDay:25 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Fiesta de Santo Domingo";
	date = [HolidayData dateWithDay:1 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Battle of San Jacinto";
	date = [HolidayData dateWithDay:14 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Indigenous Resistance Day";
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"La Griteria Immaculate";
	date = [HolidayData dateWithDay:7 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Immaculate Conception";
	date = [HolidayData dateWithDay:12 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"New Year's Eve";
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newEquatorialGuineaHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day, Ano Novo
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Good Friday
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Easter Day 
	holidayName = @"Easter Day";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Presidents' Day";
	date = [HolidayData dateWithDay:5 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Corpus Christi
	holidayName = @"Corpus Christi Day";
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Freedom Day (Golpe de la Libertad)";
	date = [HolidayData dateWithDay:3 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Constitution Day (Carta de Akonibe)";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Immaculate Conception Day";
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newBrazilHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day, Ano Novo
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Carnival, Carnaval
	holidayName = @"Carnival Monday";
	NSDate *ashWednesday = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil) {
		NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
		[offsetdc setDay:-2];
		date = [gregorian dateByAddingComponents:offsetdc toDate:ashWednesday options:0];
		
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = @"Carnival Tuesday";
		[offsetdc setDay:-1];
		date = [gregorian dateByAddingComponents:offsetdc toDate:ashWednesday options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		// Ash Wednesday
		holidayName = @"Ash Wednesday";
		holidayItem = [NSArray arrayWithObjects:holidayName, ashWednesday, nil];
		[holidays addObject:holidayItem];
	}
	
	// Good Friday
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Tiradentes
	holidayName = @"Tiradentes";
	date = [HolidayData dateWithDay:21 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Mothers' Day";
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:5 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Corpus Christi
	holidayName = @"Corpus Christi";
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Valentine Day";
	date = [HolidayData dateWithDay:12 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"St. John's Day";
	date = [HolidayData dateWithDay:24 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Fathers' Day";
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:8 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Independence Day
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:7 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Our Lady of Aparecida
	holidayName = @"Our Lady of Aparecida";
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// All Souls Day
	holidayName = @"All Souls Day";
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Proclamation of the Republic Day
	holidayName = @"Proclamation of the Republic";
	date = [HolidayData dateWithDay:15 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Eve";
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"New Year's Eve";
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}

NSMutableArray *newColombiaHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date, *originalDate;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Epiphany";
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Saint Joseph's Day";
	date = [HolidayData dateWithDay:19 month:3 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:19 month:3 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Moundy Thursday";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Ascension of Jesus";
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Corpus Christi";
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Sacred Heart";
	date = [HolidayData getSacredHeart:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"St. Peter and St. Paul";
	date = [HolidayData dateWithDay:29 month:6 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:29 month:6 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:20 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Battle of Boyacá";
	date = [HolidayData dateWithDay:7 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Assumption of Mary";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Columbus Day";
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence of Cartagena";
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Immaculate Conception";
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	return holidays;
}


NSMutableArray *newChileHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Holy Saturday";
	date = [HolidayData getHolySaturday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Navy Day";
	date = [HolidayData dateWithDay:21 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"St. Peter and St. Paul";
	date = [HolidayData dateWithDay:29 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Our Lady of Mount Carmel";
	date = [HolidayData dateWithDay:16 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Assumption of Mary";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"National Holiday";
	date = [HolidayData dateWithDay:18 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Army Day";
	date = [HolidayData dateWithDay:19 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Columbus Day";
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Reformation Day";
	date = [HolidayData dateWithDay:31 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Immaculate Conception";
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	return holidays;
}


NSMutableArray *newArgentinaHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date, *originalDate;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Maundy Thursday";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Memorial Day";
	date = [HolidayData dateWithDay:24 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Malvinas Day";
	date = [HolidayData dateWithDay:2 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Revolución de Mayo";
	date = [HolidayData dateWithDay:25 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"National Flag Day";
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:6 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"National Independence Day";
	date = [HolidayData dateWithDay:9 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Anniversary of the death of General José de San Martín";
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:8 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Columbus Day";
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:5];
	originalDate = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Immaculate Conception";
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Eve";
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"New year's Eve";
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	return holidays;
}


NSMutableArray *newMexicoHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Epiphany
	holidayName = @"Epiphany";
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Constitution Day";
	date = [HolidayData dateWithDay:5 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Valentine's Day, is celebrated on February 14th. 
	holidayName = @"Valentine's Day";
	date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Flag Day";
	date = [HolidayData dateWithDay:24 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Benito Juárez's Birthday";
	date = [HolidayData dateWithDay:21 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Maundy Thursday";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Sunday";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Children's Day";
	date = [HolidayData dateWithDay:30 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Labour Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Cinco de Mayo";
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Mother's Day";
	date = [HolidayData dateWithDay:10 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Father's Day";
	date = [HolidayData dateWithWeekday:Sunday ordinal:3 month:6 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Presidential Address";
	date = [HolidayData dateWithDay:1 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Young Cadets";
	date = [HolidayData dateWithDay:13 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Shout of Dolores";
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:16 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Columbus Day";
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"All Souls Day";
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Revolution Day";
	date = [HolidayData dateWithDay:20 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Day of the Virgin of Guadalupe";
	date = [HolidayData dateWithDay:12 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Eve";
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"New Year's Eve";
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}

NSMutableArray *newEcuadorHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Maundy Thursday";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"The Battle of Pichincha (1822)";
	date = [HolidayData dateWithDay:24 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"The Birthday of Simón Bolivar (1783)";
	date = [HolidayData dateWithDay:24 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Declaration of Independence of Quito (1809)";
	date = [HolidayData dateWithDay:10 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence of Guayaquil (1820)";
	date = [HolidayData dateWithDay:9 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"All Souls Day";
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence of Cuenca (1820)";
	date = [HolidayData dateWithDay:3 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Foundation of Quito (1534)";
	date = [HolidayData dateWithDay:6 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"New Year's Eve";
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}	


NSMutableArray *newPuertoRicoHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Epiphany";
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Birthday of Eugenio María de Hostos";
	date = [HolidayData dateWithDay:11 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"President's Day, Washington's Birthday";
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:2 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Birthday of Luis Muñoz Marín";
	date = [HolidayData dateWithDay:18 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Emancipation Day";
	date = [HolidayData dateWithDay:22 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Birthday of José de Diego";
	date = [HolidayData dateWithDay:16 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Memorial Day";
	date = [HolidayData getLastWeekday:Monday OfMonth:5 forYear:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Independence Day is July 4th.
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:4 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Birthday of Don Luis Muñoz Rivera";
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:7 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Commonwealth Constitution Day";
	date = [HolidayData dateWithDay:25 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Birthday of Dr. José Celso Barbosa";
	date = [HolidayData dateWithDay:27 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Labor Day is the first Monday of September. 
	holidayName = @"Labor Day";
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:9 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Columbus Day is celebrated on the second Monday in October.
	holidayName = @"Columbus Day";
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:10 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Veterans Day is celebrated on November 11th.
	holidayName = @"Veterans Day";
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Discovery of Puerto Rico";
	date = [HolidayData dateWithDay:19 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Thanksgiving Day is the fourth Thursday in November.
	holidayName = @"Thanksgiving Day";
	date = [HolidayData dateWithWeekday:Thursday ordinal:4 month:11 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Eve";
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"New year's Eve";
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newCanadaHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Valentine's Day";
	date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Alberta Family Day";
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:2 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Daylight Saving Time Begins";
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:3 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"St Patrick's Day";
	date = [HolidayData dateWithDay:17 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"April Fool's Day";
	date = [HolidayData dateWithDay:1 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Monday";
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Mother's Day";
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:5 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Father's Day";
	date = [HolidayData dateWithWeekday:Sunday ordinal:3 month:6 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Victoria Day";
	date = [HolidayData dateWithDay:24 month:5 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
		if ([dc weekday] != Monday) {
			NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
			[offsetDC setDay:[dc weekday] == Sunday?-6:Monday - [dc weekday]];
			date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		}
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = @"Saint Jean Baptiste";
	date = [HolidayData dateWithDay:24 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Canada Day";
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Civic Holiday";
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:8 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Alberta Heritage Day";
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Labour Day";
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:9 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Thanksgiving Day";
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:10 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Halloween";
	date = [HolidayData dateWithDay:31 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Daylight Saving Time Ends";
	date = [HolidayData dateWithWeekday:Sunday ordinal:1 month:11 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Remembrance Day";
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Boxing Day";
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newParaguayHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"National Heroes' Day";
	date = [HolidayData dateWithDay:1 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Maundy Thursday";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Day";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"National Independence Day";
	date = [HolidayData dateWithDay:15 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Chaco Armistice Day";
	date = [HolidayData dateWithDay:12 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Founding of Asunción";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Boqueron Battle Victory Day";
	date = [HolidayData dateWithDay:29 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Virgin of Caacupe";
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"New Year's Eve Bank Holiday";
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newPeruHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date, *originalDate;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Maundy Thursday";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Day";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"St. Peter and St. Paul";
	date = [HolidayData dateWithDay:29 month:6 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:29 month:6 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day(July 28~29)";
	date = [HolidayData dateWithDay:28 month:7 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:28 month:7 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Santa Rosa de Lima";
	date = [HolidayData dateWithDay:30 month:8 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:30 month:8 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Battle of Angamos";
	date = [HolidayData dateWithDay:8 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Immaculate Conception";
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newElSalvadorHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Peace Accords Day";
	date = [HolidayData dateWithDay:16 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Holy Week";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-7];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"The Day of the Cross";
	date = [HolidayData dateWithDay:3 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Mothers' Day";
	date = [HolidayData dateWithDay:10 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"August Festivals(Aug 1~7)";
	date = [HolidayData dateWithDay:1 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Día de la Raza(Columbus Day)";
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Day of the Dead";
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Queen of the Peace Day";
	date = [HolidayData dateWithDay:21 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Festival Day of the Virgin Guadalupe";
	date = [HolidayData dateWithDay:12 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newHondurasHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Maundy Thursday";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Holy Saturday";
	date = [HolidayData getHolySaturday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Day";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Americas' Day";
	date = [HolidayData dateWithDay:14 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"General Francisco Morazán's Birthday";
	date = [HolidayData dateWithDay:3 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Día de la Raza(Columbus Day)";
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Army Day";
	date = [HolidayData dateWithDay:21 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newGuatemalaHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Maundy Thursday";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Holy Saturday";
	date = [HolidayData getHolySaturday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Day";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Army Day";
	date = [HolidayData dateWithDay:30 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"July Bank Holiday";
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Assumption Day(only for Guatemala City)";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Revolution Day";
	date = [HolidayData dateWithDay:20 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Eve";
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"New year's Eve";
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newUruguayHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date, *originalDate;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	// Epiphany
	holidayName = @"Epiphany";
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Carnaval(Monday & Tuesday)";
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-2];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Maundy Thursday(Semana Santa)";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday(Semana Santa)";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Landing of the 33 Patriots Day";
	date = [HolidayData dateWithDay:19 month:4 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:19 month:4 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Battle of Las Piedras Day";
	date = [HolidayData dateWithDay:18 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Birthday of José Gervasio Artigas";
	date = [HolidayData dateWithDay:19 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Constitution Day";
	date = [HolidayData dateWithDay:18 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day(Declaratoria de la Florida";
	date = [HolidayData dateWithDay:25 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Día de la Raza/Sarandí Battle Day";
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"All Souls Day";
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newPanamaHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date, *originalDate;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Martyrs' Day";
	date = [HolidayData dateWithDay:12 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Carnaval(Shrove Monday)";
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-2];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Carnaval(Mardi Gras)";
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Carnival(Ash Wednesday)";
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Maundy Thursday";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Holy Saturday";
	date = [HolidayData getHolySaturday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Presidential Inauguration Day";
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Panama La Vieja Day";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day(Colombia)";
	date = [HolidayData dateWithDay:3 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Flag Day";
	date = [HolidayData dateWithDay:4 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Colon Day";
	date = [HolidayData dateWithDay:5 month:11 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:5 month:11 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Los Santos Uprising Day";
	date = [HolidayData dateWithDay:5 month:11 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:5 month:11 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day(Espana)";
	date = [HolidayData dateWithDay:28 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Mothers' Day";
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Eve";
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"New Year's Eve";
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newVenezuelaHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date, *originalDate;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	// Epiphany
	holidayName = @"Epiphany";
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Carnival(Monday & Tuesday)";
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-2];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Holy Week";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-7];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Saint Joseph's Day";
	date = [HolidayData dateWithDay:19 month:3 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:19 month:3 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Beginning of the Independence Movement";
	date = [HolidayData dateWithDay:19 month:4 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:19 month:4 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Battle of Carabobo";
	date = [HolidayData dateWithDay:24 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:5 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Birth of Simón Bolívar";
	date = [HolidayData dateWithDay:24 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Flag Day";
	date = [HolidayData dateWithDay:3 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Day of Indigenous Resistance";
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Feria of La Chinita(Nov. 17~19)";
	date = [HolidayData dateWithDay:17 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Immaculate Conception";
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Eve";
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:2];
	originalDate = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"New Year's Eve";
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newCostaRicaHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Maundy Thursday";
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Day";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Juan Santamaria Day";
	date = [HolidayData dateWithDay:11 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Guanacaste Day";
	date = [HolidayData dateWithDay:25 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Lady of the Angel's Day";
	date = [HolidayData dateWithDay:2 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Mother's Day/Assumption";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Día de la Raza Holiday";
	date = [HolidayData dateWithDay:18 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newHaitiHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date, *originalDate;
	
	// New years day
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:2];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Ancestry Day/National Day";
	date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Carnaval Monday";
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-2];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Mardi Gras";
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Pan-American Day/Bastilla's Day";
	date = [HolidayData dateWithDay:14 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Ascension";
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Flag and University Day";
	date = [HolidayData dateWithDay:18 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Corpus Christi";
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Assumption";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:4];
	originalDate = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Anniversary of the Death of Dessalines";
	date = [HolidayData dateWithDay:17 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = @"United Nations Day";
	date = [HolidayData dateWithDay:24 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"All Souls Day";
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Armed Forces Day";
	date = [HolidayData dateWithDay:18 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


NSMutableArray *newBahamasHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Day";
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Monday";
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Whit Sunday(Pentecost)";
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Whit Monday";
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labour Day";
	date = [HolidayData dateWithDay:4 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:10 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	if (year == 2010) {
		holidayName = @"Independence Day(day in lieu)";
		date = [HolidayData dateWithDay:12 month:7 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Emancipation Day";
	date = [HolidayData dateWithDay:2 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Discovery Day/Columbus Day Holiday";
	date = [HolidayData dateWithDay:11 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Boxing Day";
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	if (year == 2010) {
		holidayName = @"Christmas Day(day in lieu)";
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	

	
	return holidays;
}
