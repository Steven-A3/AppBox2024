/*
 *  HolidayCommon.cpp
 *  AppBox Pro
 *
 *  Created by Byeong Kwon Kwak on 6/26/09.
 *  Copyright 2009 ALLABOUTAPPS. All rights reserved.
 *
 */

#include "HolidayCommon.h"
#include "Constants.h"

int indexOfCountryCode(NSArray *array, NSString *code) {
	for (int i = 0; i < [array count]; i++) {
		NSArray *item = [array objectAtIndex:i];
		if ([[item objectAtIndex:0] isEqualToString:code]) {
			return i;
		}
	}
	return -1;
}


int indexOfCountryName(NSArray *array, NSString *name) {
	for (int i = 0; i < [array count]; i++) {
		NSArray *item = [array objectAtIndex:i];
		if ([[item objectAtIndex:1] isEqualToString:name]) {
			return i;
		}
	}
	return -1;
}

NSString *countryCodeAtIndex(NSArray *array, int index) {
	NSArray *item = [array objectAtIndex:index];
	return [[[item objectAtIndex:0] copy] autorelease];
}

NSString *countryNameAtIndex(NSArray *array, int index) {
	NSArray *item = [array objectAtIndex:index];
	return [[[item objectAtIndex:1] copy] autorelease];
}

NSString *countryNameForCode(NSArray *array, NSString *code) {
	for (int i = 0; i < [array count]; i++) {
		NSArray *item = [array objectAtIndex:i];
		if ([[item objectAtIndex:0] isEqualToString:code]) {
			return [[[item objectAtIndex:1] copy] autorelease];
		}
	}
	return nil;
}

NSString *countryCodeForName(NSArray *array, NSString *name) {
	for (int i = 0; i < [array count]; i++) {
		NSArray *item = [array objectAtIndex:i];
		if ([[item objectAtIndex:1] isEqualToString:name]) {
			return [[[item objectAtIndex:0] copy] autorelease];
		}
	}
	return nil;
}

UIImage *flagImageForCountryCode(NSString *code) {
	NSArray *codelist = [NSArray arrayWithObjects:
						 @"AR", @"AU", @"AT", @"BE", @"BW", @"BR", @"CM", @"CA", @"CF", @"CL", // 10
						 @"CN", @"CO", @"HR", @"CZ", @"DK", @"DO", @"EC", @"EG", @"SV", @"GQ", // 20
						 @"EE", @"FI", @"FR", @"DE", @"GR", @"GT", @"GN", @"GW", @"HN", @"HK", // 30
						 @"HU", @"ID", @"IE", @"IT", @"CI", @"JM", @"JP", @"IL", @"JO", @"KE", // 40
						 @"LV", @"LI", @"LT", @"LU", @"MO", @"MG", @"ML", @"MT", @"MU", @"MX", // 50
						 @"MD", @"AN", @"NZ", @"NI", @"NE", @"NO", @"PA", @"PY", @"PE", @"PH", // 60
						 @"PL", @"PT", @"PR", @"QA", @"KR", @"RE", @"RO", @"RU", @"SA", @"SN", // 70
						 @"SG", @"SK", @"ZA", @"ES", @"SE", @"CH", @"TW", @"TR", @"AE", @"GB", // 80
						 @"UY", @"US", @"VI", @"VE", @"MY", @"CR", @"IN", @"HT", @"KW", @"UA", // 90
						 @"MK", @"ET", @"BD", @"BG", @"BS", @"PK", @"TH", @"MZ",
						 nil];
	NSArray *filenamelist = [NSArray arrayWithObjects:
							 @"Argentina", @"Australia", @"Austria",
							 @"Belgium", @"Botswana", @"Brazil",
							 @"Cameroon", @"Canada", @"Central_African_Republic",
							 @"Chile", @"China", @"Colombia",
							 @"Croatia", @"Czech_Republic", @"Denmark",
							 @"Dominican_Republic", @"Ecuador", @"Egypt",
							 @"El_Salvador", @"Equatorial_Guinea", @"Estonia",
							 @"Finland", @"France", @"Germany",
							 @"Greece", @"Guatemala", @"Guinea",
							 @"Guinea-Bissau", @"Honduras", @"Hong_Kong",
							 @"Hungary", @"Indonesia", @"Ireland",
							 @"Italy", @"Ivory_Coast", @"Jamaica",
							 @"Japan", @"Israel", @"Jordan",
							 @"Kenya", @"Latvia", @"Liechtenstein",
							 @"Lithuania", @"Luxembourg", @"Macau",
							 @"Madagascar", @"Mali", @"Malta",
							 @"Mauritius", @"Mexico", @"Moldova",
							 @"Netherlands", @"New_Zealand", @"Nicaragua",
							 @"Niger", @"Norway", @"Panama",
							 @"Paraguay", @"Peru", @"Philippines",
							 @"Poland", @"Portugal", @"Puerto_Rico",
							 @"Qatar", @"South_Korea", @"France",
							 @"Romania", @"Russia", @"Saudi_Arabia",
							 @"Senegal", @"Singapore", @"Slovakia",
							 @"South_Africa", @"Spain", @"Sweden",
							 @"Switzerland", @"Republic_of_China", @"Turkey",
							 @"United_Arab_Emirates", @"United_Kingdom", @"Uruguay",
							 @"United_States", @"United_States_Virgin_Islands", @"Venezuela",
							 @"Malaysia", @"Costa_Rica", @"India",
							 @"Haiti", @"Kuwait", @"Ukraine",
							 @"Macedonia", @"Ethiopia", @"Bangladesh",
							 @"Bulgaria", @"Bahamas", @"Pakistan", @"Thaliland", @"Mozambique",
							 nil];
	for (int i = 0; i < [codelist count]; i++) {
		if ([[codelist objectAtIndex:i] isEqualToString:code]) {
			NSString *imagePath = [[NSBundle mainBundle] pathForResource:[filenamelist objectAtIndex:i] ofType:@"png"];
			UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
			return image;
		}
	}
	return nil;
}

NSInteger sortHolidaysWithName(id array1, id array2, void *context)
{
	NSString *string1 = [array1 objectAtIndex:0];
	NSString *string2 = [array2 objectAtIndex:0];
    return [string1 localizedCaseInsensitiveCompare:string2];
}

NSInteger sortHolidaysWithDate(id array1, id array2, void *context)
{
	NSDate *date1 = [array1 objectAtIndex:1];
	NSDate *date2 = [array2 objectAtIndex:1];
    return [date1 compare:date2];
}
