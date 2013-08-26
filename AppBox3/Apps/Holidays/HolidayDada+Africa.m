//
//  HolidayAfrica.m
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import "HolidayDada+Africa.h"
#import "HolidayData.h"

// Country code in http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements

@implementation HolidayData (Africa)

- (NSMutableArray *)bw_HolidaysInYear:(NSUInteger)year
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
	
	holidayName = @"New Year Holiday";
	date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
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
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:23 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Ascension Day";
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Sir Seretse Khama Day";
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Presidents' Day";
	date = [HolidayData dateWithDay:20 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"President's Day Holiday";
	date = [HolidayData dateWithDay:21 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Botswana Day";
	date = [HolidayData dateWithDay:30 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Botswana Day Holiday";
	date = [HolidayData dateWithDay:1 month:10 year:year withCalendar:gregorian option:0];
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


- (NSMutableArray *)mu_HolidaysInYear:(NSUInteger) year
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
	
	holidayName = @"New Year Holiday";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Spring Festival(The Chinese New Year)
	holidayName = @"The Chinese New Year";
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Abolition Day";
	date = [HolidayData dateWithDay:1 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Thaipoosam Cavadee";
	date = [HolidayData dateWithDay:8 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Maha Shivaratree";
	date = [HolidayData dateWithDay:23 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"National Day";
	date = [HolidayData dateWithDay:12 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Ougadi";
	date = [HolidayData dateWithDay:27 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// International Labor Day
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Ganesh Chathurthi";
	date = [HolidayData dateWithDay:24 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Hari Raya Puasa (End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Divali (Festival of Lights)";
	{
		int month, day;
		switch (year) {
			case 2008:
				month = 10;
				day = 29;
				break;
			case 2009:
				month = 10;
				day = 17;
				break;
			case 2010:
				month = 11;
				day = 5;
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
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Arrival of Indentured Labourers";
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	return holidays;
}

- (NSMutableArray *)mg_HolidaysInYear:(NSUInteger) year
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
	
	holidayName = @"Women's Day(for Women only)";
	date = [HolidayData dateWithDay:8 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Martyrs' Day";
	date = [HolidayData dateWithDay:29 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Ascension Day";
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Pentecost";
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
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:26 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Assumption Day";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	return holidays;
}



- (NSMutableArray *)cf_HolidaysInYear:(NSUInteger) year
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
	
	holidayName = @"Boganda Day";
	date = [HolidayData dateWithDay:29 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Easter Sunday";
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Ascension Day";
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Whit Sunday(Pentecost)";
	date = [HolidayData getPentecost:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Whit Monday";
	date = [HolidayData getWhitMonday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Prayer Day";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:28];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:13 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Assumption Day";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Korité (End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Tabaski (Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2006) {
		holidayName = @"Tabaski (Feast of Sacrifice)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Proclamation of the Republic";
	date = [HolidayData dateWithDay:1 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}	

// CÔTE D'IVOIRE or Ivory Coast
- (NSMutableArray *)ci_HolidaysInYear:(NSUInteger) year
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
	
	holidayName = @"Armed Forces Day";
	date = [HolidayData dateWithDay:20 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = @"The Prophet's Birthday (Mawloud)";
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = @"Easter Sunday";
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Ascension Day";
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Whit Sunday(Pentecost)";
	date = [HolidayData getPentecost:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Whit Monday";
	date = [HolidayData getWhitMonday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Independence Day(National Day)";
	date = [HolidayData dateWithDay:7 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Assumption Day";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Lailatou-Kadr (Quran Revalation)";
	date = [HolidayData getLaylat_al_Qadr:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Korité (End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Tabaski (Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2006) {
		holidayName = @"Tabaski (Feast of Sacrifice)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Peace Day";
	date = [HolidayData dateWithDay:15 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = [@"Islamic New Year" stringByAppendingFormat:@"(%d)", year - ((year > 2007)?578:579)];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	if (year == 2008) {
		holidayName = @"Islamic New Year(1429)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}	

// GUINEA-BISSAU
- (NSMutableArray *)gw_HolidaysInYear:(NSUInteger) year
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
	
	holidayName = @"Heroes' Day(Death of Amilcar Cabral)";
	date = [HolidayData dateWithDay:20 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"International Women's Day";
	date = [HolidayData dateWithDay:8 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Pidjiguiti Day";
	date = [HolidayData dateWithDay:3 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Korité (End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Tabaski (Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2006) {
		holidayName = @"Tabaski (Feast of Sacrifice)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"National Day";
	date = [HolidayData dateWithDay:24 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Readjustment Movement Day";
	date = [HolidayData dateWithDay:14 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}	


- (NSMutableArray *)gn_HolidaysInYear:(NSUInteger) year
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
	
	holidayName = @"Public Holiday (Sacrifice du 40e jour)";
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"The Prophet's Birthday";
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Second Republic Day";
	date = [HolidayData dateWithDay:3 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Africa Day";
	date = [HolidayData dateWithDay:25 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Assumption Day";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:2 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Lailatoul Qadr";
	date = [HolidayData getLaylat_al_Qadr:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Korité (End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Tabaski (Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2006) {
		holidayName = @"Tabaski (Feast of Sacrifice)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}	


- (NSMutableArray *)ml_HolidaysInYear:(NSUInteger) year
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
	
	holidayName = @"Armed Forces Day";
	date = [HolidayData dateWithDay:20 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"The Prophet's Birthday (Mawloud)";
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Monday";
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Day of Democracy";
	date = [HolidayData dateWithDay:26 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Africa Day";
	date = [HolidayData dateWithDay:25 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:22 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Korité (End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Tabaski (Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2006) {
		holidayName = @"Tabaski (Feast of Sacrifice)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}	


- (NSMutableArray *)ne_HolidaysInYear:(NSUInteger) year
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
	
	holidayName = @"Concord Day";
	date = [HolidayData dateWithDay:24 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Worker's Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:3 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Settler's Day";
	date = [HolidayData dateWithDay:5 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Republic Day";
	date = [HolidayData dateWithDay:18 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"The Prophet's Birthday (Mawlid)";
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Easter Monday";
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = [@"Muharram(Islamic New Year)" stringByAppendingFormat:@"(%d)", year - ((year > 2007)?578:579)];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	if (year == 2008) {
		holidayName = @"Muharram(Islamic New Year)(1429)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Laylat al-Qadr";
	date = [HolidayData getLaylat_al_Qadr:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Eid al Fitr";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Tabaski (Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2006) {
		holidayName = @"Tabaski (Feast of Sacrifice)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}	


- (NSMutableArray *)cm_HolidaysInYear:(NSUInteger) year
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
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Youth Day";
	date = [HolidayData dateWithDay:11 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"The Prophet's Birthday";
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
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
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"National Day";
	date = [HolidayData dateWithDay:20 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Ascension Day";
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Assumption Day";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Unification Day";
	date = [HolidayData dateWithDay:1 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Eid ul-Fitr";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Eid ul-adha";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2006) {
		holidayName = @"Eid ul-adha";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	return holidays;
}	


- (NSMutableArray *)sn_HolidaysInYear:(NSUInteger) year
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
	
	// Known Ashura date for Senegal
	if (year == 2009) {
		holidayName = @"Tamkharit (Ashura)";
		date = [HolidayData dateWithDay:8 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = @"Magal de Touba Eve";
		date = [HolidayData dateWithDay:13 month:2 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = @"Magal de Touba";
		date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = @"Magal de Touba";
		date = [HolidayData dateWithDay:15 month:2 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
	}
	
	holidayName = @"The Prophet's Birthday (Maouloud)";
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:4 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Ascension Day";
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
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
	
	holidayName = @"Assumption Day";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"All Saints Day";
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Korité (End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:3];
	if (date != nil) {
		originalDate = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
		if (![date isEqualToDate:originalDate]) {
			holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
		} else {
			holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		}
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Tabaski (Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2006) {
		holidayName = @"Tabaski (Feast of Sacrifice)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	return holidays;
}	


- (NSMutableArray *)za_HolidaysInYear:(NSUInteger) year
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date, *originalDate;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Human Rights Day";
	date = [HolidayData dateWithDay:21 month:3 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:21 month:3 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Family Day";
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Freedom Day";
	date = [HolidayData dateWithDay:27 month:4 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:27 month:4 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Youth Day";
	date = [HolidayData dateWithDay:16 month:6 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:16 month:6 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"National Women's Day";
	date = [HolidayData dateWithDay:9 month:8 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:9 month:8 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Heritage Day";
	date = [HolidayData dateWithDay:24 month:9 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:24 month:9 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Day of Reconcilation";
	date = [HolidayData dateWithDay:16 month:12 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:16 month:12 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = @"Day of Goodwill";
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];

	return holidays;
}	


- (NSMutableArray *)ke_HolidaysInYear:(NSUInteger) year
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
	
	holidayName = @"Good Friday";
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Madaraka Day";
	date = [HolidayData dateWithDay:1 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Moi Day";
	date = [HolidayData dateWithDay:10 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Eid al-Fitr(End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:3];
	if (date != nil) {
		originalDate = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
		if (![date isEqualToDate:originalDate]) {
			holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
		} else {
			holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		}
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Kenyatta Day";
	date = [HolidayData dateWithDay:20 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Feast of the Sacrifice";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2006) {
		holidayName = @"Feast of the Sacrifice";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:12 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day is celebrated on December 25 with avoid weekend.
	holidayName = @"Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Boxing Day is celebrated on December 26 with avoid weekend.
	holidayName = @"Boxing Day";
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	

	
	return holidays;
}


- (NSMutableArray *)et_HolidaysInYear:(NSUInteger) year
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = @"Ethiopian Christmas(Genna)";
	date = [HolidayData dateWithDay:7 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Timket(Epiphany)";
	date = [HolidayData dateWithDay:19 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = @"The Prophet's Birthday (Mouloud)";
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = @"Adwa Victory Day";
	date = [HolidayData dateWithDay:2 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	date = [HolidayData getGoodFriday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayName = @"Ethiopian Good Friday(Siklet)";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	date = [HolidayData getOrthodoxEaster:year withCalendar:gregorian];
	if (date != nil) {
		holidayName = @"Ethiopian Easter(Fasika)";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"International Labour Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Patriots' Victory Day";
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Dergue Downfall Day(National Day)";
	date = [HolidayData dateWithDay:28 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayName = @"Id Al Fetir(End of Ramadan)";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Ethiopian New Year";
	date = [HolidayData dateWithDay:11 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Meskel(Discovery of the True Cross)";
	date = [HolidayData dateWithDay:27 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Id Al Adaha / Arefa(Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	

	return holidays;
}


- (NSMutableArray *)mz_HolidaysInYear:(NSUInteger) year
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date, *adjusted;
	
	// New years day
	holidayName = @"New Year's Day";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = @"New Year's Day(day in lieu)";
		holidayItem = [NSArray arrayWithObjects:holidayName, adjusted, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Heroes' Day";
	date = [HolidayData dateWithDay:3 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = @"Heroes' Day(day in lieu)";
		holidayItem = [NSArray arrayWithObjects:holidayName, adjusted, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Women's Day";
	date = [HolidayData dateWithDay:7 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = @"Women's Day(day in lieu)";
		holidayItem = [NSArray arrayWithObjects:holidayName, adjusted, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Workers' Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = @"Workers' Day(day in lieu)";
		holidayItem = [NSArray arrayWithObjects:holidayName, adjusted, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:25 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = @"Independence Day(day in lieu)";
		holidayItem = [NSArray arrayWithObjects:holidayName, adjusted, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Lusaka Peace Agreement Day";
	date = [HolidayData dateWithDay:7 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = @"Lusaka Peace Agreement Day(day in lieu)";
		holidayItem = [NSArray arrayWithObjects:holidayName, adjusted, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Armed Forces Day";
	date = [HolidayData dateWithDay:25 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = @"Armed Forces Day(day in lieu)";
		holidayItem = [NSArray arrayWithObjects:holidayName, adjusted, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Peace and National Reconcillation Day";
	date = [HolidayData dateWithDay:4 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = @"Peace and National Reconcillation Day(day in lieu)";
		holidayItem = [NSArray arrayWithObjects:holidayName, adjusted, nil];
		[holidays addObject:holidayItem];
	}
	
	// Christmas Day
	holidayName = @"Family Day / Christmas Day";
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = @"Family Day / Christmas Day(day in lieu)";
		holidayItem = [NSArray arrayWithObjects:holidayName, adjusted, nil];
		[holidays addObject:holidayItem];
	}
	

	
	return holidays;
}	

@end