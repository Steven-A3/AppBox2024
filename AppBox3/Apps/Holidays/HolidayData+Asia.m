//
//  HolidayAsia.m
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import "HolidayData+Asia.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

@implementation HolidayData (Asia)

NSDate *qingmingForYear(NSInteger year, NSCalendar *calendar) {
    NSInteger day;
    switch (year) {
		case 2004:
			day = 3;
			break;
        case 1992:
        case 1996:
        case 1998:
        case 2000:
        case 2008:
        case 2009:
        case 2012:
        case 2013:
		case 2016:
		case 2020:
            day = 4;
            break;
		case 1990:
		case 1991:
		case 1993:
		case 1994:
		case 1995:
		case 1997:
		case 1999:
		case 2001:
		case 2002:
        case 2003:
		case 2005:
		case 2006:
        case 2007:
		case 2010:
        case 2011:
		case 2014:
		case 2015:
		case 2017:
		case 2018:
		case 2019:
            day = 5;
            break;
		default:
			return nil;
    }
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.year = year;
	components.month = 4;
	components.day = day;
	NSDate *date = [calendar dateFromComponents:components];

	return date;
}

// China http://en.wikipedia.org/wiki/Public_holidays_in_China#cite_note-days-4
- (NSMutableArray *)cn_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
    //todo: duration 2000-2007 1day, 2008~ 3days
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@3}];
	
      //todo: duration 2000-2007 3day, 2008~ 7days
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"Chinese New Year", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@7}];
	}
	holidayName = NSLocalizedStringFromTable(@"Chinese New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateFrom:date withOffset:-1];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Valentine's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Lantern Festival
	holidayName = NSLocalizedStringFromTable(@"Lantern Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:15 month:1 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// International Women's Day
	holidayName = NSLocalizedStringFromTable(@"International Women's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Tree-Planting Day
	holidayName = NSLocalizedStringFromTable(@"Arbor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"April Fool's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

   //todo: duration 2000-2007 N/A, 2008~ 3days
	date = qingmingForYear(year, gregorian);
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Qingming Festival", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

    //todo: duration 3days
	// International Labor Day
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    //todo: duration 2000-2007 N/A, 2008~ 3days
	// Duan Wu (Dragon Boat) Festival
	holidayName = NSLocalizedStringFromTable(@"Dragon Boat Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:5 month:5 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Youth Day
	holidayName = NSLocalizedStringFromTable(@"Youth Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:4 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:5 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Children's Day
	holidayName = NSLocalizedStringFromTable(@"International Children's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Father's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:3 month:6 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	if (year >= 2000 && year <= 2020) {
		NSUInteger solstice;
		switch (year) {
			case 2008:
			case 2012:
			case 2016:
			case 2020:
				solstice = 20;
				break;
			default:
				solstice = 21;
		}
		holidayName = NSLocalizedStringFromTable(@"Summer Solstice", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:solstice month:6 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// The CPC's Birthday
	holidayName = NSLocalizedStringFromTable(@"The CPC Founding Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Hong Kong Special Administrative Region Establishment Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Double Seven Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:7 month:7 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Spirit Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:15 month:7 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Army's Day
	holidayName = NSLocalizedStringFromTable(@"Army Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
    //todo: duration 2000-2007 N/A, 2008~ 3days
	// Mid-Autumn Festival
	holidayName = NSLocalizedStringFromTable(@"Mid-Autumn Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:15 month:8 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Teacher's Day
	holidayName = NSLocalizedStringFromTable(@"Teacher's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:10 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
    //todo: duration 7days
	// National Day
	holidayName = NSLocalizedStringFromTable(@"National Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Double Ninth Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:9 month:9 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	// Information source http://www.neoprogrammics.com/sun/Northern_Winter_Dates_and_Times.html
	date = [HolidayData getWinterSolsticeForYear:year calendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Winter Solstice", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName : holidayName, kHolidayIsPublic : @NO, kHolidayDate : date, kHolidayDuration : @1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Macau Special Administrative Region Establishment Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Indonesia
- (NSMutableArray *)id_HolidaysInYear
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

	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"Chinese New Year", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Day of Silence", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:16 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

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

	date = [HolidayData getVesakDay:year forCountryCode:@"id" withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Buddha's Birthday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Ascension Day", kHolidaysResourceName, nil);
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	if (year == 2009) {
		holidayName = NSLocalizedStringFromTable(@"Public Holiday(Legislative Elections)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:9 month:4 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

		holidayName = NSLocalizedStringFromTable(@"Public Holiday(Presidential Election)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:9 month:7 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	date = [HolidayData getIsraAndMiraj:year withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Isra and Mi'raj", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:17 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];

		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

		holidayName = NSLocalizedStringFromTable(@"Shared Holiday by Government Decree", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2006) {
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = [NSLocalizedStringFromTable(@"Islamic New Year", kHolidaysResourceName, nil) stringByAppendingFormat:@"(%lu)", (unsigned long) (year - ((year > 2007) ? 578 : 579))];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2008) {
		holidayName = NSLocalizedStringFromTable(@"Islamic New Year(1429)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

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

// Singapore
- (NSMutableArray *)sg_HolidaysInYear
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
	
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"Chinese New Year", kHolidaysResourceName, nil);
	if (year == 2010) {
		date = [HolidayData dateWithDay:15 month:2 year:2010 withCalendar:gregorian option:0];
	} else {
		date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	}
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// International Labor Day
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	date = [HolidayData getVesakDay:year forCountryCode:@"sg" withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Buddha's Birthday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"National Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:9 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	NSDateComponents *dc = [gregorian components:NSCalendarUnitWeekday fromDate:date];
	if ([dc weekday] == Sunday) {
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		holidayName = NSLocalizedStringFromTable(@"National Day Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	date = [HolidayData getDeepavaliForYear:year];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Diwali", kHolidaysResourceName, nil);
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
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Macao http://en.wikipedia.org/wiki/Public_holidays_in_Macau
- (NSMutableArray *)mo_HolidaysInYear
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
	
    //todo: Chinese New Year's Eve
    
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"Chinese New Year", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
        //todo: 3days
		// Second day
		holidayName = NSLocalizedStringFromTable(@"Chinese New Year(Second day)", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

		// Third day
		holidayName = NSLocalizedStringFromTable(@"Chinese New Year(Third day)", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		

	}

	// TODO: Verify Ching Ming Every Year 매년 확인해야 합니다.
	holidayName = NSLocalizedStringFromTable(@"Ching Ming Festival", kHolidaysResourceName, nil);
	int equinox = 20;
	if ((year == 2003) || (year == 2007)) equinox = 21;
		date = [HolidayData dateWithDay:equinox month:3 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:15];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

	}
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
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
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", kHolidaysResourceName, nil);
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// International Labor Day
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Buddha's Birthday
	holidayName = NSLocalizedStringFromTable(@"Buddha's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:8 month:4 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Duan Wu (Dragon Boat) Festival
	holidayName = NSLocalizedStringFromTable(@"Dragon Boat Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:5 month:5 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"July Bank Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"National Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"National Day Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
   // Mid-Autumn Festival
	holidayName = NSLocalizedStringFromTable(@"Mid-Autumn Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:15 month:8 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Chong Chao Bank Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
    
    //todo: "Day following the Mid-Autumn Festival" - 16th day of 8th month (Lunar)
	
	holidayName = NSLocalizedStringFromTable(@"Double Ninth Festival(Chung Yeung Festival)", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:9 month:9 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"All Souls Day(Dia de Finados)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Macau Special Administrative Region Establishment Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Macau SARE Bank Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:21 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	date = [HolidayData getWinterSolsticeForYear:year calendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Winter Solstice", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName : holidayName, kHolidayIsPublic : @NO, kHolidayDate : date, kHolidayDuration : @1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Chiristmas Bank Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
    
    holidayName = NSLocalizedStringFromTable(@"New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Hong Kong
- (NSMutableArray *)hk_HolidaysInYear
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
	
    //todo: 3days
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"Chinese New Year", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	// TODO: Ching Ming Verify Yearly, 매년 확인해야 합니다.
	holidayName = NSLocalizedStringFromTable(@"Ching Ming Festival", kHolidaysResourceName, nil);
	int equinox = 20;
	if ((year == 2003) || (year == 2007)) equinox = 21;
		date = [HolidayData dateWithDay:equinox month:3 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:15];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

	}
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
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
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", kHolidaysResourceName, nil);
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// International Labor Day
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Buddha's Birthday
	holidayName = NSLocalizedStringFromTable(@"Buddha's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:8 month:4 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Duan Wu (Dragon Boat) Festival
	holidayName = NSLocalizedStringFromTable(@"Dragon Boat Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:5 month:5 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Hong Kong Special Administrative Region Establishment Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Mid-Autumn Festival
	holidayName = NSLocalizedStringFromTable(@"Mid-Autumn Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:16 month:8 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// National Day
	holidayName = NSLocalizedStringFromTable(@"National Day of People's Republic of China", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Double Ninth Festival(Chung Yeung Festival)", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:9 month:9 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Boxing Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Korea
- (NSMutableArray *)kr_HolidaysInYear
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
	
    //todo: 3days
	holidayName = NSLocalizedStringFromTable(@"Korean New Year's Day(Seollal)", kHolidaysResourceName, nil);
	if (LANGUAGE_KOREAN) {
		NSString *duration;
		switch (year) {
			case 2010:
				duration = @"(2.13~15)";
				break;
			case 2011:
				duration = @"(2.2~4)";
				break;
			case 2015:
				duration = @"(2.18~20)";
				break;
			default:
				duration = nil;
		}
		if (duration) holidayName = [NSString stringWithFormat:@"%@%@", holidayName, duration];
	}
	date = [HolidayData koreaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Independence Movement Day
	holidayName = NSLocalizedStringFromTable(@"Independence Movement Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Children's Day
	holidayName = NSLocalizedStringFromTable(@"Children's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Buddha's Birthday
	holidayName = NSLocalizedStringFromTable(@"Buddha's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData koreaLunarDateWithSolarDay:8 month:4 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Memorial Day
	holidayName = NSLocalizedStringFromTable(@"Memorial Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Liberation Day
	holidayName = NSLocalizedStringFromTable(@"Liberation Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Foundation Day
	holidayName = NSLocalizedStringFromTable(@"National Foundation Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

    //todo: 3days

	holidayName = NSLocalizedStringFromTable(@"Chuseok", kHolidaysResourceName, nil);
	if (LANGUAGE_KOREAN) {
		NSString *duration;
		switch (year) {
			case 2010:
				duration = @"(9.21~23)";
				break;
			case 2011:
				duration = @"(9.12~13)";
				break;
			case 2015:
				duration = @"(9.26~28)";
				break;
			default:
				duration = nil;
		}
		if (duration) {
			holidayName = [NSString stringWithFormat:@"%@%@", holidayName, duration];
		}
	}
	date = [HolidayData koreaLunarDateWithSolarDay:15 month:8 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Hangul Day(HangeulNal)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:9 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Japan
- (NSMutableArray *)jp_HolidaysInYear
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
	
	holidayName = NSLocalizedStringFromTable(@"Coming of Age Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:1 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Foundation Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:11 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Vernal Equinox Day", kHolidaysResourceName, nil);
	// Adjust for known equinox
	int equinox = 20;
	switch (year) {
		case 2003:
		case 2007:
			equinox = 21;
			break;
	}
	date = [HolidayData dateWithDay:equinox month:3 year:year withCalendar:gregorian option:1];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Showa Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:29 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Memorial Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Greenery Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:4 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Children's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Marine Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:7 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Forest Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:11 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Respect for the Aged Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:9 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    // todo: 2020년 이후 추가 필요
	// Information source : http://www.usno.navy.mil/USNO/astronomical-applications/data-services/earth-seasons
	holidayName = NSLocalizedStringFromTable(@"Autumnal Equinox Day", kHolidaysResourceName, nil);
	// Adjust for known equinox
	NSUInteger autumnEquinox;
	switch (year) {
		case 2002:
		case 2003:
		case 2006:
		case 2007:
		case 2010:
		case 2011:
		case 2014:
		case 2015:
		case 2018:
		case 2019:
			autumnEquinox = 23;
			break;
		default:
			autumnEquinox = 22;
			break;
	}
	date = [HolidayData dateWithDay:autumnEquinox month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Health and Sports Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:10 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Culture Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labor Thanksgiving Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:23 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"The Emperor's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:23 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}	


// Philippines
- (NSMutableArray *)ph_HolidaysInYear
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
	
	holidayName = NSLocalizedStringFromTable(@"Chinese New Year", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"People Power Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
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
	
	holidayName = NSLocalizedStringFromTable(@"Day of Valor", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:9 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Ninoy Aquino Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:21 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"National Heroes' Day", kHolidaysResourceName, nil);
	date = [HolidayData getLastWeekday:Monday OfMonth:8 forYear:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Bonifacio Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:30 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Rizal Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:30 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}	

// Taiwan
- (NSMutableArray *)tw_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"Founding of the Republic of China", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    //todo: 3days
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"Chinese New Year", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"Chinese New Year's Eve", kHolidaysResourceName, nil);
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

	}
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Peace Memorial Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:28 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

    holidayName = NSLocalizedStringFromTable(@"Children's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:4 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
	date = qingmingForYear(year, gregorian);
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Qingming Festival", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"National Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:10 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Duan Wu (Dragon Boat) Festival
	holidayName = NSLocalizedStringFromTable(@"Dragon Boat Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:5 month:5 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	// Mid-Autumn Festival
	holidayName = NSLocalizedStringFromTable(@"Mid-Autumn Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:15 month:8 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	return holidays;
}

// New Zealand
- (NSMutableArray *)nz_HolidaysInYear
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
	
	holidayName = NSLocalizedStringFromTable(@"Day after New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Southland Anniversary Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:1 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	if (year >= 2012) {
		holidayName = NSLocalizedStringFromTable(@"Anniversary Day Auckland / Northland", kHolidaysResourceName, nil);
		date = [HolidayData dateWithWeekday:Monday ordinal:5 month:1 year:year withCalendar:gregorian];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Waitangi Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Taranaki (New Plymouth) Anniversary Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:3 year:year withCalendar:gregorian];
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
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:4 month:10 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Anzac Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Queen's Official Birthday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:6 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Canterbury (South) Anniversary Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:4 month:9 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Hawkes' Bay Anniversary Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Friday ordinal:3 month:10 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Marlborough Anniversary Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:5 month:10 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christchurch Show Day (Canterbury)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:11 year:year withCalendar:gregorian];
    {
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.day = 11;
        date = [gregorian dateByAddingComponents:components toDate:date options:0];
    }
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
    
	holidayName = NSLocalizedStringFromTable(@"Westland Anniversary Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:12 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Christmas Day is celebrated on December 25 with avoid weekend.
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	// Boxing Day is celebrated on December 26 with avoid weekend.
	holidayName = NSLocalizedStringFromTable(@"Boxing Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	if (year == 2011) {
		holidayName = NSLocalizedStringFromTable(@"Public Holiday", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	return holidays;
}

// Australia
- (NSMutableArray *)au_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date, *additionalDate;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	additionalDate = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:1];
	if (![additionalDate isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"New Year's Day Public Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:additionalDate, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Australia Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	additionalDate = [HolidayData dateWithDay:26 month:1 year:year withCalendar:gregorian option:1];
	if (![additionalDate isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"Australia Day Public Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:additionalDate, kHolidayDuration:@1}];
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
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", kHolidaysResourceName, nil);
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day(WA)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:3 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day(Tas, Vic)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:3 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day(ACT, NSW, SA)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:10 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day(Qld, NT)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:5 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:5 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Anzac Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	additionalDate = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:1];
	if (![additionalDate isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"Anzac Day Public Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:additionalDate, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Queen's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:6 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Father's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Sunday ordinal:1 month:9 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Boxing Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Christmas Day Public Holiday", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:1];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
		
		holidayName = NSLocalizedStringFromTable(@"Boxing Day Public Holiday", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:28 month:12 year:year withCalendar:gregorian option:1];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2011) {
		holidayName = NSLocalizedStringFromTable(@"Christmas Day Public Holiday", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:1];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
		
		holidayName = NSLocalizedStringFromTable(@"Boxing Day Public Holiday", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:1];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	return holidays;
}

// Malaysia
- (NSMutableArray *)my_HolidaysInYear
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
	
	holidayName = NSLocalizedStringFromTable(@"Federal Territory Day(KUL LBN PJY)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Chinese New Year", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Chinese New Year, Day 2", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		

	}

	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	date = [HolidayData getVesakDay:year forCountryCode:@"my" withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Buddha's Birthday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"King's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
    holidayName = NSLocalizedStringFromTable(@"Malaysia Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:16 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	date = [HolidayData getDeepavaliForYear:year];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Deepavali", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = [@"Islamic New Year" stringByAppendingFormat:@"(%lu)", (unsigned long) (year - ( (year > 2007) ? 578 : 579 ) ) ];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2008) {
		holidayName = NSLocalizedStringFromTable(@"Islamic New Year(1429)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// India http://en.wikipedia.org/wiki/Public_holidays_in_India http://holidayyear.com/holidays/India
- (NSMutableArray *)in_HolidaysInYear
{
	NSUInteger year = self.year;

	if ((year < 2006) || (year > 2016)) {
		return nil;
	}
	
	NSString *filepath = [[NSBundle mainBundle] pathForResource:@"indian" ofType:@"plist"];
	NSDictionary *indianBook = [NSDictionary dictionaryWithContentsOfFile:filepath];
	if (indianBook) {
		NSMutableArray *book = [[NSMutableArray alloc] initWithArray:[indianBook objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)year]]];
		NSInteger index, count = [book count];
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
		[offsetDC setHour:9 - ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600)];

		NSMutableArray *holidays = [NSMutableArray new];

		for (index = 0; index < count; index++) {
			NSMutableArray *item = [NSMutableArray arrayWithArray:[book objectAtIndex:index]];
			NSDate *newDate = [gregorian dateByAddingComponents:offsetDC toDate:[item objectAtIndex:1] options:0];

			[holidays addObject:@{kHolidayName:[item objectAtIndex:0], kHolidayIsPublic:@NO, kHolidayDate:newDate, kHolidayDuration:@1}];
			}

		return holidays;
	}
	return nil;
}

// Bangladesh
- (NSMutableArray *)bd_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"Language Martyrs' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:21 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		NSDateComponents *dc = [[NSDateComponents alloc] init];
		[dc setDay:1];

		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:[gregorian dateByAddingComponents:dc toDate:birthday options:0], kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Father of the Nation's birth anniversary", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:17 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Bangla New Year's Day", kHolidaysResourceName, nil);
	//todo: occurring on 14 April or 15 April, is the first day of the Bengali calendar,
	date = [HolidayData dateWithDay:15 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	date = [HolidayData getVesakDay:year forCountryCode:@"bd" withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Buddha's Birthday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"July Bank Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Isra and Mi'raj", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:28 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"National day of mourning", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Krishna Janmashtami", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    //todo: 날짜수정
	holidayName = [NSString stringWithFormat:@"%@(%@)",
					NSLocalizedStringFromTable(@"Shab-e-Qadar", kHolidaysResourceName, nil),
					NSLocalizedStringFromTable(@"Night of Destiny", kHolidaysResourceName, nil)
	];
	date = [HolidayData dateWithDay:7 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	//todo: "Friday of farewell" Jumu'ah-tul-Wida - Last Friday in Ramadan
    
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
	
    //Durga Puja(Bijoya Dashami), Dussehra
   // todo: 변하는 날짜 http://en.wikipedia.org/wiki/Vijayadashami
	holidayName = NSLocalizedStringFromTable(@"Vijaya Dasami", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:17 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"National Revolution Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:7 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Victory Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:16 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	if (year == 2009) {
		holidayName = NSLocalizedStringFromTable(@"Ashura", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:8 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Ashura", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:17 month:12 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Pakistan
- (NSMutableArray *)pk_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];
	
	NSString *holidayName;
	NSDate *date;
	
	holidayName = NSLocalizedStringFromTable(@"New Year Bank Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Kashmir Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Pakistan Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:23 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"July Bank Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Start of Ramadan Bank Holiday", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:12 month:8 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Birthday of Muhammad Iqbal", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:9 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha Holiday", kHolidaysResourceName, nil);
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
    //todo: 다른 해 날짜 표시. 1day만 public
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Ashura", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:16 month:12 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

		holidayName = NSLocalizedStringFromTable(@"Ashura", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:17 month:12 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = [NSString stringWithFormat:@"%@/%@",
					NSLocalizedStringFromTable(@"Birthday of Quaid-e-Azam", kHolidaysResourceName, nil),
					NSLocalizedStringFromTable(@"Christmas", kHolidaysResourceName, nil)
	];
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Second Day of Christmas", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Anniversary of Benazir Bhutto's Death(Sindh)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Thailand
- (NSMutableArray *)th_HolidaysInYear
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
	
	holidayName = NSLocalizedStringFromTable(@"Makha Bucha Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:28 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	if ((date = [HolidayData adjustDate:date calendar:gregorian option:1])) {
		holidayName = NSLocalizedStringFromTable(@"Makha Bucha Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
  
	holidayName = NSLocalizedStringFromTable(@"Chakri Memorial Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
      //todo: 3days holidays
	holidayName = NSLocalizedStringFromTable(@"Songkran(Thai New Year)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:13 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Songkran Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Songkran Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Songkran Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:16 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	if ((date = [HolidayData adjustDate:date calendar:gregorian option:1])) {
		holidayName = [NSString stringWithFormat:@"%@(%@)",
						NSLocalizedStringFromTable(@"National Labor Day", kHolidaysResourceName, nil),
						NSLocalizedStringFromTable(@"day in lieu", kHolidaysResourceName, nil)];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Coronation Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    //todo: 4th day of the 6th lunar month's waning moon http://en.wikipedia.org/wiki/Royal_Ploughing_Ceremony
	holidayName = NSLocalizedStringFromTable(@"Royal Ploughing Ceremony", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:13 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Emergency Public Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = [holidayName stringByAppendingString:NSLocalizedStringFromTable(@"(Bangkok and neighboring provinces)", kHolidaysResourceName, nil)];
	date = [HolidayData dateWithDay:17 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	date = [HolidayData dateWithDay:18 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	date = [HolidayData dateWithDay:19 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	date = [HolidayData dateWithDay:20 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	date = [HolidayData dateWithDay:21 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Nationwide Bank Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	date = [HolidayData dateWithDay:21 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	date = [HolidayData getVesakDay:year forCountryCode:@"th" withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Buddha's Birthday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Mid Year Bank Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"Asalha Puja", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    //todo: "Beginning of Vassa" - First waning moon, 8th Thai lunar month
    
	holidayName = NSLocalizedStringFromTable(@"Public Sector Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:27 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"HM the Queen's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"HM the Queen's Birthday Holiday", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:13 month:8 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Chulalongkorn Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:23 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	if ((date = [HolidayData adjustDate:date calendar:gregorian option:1])) {
		holidayName = NSLocalizedStringFromTable(@"Chulalongkorn Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"HM the King's Birthday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	if ((date = [HolidayData adjustDate:date calendar:gregorian option:1])) {
		holidayName = NSLocalizedStringFromTable(@"HM the King's Birthday Holiday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:10 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
    //todo: "Eid ul-Fitr"
    
    //todo: "Eid al-Adha"

	
	return holidays;
}

@end
