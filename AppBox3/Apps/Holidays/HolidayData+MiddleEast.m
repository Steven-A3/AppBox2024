//
//  HolidayMiddleEast.m
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import "HolidayData+MiddleEast.h"
#import "A3AppDelegate.h"

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
    
    holidayName = NSLocalizedStringFromTable(@" Independence Day", kHolidaysResourceName, nil);
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

@end
