//
//  HolidayAmerica.m
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import "HolidayData+America.h"
#import "A3AppDelegate.h"

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

@implementation HolidayData (America)

static NSUInteger jewishTable[][14][2] = {
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


/*! Jewish Holiday rather than Israel Holiday
 */
- (NSMutableArray *)il_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	if ((year < 2000) || (year > 2049)) {
		NSArray *holidayItem = [NSArray arrayWithObjects:@"Jewish Holidays (2000~2049 only)", nil];
		[holidays addObject:holidayItem];
		
		return holidays;
	}
	
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	holidayName = NSLocalizedStringFromTable(@"Tu Bishvat", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][0][1] month:jewishTable[year - 2000][0][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Purim", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][1][1] month:jewishTable[year - 2000][1][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Pesach*", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][2][1] month:jewishTable[year - 2000][2][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Yom Ha'Shoah", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][3][1] month:jewishTable[year - 2000][3][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Yom Ha'atzmaut", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][4][1] month:jewishTable[year - 2000][4][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Lag Ba'omer", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][5][1] month:jewishTable[year - 2000][5][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Shavuot*", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][6][1] month:jewishTable[year - 2000][6][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Tisha B'Av", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][7][1] month:jewishTable[year - 2000][7][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = [@"Rosh HaShanah*" stringByAppendingString:[NSString stringWithFormat:@"(%lu)", (unsigned long)year + 3761 ]];
	date = [HolidayData dateWithDay:jewishTable[year - 2000][8][1] month:jewishTable[year - 2000][8][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Yom Kippur*", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][9][1] month:jewishTable[year - 2000][9][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Sukkot*", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][10][1] month:jewishTable[year - 2000][10][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Shemini Atzeret*", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][11][1] month:jewishTable[year - 2000][11][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Simchat Torah*", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][12][1] month:jewishTable[year - 2000][12][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Hanukkah", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][13][1] month:jewishTable[year - 2000][13][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

/*! Dominican Republic
 */
- (NSMutableArray *)do_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Epiphany", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Our Lady of Altagracia", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:21 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Duarte's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:27 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Labor Day is the first Monday of September. 
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Corpus Christi
	holidayName = NSLocalizedStringFromTable(@"Corpus Christi", kHolidaysResourceName, nil);
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
    
	holidayName = NSLocalizedStringFromTable(@"Restoration Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:16 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Our Lady of las Mercedes", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

/*! Virgin Islands United States http://en.wikipedia.org/wiki/Public_holidays_in_the_United_States_Virgin_Islands
 */
- (NSMutableArray *)vi_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Three Kings Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Martin Luther King Day, Third Monday of January
	holidayName = NSLocalizedStringFromTable(@"Martin Luther King Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:1 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Presidents' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:2 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Transfer Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Easter Day 
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", kHolidaysResourceName, nil);
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Children's Carnival Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Grand Carnival Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Memorial Day is observed the last Monday of May.
	holidayName = NSLocalizedStringFromTable(@"Memorial Day", kHolidaysResourceName, nil);
	date = [HolidayData getLastWeekday:Monday OfMonth:5 forYear:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Organic Act Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Emancipation Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Independence Day is July 4th.
	holidayName = NSLocalizedStringFromTable(@"American Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:4 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Hurricane Supplication Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:27 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Labor Day is the first Monday of September. 
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:9 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Columbus Day is celebrated on the second Monday in October.
	holidayName = NSLocalizedStringFromTable(@"Columbus Day / PR Friendship Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:10 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Hurricane Thanksgiving Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:27 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Liberty Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Veterans Day is celebrated on November 11th.
	holidayName = NSLocalizedStringFromTable(@"Veterans Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Thanksgiving Day is the fourth Thursday in November.
	holidayName = NSLocalizedStringFromTable(@"Thanksgiving Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Thursday ordinal:4 month:11 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Second Day of Christmas", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}

/*! United States http://en.wikipedia.org/wiki/Public_holidays_in_the_United_States#Federal_holidays
 */
- (NSMutableArray *)us_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	NSString *holidayName;
	NSDate *date, *observance;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	observance = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:2];
	if (![date isEqualToDate:observance]) {
		holidayName = NSLocalizedStringFromTable(@"New Year's Day(Observed)", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:observance, kHolidayDuration:@1}];
	}

	// Martin Luther King Day, Third Monday of January
	holidayName = NSLocalizedStringFromTable(@"Martin Luther King, Jr. Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:1 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Groundhog Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Lincoln's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Valentine's Day, is celebrated on February 14th. 
	holidayName = NSLocalizedStringFromTable(@"Valentine's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
    //todo: "Inauguration Day" - January 20 (or 21st if the 20th is a Sunday) following a Presidential election http://en.wikipedia.org/wiki/Federal_holidays_in_the_United_States
    
 	holidayName = NSLocalizedStringFromTable(@"Washington's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:2 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Daylight Saving Time Begins", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:3 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"St. Patrick's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:17 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"April Fool's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Tax Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Earth Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:22 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Easter Day 
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Cinco de Mayo", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:5 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"John F. Kennedy's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:29 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Memorial Day is observed the last Monday of May.
	holidayName = NSLocalizedStringFromTable(@"Memorial Day", kHolidaysResourceName, nil);
	date = [HolidayData getLastWeekday:Monday OfMonth:5 forYear:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Flag Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Father's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:3 month:6 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Independence Day is July 4th.
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:4 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	observance = [HolidayData dateWithDay:4 month:7 year:year withCalendar:gregorian option:2];
	if (![date isEqualToDate:observance]) {
		holidayName = NSLocalizedStringFromTable(@"Independence Day(Observed)", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:observance, kHolidayDuration:@1}];
	}
	
	// Labor Day is the first Monday of September. 
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:9 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Patriot Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:11 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Columbus Day is celebrated on the second Monday in October.
	holidayName = NSLocalizedStringFromTable(@"Columbus Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:10 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Halloween is celebrated on October 31. 
	holidayName = NSLocalizedStringFromTable(@"Halloween", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Daylight Saving Time Ends", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:1 month:11 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	// Veterans Day is celebrated on November 11th.
	holidayName = NSLocalizedStringFromTable(@"Veterans Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	observance = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:observance]) {
		holidayName = NSLocalizedStringFromTable(@"Veterans Day(Observed)", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:observance, kHolidayDuration:@1}];
	}
	
	// Thanksgiving Day is the fourth Thursday in November.
	holidayName = NSLocalizedStringFromTable(@"Thanksgiving Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Thursday ordinal:4 month:11 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Hanukkah", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:jewishTable[year - 2000][13][1] month:jewishTable[year - 2000][13][0] year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}


/*! Jamaica http://en.wikipedia.org/wiki/Public_holidays_in_Jamaica
 */
- (NSMutableArray *)jm_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Ash Wednesday", kHolidaysResourceName, nil);
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", kHolidaysResourceName, nil);
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:23 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day(day in lieu)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Emancipation Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"National Heroes' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:10 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Boxing Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}


/*! Nicaragua http://en.wikipedia.org/wiki/Public_holidays_in_Nicaragua
 */
- (NSMutableArray *)ni_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Years", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Air Force Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Army Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:27 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Liberation Day/FSLN Revolution Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:19 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Fiesta de Santiago", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    holidayName = NSLocalizedStringFromTable(@"Fiesta de Santa Ana", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
	holidayName = NSLocalizedStringFromTable(@"Fiesta de Santo Domingo", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Battle of San Jacinto", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Indigenous Resistance Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"La Griteria Immaculate", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:7 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}


/*! Equatorial Guinea
 */
- (NSMutableArray *)gq_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];

	NSString *holidayName;
	NSDate *date;
	
	// New years day, Ano Novo
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Good Friday
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Easter Day 
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Presidents' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Corpus Christi
	holidayName = NSLocalizedStringFromTable(@"Corpus Christi", kHolidaysResourceName, nil);
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Freedom Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}


/*! Brazil
 */
- (NSMutableArray *)br_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day, Ano Novo
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Carnival, Carnaval
	holidayName = NSLocalizedStringFromTable(@"Carnival Monday", kHolidaysResourceName, nil);
	NSDate *ashWednesday = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil) {
		NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
		[offsetdc setDay:-2];
		date = [gregorian dateByAddingComponents:offsetdc toDate:ashWednesday options:0];
		
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
		
		holidayName = NSLocalizedStringFromTable(@"Carnival Tuesday", kHolidaysResourceName, nil);
		[offsetdc setDay:-1];
		date = [gregorian dateByAddingComponents:offsetdc toDate:ashWednesday options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
		
		// Ash Wednesday
		holidayName = NSLocalizedStringFromTable(@"Ash Wednesday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:ashWednesday, kHolidayDuration:@1}];
	}
	
	// Good Friday
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Tiradentes
	holidayName = NSLocalizedStringFromTable(@"Tiradentes' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:21 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Mothers' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:5 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Corpus Christi
	holidayName = NSLocalizedStringFromTable(@"Corpus Christi", kHolidaysResourceName, nil);
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Valentine Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"St. John's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Fathers' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:8 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Independence Day
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:7 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Our Lady of Aparecida
	holidayName = NSLocalizedStringFromTable(@"Our Lady of Aparecida", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// All Souls Day
	holidayName = NSLocalizedStringFromTable(@"All Souls Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Proclamation of the Republic Day
	holidayName = NSLocalizedStringFromTable(@"Republic Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}

/*! Colombia
 */
- (NSMutableArray *)co_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Epiphany", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Saint Joseph's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:19 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension of Jesus", kHolidaysResourceName, nil);
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Corpus Christi", kHolidaysResourceName, nil);
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Sacred Heart", kHolidaysResourceName, nil);
	date = [HolidayData getSacredHeart:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Saint Peter and Saint Paul", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:29 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Declaration of Independence", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Battle of Boyacá", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:7 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Columbus Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence of Cartagena", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	return holidays;
}

// Chile
- (NSMutableArray *)cl_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Holy Saturday", kHolidaysResourceName, nil);
	date = [HolidayData getHolySaturday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Navy Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:21 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Saint Peter and Saint Paul", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:29 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Our Lady of Mount Carmel", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:16 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day of Chile", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:18 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Army Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:19 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
      holidayName = NSLocalizedStringFromTable(@"Public Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
	holidayName = NSLocalizedStringFromTable(@"Race Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Reformation Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
      holidayName = NSLocalizedStringFromTable(@"Presidential Elections", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:17 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	return holidays;
}

// Argentina http://en.wikipedia.org/wiki/Public_holidays_in_Argentina
- (NSMutableArray *)ar_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
     //todo: "Carnival (Monday)" - Celebrated Monday and Tuesday before Ash Wednesday
     //todo: "Carnival (Tuesday)" - Celebrated Monday and Tuesday before Ash Wednesday
    
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Day of Remembrance for Truth and Justice", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Day of the veterans and the fallen in Malvinas War", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Day of the First National Government", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"National Flag Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:20 month:6 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:9 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Anniversary of the death of General José de San Martín", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:17 month:8 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Day of Respect for Cultural Diversity", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Day of National Sovereignty", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:4 month:11 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	return holidays;
}

// Mexico http://en.wikipedia.org/wiki/Public_holidays_in_Mexico
- (NSMutableArray *)mx_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Epiphany
	holidayName = NSLocalizedStringFromTable(@"Epiphany", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:2 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Valentine's Day, is celebrated on February 14th. 
	holidayName = NSLocalizedStringFromTable(@"Valentine's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Flag Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Benito Juárez's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:21 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Sunday", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Children's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:30 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Cinco de Mayo", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:10 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Father's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:3 month:6 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Presidential Address", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Young Cadets", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:13 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Shout of Dolores", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:16 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Columbus Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"All Souls Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Revolution Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    //ok_todo: "Change of Federal Government" - December 1, Every six years, when a new President is sworn in office. Next observance: December 1, 2018.
	if (((year + 4) % 6) == 0) {
		holidayName = NSLocalizedStringFromTable(@"Change of Federal Government", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:1 month:12 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
    
	holidayName = NSLocalizedStringFromTable(@"Day of the Virgin of Guadalupe", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}

// Ecuador http://en.wikipedia.org/wiki/Public_holidays_in_Ecuador
- (NSMutableArray *)ec_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"International Workers' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"The Battle of Pichincha (1822)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"The Birthday of Simón Bolivar (1783)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Declaration of Independence of Quito (1809)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:10 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence of Guayaquil (1820)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:9 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"All Souls Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence of Cuenca (1820)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Foundation of Quito (1534)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}// Puerto Rico http://en.wikipedia.org/wiki/Public_holidays_in_Puerto_Rico#Official_public_holidays
- (NSMutableArray *)pr_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Three Kings Day/Epiphany", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Birthday of Eugenio María de Hostos", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:11 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    //ok_todo: "Martin Luther King, Jr. Day" - Third Monday in January
	holidayName = NSLocalizedStringFromTable(@"Martin Luther King, Jr. Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:1 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Presidents' Day, Washington's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:2 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Birthday of Luis Muñoz Marín", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:18 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Emancipation Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:22 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Birthday of José de Diego", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:16 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Memorial Day", kHolidaysResourceName, nil);
	date = [HolidayData getLastWeekday:Monday OfMonth:5 forYear:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Independence Day is July 4th.
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:4 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Birthday of Don Luis Muñoz Rivera", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:7 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Constitution of Puerto Rico Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Birthday of Dr. José Celso Barbosa", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:27 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Labor Day is the first Monday of September. 
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:9 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Columbus Day is celebrated on the second Monday in October.
	holidayName = NSLocalizedStringFromTable(@"Columbus Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:10 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Veterans Day is celebrated on November 11th.
	holidayName = NSLocalizedStringFromTable(@"Veterans Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Discovery of Puerto Rico", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:19 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Thanksgiving Day is the fourth Thursday in November.
	holidayName = NSLocalizedStringFromTable(@"Thanksgiving Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Thursday ordinal:4 month:11 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}

// Canada http://en.wikipedia.org/wiki/Public_holidays_in_Canada
- (NSMutableArray *)ca_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Valentine's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Family Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:2 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Daylight Saving Time Begins", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:3 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"St Patrick's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:17 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"April Fool's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", kHolidaysResourceName, nil);
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:5 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Father's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:3 month:6 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Victoria Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:5 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
		if ([dc weekday] != Monday) {
			NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
			[offsetDC setDay:[dc weekday] == Sunday?-6:Monday - [dc weekday]];
			date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		}
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Saint Jean Baptiste", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
    //ok_todo: July 2 when July 1 is a Sunday
	holidayName = NSLocalizedStringFromTable(@"Canada Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:3];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"August Civic Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:8 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Alberta Heritage Day", kHolidaysResourceName, nil);
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:9 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Thanksgiving Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:10 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Halloween", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Daylight Saving Time Ends", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:1 month:11 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Remembrance Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Boxing Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}

// Paraguay http://en.wikipedia.org/wiki/Public_holidays_in_Paraguay
- (NSMutableArray *)py_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];[[A3AppDelegate instance] calendar];[[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Heroes' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Chaco Armistice", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Founding of Asunción", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Boqueron Battle Victory Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:29 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Virgin of Caacupe", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve Bank Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}

// Peru http://en.wikipedia.org/wiki/Public_holidays_in_Peru
- (NSMutableArray *)pe_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"St. Peter and St. Paul", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:29 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day(July 28~29)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:28 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Santa Rosa de Lima", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:30 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Battle of Angamos", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}

// El Salvador http://en.wikipedia.org/wiki/Public_holidays_in_El_Salvador#Public_holidays
- (NSMutableArray *)sv_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Peace Accords Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:16 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-7];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"The Day of the Cross", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Mothers' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:10 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
      holidayName = NSLocalizedStringFromTable(@"Father's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:17 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
   
	holidayName = NSLocalizedStringFromTable(@"August Festivals(Aug 1~7)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
      holidayName = NSLocalizedStringFromTable(@"Day of the children", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
	holidayName = NSLocalizedStringFromTable(@"Day of the race", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Day of the Dead", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
      holidayName = NSLocalizedStringFromTable(@"National Festival Of Pupusa(Nov 7~13)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:7 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
	holidayName = NSLocalizedStringFromTable(@"Queen of the Peace Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:21 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Festival Day of the Virgin Guadalupe", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
      holidayName = NSLocalizedStringFromTable(@"New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}

// Honduras http://en.wikipedia.org/wiki/Public_holidays_in_Honduras
- (NSMutableArray *)hn_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Holy Saturday", kHolidaysResourceName, nil);
	date = [HolidayData getHolySaturday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"America's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Francisco Morazan's Day/Soldier's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Columbus Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Army Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:21 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}

// Guatemala http://en.wikipedia.org/wiki/Public_holidays_in_Guatemala
- (NSMutableArray *)gt_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Holy Saturday", kHolidaysResourceName, nil);
	date = [HolidayData getHolySaturday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Army Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:30 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"July Bank Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary(Guatemala City only)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Revolution Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve(afternoon only)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New year's Eve(afternoon only)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}

// Uruguay http://en.wikipedia.org/wiki/Public_holidays_in_Uruguay
- (NSMutableArray *)uy_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Epiphany
	holidayName = NSLocalizedStringFromTable(@"Children's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Carnaval(Monday & Tuesday)", kHolidaysResourceName, nil);
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-2];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
     //todo: "Tourism Week"  - in place of Christian Holy week, moveable in late March or early April
    
	holidayName = NSLocalizedStringFromTable(@"Landing of the 33 Patriots Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:19 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"International Workers' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Battle of Las Piedras", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:18 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Birthday of José Gervasio Artigas and Never Again Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:19 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:18 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Day of the race(Columbus Day)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Deceased ones day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Day of the Family", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Panama http://en.wikipedia.org/wiki/Public_holidays_in_Panama
- (NSMutableArray *)pa_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Martyrs' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:9 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Carnival's Monday", kHolidaysResourceName, nil);
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-2];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Carnival's Tuesday", kHolidaysResourceName, nil);
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Ash Wednesday", kHolidaysResourceName, nil);
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Holy Saturday", kHolidaysResourceName, nil);
	date = [HolidayData getHolySaturday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Presidential Inauguration Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Panama La Vieja Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Separation Day from Colombia", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Flag Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:4 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Colon Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"The Uprising of Los Santos", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:10 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day from Spain", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:28 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Mothers' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Venezuela, Bolivarian Republic of http://en.wikipedia.org/wiki/Public_holidays_in_Venezuela
- (NSMutableArray *)ve_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Epiphany
	holidayName = NSLocalizedStringFromTable(@"Epiphany", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	 
      holidayName = NSLocalizedStringFromTable(@"Feast of the Divina Pastora", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
      holidayName = NSLocalizedStringFromTable(@"Youth Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
      holidayName = NSLocalizedStringFromTable(@"Federation Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
	holidayName = NSLocalizedStringFromTable(@"Carnival(Monday & Tuesday)", kHolidaysResourceName, nil);
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-2];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
    
      holidayName = NSLocalizedStringFromTable(@"International Women's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Holy Week", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-7];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Saint Joseph's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:19 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Beginning of the Independence Movement", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:19 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Fiesta de las Cruces", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	//ok_todo: "Mother's Day" - Second Sunday of May (movable)
	holidayName = NSLocalizedStringFromTable(@"Fiesta de las Cruces", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:5 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Fiesta de las Cruces", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	
	holidayName = NSLocalizedStringFromTable(@"Solemnity of Saint John the Baptist, Battle of Carabobo", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Birth of Simón Bolívar, Navy Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Flag Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Birth of the Blessed Virgin Mary and feasts of the Virgen del Valle and Our Lady of Coromoto", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Day of Indigenous Resistance", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"All Souls Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Feria of La Chinita(Nov. 17~19)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:17 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Venezuelan Air Force Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:10 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Simon Bolivar Memorial Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:17 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Costa Rica http://en.wikipedia.org/wiki/Public_holidays_in_Costa_Rica
- (NSMutableArray *)cr_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Juan Santa Maria Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:11 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Anexion de Guancaste Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Virgin of Los Angeles Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Cultures National Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Día de la Raza Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:18 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}

// Haiti http://en.wikipedia.org/wiki/Public_holidays_in_Haiti
- (NSMutableArray *)ht_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day and Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:2];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Ancestry Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Lundi Gras(Carnaval Monday)", kHolidaysResourceName, nil);
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-2];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Mardi Gras", kHolidaysResourceName, nil);
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	//ok_todo: "Ash Wednesday"
	holidayName = NSLocalizedStringFromTable(@"Ash Wednesday", kHolidaysResourceName, nil);
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

    //ok_todo: "Maundy Thursday"
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", kHolidaysResourceName, nil);
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
    
    //ok_todo: "Easter"
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Pan-American Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labor and Agriculture Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", kHolidaysResourceName, nil);
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Flag and Universities Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:18 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Corpus Christi", kHolidaysResourceName, nil);
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Dessalines Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:17 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"United Nations Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"All Souls Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Armed Forces Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:18 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
    holidayName = NSLocalizedStringFromTable(@"Discovery Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}

// Bahamas https://en.wikipedia.org/wiki/Public_holidays_in_the_Bahamas http://www.bahamas.com/holidays
- (NSMutableArray *)bs_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	if (year >= 2014) {
        holidayName = NSLocalizedStringFromTable(@"Majority Rule Day", kHolidaysResourceName, nil);
        date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
        [holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    }
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", kHolidaysResourceName, nil);
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Pentecost", kHolidaysResourceName, nil);
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Monday", kHolidaysResourceName, nil);
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	//ok_todo: on the first Friday in June
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Friday ordinal:1 month:6 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Bahamas Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:10 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Bahamas Independence Day(day in lieu)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:12 month:7 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	//ok_todo: First Monday in August
	holidayName = NSLocalizedStringFromTable(@"Emancipation Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:8 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"National Heroes' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Boxing Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Christmas Day(day in lieu)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	return holidays;
}

@end
