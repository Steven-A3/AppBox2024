//
//  HolidayMiddleEast.m
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import "HolidayData+MiddleEast.h"
#import "A3AppDelegate.h"

NSUInteger const jewishTable[][14][2] = {
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

@implementation HolidayData (MiddleEast)

// Saudi Arabia
- (NSMutableArray *)sa_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// Known Ashura dates
	// TODO: update yearly
	if (year == 2009) {
		holidayName = NSLocalizedStringFromTable(@"Ashura", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:8 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Ashura", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:16 month:12 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:birthday, kHolidayDuration:@1}];
	}
	
	//todo: Observed officially for 10 days, by most private institutions from 3 to 7 days.
	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
		[offsetDC setDay:-1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Saudi National Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:23 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	//todo: Observed officially for 10 days, by most private institutions from 5 to 7 days.
	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = [@"Islamic New Year" stringByAppendingFormat:@"(%lu)", (unsigned long) (year - ((year > 2007)?578:579) ) ];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2008) {
		holidayName = NSLocalizedStringFromTable(@"Islamic New Year(1429)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	return holidays;
}	

// United Arab Emirates
- (NSMutableArray *)ae_HolidaysInYear
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
	
	holidayName = NSLocalizedStringFromTable(@"Public Sector Holiday(Death of Umm al-Quwain ruler)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Public Sector Holiday(Death of Umm al-Quwain ruler)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Public Sector Holiday(Death of Umm al-Quwain ruler)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:4 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Private Sector Holiday(Prophet's Birthday)", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:birthday, kHolidayDuration:@1}];

		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];

		date = [gregorian dateByAddingComponents:offsetDC toDate:birthday options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

		
	}

	date = [HolidayData getIsraAndMiraj:year withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Isra and Mi'raj", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Sheikh Zayed's Accession", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
    //3 days holiday
	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
		[offsetDC setDay:-1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
    //2 days holiday
	holidayName = NSLocalizedStringFromTable(@"National Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"National Day Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    //3 days holiday
	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = [@"Islamic New Year" stringByAppendingFormat:@"(%lu)", (unsigned long) (year - ((year > 2007)?578:579) )];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2008) {
		holidayName = NSLocalizedStringFromTable(@"Islamic New Year(1429)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	return holidays;
}	

// Qatar http://en.wikipedia.org/wiki/Public_holidays_in_Qatar
- (NSMutableArray *)qa_HolidaysInYear
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
    
    //todo: "National Sports Day" - on the second Tuesday of February (from 2012 AD)
    
    holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
		[offsetDC setDay:-1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"National Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:18 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}	

// Jordan
- (NSMutableArray *)jo_HolidaysInYear
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
	
	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = [@"Islamic New Year" stringByAppendingFormat:@"(%lu)", (unsigned long) (year - ((year > 2007)?578:579) ) ];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2008) {
		holidayName = NSLocalizedStringFromTable(@"Islamic New Year(1429)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	return holidays;
}	

// Egypt
- (NSMutableArray *)eg_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	int day = 7;
	if (year >= 2100) day = 8;
		date = [HolidayData dateWithDay:day month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    holidayName = NSLocalizedStringFromTable(@"Police Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
	holidayName = NSLocalizedStringFromTable(@"Sportsmen's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:21 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Sinai Liberation Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Evacuation Day(Eid el-Galaa)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:18 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Revolution Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:23 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Flooding of the Nile(Wafaa Elnil)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Armed Forces Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Egyptian Naval Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:21 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Suez Day / Popular Resistance Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Victory Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:23 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Spring Festival(Sham El Nessim)", kHolidaysResourceName, nil);
	date = [HolidayData getShamElNessim:year withCalendar:gregorian];
	if (date != nil) {	// Only if it gets the date.
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = [@"Islamic New Year" stringByAppendingFormat:@"(%lu)", (unsigned long) (year - ((year > 2007)?578:579) ) ];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2008) {
		holidayName = NSLocalizedStringFromTable(@"Islamic New Year(1429)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	return holidays;
}

// Kuwait
- (NSMutableArray *)kw_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:3 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"National Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    holidayName = NSLocalizedStringFromTable(@"Liberation Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
	}
	
	date = [HolidayData getIsraAndMiraj:year withCalendar:gregorian];
	if (date != nil) {
		holidayName = NSLocalizedStringFromTable(@"Isra and Mi'raj", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Government Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:9 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = [@"Islamic New Year" stringByAppendingFormat:@"(%lu)", (unsigned long) (year - ( (year > 2007) ? 578 : 579) ) ];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2008) {
		holidayName = NSLocalizedStringFromTable(@"Islamic New Year(1429)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	return holidays;
}

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

/*! Jewish Holiday rather than Israel Holiday
 */
- (NSMutableArray * _Nonnull)jewish_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	if ((year < 2000) || (year > 2049)) {
		NSDictionary *holidayItem = @{kHolidayName:@"Jewish Holidays (2000~2049 only)"};
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

	holidayName = [NSLocalizedStringFromTable(@"Rosh HaShanah*", kHolidaysResourceName, nil) stringByAppendingString:[NSString stringWithFormat:@"(%lu)", (unsigned long)year + 3761 ]];
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

- (NSMutableArray * _Nonnull)il_HolidaysInYear {
	NSUInteger year = self.year;

	if ((year < 2014) || (year > 2017)) {
		NSMutableArray *holidays = [NSMutableArray new];
		NSDictionary *holidayItem = @{kHolidayName:@"Israel Holidays (2014~2017 only)"};
		[holidays addObject:holidayItem];
		return holidays;
	}

	NSString *filepath = [[NSBundle mainBundle] pathForResource:@"IsraelHolidays" ofType:@"plist"];
	NSDictionary *israelHolidays = [NSDictionary dictionaryWithContentsOfFile:filepath];
	if (israelHolidays) {
		NSMutableArray *book = [[NSMutableArray alloc] initWithArray:[israelHolidays objectForKey:[NSString stringWithFormat:@"Y%lu", (unsigned long) year]]];
		NSInteger index, count = [book count];
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
		[offsetDC setHour:[[NSTimeZone systemTimeZone] secondsFromGMT] / 3600];

		NSMutableArray *holidays = [NSMutableArray new];

		NSArray *publicHolidayNames = @[
				@"Purim (Tel Aviv)",
				@"Shushan Purim (Jerusalem)",
				@"Pesach I (First day of Passover)",
				@"Pesach VII (Last day of Passover)",
				@"Yom HaAtzmaut (Independence Day)",
				@"Shavuot (Pentecost)",
				@"Tisha B'Av",
				@"Rosh Hashana (New Year)",
				@"Rosh Hashana II (New Year day 2)",
				@"Yom Kippur",
				@"Sukkot I",
				@"Shmini Atzeret/Simchat Torah",
				@"Election Day"
		];
		for (index = 0; index < count; index++) {
			NSMutableArray *item = [NSMutableArray arrayWithArray:[book objectAtIndex:index]];
			NSString *holidayName = item[0];
			BOOL isPublicHoliday = [publicHolidayNames indexOfObject:holidayName] != NSNotFound;
			NSDate *newDate = [gregorian dateByAddingComponents:offsetDC toDate:[item objectAtIndex:1] options:0];
			[holidays addObject:@{kHolidayName:NSLocalizedStringFromTable(holidayName, kHolidaysResourceName, nil), kHolidayIsPublic:@(isPublicHoliday), kHolidayDate:newDate, kHolidayDuration:@1}];
		}

		return holidays;
	}
	return nil;
}

@end
