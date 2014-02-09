//
//  A3ClockInfo.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockInfo.h"
#import "NSDateFormatter+A3Addition.h"
#import "NSUserDefaults+A3Defaults.h"

@implementation A3ClockInfo

- (NSCalendar *)calendar {
	if (!_calendar) {
		_calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	}
	return _calendar;
}

- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [NSDateFormatter new];
		[_dateFormatter setDateStyle:NSDateFormatterFullStyle];
		_fullStyleFormatWithoutYear = [_dateFormatter formatStringByRemovingYearComponent:_dateFormatter.dateFormat];
		[_dateFormatter setDateStyle:NSDateFormatterLongStyle];
		_mediumStyleFormatWithoutYear = [_dateFormatter formatStringByRemovingYearComponent:_dateFormatter.dateFormat];
	}
	return _dateFormatter;
}

- (NSString *)fullStyleDateStringWithoutYear {
	[self.dateFormatter setDateFormat:_fullStyleFormatWithoutYear];
	return [_dateFormatter stringFromDate:_date];
}

- (NSString *)mediumStyleDateStringWithoutYear {
	[self.dateFormatter setDateFormat:_mediumStyleFormatWithoutYear];
	return [_dateFormatter stringFromDate:_date];
}

- (NSString *)dateStringConsideringOptions {
	NSString *dateString;
	if([[NSUserDefaults standardUserDefaults] clockShowTheDayOfTheWeek] && [[NSUserDefaults standardUserDefaults] clockShowDate])
	{
		dateString = self.fullStyleDateStringWithoutYear;
	}
	else if([[NSUserDefaults standardUserDefaults] clockShowTheDayOfTheWeek])
	{
		dateString = [NSString stringWithFormat:@"%@", self.weekday];
	}
	else if([[NSUserDefaults standardUserDefaults] clockShowDate])
	{
		dateString = self.mediumStyleDateStringWithoutYear;
	}
	else {
		dateString = @"";
	}
	return dateString;
}

@end
