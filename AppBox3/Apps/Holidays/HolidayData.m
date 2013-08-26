//
//  HolidayUtil.m
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import "HolidayData.h"
#import "A3UIDevice.h"

@implementation HolidayData

// Option 0, no adjustment
// Option 1, if it falls in Saturday or Sunday put that day to monday
// Option 2, if it falls in Saturday put it Friday, it it falls in Sunday put it Monday
// Option 3, if it falls in Sunday put it Monday, for Saturday no adjustment
// Option 4, if it doesn't fall at Monday, these holidays are observed the following Monday. (Colombia)
// Option 5, If the date falls on a Tuesday or Wednesday, the holiday is the preceding Monday. 
//           If it falls on a Thursday or a Friday then the holiday is the following Monday.
// Option 6, if it falls in Saturday put it Monday, it it falls in Sunday put it Tuesday (Second day of New year, or St. Stephen's Day)
+ (NSDate *)adjustDate:(NSDate *)date calendar:(NSCalendar *)calendar option:(int)option
{
	NSDate *result = nil;
	if (option == 6) {
		NSDateComponents *originalDC = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
		switch ([originalDC weekday]) {
			case Sunday:
			case Saturday:
			{
				NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
				[offsetdc setDay:2];
				result = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
				break;
			}
		}
	} else if (option == 5) {
		NSDateComponents *originalDC = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
		switch ([originalDC weekday]) {
			case Sunday:
			case Monday:
			case Saturday:
				// Do Nothing
				break;
			default:
			{
				NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
				switch ([originalDC weekday]) {
					case Tuesday:
						[offsetdc setDay:-8];
						break;
					case Wednesday:
						[offsetdc setDay:-9];
						break;
					case Thursday:
						[offsetdc setDay:4];
						break;
					case Friday:
						[offsetdc setDay:3];
						break;
				}
				result = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
			}
		}
	} else if (option == 4) {
		NSDateComponents *originalDC = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
		if ([originalDC weekday] != Monday) {
			NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
			[offsetdc setDay:([originalDC weekday] == 1)?1:(9 - [originalDC weekday])];
			result = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
		}
	} else if (option != 0) {
		NSDateComponents *originalDC = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
		int offset = 0;
		if ([originalDC weekday] == Saturday) {
			if (option == 1)
				offset = 2;
			else if (option == 2)
				offset = -1;
		} else if ([originalDC weekday] == Sunday) {
			offset = 1;
		}
		if (offset != 0) {
			NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
			[offsetdc setDay:offset];
			result = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
		}
	}
	return result;
}

+ (NSDate *)dateWithDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger) year withCalendar:(NSCalendar *)calendar option:(int)option
{
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	[dateComponents setDay:day];
	[dateComponents setMonth:month];
	[dateComponents setYear:year];
	NSDate *date = [calendar dateFromComponents:dateComponents];
	
	if (option != 0) {
		NSDate *temp = [self adjustDate:date calendar:calendar option:option];
		if (temp != nil)
			date = temp;
	}
	return date;
}

+ (NSDate *)dateWithWeekday:(NSUInteger)weekday ordinal:(NSUInteger)ordinal month:(NSUInteger)month year:(NSUInteger)year withCalendar:(NSCalendar *)calendar 
{
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	[dateComponents setWeekday:weekday];
	[dateComponents setWeekdayOrdinal:ordinal];
	[dateComponents setMonth:month];
	[dateComponents setYear:year];
	NSDate *date = [calendar dateFromComponents:dateComponents];
	if (ordinal >= 5) {
		NSDateComponents *verifyDC = [calendar components:NSMonthCalendarUnit fromDate:date];
		if ([verifyDC month] != month) {
			[dateComponents setWeekdayOrdinal:ordinal - 1];
			date = [calendar dateFromComponents:dateComponents];
		}
	}
	
	return date;
}

+ (NSDate *)getEasterDayOfYear:(NSUInteger)y withCalendar:(NSCalendar *)calendar
{
	NSUInteger c = y / 100;
    NSUInteger n = y - 19 * ( y / 19 );
    NSUInteger k = ( c - 17 ) / 25;
    NSUInteger i = c - c / 4 - ( c - k ) / 3 + 19 * n + 15;
    i = i - 30 * ( i / 30 );
    i = i - ( i / 28 ) * ( 1 - ( i / 28 ) * ( 29 / ( i + 1 ) )
						  * ( ( 21 - n ) / 11 ) );
    NSUInteger j = y + y / 4 + i + 2 - c + c / 4;
    j = j - 7 * ( j / 7 );
    NSUInteger l = i - j;
    NSUInteger m = 3 + ( l + 40 ) / 44;
	NSUInteger d = l + 28 - 31 * ( m / 4 );
	NSDate *date = [self dateWithDay:d month:m year:y withCalendar:calendar option:0];
	return date;
}

// Orthodox Easter Sunday Table for 1982~2022, {month, day}
static int orthodoxEasterSunday[][2] = {
	/*1982*/        {4,18}, {5, 8}, {4,22}, {4,14}, {5, 4}, {4,19}, {4,10}, {4,30}, {4,15}, 
	/*1991*/{4, 7}, {4,26}, {4,18}, {5, 1}, {4,23}, {4,14}, {4,27}, {4,19}, {4,11}, {4,30},
	/*2001*/{4,15}, {5, 5}, {4,27}, {4,11}, {5, 1}, {4,23}, {4, 8}, {4,27}, {4,19}, {4, 4}, 
	/*2011*/{4,24}, {4,15}, {5, 5}, {4,20}, {4,12}, {5, 1}, {4,16}, {4, 8}, {4,28}, {4,19},
	/*2021*/{5, 2}, {4,24}};

+ (NSDate *)getOrthodoxEaster:(NSUInteger)y withCalendar:(NSCalendar *)calendar
{
	if ((y < 1982) || (y > 2022)) return nil;
	
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	[dateComponents setDay:orthodoxEasterSunday[y - 1982][1]];
	[dateComponents setMonth:orthodoxEasterSunday[y - 1982][0]];
	[dateComponents setYear:y];
	NSDate *date = [calendar dateFromComponents:dateComponents];
	
	return date;
}

+ (NSDate *)getShamElNessim:(NSUInteger)y withCalendar:(NSCalendar *)calendar
{
	if ((y < 1982) || (y > 2022)) return nil;
	
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	[dateComponents setDay:orthodoxEasterSunday[y - 1982][1] + 1];
	[dateComponents setMonth:orthodoxEasterSunday[y - 1982][0]];
	[dateComponents setYear:y];
	NSDate *date = [calendar dateFromComponents:dateComponents];
	
	return date;
}


+ (NSDate *)getMaundiThursday:(NSUInteger)y withCalendar:(NSCalendar *)calendar
{
	NSDate *date = [self getEasterDayOfYear:y withCalendar:calendar];
	if (date == nil) return nil;
	NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
	[offsetdc setDay:-3];
	date = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
	 
	return date;
}

+ (NSDate *)getGoodFriday:(NSUInteger)y western:(BOOL)western withCalendar:(NSCalendar *)calendar 
{
	NSDate *date;
	if (western) date = [self getEasterDayOfYear:y withCalendar:calendar];
		else date = [self getOrthodoxEaster:y withCalendar:calendar];
			if (date == nil) return nil;
	NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
	[offsetdc setDay:-2];
	date = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
	 
	return date;
}

+ (NSDate *)getHolySaturday:(NSUInteger)y withCalendar:(NSCalendar *)calendar 
{
	NSDate *date = [self getEasterDayOfYear:y withCalendar:calendar];
	if (date == nil) return nil;
	NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
	[offsetdc setDay:-1];
	date = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
	 
	return date;
}

+ (NSDate *)getEasterMonday:(NSUInteger)y western:(BOOL)western withCalendar:(NSCalendar *)calendar 
{
	NSDate *date;
	if (western) date = [self getEasterDayOfYear:y withCalendar:calendar];
		else date = [self getOrthodoxEaster:y withCalendar:calendar];
			if (date == nil) return nil;
	NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
	[offsetdc setDay:1];
	date = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
	 
	return date;
}

+ (NSDate *)getAshWednesday:(NSUInteger)y withCalendar:(NSCalendar *)calendar
{
	NSDate *date = [self getEasterDayOfYear:y withCalendar:calendar];
	if (date == nil) return nil;
	NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
	[offsetdc setDay:-46];
	date = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
	 
	return date;
}

+ (NSDate *)getAscensionDay:(NSUInteger)y western:(BOOL)western withCalendar:(NSCalendar *)calendar
{
	NSDate *date;
	if (western) date = [self getEasterDayOfYear:y withCalendar:calendar];
		else date = [self getOrthodoxEaster:y withCalendar:calendar];
			if (date == nil) return nil;
	NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
	[offsetdc setDay:39];
	date = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
	 
	return date;
}


+ (NSDate *)getPentecost:(NSUInteger)y western:(BOOL)western withCalendar:(NSCalendar *)calendar
{
	NSDate *date;
	if (western) date = [self getEasterDayOfYear:y withCalendar:calendar];
		else date = [self getOrthodoxEaster:y withCalendar:calendar];
			if (date == nil) return nil;
	NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
	[offsetdc setDay:49];
	date = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
	 
	return date;
}

+ (NSDate *)getWhitMonday:(NSUInteger)y western:(BOOL)western withCalendar:(NSCalendar *)calendar
{
	NSDate *date;
	if (western) date = [self getEasterDayOfYear:y withCalendar:calendar];
		else date = [self getOrthodoxEaster:y withCalendar:calendar];
			if (date == nil) return nil;
	NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
	[offsetdc setDay:50];
	date = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
	 
	return date;
}

+ (NSDate *)getSacredHeart:(NSUInteger)y withCalendar:(NSCalendar *)calendar
{
	NSDate *date = [self getEasterDayOfYear:y withCalendar:calendar];
	if (date == nil) return nil;
	NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
	[offsetdc setDay:68];
	date = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
	 
	return date;
}

+ (NSDate *)getCorpusChristi:(NSUInteger)y withCalendar:(NSCalendar *)calendar
{
	NSDate *date = [self getEasterDayOfYear:y withCalendar:calendar];
	if (date == nil) return nil;
	NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
	[offsetdc setDay:60];
	date = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
	 
	return date;
}

// Islamic New Year for 1989~2012, with {month, day} format
// TODO: Update yearly
static NSUInteger islamicNewYear[][2] = {
	/*1989,1410*/{ 8, 2},{ 7,23}, 
	/*1991,1412*/{ 7,12},{ 7, 1},{ 6,20},{ 6,10},{ 5,30},{ 5,19},{ 5, 8},{ 4,28},{ 4,17},{ 4, 5},
	/*2001,1422*/{ 3,26},{ 3,15},{ 3, 4},{ 2,22},{ 2,10},{ 1,31},{ 1,20},{12,28},{12,17},{12, 7},
	/*2011,1432*/{11,26},{11,14},{11,4},{10,24},{10,13}};

// From year 2008-2015, {month, day}, Eidul Fitr or Ramadan Feast
// TODO: Update yearly
static NSUInteger Eidul_Fitr[][2] = {{10, 1}, {9, 20}, {9, 10}, {8, 31}, {8, 19}, {8, 8}, {7, 29}, {7, 19}};

// From year 1980-2021, {month, day}, Sacrifice Feast or Eid al-Adha
// TODO: Update yearly
static NSUInteger Eid_al_adha[][2] = {
	/*1980*/{10,17},{10, 6},{ 9,26},{ 9,15},{ 9, 4},{ 8,24},{ 8,14},{ 8, 3},{ 7,23},{ 7,21},
	/*1990*/{ 7, 2},{ 6,21},{ 6,10},{ 5,30},{ 5,20},{ 5, 9},{ 4,28},{ 4,17},{ 4, 7},{ 3,27},
	/*2000*/{ 3,16},{ 3, 5},{ 2,22},{ 2,11},{ 2, 1},{ 1,20},{12,30},{12,19},{12, 8},{11,27},
	/*2010*/{11,17},{11, 6},{10,26},{10,15},{10, 4},{ 9,23},{ 9,11},{ 9, 1},{ 8,21},{ 8,11},
	/*2020*/{7,31},{7,23}};

+ (NSDate *)getIslamicNewYear:(NSUInteger)year withCalendar:(NSCalendar *)calendar
{
	if ((year < 1989) || (year > 2015)) return nil;
	return [self dateWithDay:islamicNewYear[year - 1989][1] month:islamicNewYear[year - 1989][0] year:year withCalendar:calendar option:0];
}

// option:0 no additional adjustment
// option:1 Holiday falling on a Sunday are observed the following Monday
+ (NSDate *)getRamadanFeast:(NSUInteger)year withCalendar:(NSCalendar *)calendar option:(int)option
{
	if ((year < 2008) || (year > 2015)) return nil;
	return [self dateWithDay:Eidul_Fitr[year - 2008][1] month:Eidul_Fitr[year - 2008][0] year:year withCalendar:calendar option:option];
}

+ (NSDate *)getLaylat_al_Qadr:(NSUInteger)y withCalendar:(NSCalendar *)calendar
{
	NSDate *date = [self getRamadanFeast:y withCalendar:calendar option:0];
	if (date == nil) return nil;
	NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
	[offsetdc setDay:-3];
	date = [calendar dateByAddingComponents:offsetdc toDate:date options:0];
	 
	return date;
}

+ (NSDate *)getSacrificeFeast:(NSUInteger)year withCalendar:(NSCalendar *)calendar
{
	if ((year < 1980) || (year > 2021)) return nil;
	return [self dateWithDay:Eid_al_adha[year - 1980][1] month:Eid_al_adha[year - 1980][0] year:year withCalendar:calendar option:0];
}

+ (NSArray *)getMohamedBirthday:(NSUInteger)year
{
	// TODO: Update yearly

	NSDictionary *birthday = @{
	@"1980":@"1980-01-30",
	@"1981":@"1981-01-18",
	@"1982":@"1982-01-08",
	@"1982":@"1982-12-28",
	@"1983":@"1983-12-17",
	@"1984":@"1984-12-06",
	@"1985":@"1985-11-04",
	@"1986":@"1986-11-15",
	@"1987":@"1987-11-04",
	@"1988":@"1988-10-23",
	@"1989":@"1989-10-13",
	@"1990":@"1990-10-02",
	@"1991":@"1991-09-21",
	@"1992":@"1992-09-10",
	@"1993":@"1993-08-30",
	@"1994":@"1994-08-19",
	@"1995":@"1995-08-09",
	@"1996":@"1996-07-28",
	@"1997":@"1997-07-18",
	@"1998":@"1998-07-07",
	@"1999":@"1999-06-26",
	@"2000":@"2000-06-15",
	@"2001":@"2001-06-04",
	@"2002":@"2002-05-24",
	@"2003":@"2003-05-14",
	@"2004":@"2004-05-02",
	@"2005":@"2005-04-21",
	@"2006":@"2006-04-11",
	@"2007":@"2007-03-31",
	@"2008":@"2008-03-20",
	@"2009":@"2009-03-09",
	@"2010":@"2010-02-26",
	@"2011":@"2011-02-16",
	@"2012":@"2012-02-05",
	@"2013":@"2013-01-24",
	@"2014":@"2014-01-14",
	@"2015-1":@"2015-01-03",
	@"2015-2":@"2015-12-24"
	};

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSArray *resultArray = nil;
	if (year == 2015) {
		resultArray = @[[dateFormatter dateFromString:[birthday objectForKey:@"2015-1"]],
						[dateFormatter dateFromString:[birthday objectForKey:@"2015-2"]] ];
	} else {
		NSString *dateString = [birthday objectForKey:[NSString stringWithFormat:@"%d",year]];
		if (dateString) {
			resultArray = @[[dateFormatter dateFromString:dateString]];
		}
	}
	

	return resultArray;
}

//	http://en.wikipedia.org/wiki/Muslim_holidays
+ (NSDate *)getIsraAndMiraj:(NSUInteger)year withCalendar:(NSCalendar *)calendar {
	// TODO: Update yearly
	NSDictionary *days = @{
	@"2008":@"2008-07-31",
	@"2009":@"2009-07-20",
	@"2010":@"2010-07-09",
	@"2011":@"2011-06-29",
	@"2012":@"2012-06-17",
	@"2013":@"2013-06-06",
	@"2014":@"2014-05-26"
	};
	NSDate *resultDate = [self getDate:year dictionary:days];
	return resultDate;
}

+ (NSDate *)getVesakDay:(NSUInteger) year forCountryCode:(NSString *)countryCode withCalendar:(NSCalendar *)calendar {
	// TODO: Update yearly
	NSDictionary *thailand = @{
	@"2001":@"2001-05-07",
	@"2002":@"2002-05-26",
	@"2003":@"2003-05-15",
	@"2004":@"2004-06-02",
	@"2005":@"2005-05-22",
	@"2006":@"2006-05-12",
	@"2007":@"2007-05-31",
	@"2008":@"2008-05-19",
	@"2009":@"2009-05-08",
	@"2010":@"2010-05-28",
	@"2011":@"2011-05-17",
	@"2012":@"2012-06-04",
	@"2013":@"2013-05-24",
	@"2014":@"2014-05-13",
	@"2015":@"2015-06-01",
	@"2016":@"2016-05-20",
	@"2017":@"2017-05-10"
	};
	NSDictionary *singapore = @{
	@"2001":@"2001-05-07",
	@"2002":@"2002-05-27",
	@"2003":@"2003-05-15",
	@"2004":@"2004-06-02",
	@"2005":@"2005-05-22",
	@"2006":@"2006-05-12",
	@"2007":@"2007-05-31",
	@"2008":@"2008-05-19",
	@"2009":@"2009-05-08",
	@"2010":@"2010-05-28",
	@"2011":@"2011-05-17",
	@"2012":@"2012-05-05"
	};
	NSDictionary *indonesia = @{
	@"2007":@"2007-06-01",
	@"2008":@"2008-05-20",
	@"2009":@"2009-05-09",
	@"2010":@"2010-05-28",
	@"2011":@"2011-05-17",
	@"2012":@"2012-05-06"
	};
	NSDictionary *malaysia = @{
	@"2008":@"2008-05-19",
	@"2009":@"2009-05-09",
	@"2010":@"2010-05-28",
	@"2011":@"2011-05-17",
	@"2012":@"2012-05-05"
	};
	NSDictionary *bangladesh = @{
	@"2004":@"2004-05-03",
	@"2005":@"2005-05-23",
	@"2006":@"2006-05-13",
	@"2007":@"2007-05-02",
	@"2008":@"2008-05-20",
	@"2009":@"2009-05-08",
	@"2010":@"2010-05-27",
	@"2011":@"2011-05-17",
	@"2012":@"2012-05-06"
	};

	NSDictionary *vesak = @{
	@"th":thailand,
	@"sg":singapore,
	@"id":indonesia,
	@"my":malaysia,
	@"bd":bangladesh
	};

	NSDate *vesakDate = nil;

	NSDictionary *myCountry = [vesak objectForKey:countryCode];
	if (myCountry) {
		NSString *myVesakDate = [myCountry objectForKey:[NSString stringWithFormat:@"%d",year]];
		if (myVesakDate) {
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"yyyy-MM-dd"];
			vesakDate = [dateFormatter dateFromString:myVesakDate];
			
		}
	}
	return vesakDate;
}

+ (NSDate *)getDate:(NSInteger)year dictionary:(NSDictionary *)dictionary {
	NSString *deepavaliDateString = [dictionary objectForKey:[NSString stringWithFormat:@"%d", year]];
	NSDate *resultDate = nil;
	if (deepavaliDateString) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		resultDate = [dateFormatter dateFromString:deepavaliDateString];
	}
	return resultDate;
}

+ (NSDate *)getDeepavaliForYear:(NSInteger)year {
	NSDictionary *deepavali = @{
	@"2008":@"2008-10-29",
	@"2009":@"2009-10-17",
	@"2010":@"2010-11-05",
	@"2011":@"2011-10-26",
	@"2012":@"2012-11-13",
	@"2013":@"2013-11-03"
	};

	NSDate *resultDate = [self getDate:year dictionary:deepavali];
	return resultDate;
}

+ (NSDate *)koreaLunarDateWithSolarDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year
{
	NSDateComponents *lunarComponents = [[NSDateComponents alloc] init];
	[lunarComponents setDay:day];
	[lunarComponents setMonth:month];
	[lunarComponents setYear:year];
	NSDate *date = [HolidayData lunarCalcWithComponents:lunarComponents gregorianToLunar:NO leapMonth:NO korean:YES];
	
	return date;
}

+ (NSDate *)chinaLunarDateWithSolarDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year
{
	NSDateComponents *lunarComponents = [[NSDateComponents alloc] init];
	[lunarComponents setDay:day];
	[lunarComponents setMonth:month];
	[lunarComponents setYear:year];
	NSDate *date = [HolidayData lunarCalcWithComponents:lunarComponents gregorianToLunar:NO leapMonth:NO korean:NO];
	
	return date;
}

+ (NSDate *)lunarDateWithSolarDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year
{
	NSDateComponents *lunarComponents = [[NSDateComponents alloc] init];
	[lunarComponents setDay:day];
	[lunarComponents setMonth:month];
	[lunarComponents setYear:year];
	
// TODO: Global Settings for Korean/Chinese Lunar calendar usage
//	BOOL korean = [[[NSUserDefaults standardUserDefaults] objectForKey:APPBOX_KEY_GLOBAL_LUNAR_CALENDAR] isEqualToString:APPBOX_VALUE_LUNAR_CALENDAR_KOREA];
	
	NSDate *date = [HolidayData lunarCalcWithComponents:lunarComponents gregorianToLunar:NO leapMonth:NO korean:NO];
	return date;
}

+ (NSDate *)getLastWeekday:(NSUInteger)weekday OfMonth:(NSUInteger)month forYear:(NSUInteger)year withCalendar:(NSCalendar *)calendar
{
	NSDateComponents *dc = [[NSDateComponents alloc] init];
	NSDate *date;
	
	[dc setWeekday:weekday];
	[dc setMonth:month];
	[dc setYear:year];
	date = [calendar dateFromComponents:dc];
	
	NSRange range = [calendar rangeOfUnit:NSWeekdayOrdinalCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
	[dc setWeekday:weekday];
	[dc setWeekdayOrdinal:(range.location - 1) + range.length];
	[dc setMonth:month];
	[dc setYear:year];
	
	NSDate *dateReturn = [calendar dateFromComponents:dc];
	
	NSDateComponents *dcForMonth = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:dateReturn];
	if (month != [dcForMonth month]) {
		NSDateComponents *newDC = [[NSDateComponents alloc] init];
		[newDC setWeekday:weekday];
		[newDC setWeekdayOrdinal:(range.location - 1) + range.length - 1];
		[newDC setMonth:month];
		[newDC setYear:year];
		dateReturn = [calendar dateFromComponents:newDC];
	}
	NSLog(@"%@", [dateReturn description]);
	return dateReturn;
}

typedef NSUInteger arrayOfMonths[12];

// 음력 데이터 (평달 - 작은달 :1,  큰달:2 )
// (윤달이 있는 달 - 평달이 작고 윤달도 작으면 :3 , 평달이 작고 윤달이 크면 : 4)
// (윤달이 있는 달 - 평달이 크고 윤달이 작으면 :5,  평달과 윤달이 모두 크면 : 6)
static arrayOfMonths lunarMonthTable_Korean[] = {
	{2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 2, 5, 2, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1},   /* 1901 */
	{2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2},
	{1, 2, 1, 2, 3, 2, 1, 1, 2, 2, 1, 2},
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1},
	{2, 2, 1, 2, 2, 1, 1, 2, 1, 2, 1, 2},
	{1, 2, 2, 4, 1, 2, 1, 2, 1, 2, 1, 2},
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},
	{2, 1, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2},
	{1, 5, 1, 2, 1, 2, 1, 2, 2, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1},
	{2, 1, 2, 1, 1, 5, 1, 2, 2, 1, 2, 2},   /* 1911 */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2},
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2},
	{2, 2, 1, 2, 5, 1, 2, 1, 2, 1, 1, 2},
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},
	{2, 3, 2, 1, 2, 2, 1, 2, 2, 1, 2, 1},
	{2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 5, 2, 2, 1, 2, 2},
	{1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2, 2},
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2},   /* 1921 */
	{2, 1, 2, 2, 3, 2, 1, 1, 2, 1, 2, 2},
	{1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2},
	{2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 1},
	{2, 1, 2, 5, 2, 1, 2, 2, 1, 2, 1, 2},
	{1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},
	{2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2},
	{1, 5, 1, 2, 1, 1, 2, 2, 1, 2, 2, 2},
	{1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2},
	{1, 2, 2, 1, 1, 5, 1, 2, 1, 2, 2, 1},
	{2, 2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 1},   /* 1931 */
	{2, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},
	{1, 2, 2, 1, 6, 1, 2, 1, 2, 1, 1, 2},
	{1, 2, 1, 2, 2, 1, 2, 2, 1, 2, 1, 2},
	{1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},
	{2, 1, 4, 1, 2, 1, 2, 1, 2, 2, 2, 1},
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1},
	{2, 2, 1, 1, 2, 1, 4, 1, 2, 2, 1, 2},
	{2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 1, 2},
	{2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1},
	{2, 2, 1, 2, 2, 4, 1, 1, 2, 1, 2, 1},   /* 1941 */
	{2, 1, 2, 2, 1, 2, 2, 1, 2, 1, 1, 2},
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2},
	{1, 1, 2, 4, 1, 2, 1, 2, 2, 1, 2, 2},
	{1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2},
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2},
	{2, 5, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2},
	{2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},
	{2, 2, 1, 2, 1, 2, 3, 2, 1, 2, 1, 2},
	{2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1},
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},   /* 1951 */
	{1, 2, 1, 2, 4, 2, 1, 2, 1, 2, 1, 2},
	{1, 2, 1, 1, 2, 2, 1, 2, 2, 1, 2, 2},
	{1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2},
	{2, 1, 4, 1, 1, 2, 1, 2, 1, 2, 2, 2},
	{1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2},
	{2, 1, 2, 1, 2, 1, 1, 5, 2, 1, 2, 2},
	{1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},
	{1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1},
	{2, 1, 2, 1, 2, 5, 2, 1, 2, 1, 2, 1},
	{2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2},   /* 1961 */
	{1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1},
	{2, 1, 2, 3, 2, 1, 2, 1, 2, 2, 2, 1},
	{2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2},
	{1, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 2},
	{1, 2, 5, 2, 1, 1, 2, 1, 1, 2, 2, 1},
	{2, 2, 1, 2, 2, 1, 1, 2, 1, 2, 1, 2},
	{1, 2, 2, 1, 2, 1, 5, 2, 1, 2, 1, 2},
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},
	{2, 1, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2},
	{1, 2, 1, 1, 5, 2, 1, 2, 2, 2, 1, 2},   /* 1971 */
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1},
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 2, 1},
	{2, 2, 1, 5, 1, 2, 1, 1, 2, 2, 1, 2},
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2},
	{2, 2, 1, 2, 1, 2, 1, 5, 2, 1, 1, 2},
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 1},
	{2, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},
	{2, 1, 1, 2, 1, 6, 1, 2, 2, 1, 2, 1},
	{2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2},
	{1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2, 2},   /* 1981 */
	{2, 1, 2, 3, 2, 1, 1, 2, 2, 1, 2, 2},
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2},
	{2, 1, 2, 2, 1, 1, 2, 1, 1, 5, 2, 2},
	{1, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},
	{1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 1, 1},
	{2, 1, 2, 2, 1, 5, 2, 2, 1, 2, 1, 2},
	{1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},
	{2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2},
	{1, 2, 1, 1, 5, 1, 2, 2, 1, 2, 2, 2},
	{1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2},   /* 1991 */
	{1, 2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2},
	{1, 2, 5, 2, 1, 2, 1, 1, 2, 1, 2, 1},
	{2, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},
	{1, 2, 2, 1, 2, 2, 1, 5, 2, 1, 1, 2},
	{1, 2, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2},
	{1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},
	{2, 1, 1, 2, 3, 2, 2, 1, 2, 2, 2, 1},
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1},
	{2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1},
	{2, 2, 2, 3, 2, 1, 1, 2, 1, 2, 1, 2},   /* 2001 */
	{2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1},
	{2, 2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2},
	{1, 5, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1, 1},
	{2, 1, 2, 1, 2, 1, 5, 2, 2, 1, 2, 2},
	{1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2},
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2},
	{2, 2, 1, 1, 5, 1, 2, 1, 2, 1, 2, 2},
	{2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},
	{2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1},   /* 2011 */
	{2, 1, 6, 2, 1, 2, 1, 1, 2, 1, 2, 1},
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},
	{1, 2, 1, 2, 1, 2, 1, 2, 5, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2, 1},
	{2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2},
	{2, 1, 1, 2, 3, 2, 1, 2, 1, 2, 2, 2},
	{1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2},
	{2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},
	{2, 1, 2, 5, 2, 1, 1, 2, 1, 2, 1, 2},
	{1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1},   /* 2021 */
	{2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2},
	{1, 5, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1},
	{2, 1, 2, 1, 1, 5, 2, 1, 2, 2, 2, 1},
	{2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2},
	{1, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 2},
	{1, 2, 2, 1, 5, 1, 2, 1, 1, 2, 2, 1},
	{2, 2, 1, 2, 2, 1, 1, 2, 1, 1, 2, 2},
	{1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1},
	{2, 1, 5, 2, 1, 2, 2, 1, 2, 1, 2, 1},   /* 2031 */
	{2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 5, 2},
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1},
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2},
	{2, 2, 1, 2, 1, 4, 1, 1, 2, 2, 1, 2},
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2},
	{2, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 1},
	{2, 2, 1, 2, 5, 2, 1, 2, 1, 2, 1, 1},
	{2, 1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 1},
	{2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2},   /* 2041 */
	{1, 5, 1, 2, 1, 2, 1, 2, 2, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2, 2}};

// 음력 데이터 (평달 - 작은달 :1,  큰달:2 )
// (윤달이 있는 달 - 평달이 작고 윤달도 작으면 :3 , 평달이 작고 윤달이 크면 : 4)
// (윤달이 있는 달 - 평달이 크고 윤달이 작으면 :5,  평달과 윤달이 모두 크면 : 6)
static arrayOfMonths lunarMonthTable_Chinese[] = {
	{2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2},	/* 1899 */
	{1, 2, 1, 1, 2, 1, 2, 5, 2, 2, 1, 2},	/* 1900 */
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1},   /* 1901 Verified */
	{2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2},	/* 1902 Verified */
	{1, 2, 1, 2, 3, 2, 1, 1, 2, 2, 1, 2},	/* 1903 Verified */
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1},	/* 1904 Verified */
	{2, 2, 1, 2, 2, 1, 1, 2, 1, 2, 1, 2},	/* 1905 Verified */
	{1, 2, 2, 4, 1, 2, 1, 2, 1, 2, 1, 2},	/* 1906 Verified */
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},	/* 1907 Verified */
	{2, 1, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2},	/* 1908 Verified */
	{1, 5, 1, 2, 1, 2, 1, 2, 2, 2, 1, 2},	/* 1909 Verified */
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1},	/* 1910 Verified */
	{2, 1, 2, 1, 1, 5, 1, 2, 2, 1, 2, 2},   /* 1911 Verified */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2},	/* 1912 Verified */
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2},	/* 1913 Verified */
	{2, 2, 1, 2, 4, 1, 2, 1, 1, 2, 1, 2},	/* 1914 Verified -- Different from Korean */
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 1},	/* 1915 Verified -- Different from Korean */
	{2, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},	/* 1916 Verified */
	{2, 3, 2, 1, 2, 2, 1, 2, 2, 1, 2, 1},	/* 1917 Verified */
	{2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2},	/* 1918 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 1, 4, 2, 1, 2, 2, 2},	/* 1919 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2},	/* 1920 Verified -- Different from Korean */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2},   /* 1921 Verified */
	{2, 1, 2, 2, 3, 2, 1, 1, 2, 1, 2, 2},	/* 1922 Verified */
	{1, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},	/* 1923 Verified -- Different from Korean */
	{1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 1, 1},	/* 1924 Verified -- Different from Korean */
	{2, 1, 2, 4, 2, 1, 2, 2, 1, 2, 1, 2},	/* 1925 Verified -- Different from Korean */
	{1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},	/* 1926 Verified */
	{2, 1, 1, 2, 1, 2, 1, 2, 1, 2, 2, 2},	/* 1927 Verified -- Different from Korean */
	{1, 5, 1, 2, 1, 1, 2, 1, 2, 2, 2, 2},	/* 1928 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2},	/* 1929 Verified */
	{1, 2, 2, 1, 1, 5, 1, 2, 1, 2, 2, 1},	/* 1930 Verified */
	{2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1},   /* 1931 Verified -- Different from Korean */
	{2, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},	/* 1932 Verified */
	{1, 2, 2, 1, 6, 1, 2, 1, 2, 1, 1, 2},	/* 1933 Verified */
	{1, 2, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2},	/* 1934 Verified -- Different from Korean */
	{1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},	/* 1935 Verified */
	{2, 1, 4, 1, 1, 2, 2, 1, 2, 2, 2, 1},	/* 1936 Verified -- Different from Korean */
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1},	/* 1937 Verified */
	{2, 2, 1, 1, 2, 1, 4, 1, 2, 2, 1, 2},	/* 1938 Verified */
	{2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 1, 2},	/* 1939 Verified */
	{2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1},	/* 1940 Verified */
	{2, 2, 1, 2, 2, 4, 1, 1, 2, 1, 2, 1},   /* 1941 Verified */
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},	/* 1942 Verified -- Different from Korean */
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},	/* 1943 Verified -- Different from Korean */
	{2, 1, 2, 4, 1, 2, 1, 2, 2, 1, 2, 2},	/* 1944 Verified -- Different from Korean */
	{1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2},	/* 1945 Verified */
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2},	/* 1946 Verified */
	{2, 5, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2},	/* 1947 Verified */
	{2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},	/* 1948 Verified */
	{2, 1, 2, 2, 1, 2, 3, 2, 1, 2, 1, 2},	/* 1949 Verified -- Different from Korean */
	{1, 2, 2, 1, 2, 2, 1, 1, 2, 1, 2, 1},	/* 1950 Verified -- Different from Korean */
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},   /* 1951 Verified */
	{1, 2, 1, 2, 4, 1, 2, 2, 1, 2, 1, 2},	/* 1952 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 2, 1, 2, 2, 1, 2, 1},	/* 1953 Verified -- Different from Korean */
	{2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2},	/* 1954 Verified -- Different from Korean */
	{1, 2, 4, 1, 1, 2, 1, 2, 1, 2, 2, 2},	/* 1955 Verified -- Different from Korean */
	{1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2},	/* 1956 Verified */
	{2, 1, 2, 1, 2, 1, 1, 5, 2, 1, 2, 1},	/* 1957 Verified -- Different from Korean */
	{2, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},	/* 1958 Verified -- Different from Korean */
	{1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1},	/* 1959 Verified */
	{2, 1, 2, 1, 2, 5, 2, 1, 2, 1, 2, 1},	/* 1960 Verified */
	{2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2},   /* 1961 Verified */
	{1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1},	/* 1962 Verified */
	{2, 1, 2, 3, 2, 1, 2, 1, 2, 2, 2, 1},	/* 1963 Verified */
	{2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2},	/* 1964 Verified */
	{1, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1},	/* 1965 Verified -- Different from Korean */
	{2, 2, 5, 2, 1, 1, 2, 1, 1, 2, 2, 1},	/* 1966 Verified -- Different from Korean */
	{2, 2, 1, 2, 2, 1, 1, 2, 1, 2, 1, 2},	/* 1967 Verified */
	{1, 2, 1, 2, 2, 1, 5, 2, 1, 2, 1, 2},	/* 1968 Verified -- Different from Korean */
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},	/* 1969 Verified */
	{2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2},	/* 1970 Verified -- Different from Korean */
	{1, 2, 1, 1, 5, 2, 1, 2, 2, 2, 1, 2},   /* 1971 Verified */
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2},	/* 1972 Verified -- Different from Korean */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2},	/* 1973 Verified -- Different from Korean */
	{2, 2, 1, 5, 1, 2, 1, 1, 2, 2, 1, 2},	/* 1974 Verified */
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2},	/* 1975 Verified */
	{2, 2, 1, 2, 1, 2, 1, 5, 1, 2, 1, 2},	/* 1976 Verified -- Different from Korean */
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 1},	/* 1977 Verified */
	{2, 1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 1},	/* 1978 Verified -- Different from Korean */
	{2, 1, 1, 2, 1, 6, 1, 2, 2, 1, 2, 1},	/* 1979 Verified */
	{2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2},	/* 1980 Verified */
	{1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2, 2},   /* 1981 Verified */
	{2, 1, 2, 3, 2, 1, 1, 2, 1, 2, 2, 2},	/* 1982 Verified -- Different from Korean */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2},	/* 1983 Verified */
	{2, 1, 2, 2, 1, 1, 2, 1, 1, 5, 2, 2},	/* 1984 Verified */
	{1, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},	/* 1985 Verified */
	{1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 1, 1},	/* 1986 Verified */
	{2, 1, 2, 1, 2, 5, 2, 2, 1, 2, 1, 1},	/* 1987 Verified -- Different from Korean */
	{2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},	/* 1988 Verified -- Different from Korean */
	{2, 1, 1, 2, 1, 2, 1, 2, 1, 2, 2, 2},	/* 1989 Verified -- Different from Korean */
	{1, 2, 1, 1, 5, 1, 2, 1, 2, 2, 2, 2},	/* 1990 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2},   /* 1991 Verified */
	{1, 2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2},	/* 1992 Verified */
	{1, 2, 5, 2, 1, 2, 1, 1, 2, 1, 2, 1},	/* 1993 Verified */
	{2, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},	/* 1994 Verified */
	{1, 2, 2, 1, 2, 1, 2, 5, 1, 2, 1, 2},	/* 1995 Verified -- Different from Korean */
	{1, 2, 1, 2, 2, 1, 2, 1, 2, 2, 1, 1},	/* 1996 Verified -- Different from Korean */
	{2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},	/* 1997 Verified -- Different from Korean */
	{2, 1, 1, 2, 3, 2, 2, 1, 2, 2, 1, 2},	/* 1998 Verified -- Different from Korean */
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1},	/* 1999 Verified */
	{2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1},	/* 2000 Verified */
	{2, 2, 1, 5, 2, 1, 1, 2, 1, 2, 1, 2},   /* 2001 Verified -- Different from Korean */
	{2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1},	/* 2002 Verified */
	{2, 2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2},	/* 2003 Verified */
	{1, 5, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},	/* 2004 Verified */
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},	/* 2005 Verified -- Different from Korean */
	{2, 1, 2, 1, 2, 1, 5, 2, 2, 1, 2, 2},	/* 2006 Verified */
	{1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2},	/* 2007 Verified */
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2},	/* 2008 Verified */
	{2, 2, 1, 1, 5, 1, 2, 1, 2, 1, 2, 2},	/* 2009 Verified */
	{2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},	/* 2010 Verified */
	{2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1},   /* 2011 Verified */
	{2, 1, 2, 5, 2, 1, 2, 1, 2, 1, 2, 1},	/* 2012 Verified -- Different from Korean */
	{2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2},	/* 2013 Verified -- Different from Korean */
	{1, 2, 1, 2, 1, 2, 1, 2, 5, 2, 1, 2},	/* 2014 Verified */
	{1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2, 1},	/* 2015 Verified */
	{2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2},	/* 2016 Verified */
	{1, 2, 1, 2, 1, 4, 1, 2, 1, 2, 2, 2},	/* 2017 Verified -- Different from Korean */
	{1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2},	/* 2018 Verified */
	{2, 1, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2},	/* 2019 Verified -- Different from Korean */
	{1, 2, 2, 5, 2, 1, 1, 2, 1, 2, 1, 2},	/* 2020 Verified -- Different from Korean */
	{1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1},   /* 2021 Verified */
	{2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2},	/* 2022 Verified */
	{1, 5, 1, 2, 2, 1, 2, 2, 1, 2, 1, 2},	/* 2023 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1},	/* 2024 Verified */
	{2, 1, 2, 1, 1, 5, 2, 1, 2, 2, 2, 1},	/* 2025 Verified */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 2, 1},	/* 2026 Verified -- Different from Korean */
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1},	/* 2027 Verified -- Different from Korean */
	{2, 2, 2, 1, 5, 1, 2, 1, 1, 2, 2, 1},	/* 2028 Verified -- Different from Korean */
	{2, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 2},	/* 2029 Verified -- Different from Korean */
	{1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1},	/* 2030 Verified */
	{1, 2, 5, 2, 1, 2, 2, 1, 2, 1, 2, 1},   /* 2031 Verified -- Different from Korean */
	{2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2},	/* 2032 Verified */
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 5, 2},	/* 2033 Verified */
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2},	/* 2034 Verified -- Different from Korean */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2},	/* 2035 Verified */
	{2, 2, 1, 2, 1, 4, 1, 1, 2, 1, 2, 2},	/* 2036 Verified -- Different from Korean */
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2},	/* 2037 Verified */
	{2, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 1},	/* 2038 Verified */
	{2, 1, 2, 2, 5, 2, 1, 2, 1, 2, 1, 1},	/* 2039 Verified -- Different from Korean */
	{2, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2, 1},	/* 2040 Verified -- Different from Korean */
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2},   /* 2041 Verified -- Different from Korean */
	{1, 5, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2},	/* 2042 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2, 2}};	/* 2043 Verified */

+ (NSDate *)lunarCalcWithComponents:(NSDateComponents *)components gregorianToLunar:(BOOL)isGregorianToLunar leapMonth:(BOOL)isLeapMonth korean:(BOOL)isKorean {
	arrayOfMonths *lunarMonthTable = isKorean ? lunarMonthTable_Korean:lunarMonthTable_Chinese;
	NSDate *result;
    NSUInteger solYear, solMonth, solDay;
    NSUInteger lunYear, lunMonth, lunDay;
    NSUInteger lunMonthDay;
	BOOL lunLeapMonth;
    NSInteger lunIndex;
	
    NSUInteger solMonthDay[] = {31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	
	NSUInteger year = [components year];
	NSUInteger month = [components month];
	NSUInteger day = [components day];
	
	/* range check */
	if ((year < 1900) || (year > 2043))
	{
		//		alert('1900년부터 2043년까지만 지원합니다');
		return nil;
	}
	
	/* 속도 개선을 위해 기준 일자를 여러개로 한다 */
	if (year >= 2000)
	{
		/* 기준일자 양력 2000년 1월 1일 (음력 1999년 11월 25일) */
		solYear = 2000;
		solMonth = 1;
		solDay = 1;
		lunYear = 1999;
		lunMonth = 11;
		lunDay = 25;
		lunLeapMonth = NO;
		
		solMonthDay[1] = 29;	/* 2000 년 2월 28일 */
		lunMonthDay = 30;	/* 1999년 11월 */
	}
	else if (year >= 1970)
	{
		/* 기준일자 양력 1970년 1월 1일 (음력 1969년 11월 24일) */
		solYear = 1970;
		solMonth = 1;
		solDay = 1;
		lunYear = 1969;
		lunMonth = 11;
		lunDay = 24;
		lunLeapMonth = NO;
		
		solMonthDay[1] = 28;	/* 1970 년 2월 28일 */
		lunMonthDay = 30;	/* 1969년 11월 */
	}
	else if (year >= 1940)
	{
		/* 기준일자 양력 1940년 1월 1일 (음력 1939년 11월 22일) */
		solYear = 1940;
		solMonth = 1;
		solDay = 1;
		lunYear = 1939;
		lunMonth = 11;
		lunDay = 22;
		lunLeapMonth = NO;
		
		solMonthDay[1] = 29;	/* 1940 년 2월 28일 */
		lunMonthDay = 29;	/* 1939년 11월 */
	}
	else
	{
		/* 기준일자 양력 1900년 1월 1일 (음력 1899년 12월 1일) */
		solYear = 1900;
		solMonth = 1;
		solDay = 1;
		lunYear = 1899;
		lunMonth = 12;
		lunDay = 1;
		lunLeapMonth = NO;
		
		solMonthDay[1] = 28;	/* 1900 년 2월 28일 */
		lunMonthDay = 30;	/* 1899년 12월 */
	}
	
	lunIndex = lunYear - 1899;
	
	while (true)
	{
		//		document.write(solYear + "-" + solMonth + "-" + solDay + "<->");
		//		document.write(lunYear + "-" + lunMonth + "-" + lunDay + " " + lunLeapMonth + " " + lunMonthDay + "<br>");
		
		if ((isGregorianToLunar) &&
			(year == solYear) &&
			(month == solMonth) &&
			(day == solDay))
		{
			//			return new myDate(lunYear, lunMonth, lunDay, lunLeapMonth);
			NSDateComponents *comps = [[NSDateComponents alloc] init];
			[comps setDay:lunDay];
			[comps setMonth:lunMonth];
			[comps setYear:lunYear];
			
			NSCalendar *gregorian = [[NSCalendar alloc]
									 initWithCalendarIdentifier:NSGregorianCalendar];
			result = [gregorian dateFromComponents:comps];
			return result;
		}	
		else if (!isGregorianToLunar &&
				 (year == lunYear) &&
				 (month == lunMonth) &&
				 (day == lunDay) && 
				 (isLeapMonth == lunLeapMonth))
		{
			NSDateComponents *comps = [[NSDateComponents alloc] init];
			[comps setDay:solDay];
			[comps setMonth:solMonth];
			[comps setYear:solYear];
			
			NSCalendar *gregorian = [[NSCalendar alloc]
									 initWithCalendarIdentifier:NSGregorianCalendar];
			result = [gregorian dateFromComponents:comps];
			return result;
		}
		
		/* add a day of solar calendar */
		if ((solMonth == 12) && (solDay == 31))
		{
			solYear++;
			solMonth = 1;
			solDay = 1;
			
			/* set monthDay of Feb */
			if (solYear % 400 == 0)
				solMonthDay[1] = 29;
			else if (solYear % 100 == 0)
				solMonthDay[1] = 28;
			else if (solYear % 4 == 0)
				solMonthDay[1] = 29;
			else
				solMonthDay[1] = 28;
			
		}
		else if (solMonthDay[solMonth - 1] == solDay)
		{
			solMonth++;
			solDay = 1;	
		}
		else
			solDay++;
		
		/* add a day of lunar calendar */
		if ((lunMonth == 12) &&
			(((lunarMonthTable[lunIndex][lunMonth - 1] == 1) && (lunDay == 29)) ||
			 ((lunarMonthTable[lunIndex][lunMonth - 1] == 2) && (lunDay == 30))))
		{
			lunYear++;
			lunMonth = 1;
			lunDay = 1;
			
			if (lunYear > 2043) {
				//				alert("입력하신 달은 없습니다.");
				break;
			}
			
			lunIndex = lunYear - 1899;
			
			if (lunarMonthTable[lunIndex][lunMonth - 1] == 1)
				lunMonthDay = 29;
			else if (lunarMonthTable[lunIndex][lunMonth - 1] == 2)
				lunMonthDay = 30;
		}
		else if (lunDay == lunMonthDay)
		{
			if ((lunarMonthTable[lunIndex][lunMonth - 1] >= 3)
				&& (lunLeapMonth == NO))
			{
				lunDay = 1;
				lunLeapMonth = YES;
			}
			else
			{
				lunMonth++;
				lunDay = 1;
				lunLeapMonth = NO;
			}
			
			if (lunarMonthTable[lunIndex][lunMonth - 1] == 1)
				lunMonthDay = 29;
			else if (lunarMonthTable[lunIndex][lunMonth - 1] == 2)
				lunMonthDay = 30;
			else if (lunarMonthTable[lunIndex][lunMonth - 1] == 3)
				lunMonthDay = 29;
			else if ((lunarMonthTable[lunIndex][lunMonth - 1] == 4) &&
					 (lunLeapMonth == NO))
				lunMonthDay = 29;
			else if ((lunarMonthTable[lunIndex][lunMonth - 1] == 4) &&
					 (lunLeapMonth == YES))
				lunMonthDay = 30;
			else if ((lunarMonthTable[lunIndex][lunMonth - 1] == 5) &&
					 (lunLeapMonth == NO))
				lunMonthDay = 30;
			else if ((lunarMonthTable[lunIndex][lunMonth - 1] == 5) &&
					 (lunLeapMonth == YES))
				lunMonthDay = 29;
			else if (lunarMonthTable[lunIndex][lunMonth - 1] == 6)
				lunMonthDay = 30;
		}
		else
			lunDay++;
	}
	return nil;
}

+ (NSDate *)koreaLunarDateWithGregorianDate:(NSDate *)date
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	NSDateComponents *lunarComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
	NSDate *newDate = [self lunarCalcWithComponents:lunarComponents gregorianToLunar:YES leapMonth:NO korean:YES];
	
	return newDate;
}

+ (NSDate *)lunarDateWithGregorianDate:(NSDate *)date
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *lunarComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
	// TODO: Lunar calendar usage for China or Korean
//	BOOL korean = [[[NSUserDefaults standardUserDefaults] objectForKey:APPBOX_KEY_GLOBAL_LUNAR_CALENDAR] isEqualToString:APPBOX_VALUE_LUNAR_CALENDAR_KOREA];
	NSDate *newDate = [self lunarCalcWithComponents:lunarComponents gregorianToLunar:YES leapMonth:NO korean:NO];
	return newDate;
}

+ (NSDate *)justDateWithDate:(NSDate *)date {
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
	NSDate *dateReturn = [gregorian dateFromComponents:components];
	
	return dateReturn;
}

+ (NSString *)stringFromDate:(NSDate *) date {
	NSDateFormatter *commonDateFormatter = [[NSDateFormatter alloc] init];
	setDateStyleMedium(commonDateFormatter);
	NSString *string = [commonDateFormatter stringFromDate:date];
	return string;
}

+ (NSDate *)dateFrom:(NSDate *)from withOffset:(NSInteger)offset {
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *sourceComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:from];
    sourceComponents.day += offset;
    sourceComponents.hour = 12;
    NSDate *date = [gregorian dateFromComponents:sourceComponents];
    sourceComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    date = [gregorian dateFromComponents:sourceComponents];
    
	
	return date;
}

@end

void setDateStyleMedium(NSDateFormatter *df) {
	if (LANGUAGE_KOREAN) {
		[df setDateFormat:@"yyyy.MM.dd"];
	} else {
		[df setDateStyle:NSDateFormatterMediumStyle];
	}
}
