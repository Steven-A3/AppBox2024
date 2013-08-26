//
//  HolidayMiddleEast.m
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import "HolidayMiddleEast.h"
#import "HolidayData.h"

NSMutableArray *newSaudiArabiaHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	// Known Ashura dates
	if (year == 2009) {
		holidayName = NSLocalizedStringFromTable(@"Ashura", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:8 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData dateWithDay:27 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Ashura", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:16 month:12 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Mawlid al-Navi (Prophet's Birthday)", @"holidays", @"Messages");
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Eid al Fitr(End of Ramadan)", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Fitr Holiday", @"holidays", @"Messages");
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
		
		[offsetDC release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"National Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Eid al Adha (Feast of Sacrifice)", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
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
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday (Arafat Day)", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha (Feast of Sacrifice)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
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
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday (Arafat Day)", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
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
	
	[gregorian release];
	
	return [holidays autorelease];
}	


NSMutableArray *newUAEHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Public Sector Holiday (Death of Umm al-Quwain ruler)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:2 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Public Sector Holiday (Death of Umm al-Quwain ruler)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:3 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Public Sector Holiday (Death of Umm al-Quwain ruler)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:4 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Private Sector Holiday(The Prophet's Birthday)", @"holidays", @"Messages");
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];

		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:-1];

		date = [gregorian dateByAddingComponents:offsetDC toDate:birthday options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];

		[offsetDC release];
	}

	date = [HolidayData getIsraAndMiraj:year withCalendar:gregorian];
	if (date) {
		holidayName = NSLocalizedStringFromTable(@"Prophet's Ascension(Isra and Miraj)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Sheikh Zayed's Accession", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Eid al Fitr(End of Ramadan)", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Fitr Holiday", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
		[offsetDC setDay:-1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Fitr Holiday (Last Day of Ramadan)", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"National Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:2 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"National Day Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:3 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Eid al Adha (Feast of Sacrifice)", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
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
		
		[offsetDC release];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha (Feast of Sacrifice)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
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
		
		[offsetDC release];
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
	
	[gregorian release];
	
	return [holidays autorelease];
}	


NSMutableArray *newQatarHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Eid al Fitr(End of Ramadan)", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Fitr", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Fitr", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Fitr", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
		[offsetDC setDay:-1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Fitr", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Fitr", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Eid al Adha (Feast of Sacrifice)", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha (Feast of Sacrifice)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
		[offsetDC setDay:-1];
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"National Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:18 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}	


NSMutableArray *newJordanHolidaysForYear(NSInteger year)
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
	
	holidayName = NSLocalizedStringFromTable(@"Mawlid al-Navi (Prophet's Birthday)", @"holidays", @"Messages");
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Independence Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
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
	
	holidayName = NSLocalizedStringFromTable(@"Eid al Fitr(End of Ramadan)", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Fitr", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Fitr", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Fitr Bank Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Eid al Adha (Feast of Sacrifice)", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha (Feast of Sacrifice)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	// Christmas Day
	holidayName = NSLocalizedStringFromTable(@"Christmas Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	[gregorian release];
	
	return [holidays autorelease];
}	


NSMutableArray *newEgyptHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	holidayName = NSLocalizedStringFromTable(@"Christmas(Old Calendarists)", @"holidays", @"Messages");
	int day = 7;
	if (year >= 2100) day = 8;
		date = [HolidayData dateWithDay:day month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Sportsmen's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Mother's Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:21 month:3 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Sinai Liberation Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:4 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Labor Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:5 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Evacuation Day(Eid el-Galaa)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:18 month:6 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Revolution Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:7 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Flooding of the Nile(Wafaa Elnil)", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:15 month:8 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Armed Forces Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:6 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Egyptian Naval Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:21 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Suez Day / Popular Resistance Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:24 month:10 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Victory Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:23 month:12 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Sham El Nessim(Spring Festival)", @"holidays", @"Messages");
	date = [HolidayData getShamElNessim:year withCalendar:gregorian];
	if (date != nil) {	// Only if it gets the date.
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
	
	holidayName = NSLocalizedStringFromTable(@"Prophet Mohamed's Birthday", @"holidays", @"Messages");
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Ramadan Feast", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Sacrifice Feast", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
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


NSMutableArray *newKuwaitHolidaysForYear(NSInteger year)
{
	NSMutableArray *holidays = [[NSMutableArray alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSArray *holidayItem;
	NSString *holidayName;
	NSDate *date;
	
	holidayName = NSLocalizedStringFromTable(@"Gregorian New Year", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:1 month:1 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	if (year == 2010) {
		holidayName = NSLocalizedStringFromTable(@"Gregorian New Year Holiday", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:3 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"National Day", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:25 month:2 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Prophet's Birthday", @"holidays", @"Messages");
	NSArray *mohamedBirthday = [HolidayData getMohamedBirthday:year];
	for (NSDate *birthday in mohamedBirthday) {
		holidayItem = [NSArray arrayWithObjects:holidayName, birthday, nil];
		[holidays addObject:holidayItem];
	}
	
	date = [HolidayData getIsraAndMiraj:year withCalendar:gregorian];
	if (date != nil) {
		holidayName = NSLocalizedStringFromTable(@"Prophet's Ascension(Isra and Miraj)", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Government Holiday", @"holidays", @"Messages");
	date = [HolidayData dateWithDay:9 month:9 year:year withCalendar:gregorian option:0];
	holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
	[holidays addObject:holidayItem];
	
	holidayName = NSLocalizedStringFromTable(@"Eid al Fitr(End of Ramadan)", @"holidays", @"Messages");
	date = [HolidayData getRamadanFeast:year withCalendar:gregorian option:0];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayName = NSLocalizedStringFromTable(@"Eid al Fitr Holiday", @"holidays", @"Messages");
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
	}
	
	holidayName = NSLocalizedStringFromTable(@"Eid al Adha (Feast of Sacrifice)", @"holidays", @"Messages");
	date = [HolidayData getSacrificeFeast:year withCalendar:gregorian];
	if (date != nil) {
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
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
		
		[offsetDC release];
	}
	
	if (year == 2006) {
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha (Feast of Sacrifice)", @"holidays", @"Messages");
		date = [HolidayData dateWithDay:10 month:1 year:year withCalendar:gregorian option:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		NSDateComponents *offsetDC = [[NSDateComponents alloc] init];
		[offsetDC setDay:1];
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
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
		
		holidayName = NSLocalizedStringFromTable(@"Eid al Adha Holiday", @"holidays", @"Messages");
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		date = [gregorian dateByAddingComponents:offsetDC toDate:date options:0];
		holidayItem = [NSArray arrayWithObjects:holidayName, date, nil];
		[holidays addObject:holidayItem];
		
		[offsetDC release];
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
	
	[gregorian release];
	
	return [holidays autorelease];
}	


