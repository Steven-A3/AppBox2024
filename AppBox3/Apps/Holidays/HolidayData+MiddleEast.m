//
//  HolidayMiddleEast.m
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import "HolidayData+MiddleEast.h"

@implementation HolidayData (MiddleEast) 

- (NSMutableArray *)sa_HolidaysInYear:(NSUInteger)year
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// Known Ashura dates
	// TODO: update yearly
	if (year == 2009) {
		holidayName = @"Ashura";
		date = [HolidayData dateWithDay:8 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	if (year == 2010) {
		holidayName = @"Ashura";
		date = [HolidayData dateWithDay:16 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Mawlid al-Navi (Prophet's Birthday)";
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Eid al Fitr(End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Fitr Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
		[offsetDC setDay:-1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
	holidayName = @"National Day";
	date = [HolidayData dateWithDay:23 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Eid al Adha (Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = @"Eid al Adha Holiday";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		
		holidayName = @"Eid al Adha Holiday (Arafat Day)";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = @"Eid al Adha Holiday";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
	if (year == 2006) {
		holidayName = @"Eid al Adha (Feast of Sacrifice)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = @"Eid al Adha Holiday";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		
		holidayName = @"Eid al Adha Holiday (Arafat Day)";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = @"Eid al Adha Holiday";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
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
	
	
	
	return holidays;
}	

// United Arab Emirates
- (NSMutableArray *)ae_HolidaysInYear:(NSUInteger)year
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
	
	holidayName = @"Public Sector Holiday (Death of Umm al-Quwain ruler)";
	date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Public Sector Holiday (Death of Umm al-Quwain ruler)";
	date = [HolidayData dateWithDay:3 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Public Sector Holiday (Death of Umm al-Quwain ruler)";
	date = [HolidayData dateWithDay:4 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Private Sector Holiday(The Prophet's Birthday)";
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];

		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];

		date = [gregorian dateByAddingComponents:offsetDC toDate:birthday options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];

		
	}

	date = [HolidayData getIsraAndMiraj:year withCalendar:gregorian];
	if (date) {
		holidayName = @"Prophet's Ascension(Isra and Miraj)";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Sheikh Zayed's Accession";
	date = [HolidayData dateWithDay:6 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Eid al Fitr(End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = @"Eid al Fitr Holiday";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
		[offsetDC setDay:-1];
		
		holidayName = @"Eid al Fitr Holiday (Last Day of Ramadan)";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
	holidayName = @"National Day";
	date = [HolidayData dateWithDay:2 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"National Day Holiday";
	date = [HolidayData dateWithDay:3 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Eid al Adha (Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = @"Eid al Adha Holiday";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
	if (year == 2006) {
		holidayName = @"Eid al Adha (Feast of Sacrifice)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = @"Eid al Adha Holiday";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
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
	
	
	
	return holidays;
}	

// Qatar
- (NSMutableArray *)qa_HolidaysInYear:(NSUInteger)year
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
	
	holidayName = @"Eid al Fitr(End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Fitr";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Fitr";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Fitr";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
		[offsetDC setDay:-1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Fitr";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Fitr";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
	holidayName = @"Eid al Adha (Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
	if (year == 2006) {
		holidayName = @"Eid al Adha (Feast of Sacrifice)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
	holidayName = @"National Day";
	date = [HolidayData dateWithDay:18 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	
	
	return holidays;
}	

// Jordan
- (NSMutableArray *)jo_HolidaysInYear:(NSUInteger)year
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
	
	holidayName = @"Mawlid al-Navi (Prophet's Birthday)";
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Independence Day";
	date = [HolidayData dateWithDay:25 month:5 year:year withCalendar:gregorian option:0];
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
	
	holidayName = @"Eid al Fitr(End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Fitr";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Fitr";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Fitr Bank Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
	holidayName = @"Eid al Adha (Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
	if (year == 2006) {
		holidayName = @"Eid al Adha (Feast of Sacrifice)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Adha Holiday";
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

// Egypt
- (NSMutableArray *)eg_HolidaysInYear:(NSUInteger)year
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	holidayName = @"Christmas(Old Calendarists)";
	int day = 7;
	if (year >= 2100) day = 8;
		date = [HolidayData dateWithDay:day month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	
	holidayName = @"Sportsmen's Day";
	date = [HolidayData dateWithDay:1 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Mother's Day";
	date = [HolidayData dateWithDay:21 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Sinai Liberation Day";
	date = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Labor Day";
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Evacuation Day(Eid el-Galaa)";
	date = [HolidayData dateWithDay:18 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Revolution Day";
	date = [HolidayData dateWithDay:23 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Flooding of the Nile(Wafaa Elnil)";
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Armed Forces Day";
	date = [HolidayData dateWithDay:6 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Egyptian Naval Day";
	date = [HolidayData dateWithDay:21 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Suez Day / Popular Resistance Day";
	date = [HolidayData dateWithDay:24 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Victory Day";
	date = [HolidayData dateWithDay:23 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Sham El Nessim(Spring Festival)";
	date = [HolidayData getShamElNessim:year withCalendar:gregorian];
	if (date != nil) {	// Only if it gets the date.
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
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
	
	holidayName = @"Prophet Mohamed's Birthday";
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Ramadan Feast";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Sacrifice Feast";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	if (year == 2006) {
		holidayName = @"Sacrifice Feast";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	
	
	return holidays;
}

// Kuwait
- (NSMutableArray *)kw_HolidaysInYear:(NSUInteger)year
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	holidayName = @"Gregorian New Year";
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	if (year == 2010) {
		holidayName = @"Gregorian New Year Holiday";
		date = [HolidayData dateWithDay:3 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"National Day";
	date = [HolidayData dateWithDay:25 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Prophet's Birthday";
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	date = [HolidayData getIsraAndMiraj:year withCalendar:gregorian];
	if (date != nil) {
		holidayName = @"Prophet's Ascension(Isra and Miraj)";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = @"Government Holiday";
	date = [HolidayData dateWithDay:9 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = @"Eid al Fitr(End of Ramadan)";
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = @"Eid al Fitr Holiday";
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
	holidayName = @"Eid al Adha (Feast of Sacrifice)";
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = @"Eid al Adha Holiday";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
	if (year == 2006) {
		holidayName = @"Eid al Adha (Feast of Sacrifice)";
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = @"Eid al Adha Holiday";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		
		holidayName = @"Eid al Adha Holiday";
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		
	}
	
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
	
	
	
	return holidays;
}	

@end