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

/*!
 * \ 한가지 종류는 한번씩만 있어야 한다. 종류는 E, EEE, EEEE, d, dd, M, MMM, MMMM 월 종류중에서 한가지만, 요일 종류중에서 한가지만 있어야 함.
 * \
 * \returns
 */
- (NSString *)stringFromDateComponents:(NSDateComponents *)dateComponents {
	NSMutableString *dateFormat = [self.dateFormat mutableCopy];
	NSUInteger idx = 0;
	NSRange weekdayRange = NSMakeRange(NSNotFound, 0), monthRange = NSMakeRange(NSNotFound, 0), dayRange = NSMakeRange(NSNotFound, 0);
	NSRange yearRange = NSMakeRange(NSNotFound, 0);
	NSRange quoteRange = NSMakeRange(NSNotFound, 0);
	NSMutableSet *quotedTexts;
	for (; idx < [dateFormat length]; idx++) {
		unichar character = [dateFormat characterAtIndex:idx];
		if (character == '\'') {
			if (quoteRange.location == NSNotFound) {
				quoteRange.location = idx;
			} else {
				quoteRange.length = idx - quoteRange.location + 1;
				if (!quotedTexts) {
					quotedTexts = [NSMutableSet new];
				}
				[quotedTexts addObject:[dateFormat substringWithRange:quoteRange]];
				quoteRange = NSMakeRange(NSNotFound, 0);
			}
			continue;
		}
		if (quoteRange.location != NSNotFound) continue;

		switch ([dateFormat characterAtIndex:idx]) {
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
	if (dateComponents.year != NSDateComponentUndefined && yearRange.location != NSNotFound) {
		NSString *year = [NSString stringWithFormat:@"%ld", (long) dateComponents.year];
		[dateFormat replaceOccurrencesOfString:[dateFormat substringWithRange:yearRange] withString:year options:0 range:yearRange];
		yearRange.length = [year length] - yearRange.length;

		monthRange = [self updateRange:monthRange withChangedRange:yearRange];
		dayRange = [self updateRange:dayRange withChangedRange:yearRange];
		weekdayRange = [self updateRange:weekdayRange withChangedRange:yearRange];
	}
	if (dateComponents.month != NSDateComponentUndefined && monthRange.location != NSNotFound) {
		NSString *month;
		if (monthRange.length == 1) {
			month = [NSString stringWithFormat:@"%ld", (long)dateComponents.month];
		} else if (monthRange.length == 2) {
			month = [NSString stringWithFormat:@"%02ld", (long)dateComponents.month];
		} else if (monthRange.length == 3) {
			month = self.shortMonthSymbols[dateComponents.month - 1];
		} else {
			month = self.monthSymbols[dateComponents.month - 1];
		}
		[dateFormat replaceOccurrencesOfString:[dateFormat substringWithRange:monthRange] withString:month options:0 range:monthRange];

		monthRange.length = [month length] - monthRange.length;
		dayRange = [self updateRange:dayRange withChangedRange:monthRange];
		weekdayRange = [self updateRange:weekdayRange withChangedRange:monthRange];
	}
	if (dateComponents.day != NSDateComponentUndefined && dayRange.location != NSNotFound) {
		NSString *dayFormat = [NSString stringWithFormat:@"%%%ldld", (long) dayRange.length];
		NSString *day = [NSString stringWithFormat:dayFormat, dateComponents.day];
		[dateFormat replaceOccurrencesOfString:[dateFormat substringWithRange:dayRange] withString:day options:0 range:dayRange];

		dayRange.length = [day length] - dayRange.length;
		weekdayRange = [self updateRange:weekdayRange withChangedRange:dayRange];
	}
	if (dateComponents.weekday != NSDateComponentUndefined && weekdayRange.location != NSNotFound) {
		NSString *weekday;
		if (weekdayRange.length > 3) {
			weekday = self.weekdaySymbols[dateComponents.weekday - 1];
		} else {
			weekday = self.shortWeekdaySymbols[dateComponents.weekday - 1];
		}
		[dateFormat replaceOccurrencesOfString:[dateFormat substringWithRange:weekdayRange] withString:weekday options:0 range:weekdayRange];
	}
	[quotedTexts enumerateObjectsUsingBlock:^(NSString *obj, BOOL *stop) {
		NSString *targetString = [obj stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'"]];
		[dateFormat replaceOccurrencesOfString:obj withString:targetString options:0 range:NSMakeRange(0, [dateFormat length])];
	}];
	return dateFormat;
}

@end
