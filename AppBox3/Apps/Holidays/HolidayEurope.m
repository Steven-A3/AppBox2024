//
//  HolidayEurope.m
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import "HolidayEurope.h"
#import "HolidayData.h"

NSMutableArray *newIrelandHolidaysForYear(NSInteger year)
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
	
	// St Patrick's Day, 17 March
	holidayName = NSLocalizedStringFromTable(@"St Patrick's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:17 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:5 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"June Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:6 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"August Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:8 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"October Holiday", @"holidays", @"Messages");
	date = [HolidayData getLastWeekday:Monday OfMonth:10 forYear:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Stephen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newUnitedKingdomHolidaysForYear(NSInteger year)
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
	
	if (year != 2012) {
		// Second of January
		holidayName = NSLocalizedStringFromTable(@"Second of January(Scotland)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:1];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2011) {
		// New years day
		holidayName = NSLocalizedStringFromTable(@"New Year's Day Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:3 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		// Second of January
		holidayName = NSLocalizedStringFromTable(@"Second of January Public Holiday(Scotland)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:4 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	} else if (year == 2012) {
		// New years day
		holidayName = NSLocalizedStringFromTable(@"New Year's Day Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		// Second of January
		holidayName = NSLocalizedStringFromTable(@"Second of January(Scotland)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:3 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Saint David's Day(Wales)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// St Patrick's Day, 17 March
	holidayName = NSLocalizedStringFromTable(@"St Patrick's Day(Northern Ireland)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:17 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Mothering Sunday", @"holidays", @"Messages");
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-21];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[offsetDC release];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday(England/Wales)", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"St George's Day(England)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:4 year:year withCalendar:gregorian option:1];
	originalDate = [HolidayData dateWithDay:23 month:4 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	if (year == 2011) {
		holidayName = NSLocalizedStringFromTable(@"Royal Wedding Bank Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:29 month:4 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Early May Bank Holiday, First Monday in May
	holidayName = NSLocalizedStringFromTable(@"Early May Bank Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:1 month:5 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if (year == 2012) {
			// Spring Bank Holiday, Last Monday in May
		holidayName = NSLocalizedStringFromTable(@"Spring Bank Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:4 month:6 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];

		holidayName = NSLocalizedStringFromTable(@"Queen's Diamond Jubilee", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:5 month:6 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	} else {
			// Spring Bank Holiday, Last Monday in May
		holidayName = NSLocalizedStringFromTable(@"Spring Bank Holiday", @"holidays", @"Messages");
		date = [HolidayData getLastWeekday:Monday OfMonth:5 forYear:year withCalendar:gregorian];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Father's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:3 month:6 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Battle of the Boyne(Northern Ireland)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:12 month:7 year:year withCalendar:gregorian option:1];
	originalDate = [HolidayData dateWithDay:12 month:7 year:year withCalendar:gregorian option:0];
	if (![date isEqualToDate:originalDate]) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, originalDate, nil];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	}
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Summer Bank Holiday", @"holidays", @"Messages");
	date = [HolidayData getLastWeekday:Monday OfMonth:8 forYear:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St Andrew's Day(Scotland)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:30 month:11 year:year withCalendar:gregorian option:0];
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
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Boxing Day Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:28 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	} else if (year == 2011) {
		holidayName = NSLocalizedStringFromTable(@"Christmas Day Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Boxing Day Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newPortugalHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day, Ano Novo
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Carnival, Carnaval
	holidayName = NSLocalizedStringFromTable(@"Carnival", @"holidays", @"Messages");
	NSDate *ashWednesday = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetdc = [[NSDateComponents alloc] init];
		[offsetdc setDay:-1];
		date = [gregorian dateByAddingComponents:offsetdc toDate:ashWednesday options:0];
		[offsetdc release];
		
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Good Friday
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Easter Day 
	holidayName = NSLocalizedStringFromTable(@"Easter Day", @"holidays", @"Messages");
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Freedom Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Corpus Christi
	holidayName = NSLocalizedStringFromTable(@"Corpus Christi (feast)", @"holidays", @"Messages");
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Portugal Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:10 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Republic Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Restoration of Independence", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}



NSMutableArray *newNorwayHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Palm Sunday", @"holidays", @"Messages");
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-7];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[offsetDC release];
		
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
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
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:17 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Pentecost", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Stephen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newDenmarkHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Palm Sunday", @"holidays", @"Messages");
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-7];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[offsetDC release];
		
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
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
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"General Prayer Day", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:28];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[offsetDC release];
		
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Sunday", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"First Day of Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Second Day of Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newLuxembourgHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Carnival (jour férié d'usage)", @"holidays", @"Messages");
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil) {
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-2];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[offsetDC release];
		
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
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
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Sunday(Pentecost)", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Grand Duke's Birthday (National Day)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Luxembourg City Kermesse (jour férié d'usqge)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Saint-Ètienne", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newBelgiumHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Pentecost", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Pentecost Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"National Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:21 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Armistice Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newFrenchHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Valentine's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Grand Mother's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:1 month:3 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
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
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"V-E Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", @"holidays", @"Messages");
	NSDate *mothersday = [HolidayData getLastWeekday:Sunday OfMonth:5 forYear:year withCalendar:gregorian];
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if ([date isEqualToDate:mothersday]) {
		mothersday = [HolidayData dateWithWeekday:Sunday ordinal:1 month:6 year:year withCalendar:gregorian];
		holidayItem = [NSArray arrayWithObjects:holidayName, mothersday, nil];
		[holidays addObject:holidayItem];
	} else {
		holidayItem = [NSArray arrayWithObjects:holidayName, mothersday, nil];
		[holidays addObject:holidayItem];
	}
	holidayName = NSLocalizedStringFromTable(@"Pentecost", @"holidays", @"Messages");
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Father's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:3 month:6 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Whit Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Bastille Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:14 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Grand Father's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:1 month:10 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Armistice Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}

NSMutableArray *newReunionHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
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
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Victory Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Sunday(Pentecost)", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"National Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:14 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Armistice Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Abolition Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:20 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}


NSMutableArray *newNetherlandsHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter and Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Queen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:30 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Remembrance of the dead", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:4 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Liberation Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Pentecost", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Saint Nicholas' Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day(25~26)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}


NSMutableArray *newGermanyHolidaysForYear(NSInteger year)
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
	
	// Epiphany, Heilige Drei Könige
	holidayName = NSLocalizedStringFromTable(@"Epiphany", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Valentine's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Carnival Monday", @"holidays", @"Messages");
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-2];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		[offsetDC release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Carnival", @"holidays", @"Messages");
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
	if (date != nil) {
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		[offsetDC release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Ash Wednesday", @"holidays", @"Messages");
	date = [HolidayData getAshWednesday:year withCalendar:gregorian];
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
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:2 month:5 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Sunday", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Corpus Christi", @"holidays", @"Messages");
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Peace of Augsburg", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"German Unity Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:3 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Thanksgiving Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:1 month:10 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Halloween", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Reformation Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Memorial Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
		NSDateComponents *addDC = [[NSDateComponents alloc] init];
		[addDC setDay:-5*7 - ([dc weekday] == 1?8:[dc weekday]) + 1];
		NSDate *targetDate = [gregorian dateByAddingComponents:addDC toDate:date options:0];
		[addDC release];
		holidayItem = [NSArray arrayWithObjects:holidayName, targetDate, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Repentance Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:11 year:year withCalendar:gregorian option:0];
	NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
	NSDateComponents *addDC = [[NSDateComponents alloc] init];
    int diff;
    if ([dc weekday] > 4) {
        diff = -([dc weekday] - 4);
    } else {
        diff = (4 - [dc weekday]) - 7;
    }
	[addDC setDay:diff];
	NSDate *targetDate = [gregorian dateByAddingComponents:addDC toDate:date options:0];
	[addDC release];
	holidayItem = [NSArray arrayWithObjects:holidayName, targetDate, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Sunday in commemoration of the dead", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
		NSDateComponents *addDC = [[NSDateComponents alloc] init];
		[addDC setDay:-4*7 - ([dc weekday] == 1?8:[dc weekday]) + 1];
		NSDate *targetDate = [gregorian dateByAddingComponents:addDC toDate:date options:0];
		[addDC release];
		holidayItem = [NSArray arrayWithObjects:holidayName, targetDate, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"1.Advent", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
		NSDateComponents *addDC = [[NSDateComponents alloc] init];
#ifdef TRACE_LOG
		NSLog(@"%d", [dc weekday]);
#endif	
		[addDC setDay:-3*7 - ([dc weekday] == 1?8:[dc weekday]) + 1];
		NSDate *targetDate = [gregorian dateByAddingComponents:addDC toDate:date options:0];
		[addDC release];
		holidayItem = [NSArray arrayWithObjects:holidayName, targetDate, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"2.Advent", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
		NSDateComponents *addDC = [[NSDateComponents alloc] init];
		[addDC setDay:-2*7 - ([dc weekday] == 1?8:[dc weekday]) + 1];
		NSDate *targetDate = [gregorian dateByAddingComponents:addDC toDate:date options:0];
		[addDC release];
		holidayItem = [NSArray arrayWithObjects:holidayName, targetDate, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Barbara", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:4 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St Nicholas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"3.Advent", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
		NSDateComponents *addDC = [[NSDateComponents alloc] init];
		[addDC setDay:-7 - ([dc weekday] == 1?8:[dc weekday]) + 1];
		NSDate *targetDate = [gregorian dateByAddingComponents:addDC toDate:date options:0];
		[addDC release];
		holidayItem = [NSArray arrayWithObjects:holidayName, targetDate, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"4.Advent", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
		NSDateComponents *addDC = [[NSDateComponents alloc] init];
		[addDC setDay:-([dc weekday] == 1?8:[dc weekday]) + 1];
		NSDate *targetDate = [gregorian dateByAddingComponents:addDC toDate:date options:0];
		[addDC release];
		holidayItem = [NSArray arrayWithObjects:holidayName, targetDate, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day 1", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day 2", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}	


NSMutableArray *newTurkeyHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"National Sovereignty and Children's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Commemoration of Atatürk, Youth and Sports Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:19 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Victory Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:30 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Republic Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:29 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ramadan Feast", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[offsetDC release];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Sacrifice Feast", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[offsetDC release];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Sacrifice Feast", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	[gregorian release];
	return [holidays autorelease];
}	


NSMutableArray *newEstoniaHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Afternoon before Independence Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
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
	
	holidayName = NSLocalizedStringFromTable(@"Spring Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Whit Sunday(Pentecost)", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Afternoon before Victory Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:22 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Victory Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Midsummer/Saint John's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Afternoon before Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Second Day of Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Afternoon before New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}	


NSMutableArray *newCroatiaHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Epiphany", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Corpus Christi", @"holidays", @"Messages");
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Anti-fascist struggle day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:22 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Statehood Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Victory and Homeland Thanksgiving Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Stephen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}	


NSMutableArray *newSlovakiaHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Epiphany", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Day of Victory over fascism", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Cyril and Methodius Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Slovak National Uprising anniversary", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:29 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Day of the Constitution of the Slovak Republic", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Day of Our Lady of Sorrows, patron saint of Slovakia", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Struggle for Freedom and Democracy Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:17 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Stephen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}	


NSMutableArray *newCzechRepublicHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Liberation Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Saints Cyril and Methodius Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Jan Hus Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Wenceslas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:28 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independent Czechoslovak State Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:28 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Struggle for Freedom and Democracy Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:17 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Stephen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}	


NSMutableArray *newLatviaHolidaysForYear(NSInteger year)
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Declaration of Independence", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:4 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Midsummer Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Midsummer", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Proclamation of the Republic of Latvia", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:18 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Second Day of Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}	


NSMutableArray *newFinlandHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Epiphany", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Pentecost", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Midsummer's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:20 month:6 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
		if ([dc weekday] != Saturday) {
			NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
			[offsetDC setDay:7 - [dc weekday]];
			date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
			[offsetDC release];
		}
	}
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:10 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
		if ([dc weekday] != Saturday) {
			NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
			[offsetDC setDay:7 - [dc weekday]];
			date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
			[offsetDC release];
		}
	}
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Stephen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}	


NSMutableArray *newSwedenHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Twelfth Night", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:5 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Epiphany", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
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
	
	holidayName = NSLocalizedStringFromTable(@"Easter Saturday", @"holidays", @"Messages");
	date = [HolidayData dateFrom:date withOffset:-1];
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
	
	holidayName = NSLocalizedStringFromTable(@"Walpurgis Night", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:30 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Eve", @"holidays", @"Messages");
	date = [HolidayData dateFrom:date withOffset:-1];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Sunday", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"National Day of Sweden", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Midsummer's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:20 month:6 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
		if ([dc weekday] != Saturday) {
			NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
			[offsetDC setDay:7 - [dc weekday]];
			date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
			[offsetDC release];
		}
	}
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Midsummer's Eve", @"holidays", @"Messages");
	date = [HolidayData dateFrom:date withOffset:-1];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:10 year:year withCalendar:gregorian option:0];
	{
		NSDateComponents *dc = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
		if ([dc weekday] != Saturday) {
			NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
			[offsetDC setDay:7 - [dc weekday]];
			date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
			[offsetDC release];
		}
	}
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Eve", @"holidays", @"Messages");
	date = [HolidayData dateFrom:date withOffset:-1];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = NSLocalizedStringFromTable(@"2nd Day of Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}	


NSMutableArray *newLiechtensteinHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Saint Berchtolds' Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Epiphany", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Candlemas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:2 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Shrove Tuesday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:3 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Saint Joseph's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:19 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
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
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Sunday(Pentecost)", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Corpus Christi Day", @"holidays", @"Messages");
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"National Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Mary's Birthday (Nativity of Our Lady)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Stephen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}	


NSMutableArray *newAustriaHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Epiphany", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Saint Joseph", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:19 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Saint Florian", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:4 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Corpus Christi", @"holidays", @"Messages");
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Rupert of Salzburg", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Carinthian Plebiscite", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:10 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"National Day (Declaration of Neutrality)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Martin of Tours", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Leopold III, Margrave of Austria", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Stephen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}	


NSMutableArray *newItalyHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Epiphany", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
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
	
	holidayName = NSLocalizedStringFromTable(@"Anniversary of Liberation", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Republic Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:2 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ferragosto/Assumption Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Day of Dead", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Victory Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:4 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Stephen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}	


NSMutableArray *newLithuaniaHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day, Ano Novo
	holidayName = NSLocalizedStringFromTable(@"New Year's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Day of Re-establishment of the State of Lithuania(1918)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:16 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Day of Restitution of Independence of Lithuania", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:11 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Easter Day 
	holidayName = NSLocalizedStringFromTable(@"Easter Day", @"holidays", @"Messages");
	date = [HolidayData getEasterDayOfYear:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:1 month:5 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Father's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:1 month:6 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. John's Day/Day of Dew", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Statehood Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day(25~26)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}


NSMutableArray *newRussianHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Orthodox Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:7 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Defender of the Fatherland Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"International Women's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Spring and Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Victory Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:9 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Russia Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:12 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Unity Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:4 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}	

NSMutableArray *newSpainHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Epiphany", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Father's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:19 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Holy Thursday", @"holidays", @"Messages");
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
	
	holidayName = NSLocalizedStringFromTable(@"Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. George's Day / Castile and León Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. John's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. James Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Covadonga and Guadalupe Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Hispanic Day(Columbus Day)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:12 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Stephen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}


NSMutableArray *newMaltaHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Feast of St. Paul's Shipwreck", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:10 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Feast of St. Joseph", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:19 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Freedom Day (Jum il-Helsien)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
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
	
	holidayName = NSLocalizedStringFromTable(@"Workers' Day (Jum il-Haddiem)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Sette Giugno", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:7 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Feast of St. Peter and St. Paul (L-Imnarja)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:29 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Feast of Assumption", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Feast of Our Lady of Victories (Jum il-Vittorja)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day(Jum I-Indipendenza)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:21 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Republic Day (Jum ir-Repubblika)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:13 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}


NSMutableArray *newSwitzerlandHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Saint Berchtolds' Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Epiphany", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Saint Joseph's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:19 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Good Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Easter", @"holidays", @"Messages");
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Ascension Day", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Corpus Christi", @"holidays", @"Messages");
	date = [HolidayData getCorpusChristi:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"St. Peter and St. Paul", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:29 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Swiss National Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption of Mary", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Swiss federal fast", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Sunday ordinal:3 month:9 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Swiss federal fast Monday", @"holidays", @"Messages");
	date = [HolidayData dateWithWeekday:Monday ordinal:3 month:9 year:year withCalendar:gregorian];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Immaculate Conception", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Stephen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}


NSMutableArray *newPolandHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Epiphany", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Grandma's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:21 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Grandpa's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:22 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Valentine's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:14 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"April Fool's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Easter", @"holidays", @"Messages");
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
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day May 3", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:3 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Children's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Father's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Assumption Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Souls' Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:2 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:11 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Andrew's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:30 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"First Day of Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Second Day of Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}


NSMutableArray *newMoldovaHolidaysForYear(NSInteger year)
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
	
	if (year == 2009) {
		holidayName = NSLocalizedStringFromTable(@"Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:5 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:9 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Orthodox Christmas (Craciunul)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:7 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Orthodox Christmas Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Intl' Women's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Orthodox Easter(Paste)", @"holidays", @"Messages");
	date = [HolidayData getOrthodoxEaster:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Orthodox Easter Monday(Doua zi de Paste)", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Memory/Parents' Day(Pastele Blanjinilor)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:27 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Intl' Solidarity Day of Workers", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Victory Day(Ziua Victoriei)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:9 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day(Ziua Republicii)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:27 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"National Language Day(Limba Noastra)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Chisinau Day (Hramul Chisinaului)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}


NSMutableArray *newGreeceHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Theophany", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"The Three Holy Hierarchs(School only)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:30 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Clean Monday", @"holidays", @"Messages");
	date = [HolidayData getOrthodoxEaster:year withCalendar:gregorian];
	if (date != nil)
	{
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-48];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		[offsetDC release];
		
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"25th of March", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Great and Holy Friday", @"holidays", @"Messages");
	date = [HolidayData getGoodFriday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Pascha", @"holidays", @"Messages");
	date = [HolidayData getOrthodoxEaster:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Bright Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Holy Sprit Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"The Dormition of the Holy Virgin", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"The \"Ochi day\"", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:28 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Polytechneio(School only)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:17 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Synaxis of the Mother of God", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}


NSMutableArray *newHungaryHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"National Day(1848 Revolution)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
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
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Pentecost Sunday", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Pentecost Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:YES withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"St. Stephen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:20 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"National Day(1956 Revolution)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"All Saints Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Second Day of Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}


NSMutableArray *newRomaniaHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day(Jan 1~2)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Unification Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Dragobetele", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Spring festival", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Women's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Easter(Orthodox)", @"holidays", @"Messages");
	date = [HolidayData getOrthodoxEaster:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Heroes' Day(Ascension)", @"holidays", @"Messages");
	date = [HolidayData getAscensionDay:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Pentecost", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Whit Monday", @"holidays", @"Messages");
	date = [HolidayData getWhitMonday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Children's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Flag Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"National Anthem Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:29 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Dormition of the Theotokos", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Great Union Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day(25~26)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	return [holidays autorelease];
}


NSMutableArray *newUkraineHolidaysForYear(NSInteger year)
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
		holidayName = NSLocalizedStringFromTable(@"Bank Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:4 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:5 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:8 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Bank Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:9 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Orthodox Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:7 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Orthodox New Year", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:14 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Unification Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:22 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Women's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Orthodox Easter", @"holidays", @"Messages");
	date = [HolidayData getOrthodoxEaster:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Orthodox Easter Monday", @"holidays", @"Messages");
	date = [HolidayData getEasterMonday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Labor Day Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:3 month:5 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Labor Day Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:4 month:5 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"Victory Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:9 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Victory Day Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:10 month:5 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Orthodox Pentecost(Triytsia)", @"holidays", @"Messages");
	date = [HolidayData getPentecost:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	if (date != nil) {
		holidayName = NSLocalizedStringFromTable(@"Orthodox Pentecost Monday", @"holidays", @"Messages");
		NSDateComponents *dc = [[NSDateComponents alloc] init];
		[dc setDay:1];
		date = [gregorian dateByAddingComponents:dc toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		[dc release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Constitution Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:28 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Independence Day Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:23 month:8 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	[gregorian release];
	return [holidays autorelease];
}


NSMutableArray *newMacedoniaHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// New years day
	holidayName = NSLocalizedStringFromTable(@"New Year's Day(Nova Godina)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Badnik", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Orthodox Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:7 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Bogojavlenie(Vodici)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:19 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	date = [HolidayData getGoodFriday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayName = NSLocalizedStringFromTable(@"Orthodox Good Friday(Veliki Petok)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	date = [HolidayData getOrthodoxEaster:year withCalendar:gregorian];
	if (date != nil) {
		holidayName = NSLocalizedStringFromTable(@"Orthodox Easter(Prv den veligden)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	date = [HolidayData getEasterMonday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayName = NSLocalizedStringFromTable(@"Orthodox Easter Monday(Vtor den Veligden)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day(Den na trudot)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Duhovden(All Souls)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:21 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = NSLocalizedStringFromTable(@"Saints Cyril and Methodius' Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Iliden Day(Republic Day)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:2 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Golema Bogorodica(Dormition of the Holy Mother of God)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:28 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		NSDateComponents *dc = [[NSDateComponents alloc] init];
		[dc setDay:-1];
		date = [gregorian dateByAddingComponents:dc toDate:date options:0];
		[dc release];
		holidayName = NSLocalizedStringFromTable(@"Ramazan Bajram(End of Ramadan)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}

	holidayName = NSLocalizedStringFromTable(@"Uprising Against Fascism Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:11 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Day of the Macedonian Revolution", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = NSLocalizedStringFromTable(@"Kurban Bajram(Feast of Sacrifice)", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		NSDateComponents *dc = [[NSDateComponents alloc] init];
		[dc setDay:-1];
		date = [gregorian dateByAddingComponents:dc toDate:date options:0];
		[dc release];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Day of the Albanian Alphabet", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:22 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"St. Kliment Ohirdski(St. Clement of Ohrid)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:8 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	[gregorian release];
	return [holidays autorelease];
}


NSMutableArray *newBulgariaHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Liberation Day(National Day)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:3 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	date = [HolidayData getGoodFriday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayName = NSLocalizedStringFromTable(@"Orthodox Good Friday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	date = [HolidayData getOrthodoxEaster:year withCalendar:gregorian];
	if (date != nil) {
		holidayName = NSLocalizedStringFromTable(@"Orthodox Easter", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	date = [HolidayData getEasterMonday:year western:NO withCalendar:gregorian];
	if (date != nil) {
		holidayName = NSLocalizedStringFromTable(@"Orthodox Easter Monday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labour Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Saint George's Day/Army Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Saint George's Day Bridge Public Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:7 month:5 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Culture and Literacy Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Unification Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:22 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Revival Leader's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:11 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];

	holidayName = NSLocalizedStringFromTable(@"Christmas Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Second Day of Christmas", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:26 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"New Year's Eve", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:31 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
		
	[gregorian release];
	return [holidays autorelease];
}
