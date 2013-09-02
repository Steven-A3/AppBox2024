//
//  HolidayData+Country.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "HolidayData+Country.h"
#import "NSMutableArray+IMSExtensions.h"

NSString *const kHolidayCountriesForCurrentDevice = @"HolidayCountrisForCurrentDevice";
NSString *const kHolidayCountryExcludedHolidays = @"kHolidayCountryExcludedHolidays";
NSString *const kHolidayCountriesShowLunarDates = @"kHolidayCountriesShowLunarDates"; // Holds array of country codes

@implementation HolidayData (Country)

+ (NSArray *)supportedCountries {
	return @[
			@"ar", @"au", @"at", @"be", @"bw", @"br", @"cm", @"ca", @"cf", @"cl", // 10
			@"cn", @"co", @"hr", @"cz", @"dk", @"do", @"ec", @"eg", @"sv", @"gq", // 20
			@"ee", @"fi", @"fr", @"de", @"gr", @"gt", @"gn", @"gw", @"hn", @"hk", // 30
			@"hu", @"id", @"ie", @"it", @"ci", @"jm", @"jp", @"il", @"jo", @"ke", // 40
			@"lv", @"li", @"lt", @"lu", @"mo", @"mg", @"ml", @"mt", @"mu", @"mx", // 50
			@"md", @"nl", @"nz", @"ni", @"ne", @"no", @"pa", @"py", @"pe", @"ph", // 60
			@"pl", @"pt", @"pr", @"qa", @"kr", @"re", @"ro", @"ru", @"sa", @"sn", // 70
			@"sg", @"sk", @"za", @"es", @"se", @"ch", @"tw", @"tr", @"ae", @"gb", // 80
			@"uy", @"us", @"vi", @"ve", @"my", @"cr", @"in", @"ht", @"kw", @"ua", // 90
			@"mk", @"et", @"bd", @"bg", @"bs", @"pk", @"th", @"mz",
			];
}

- (NSMutableArray *)holidaysForCountry:(NSString *)countryCode year:(NSUInteger)year fullSet:(BOOL)fullSet {
	self.year = year;
	NSMutableArray *holidays = [self valueForKeyPath:[NSString stringWithFormat:@"%@_HolidaysInYear", [countryCode lowercaseString]]];
	if (!fullSet) {
		NSArray *excludedHoliday = [[NSUserDefaults standardUserDefaults] objectForKey:[[self class] keyForExcludedHolidaysForCountry:countryCode]];
		NSMutableArray *needToDelete = [NSMutableArray new];
		for (NSDictionary *item in holidays) {
			if ([excludedHoliday containsObject:item[kHolidayName]]) {
				[needToDelete addObject:item];
			}
		}
		[holidays removeObjectsInArray:needToDelete];
	}
	[holidays sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj1[kHolidayDate] compare:obj2[kHolidayDate]];
	}];
	return holidays;
}

+ (NSArray *)userSelectedCountries {
	NSArray *countries = [[NSUserDefaults standardUserDefaults] objectForKey:kHolidayCountriesForCurrentDevice];
	if (!countries) {

		countries = @[@"us", @"kr", @"jp", @"gb"];

		NSString *systemCountry = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];

		if (![countries containsObject:systemCountry]) {
			countries = [@[systemCountry] arrayByAddingObjectsFromArray:countries];
		}
		[[NSUserDefaults standardUserDefaults] setObject:countries forKey:kHolidayCountriesForCurrentDevice];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	return countries;
}

+ (void)setUserSelectedCountries:(NSArray *)newData {
	[[NSUserDefaults standardUserDefaults] setObject:newData forKey:kHolidayCountriesForCurrentDevice];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)thisYear {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
	return [components year];
}

+ (id)keyForExcludedHolidaysForCountry:(NSString *)countryCode {
	return [NSString stringWithFormat:@"%@%@", kHolidayCountryExcludedHolidays, countryCode];
}

+ (NSArray *)candidateForLunarDates {
	return @[@"kr", @"cn", @"hk", @"tw"];
}
+ (NSMutableArray *)arrayOfShowingLunarDates {
	NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:kHolidayCountriesShowLunarDates];
	if (!array) {
		array = [HolidayData candidateForLunarDates];
		[[NSUserDefaults standardUserDefaults] setObject:array forKey:kHolidayCountriesShowLunarDates];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	return [array mutableCopy];
}

+ (BOOL)needToShowLunarDatesForCountryCode:(NSString *)countryCode {
	NSMutableArray *array = [HolidayData arrayOfShowingLunarDates];
	return [array containsObject:countryCode];
}

+ (BOOL)needToShowLunarDatesOptionMenuForCountryCode:(NSString *)countryCode {
	return [[HolidayData candidateForLunarDates] containsObject:countryCode];
}

+ (void)addCountryToShowLunarDatesSet:(NSString *)countryCode {
	NSMutableArray *array = [HolidayData arrayOfShowingLunarDates];
	if (![array containsObject:countryCode]) {
		[array addObject:countryCode];
		[[NSUserDefaults standardUserDefaults] setObject:array forKey:kHolidayCountriesShowLunarDates];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

+ (void)removeCountryFromShowLunarDatesSet:(NSString *)countryCode {
	NSMutableArray *array = [HolidayData arrayOfShowingLunarDates];
	if ([array containsObject:countryCode]) {
		[array removeObject:countryCode];
		[[NSUserDefaults standardUserDefaults] setObject:array forKey:kHolidayCountriesShowLunarDates];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

@end
