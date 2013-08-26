//
//  HolidayAsia.m
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import "HolidayAsia.h"
#import "HolidayData.h"

NSDate *qingmingForYear(NSInteger year, NSCalendar *calendar) {
    NSInteger day;
    switch (year) {
        case 2001:
        case 2002:
        case 2004:
        case 2005:
        case 2006:
        case 2008:
        case 2009:
        case 2010:
        case 2012:
        case 2013:
        case 2014:
            day = 4;
            break;
        case 2003:
        case 2007:
        case 2011:
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

NSMutableArray *newChineseHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"The Chinese New Year", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	holidayName = NSLocalizedStringFromTable(@"The Chinese New Year's Eve", @"holidays", @"Messages");
	date = [HolidayData dateFrom:date withOffset:-1];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Valentine's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Lantern Festival
	holidayName = NSLocalizedStringFromTable(@"Lantern Festival", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:15 month:1 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// International Women's Day
	holidayName = NSLocalizedStringFromTable(@"International Women's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Tree-Planting Day
	holidayName = NSLocalizedStringFromTable(@"Arbor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:12 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"April Fool's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	date = qingmingForYear(year, gregorian);
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Qingming Festival", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	// International Labor Day
	holidayName = NSLocalizedStringFromTable(@"International Worker's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Duan Wu (Dragon Boat) Festival
	holidayName = NSLocalizedStringFromTable(@"Dragon Boat Festival", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:5 month:5 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Youth Day
	holidayName = NSLocalizedStringFromTable(@"Youth Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:4 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:5 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Children's Day
	holidayName = NSLocalizedStringFromTable(@"International Children's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Father's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:3 month:6 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if (year >= 2000 && year <= 2020) {
		NSInteger solstice = 21;
		switch (year) {
			case 2008:
			case 2012:
			case 2016:
			case 2020:
				solstice = 20;
				break;
		}
		holidayName = NSLocalizedStringFromTable(@"Summer Solstice", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:solstice month:6 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// The CPC's Birthday
	holidayName = NSLocalizedStringFromTable(@"The CPC Founding Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Hong Kong Special Administrative Region Establishment Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Double Seven Festival", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:7 month:7 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Spirit Festival", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:15 month:7 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Army's Day
	holidayName = NSLocalizedStringFromTable(@"Army Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Mid-Autumn Festival
	holidayName = NSLocalizedStringFromTable(@"Mid-Autumn Festival", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:15 month:8 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Teacher's Day
	holidayName = NSLocalizedStringFromTable(@"Teacher's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:10 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// National Day
	holidayName = NSLocalizedStringFromTable(@"National Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Double Ninth Festival", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:9 month:9 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Winter Solstice", @"holidays", @"Messages");
	{
		int month, day;
		switch (year) {
			case 2007:
			case 2011:
				month = 12;
				day = 22;
				break;
			case 2008:
			case 2009:
			case 2010:
			case 2012:
			case 2013:
			case 2014:
				month = 12;
				day = 21;
				break;
			default:
				day = -1;
				break;
		}
		if (day > 0) {
			date = [HolidayData dateWithDay:day month:month year:year withCalendar:gregorian option:0];
			holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
			[holidays addObject:holidayItem];
		}
	}

	holidayName = NSLocalizedStringFromTable(@"Macau Special Administrative Region Establishment Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:20 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newIndonesiaHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date, *originalDate;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Shared Holiday by Government Decree", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"Chinese New Year (Imlek)", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"The Prophet's Birthday (Maulidur Rasul)", @"holidays", @"Messages");
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Hari Raya Nyepi Tahun Baru (Hindu New Year)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:16 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday (Hari Raya Paskah)", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Day", @"holidays", @"Messages");
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	date = [HolidayData getVesakDay:year forCountryCode:@"id" withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Waisak (Buddha Day)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2009) {
		holidayName = NSLocalizedStringFromTable(@"Public Holiday(Legislative Elections)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:9 month:4 year:year withCalendar:gregorian option:3];
		originalDate = [HolidayData dateWithDay:9 month:4 year:year withCalendar:gregorian option:0];
		if (![date isEqualToDate:originalDate]) {
			holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
		} else {
			holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		}
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Public Holiday(Presidential Election)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:9 month:7 year:year withCalendar:gregorian option:3];
		originalDate = [HolidayData dateWithDay:9 month:7 year:year withCalendar:gregorian option:0];
		if (![date isEqualToDate:originalDate]) {
			holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
		} else {
			holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		}
		[holidays addObject:holidayItem];
	}
	
	date = [HolidayData getIsraAndMiraj:year withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Prophet's Ascension(Isra' Miraj Nabi)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:17 month:8 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:17 month:8 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Hari Raya Idul Fitri (End of Ramadan)", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Idul Fitri Holiday", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Shared Holiday by Government Decree", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	
	holidayName = NSLocalizedStringFromTable(@"Idul Adha (Feast of Sacrifice)", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	if (year == 2006) {
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = [NSLocalizedStringFromTable(@"Islamic New Year", @"holidays", @"Messages") stringByAppendingFormat:@"(%d)", year - ((year > 2007)?578:579)];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	if (year == 2008) {
		holidayName = NSLocalizedStringFromTable(@"Islamic New Year(1429)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Shared Holiday by Government Decree", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve Bank Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newSingaporeHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"The Chinese New Year", @"holidays", @"Messages");
	if (year == 2010) {
		date = [HolidayData dateWithDay:15 month:2 year:2010 withCalendar:gregorian option:0];
	} else {
		date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	}
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// International Labor Day
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	date = [HolidayData getVesakDay:year forCountryCode:@"sg" withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Vesak Day", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"National Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:9 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
	if ([dc weekday] == Sunday) {
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[offsetDC release];
		holidayName = NSLocalizedStringFromTable(@"National Day Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Hari Raya Puasa (End of Ramadan)", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	date = [HolidayData getDeepavaliForYear:year];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Deepavali", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"Hari Raya Haji (Feast of Sacrifice)", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Hari Raya Haji (Feast of Sacrifice)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newMacauHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day(Fraternidade Universal)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"Lunar New Year(Novo Ano Lunar)", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Lunar New Year Holiday", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Cheng Ming Festival(Tomb Sweeping Day)", @"holidays", @"Messages");
	int equinox = 20;
	if ((year == 2003) || (year == 2007)) equinox = 21;
		date = [HolidayData dateWithDay:equinox month:3 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:15];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[offsetDC release];
	}
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Holy Saturday", @"holidays", @"Messages");
	date = [HolidayData getHolySaturday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Day", @"holidays", @"Messages");
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// International Labor Day
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Buddha's Birthday
	holidayName = NSLocalizedStringFromTable(@"The Buddha's Birthday (Dia do Buda)", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:8 month:4 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Duan Wu (Dragon Boat) Festival
	holidayName = NSLocalizedStringFromTable(@"Tung Ng (Dragon Boat Festival)", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:5 month:5 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"July Bank Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"PRC National Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"PRC National Day Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:2 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Mid-Autumn Festival
	holidayName = NSLocalizedStringFromTable(@"Chong Chao (Mid-Autumn Festival)", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:15 month:8 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Chong Chao Bank Holiday", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Chong Yeong (Ancestors' Day)", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:9 month:9 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"All Souls Day(Dia de Finados)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:12 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Macau SARE Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:20 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Macau SARE Bank Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:21 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Dongzhi (Winter Solstice)", @"holidays", @"Messages");
	{
		int month, day;
		switch (year) {
			case 2007:
			case 2011:
				month = 12;
				day = 22;
				break;
			case 2008:
			case 2009:
			case 2010:
			case 2012:
			case 2013:
			case 2014:
				month = 12;
				day = 21;
				break;
			default:
				day = -1;
				break;
		}
		if (day > 0) {
			date = [HolidayData dateWithDay:day month:month year:year withCalendar:gregorian option:0];
			holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
			[holidays addObject:holidayItem];
		}
	}
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Chiristmas Bank Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newHongKongHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"The Chinese New Year", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Ching Ming Festival", @"holidays", @"Messages");
	int equinox = 20;
	if ((year == 2003) || (year == 2007)) equinox = 21;
		date = [HolidayData dateWithDay:equinox month:3 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:15];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[offsetDC release];
	}
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Holy Saturday", @"holidays", @"Messages");
	date = [HolidayData getHolySaturday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// International Labor Day
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Buddha's Birthday
	holidayName = NSLocalizedStringFromTable(@"Buddha's Birthday", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:8 month:4 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Duan Wu (Dragon Boat) Festival
	holidayName = NSLocalizedStringFromTable(@"Dragon Boat Festival", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:5 month:5 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Hong Kong Special Administrative Region Establishment Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Mid-Autumn Festival
	holidayName = NSLocalizedStringFromTable(@"Mid-Autumn Festival", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:16 month:8 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// National Day
	holidayName = NSLocalizedStringFromTable(@"National Day of People's Republic of China", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Chung Yeung Festival", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:9 month:9 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Boxing Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newKoreanHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Seol-nal(2.13~15)", @"holidays", @"Messages");
	} else if (year == 2011) {
		holidayName = NSLocalizedStringFromTable(@"Seol-nal(2.2~4)", @"holidays", @"Messages");
	} else {
		holidayName = NSLocalizedStringFromTable(@"Seol-nal(New Year)", @"holidays", @"Messages");
	}
	date = [HolidayData koreaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Independence Movement Day
	holidayName = NSLocalizedStringFromTable(@"Independence Movement Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Children's Day
	holidayName = NSLocalizedStringFromTable(@"Children's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Buddha's Birthday
	holidayName = NSLocalizedStringFromTable(@"Buddha's Birthday", @"holidays", @"Messages");
	date = [HolidayData koreaLunarDateWithSolarDay:8 month:4 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Memorial Day
	holidayName = NSLocalizedStringFromTable(@"Memorial Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Liberation Day
	holidayName = NSLocalizedStringFromTable(@"Liberation Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Foundation Day
	holidayName = NSLocalizedStringFromTable(@"Foundation Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:3 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Harvest Moon Festival(Sep 21~23)", @"holidays", @"Messages");
	} else if (year == 2011) {
		holidayName = NSLocalizedStringFromTable(@"Harvest Moon Festival(~ Sep 13)", @"holidays", @"Messages");
	} else {
		holidayName = NSLocalizedStringFromTable(@"Harvest Moon Festival", @"holidays", @"Messages");
	}
	date = [HolidayData koreaLunarDateWithSolarDay:15 month:8 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newJapaneseHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Coming-of-Age Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:1 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"National Foundation Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:11 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Vernal Equinox", @"holidays", @"Messages");
	// Adjust for known equinox
	int equinox = 20;
	switch (year) {
		case 2003:
		case 2007:
		case 2010:
			equinox = 21;
			break;
	}
	date = [HolidayData dateWithDay:equinox month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Shōwa Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:29 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:3 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Greenery Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:4 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Children's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Marine Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:7 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Respect-for-the-Aged Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:9 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Autumnal Equinox", @"holidays", @"Messages");
	// Adjust for known equinox
	int autumnEquinox = 23;
	switch (year) {
		case 2004:
		case 2005:
		case 2008:
		case 2009:
		case 2012:
		case 2013:
			autumnEquinox = 22;
			break;
		case 2002:
		case 2003:
		case 2006:
		case 2007:
		case 2010:
		case 2011:
		case 2014:
			autumnEquinox = 23;
			break;
		default:
			break;
	}
	date = [HolidayData dateWithDay:autumnEquinox month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Health and Sports Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:10 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Culture Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:3 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Labor Thanksgiving Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"The Emperor's Birthday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}	



NSMutableArray *newPhilippinesHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"The Chinese New Year", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"People Power Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Maundy Thursday", @"holidays", @"Messages");
	date = [HolidayData getMaundiThursday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Sunday", @"holidays", @"Messages");
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Bataan and Corregidor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:9 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:12 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ninoy Aquino Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:21 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"National Heroes' Day", @"holidays", @"Messages");
	date = [HolidayData getLastWeekday:Monday OfMonth:8 forYear:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Eidul Fitr", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Bonifacio Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:30 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Rizal Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:30 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}	


NSMutableArray *newTaiwanHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"Founding Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"The Chinese New Year", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"The Chinese New Year's Eve", @"holidays", @"Messages");
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[offsetDC release];
	}
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Peace Memorial Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:28 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	date = qingmingForYear(year, gregorian);
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Qingming Festival(Tomb Sweeping Day)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"Double Tenth Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:10 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Duan Wu (Dragon Boat) Festival
	holidayName = NSLocalizedStringFromTable(@"Dragon Boat Festival", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:5 month:5 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Mid-Autumn Festival
	holidayName = NSLocalizedStringFromTable(@"Mid-Autumn Festival", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:15 month:8 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newNewZealandHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Day after New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Southland Anniversary Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:1 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	if (year >= 2012) {
		holidayName = NSLocalizedStringFromTable(@"Anniversary Day Auckland / Northland", @"holidays", @"Messages");
		date = [HolidayData dateWithWeekday:Monday ordinal:5 month:1 year:year withCalendar:gregorian];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Waitangi Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Taranaki (New Plymouth) Anniversary Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:3 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Sunday", @"holidays", @"Messages");
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:4 month:10 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Anzac Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Queen's Birthday", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:6 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Canterbury (South) Anniversary Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:4 month:9 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Hawkes' Bay Anniversary Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Friday ordinal:3 month:10 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Marlborough Anniversary Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:5 month:10 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christchurch Show Day (Canterbury)", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:11 year:year withCalendar:gregorian];
    {
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.day = 11;
        date = [gregorian dateByAddingComponents:components toDate:date options:0];
    }
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
    
	holidayName = NSLocalizedStringFromTable(@"Westland Anniversary Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:12 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day is celebrated on December 25 with avoid weekend.
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Boxing Day is celebrated on December 26 with avoid weekend.
	holidayName = NSLocalizedStringFromTable(@"Boxing Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if (year == 2011) {
		holidayName = NSLocalizedStringFromTable(@"Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newAustraliaHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date, *additionalDate;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	additionalDate = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:1];
	if (![additionalDate isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"New Year's Day Public Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, additionalDate, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Australia Day(National Day)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	additionalDate = [HolidayData dateWithDay:26 month:1 year:year withCalendar:gregorian option:1];
	if (![additionalDate isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"Australia Day Public Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, additionalDate, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Saturday", @"holidays", @"Messages");
	date = [HolidayData getHolySaturday:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Sunday", @"holidays", @"Messages");
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day(WA)", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:3 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day(Tas, Vic)", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:3 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day(ACT, NSW, SA)", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:10 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day(Qld, NT)", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:5 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:5 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Anzac Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	additionalDate = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:1];
	if (![additionalDate isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"Anzac Day Public Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, additionalDate, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Queen's Birthday", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:2 month:6 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = NSLocalizedStringFromTable(@"Father's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:1 month:9 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Boxing Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Christmas Day Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:1];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Boxing Day Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:28 month:12 year:year withCalendar:gregorian option:1];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	if (year == 2011) {
		holidayName = NSLocalizedStringFromTable(@"Christmas Day Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:1];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Boxing Day Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:1];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newMalaysiaHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Federal Territory Day(KUL LBN PJY)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Chinese New Year", @"holidays", @"Messages");
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];

		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Chinese New Year, Day 2", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}

	holidayName = NSLocalizedStringFromTable(@"The Prophet's Birthday (Maulidur Rasul)", @"holidays", @"Messages");
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	date = [HolidayData getVesakDay:year forCountryCode:@"my" withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Wesak Day(Birth of Buddha)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"King's Birthday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = NSLocalizedStringFromTable(@"National Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Hari Raya Puasa (End of Ramadan)", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];

		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Hari Raya Puasa Holiday", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}

	date = [HolidayData getDeepavaliForYear:year];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Deepavali", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"Hari Raya Qurban (Feast of Sacrifice)", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = [NSLocalizedStringFromTable(@"Awal Muharram(Islamic New Year)", @"holidays", @"Messages") stringByAppendingFormat:@"(%d)", year - ((year > 2007)?578:579)];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	if (year == 2008) {
		holidayName = NSLocalizedStringFromTable(@"Awal Muharram(Islamic New Year)(1429)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
		
	[gregorian release];
	
	return [holidays autorelease];
}

NSMutableArray *newIndiaHoliadysForYear(NSInteger year) {
	if ((year < 2006) || (year > 2013)) {
		NSMutableArray *holidays = [[NSMutableArray alloc] init];
		NSArray *holidayItem = [NSArray arrayWithObjects:@"Indian Holidays (2006~2013 only)", nil];
		[holidays addObject:holidayItem];
		
		return [holidays autorelease];
	}
	
	NSString *filepath = [[NSBundle mainBundle] pathForResource:@"indian" ofType:@"plist"];
	NSDictionary *indianBook = [NSDictionary dictionaryWithContentsOfFile:filepath];
	if (indianBook) {
		NSMutableArray *holidayArray = [[NSMutableArray alloc] initWithArray:[indianBook objectForKey:[NSString stringWithFormat:@"%d", year]]];
		NSInteger index, count = [holidayArray count];
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		[offsetDC setHour:9 - ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600)];
		for (index = 0; index < count; index++) {
			NSMutableArray *item = [NSMutableArray arrayWithArray:[holidayArray objectAtIndex:index]];
			NSDate *newDate = [gregorian dateByAddingComponents:offsetDC toDate:[item objectAtIndex:1] options:0];
			[item replaceObjectAtIndex:1 withObject:newDate];
			[holidayArray replaceObjectAtIndex:index withObject:item];
		}
		[offsetDC release];
		[gregorian release];
		return holidayArray;
	}
	return nil;
}

NSMutableArray *newBangladeshHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"Shahid Dibosh(International Mother Language Day)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:21 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = NSLocalizedStringFromTable(@"Eid-e-Milad-Un Nabi(Prophet's Birthday)", @"holidays", @"Messages");
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		NSDateComponents *dc = [[NSDateComponents alloc] init];
		[dc setDay:1];
		birthday = [gregorian dateByAddingComponents:dc toDate:birthday options:0];
		[dc release];
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"Sheikh Mujibur Rahman's Birth Anniversary", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:17 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day(National Day)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Pahela Baishakh(Bengla New Year)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:14 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	date = [HolidayData getVesakDay:year forCountryCode:@"bd" withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Buddha Purnuma(Buddha Day)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"July Bank Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Shab e-Barat(Ascension of the Prophet)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:28 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"National Mourning Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Sri Krishna Janamashtami", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Public Holiday for Shab-e-Qadar(Night of Destiny)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:7 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = NSLocalizedStringFromTable(@"Eid-ul-Fiter(End of Ramadan)", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid-ul-Fiter Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Durga Puja(Bijoya Dashami)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:17 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"National Revolution Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:7 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = NSLocalizedStringFromTable(@"Eid-ul-Azha(Feast of Sacrifice)", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid-ul-Azha Holiday", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}		
	
	holidayName = NSLocalizedStringFromTable(@"Bijoy Dibosh(Victory Day)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:16 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if (year == 2009) {
		holidayName = NSLocalizedStringFromTable(@"Ashura(Muharrum)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:8 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Ashura(Muharrum)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:17 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
		
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newPakistanHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	holidayName = NSLocalizedStringFromTable(@"New Year Bank Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Kashmir Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = NSLocalizedStringFromTable(@"Eid Milad un Nabi(Prophet's Birthday)", @"holidays", @"Messages");
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"Pakistan Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = NSLocalizedStringFromTable(@"July Bank Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Start of Ramadan Bank Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:12 month:8 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"Independence Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:14 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Eidul Fitr(End of Ramadan)", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eidul Fitr Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Allama lqbal Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:9 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Eidul Azha(Feast of Sacrifice)", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eidul Azha Holiday", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}		
	
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Ashura Holiday(Yaum-e-Ashur)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:16 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];

		holidayName = NSLocalizedStringFromTable(@"Ashura Holiday(Yaum-e-Ashur)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:17 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Quaid-e-Azam's Birthday/Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Second Day of Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Anniversary of Benazir Bhutto's Death(Sindh)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}

NSMutableArray *newThailandHolidaysForYear(NSInteger year) 
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Makha Bucha Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:28 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if ((date = [HolidayData adjustDate:date calendar:gregorian option:1])) {
		holidayName = NSLocalizedStringFromTable(@"Makha Bucha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"King Rama | Memorial and Chakri Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Songkran (Thai New Year)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:13 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Songkran Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:14 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Songkran Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Songkran Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:16 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"National Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if ((date = [HolidayData adjustDate:date calendar:gregorian option:1])) {
		holidayName = NSLocalizedStringFromTable(@"National Labor Day(day in lieu)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Coronation Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Royal Ploughing Ceremony Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:13 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Emergency Public Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:14 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = NSLocalizedStringFromTable(@"Emergency Public Holiday(Bangkok and neighboring provinces)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:17 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Emergency Public Holiday(Bangkok and neighboring provinces)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:18 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Emergency Public Holiday(Bangkok and neighboring provinces)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:19 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Emergency Public Holiday(Bangkok and neighboring provinces)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:20 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Nationwide Bank Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:20 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Emergency Public Holiday(Bangkok and neighboring provinces)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:21 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Nationwide Bank Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:21 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	date = [HolidayData getVesakDay:year forCountryCode:@"th" withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Visakha Bucha Day(Buddha Day)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Mid Year Bank Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Asarnha Bucha Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Public Sector Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:27 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"HM the Queen's Birthday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:12 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Holiday for HM the Queen's Birthday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:13 month:8 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Chulalongkorn Day(Rama V Day)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if ((date = [HolidayData adjustDate:date calendar:gregorian option:1])) {
		holidayName = NSLocalizedStringFromTable(@"Chulalongkorn Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"HM the King's Birthday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if ((date = [HolidayData adjustDate:date calendar:gregorian option:1])) {
		holidayName = NSLocalizedStringFromTable(@"Holiday for HM the King's Birthday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:10 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}
