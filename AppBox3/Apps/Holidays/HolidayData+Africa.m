//
//  HolidayAfrica.m
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import "HolidayData+Africa.h"
#import "A3AppDelegate.h"

// Country code in http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements

@implementation HolidayData (Africa)

// BOTSWANA http://en.wikipedia.org/wiki/Public_holidays_in_Botswana
- (NSMutableArray *)bw_HolidaysInYear
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

	holidayName = NSLocalizedStringFromTable(@"New Year Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
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

	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Ascension Day", kHolidaysResourceName, nil);
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Sir Seretse Khama Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Presidents' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:7 year:year withCalendar:gregorian];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"President's Day Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithWeekday:Tuesday ordinal:3 month:7 year:year withCalendar:gregorian];
	date = [HolidayData dateWithDay:21 month:7 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];


	holidayName = NSLocalizedStringFromTable(@"Botswana Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:30 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];


	holidayName = NSLocalizedStringFromTable(@"Botswana Day Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];


	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];


	holidayName = NSLocalizedStringFromTable(@"Boxing Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Mauritius http://en.wikipedia.org/wiki/Public_holidays_in_Mauritius#Public_holidays_and_festivals
- (NSMutableArray *)mu_HolidaysInYear
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

	holidayName = NSLocalizedStringFromTable(@"New Year Holiday", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	// Spring Festival(The Chinese New Year)
	holidayName = NSLocalizedStringFromTable(@"Chinese Spring Festival", kHolidaysResourceName, nil);
	date = [HolidayData chinaLunarDateWithSolarDay:1 month:1 year:year];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Abolition of Slavery", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

    //todo: http://en.wikipedia.org/wiki/Thaipusam Hindu Festival. in January/February, more precisely by the Tamil community in Mauritius
	holidayName = NSLocalizedStringFromTable(@"Thaipoosam Cavadee", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

    //todo: http://en.wikipedia.org/wiki/Maha_Shivaratri  Hindu Festival. Between February and March
	holidayName = NSLocalizedStringFromTable(@"Maha Shivaratree", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:23 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"National Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

    //todo: http://en.wikipedia.org/wiki/Ugadi Hindu Festival
	holidayName = NSLocalizedStringFromTable(@"Ugadi", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:27 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	// International Labor Day
	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

    //todo: "Assumption of Mary" – 15 August. The 15 August becomes a public holiday in even years, for example 2006, 2008 and 2010. During odd years (2005, 2007, 2009), it is not a public holiday

    //todo: on the 4th day of the lunar month of the Hindu calendar
	holidayName = NSLocalizedStringFromTable(@"Ganesh Chathurthi", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Hari Raya Puasa (End of Ramadan)", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

    //todo: http://en.wikipedia.org/wiki/Diwali Hindu Festival. Between October and November
	holidayName = NSLocalizedStringFromTable(@"Diwali", kHolidaysResourceName, nil);
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
			[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		}
	}

    //todo: "Eid ul-Fitr" (Between October and November) Muslim Festival
    
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Arrival of Indentured Labourers", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Madagascar
- (NSMutableArray *)mg_HolidaysInYear
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

	holidayName = NSLocalizedStringFromTable(@"Women's Day(for Women only)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Martyrs' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:29 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Ascension Day", kHolidaysResourceName, nil);
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
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

	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}


// Central African Republic
- (NSMutableArray *)cf_HolidaysInYear
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

	holidayName = NSLocalizedStringFromTable(@"Boganda Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:29 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Ascension Day", kHolidaysResourceName, nil);
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Pentecost", kHolidaysResourceName, nil);
	date = [HolidayData getPentecost:year western:NO withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Whit Monday", kHolidaysResourceName, nil);
	date = [HolidayData getWhitMonday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

    holidayName = NSLocalizedStringFromTable(@"General Prayer Day", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:28];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];

		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:13 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Republic Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// CÔTE D'IVOIRE or Ivory Coast
- (NSMutableArray *)ci_HolidaysInYear
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

	holidayName = NSLocalizedStringFromTable(@"Armed Forces Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Ascension Day", kHolidaysResourceName, nil);
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Pentecost", kHolidaysResourceName, nil);
	date = [HolidayData getPentecost:year western:NO withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Whit Monday", kHolidaysResourceName, nil);
	date = [HolidayData getWhitMonday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:7 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Lailatou-Kadr(Revelation of the Qur'an)", kHolidaysResourceName, nil);
	date = [HolidayData getLaylat_al_Qadr:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
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

	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"National Peace Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = [@"Islamic New Year" stringByAppendingFormat:@"(%lu)", (unsigned long)(year - ((year > 2007)?578:579))];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2008) {
		holidayName = NSLocalizedStringFromTable(@"Islamic New Year(1429)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// GUINEA-BISSAU
- (NSMutableArray *)gw_HolidaysInYear
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

	holidayName = NSLocalizedStringFromTable(@"Heroes' Day(Death of Amilcar Cabral)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"International Women's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:8 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Anniversary of the Killing of Pidjiguoiti", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

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

	holidayName = NSLocalizedStringFromTable(@"National Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Anniversary of the Movement of Readjustment", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:14 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Guinea http://en.wikipedia.org/wiki/Public_holidays_in_Guinea
- (NSMutableArray *)gn_HolidaysInYear
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

	holidayName = NSLocalizedStringFromTable(@"Public Holiday (Sacrifice du 40e jour)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Second Republic Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Africa Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Lailatoul Qadr", kHolidaysResourceName, nil);
	date = [HolidayData getLaylat_al_Qadr:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
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

	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Mali http://en.wikipedia.org/wiki/Public_holidays_in_Mali
- (NSMutableArray *)ml_HolidaysInYear
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

	holidayName = NSLocalizedStringFromTable(@"Army Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
    
	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
	}

    //todo: "Prophet's Baptism", variable Islamic
    
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", kHolidaysResourceName, nil);
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Martyrs' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Workers' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Africa Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:22 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

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

	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Niger
- (NSMutableArray *)ne_HolidaysInYear
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

	holidayName = NSLocalizedStringFromTable(@"Concord Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Nigerien Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Settler's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Nigerien Republic Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:18 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Easter Monday", kHolidaysResourceName, nil);
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = [@"First day of Muharram(Islamic New Year)" stringByAppendingFormat:@"(%lu)", (unsigned long)year - ((year > 2007)?578:579)];
	date = [HolidayData getIslamicNewYear:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
	if (year == 2008) {
		holidayName = NSLocalizedStringFromTable(@"First day of Muharram(Islamic New Year)(1429)", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Laylat al-Qadr", kHolidaysResourceName, nil);
	date = [HolidayData getLaylat_al_Qadr:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Eid al Fitr", kHolidaysResourceName, nil);
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

	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Cameroon
- (NSMutableArray *)cm_HolidaysInYear
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

	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Youth Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:11 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
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

	holidayName = NSLocalizedStringFromTable(@"National Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Ascension Day", kHolidaysResourceName, nil);
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Unification Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Eid ul-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Eid ul-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid ul-Adha", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Senegal http://en.wikipedia.org/wiki/Public_holidays_in_Senegal
- (NSMutableArray *)sn_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];

	NSString *holidayName;
	NSDate *date, *originalDate;

	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	// Known Ashura date for Senegal
	if (year == 2009) {
		holidayName = NSLocalizedStringFromTable(@"Ashura", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:8 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

		holidayName = NSLocalizedStringFromTable(@"Magal de Touba Eve", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:13 month:2 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

		holidayName = NSLocalizedStringFromTable(@"Magal de Touba", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

		holidayName = NSLocalizedStringFromTable(@"Magal de Touba", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:15 month:2 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	}

	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:4 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Ascension Day", kHolidaysResourceName, nil);
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
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

	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"All Saints Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:3];
	if (date != nil) {
		originalDate = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
		if (![date isEqualToDate:originalDate]) {
			[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:originalDate, kHolidayDuration:@1}];
		} else {
			[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
		}
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

// South Africa
- (NSMutableArray *)za_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];

	NSString *holidayName;
	NSDate *date, *originalDate;

	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:originalDate, kHolidayDuration:@1}];
	} else {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Human Rights Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:21 month:3 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:21 month:3 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:originalDate, kHolidayDuration:@1}];
	} else {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Family Day", kHolidaysResourceName, nil);
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Freedom Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:27 month:4 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:27 month:4 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:originalDate, kHolidayDuration:@1}];
	} else {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Workers' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:originalDate, kHolidayDuration:@1}];
	} else {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Youth Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:16 month:6 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:16 month:6 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:originalDate, kHolidayDuration:@1}];
	} else {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"National Women's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:9 month:8 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:9 month:8 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:originalDate, kHolidayDuration:@1}];
	} else {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Heritage Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:24 month:9 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:24 month:9 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:originalDate, kHolidayDuration:@1}];
	} else {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Day of Reconcilation", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:16 month:12 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:16 month:12 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:originalDate, kHolidayDuration:@1}];
	} else {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:originalDate, kHolidayDuration:@1}];
	} else {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Day of Goodwill", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:3];
	originalDate = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:originalDate, kHolidayDuration:@1}];
	} else {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	return holidays;
}

// Kenya http://en.wikipedia.org/wiki/Public_holidays_in_Kenya
- (NSMutableArray *)ke_HolidaysInYear
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

    //todo: "Easter" - date variable
    
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", kHolidaysResourceName, nil);
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Labor Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Madaraka Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Moi Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:10 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:3];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Kenyatta Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:20 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@NO, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Jamhuri Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:12 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	// Christmas Day is celebrated on December 25 with avoid weekend.
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	// Boxing Day is celebrated on December 26 with avoid weekend.
	holidayName = NSLocalizedStringFromTable(@"Boxing Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	return holidays;
}

// Ethiopia http://en.wikipedia.org/wiki/Public_holidays_in_Ethiopia
- (NSMutableArray *)et_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];

	NSString *holidayName;
	NSDate *date;

	// New years day
	holidayName = NSLocalizedStringFromTable(@"Ethiopian Christmas", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:7 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

    //todo: Leap year - January 20
	holidayName = NSLocalizedStringFromTable(@"Epiphany", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:19 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", kHolidaysResourceName, nil);
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:birthday, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Victory at Adwa Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:2 month:3 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	date = [HolidayData getGoodFriday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayName = NSLocalizedStringFromTable(@"Good Friday", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	date = [HolidayData getOrthodoxEaster:year withCalendar:gregorian];
	if (date != nil) {
		holidayName = NSLocalizedStringFromTable(@"Easter", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Labour Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Patriots' VDay", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Dergue Downfall Day(National Day)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:28 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayName = NSLocalizedStringFromTable(@"Eid al-Fitr", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}
    
    //todo: moveable	Ramadan http://en.wikipedia.org/wiki/Ramadan

    //todo: Leap year- September 12
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:11 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

    //todo: Leap year- September 28
	holidayName = NSLocalizedStringFromTable(@"Finding of the True Cross", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:27 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	holidayName = NSLocalizedStringFromTable(@"Eid al-Adha", kHolidaysResourceName, nil);
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	return holidays;
}

// Mozambique
- (NSMutableArray *)mz_HolidaysInYear
{
	NSUInteger year = self.year;

	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[A3AppDelegate instance] calendar];

	NSString *holidayName;
	NSDate *date, *adjusted;

	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"New Year's Day(day in lieu)", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Heroes' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:3 month:2 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"Heroes' Day(day in lieu)", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Women's Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:7 month:4 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"Women's Day(day in lieu)", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Workers' Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"Workers' Day(day in lieu)", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Independence Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:6 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"Independence Day(day in lieu)", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Victory Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:7 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"Victory Day(day in lieu)", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Revolution Day", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:9 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"Revolution Day(day in lieu)", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	holidayName = NSLocalizedStringFromTable(@"Day of Peace and Reconciliation", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:4 month:10 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];

	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"Day of Peace and Reconciliation(day in lieu)", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Family Day(Christmas)", kHolidaysResourceName, nil);
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	
	adjusted = [HolidayData adjustDate:date calendar:gregorian option:3];
	if (adjusted && ![adjusted isEqualToDate:date]) {
		holidayName = NSLocalizedStringFromTable(@"Family Day(Christmas)(day in lieu)", kHolidaysResourceName, nil);
		[holidays addObject:@{kHolidayName:holidayName, kHolidayIsPublic:@YES, kHolidayDate:date, kHolidayDuration:@1}];
	}

	return holidays;
}

@end
