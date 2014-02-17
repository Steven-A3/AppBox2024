//
//  NSDateFormatter+LunarDate.m
//  AppBox3
//
//  Created by A3 on 2/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "NSDateFormatter+LunarDate.h"

@implementation NSDateFormatter (LunarDate)

- (NSRange)updateRange:(NSRange)originalRange withChangedRange:(NSRange)changed {
	if (originalRange.location == NSNotFound) return originalRange;
	if (changed.location > originalRange.location) return originalRange;
	return NSMakeRange(originalRange.location + changed.length, originalRange.length);
}

- (NSString *)stringFromDateComponents:(NSDateComponents *)dateComponents {
	NSMutableString *resultString = [self.dateFormat mutableCopy];
	NSUInteger idx = 0;
	NSRange weekdayRange = NSMakeRange(NSNotFound, 0), monthRange = NSMakeRange(NSNotFound, 0), dayRange = NSMakeRange(NSNotFound, 0);
	NSRange yearRange = NSMakeRange(NSNotFound, 0);
	for (; idx < [resultString length]; idx++) {
		switch ([resultString characterAtIndex:idx]) {
			case 'E':
				if (weekdayRange.location == NSNotFound) weekdayRange.location = idx;
				weekdayRange.length++;
				continue;
			case 'M':
				if (monthRange.location == NSNotFound) monthRange.location = idx;
				monthRange.length++;
				continue;
			case 'd':
				if (dayRange.location == NSNotFound) dayRange.location = idx;
				dayRange.length++;
				continue;
			case 'y':
				if (yearRange.location == NSNotFound) yearRange.location = idx;
				yearRange.length++;
				continue;
		}
	}
	if (dateComponents.year != NSUndefinedDateComponent && yearRange.location != NSNotFound) {
		NSString *year = [NSString stringWithFormat:@"%ld", (long) dateComponents.year];
		[resultString replaceOccurrencesOfString:[resultString substringWithRange:yearRange] withString:year options:0 range:yearRange];
		yearRange.length = [year length] - yearRange.length;

		monthRange = [self updateRange:monthRange withChangedRange:yearRange];
		dayRange = [self updateRange:dayRange withChangedRange:yearRange];
		weekdayRange = [self updateRange:weekdayRange withChangedRange:yearRange];
	}
	if (dateComponents.month != NSUndefinedDateComponent && monthRange.location != NSNotFound) {
		NSString *month;
		if (monthRange.length > 3) {
			month = self.monthSymbols[dateComponents.month - 1];
		} else {
			month = self.shortMonthSymbols[dateComponents.month - 1];
		}
		[resultString replaceOccurrencesOfString:[resultString substringWithRange:monthRange] withString:month options:0 range:monthRange];

		monthRange.length = [month length] - monthRange.length;
		dayRange = [self updateRange:dayRange withChangedRange:monthRange];
		weekdayRange = [self updateRange:weekdayRange withChangedRange:monthRange];
	}
	if (dateComponents.day != NSUndefinedDateComponent && dayRange.location != NSNotFound) {
		NSString *dayFormat = [NSString stringWithFormat:@"%%%ldld", (long) dayRange.length];
		NSString *day = [NSString stringWithFormat:dayFormat, dateComponents.day];
		[resultString replaceOccurrencesOfString:[resultString substringWithRange:dayRange] withString:day options:0 range:dayRange];

		dayRange.length = [day length] - dayRange.length;
		weekdayRange = [self updateRange:weekdayRange withChangedRange:dayRange];
	}
	if (dateComponents.weekday != NSUndefinedDateComponent && weekdayRange.location != NSNotFound) {
		NSString *weekday;
		if (weekdayRange.length > 3) {
			weekday = self.weekdaySymbols[dateComponents.weekday - 1];
		} else {
			weekday = self.shortWeekdaySymbols[dateComponents.weekday - 1];
		}
		[resultString replaceOccurrencesOfString:[resultString substringWithRange:weekdayRange] withString:weekday options:0 range:weekdayRange];
	}
	return resultString;
}

@end
