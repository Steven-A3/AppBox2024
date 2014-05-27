//
//  NSDate+formatting.m
//  A3TeamWork
//
//  Created by A3 on 11/4/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"

@implementation NSDate (formatting)

- (NSString *)a3FullStyleString {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    return [dateFormatter localizedLongStyleYearMonthFromDate:self];
    
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
//	NSString *dateFormat = [dateFormatter dateFormat];
//	if (![[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"KR"]) {
//		dateFormat = [dateFormat stringByReplacingOccurrencesOfString:@"EEEE" withString:@"EEE"];
//	}
//	dateFormat = [dateFormat stringByReplacingOccurrencesOfString:@"MMMM" withString:@"MMM"];
//	[dateFormatter setDateFormat:dateFormat];
	return [dateFormatter stringFromDate:self];
}

- (NSString *)a3FullCustomStyleString {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:[dateFormatter customFullStyleFormat]];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)a3FullStyleStringByRemovingYearComponent {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:[dateFormatter formatStringByRemovingYearComponent:[dateFormatter dateFormat]]];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)a3FullStyleWithTimeString {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	NSString *dateFormat = [dateFormatter dateFormat];
	if (![[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"KR"]) {
		dateFormat = [dateFormat stringByReplacingOccurrencesOfString:@"EEEE" withString:@"EEE"];
	}
	dateFormat = [dateFormat stringByReplacingOccurrencesOfString:@"MMMM" withString:@"MMM"];
	[dateFormatter setDateFormat:[NSString stringWithFormat:@"%@ hh:mm a", dateFormat]];
	return [dateFormatter stringFromDate:self];
}

- (NSString *)a3LongStyleString {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	NSString *dateFormat;
    if ([[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"KR"]) {
        dateFormat = [NSString stringWithFormat:@"EEEE, %@", [dateFormatter dateFormat]];
	}
    else {
        dateFormat = [NSString stringWithFormat:@"%@ EEEE", [dateFormatter dateFormat]];
    }

	[dateFormatter setDateFormat:dateFormat];
	return [dateFormatter stringFromDate:self];
}

- (NSString *)a3ShortStyleString {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	NSString *dateFormat = [dateFormatter dateFormat];
	//if (![[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"KR"]) {
    if ([[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"KR"]) {
		//dateFormat = [dateFormat stringByReplacingOccurrencesOfString:@"EEEE" withString:@"EEE"];
        dateFormat = @"yyyy.MM.dd EEE";
	}
	dateFormat = [dateFormat stringByReplacingOccurrencesOfString:@"MMMM" withString:@"MMM"];
	[dateFormatter setDateFormat:dateFormat];
	return [dateFormatter stringFromDate:self];
}

- (NSString *)a3HistoryDateString {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:@"MM/dd/yy hh:mm aaa"];
	return [dateFormatter stringFromDate:self];
}

+ (BOOL)isFullStyleLocale {
    NSString *locale = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if ( [locale isEqualToString:@"KR"] || [locale isEqualToString:@"JP"] || [locale isEqualToString:@"CN"] || [locale isEqualToString:@"TW"] || [locale isEqualToString:@"HK"] || [locale isEqualToString:@"MO"] || [locale isEqualToString:@"SG"] )
        return YES;
    
    return NO;
}

@end
