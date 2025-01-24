//
//  NSDateFormatter(A3Addition)
//  AppBox3
//
//  Created by A3 on 2/8/14 3:40 PM.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "NSDateFormatter+A3Addition.h"


@implementation NSDateFormatter (A3Addition)

/*! Generate string from updateDate with NSDateFormatterLongStyle omitting Day part
 * \param NSDate
 * \returns string like February, 2014, 2014년 2월
 */
- (NSString *)localizedLongStyleYearMonthFromDate:(NSDate *)date {
	[self setDateStyle:NSDateFormatterLongStyle];
	NSString *dateFormat = [self formatStringByRemovingDayComponent:self.dateFormat];
	[self setDateFormat:dateFormat];
	return [self stringFromDate:date];
}

/*! Generate string from updateDate with NSDateFormatterMediumStyle omitting Day part
 * \param NSDate
 * \returns string like Feb, 2014, 2014년 2월
 */
- (NSString *)localizedMediumStyleYearMonthFromDate:(NSDate *)date {
	[self setDateStyle:NSDateFormatterMediumStyle];
	NSString *dateFormat = [self formatStringByRemovingDayComponent:self.dateFormat];
	[self setDateFormat:dateFormat];
	return [self stringFromDate:date];
}

- (NSString *)formatStringByRemovingYearComponent:(NSString *)originalFormat {
	NSArray *replaceArray = @[
                              @"y 'm'. ", @"'de' y", @"y 'оны' ", @" y 'г'.", @" y 'ж'.", @" 'di' y", @"y년 ", @" y 'р'.",
                              @"G y د ", @" G y", @" y G", @"y年", @"སྤྱི་ལོ་y ", @"y թ., ", @" 'lia' y", @" 'năm' y",
                              @"y. 'gada' ", @"G y د ", @"G y ", @".y", @"y/"
                              ];

	for (NSString *yearComponent in replaceArray) {
		NSRange range = [originalFormat rangeOfString:yearComponent];
		if (range.location != NSNotFound) {
			return [originalFormat stringByReplacingOccurrencesOfString:yearComponent withString:@""];
		}
	}

	NSRange range = [originalFormat rangeOfString:@"MMMM y,"];
	if (range.location != NSNotFound) {
		return [originalFormat stringByReplacingOccurrencesOfString:@"MMMM y," withString:@"MMMM,"];
	}

	return [self formatStringByRemovingComponent:@"y" formFormat:originalFormat];
}

- (NSString *)formatStringByRemovingMediumYearComponent:(NSString *)originalFormat {
	NSArray *replaceArray = @[ @"-y", @"/y", @",y", @" 'de' y", @" y G", @" y", @", y", @"y/", @"G y ", @".y",
                               @", y թ.", @"y年", @" y 'г'.", @"y-", @"y ལོ་འི་", @" 'di' y", @"y. ", @"y.", @"/yyyy", @"y ",
                               @"y, ", @"སྤྱི་ལོ་y ", @"y. 'gada' "];
    
	for (NSString *yearComponent in replaceArray) {
		NSRange range = [originalFormat rangeOfString:yearComponent];
		if (range.location != NSNotFound) {
			return [originalFormat stringByReplacingOccurrencesOfString:yearComponent withString:@""];
		}
	}
    
	NSRange range = [originalFormat rangeOfString:@"MMMM y,"];
	if (range.location != NSNotFound) {
		return [originalFormat stringByReplacingOccurrencesOfString:@"MMMM y," withString:@"MMMM,"];
	}
    
	return [self formatStringByRemovingComponent:@"y" formFormat:originalFormat];
}

- (NSString *)formatStringByRemovingDayComponent:(NSString *)originalFormat {
	// Group 1, just removing specific component
	NSArray *replaceArray = @[
			@"dd/", @"/dd", @"/d", @"d. ", @"d.", @"dd.", @"d/", @"-dd", @"dd-", @"d-", @"d日", @"dd日",
			@"dd.", @"dད", @"d 'de' ", @"dd 'de' ",  @"d 'di' ", @" d일", @" d 'd'.",
			@"d 'ta'’ ",  @"d 'de' ", @"d 'da' ", @"ཙེས་d", @" ཚེས་dd",
	];

	for (NSString *yearComponent in replaceArray) {
		NSRange range = [originalFormat rangeOfString:yearComponent];
		if (range.location != NSNotFound) {
            // Medium Type 의 경우, 오동작을 방지하기 위하여 추가.
            NSRange extraCheckRange = [originalFormat rangeOfString:@"d" options:NSCaseInsensitiveSearch range:NSMakeRange(0, range.location)];
            if (extraCheckRange.location != NSNotFound) {
                continue;
            }

			return [originalFormat stringByReplacingOccurrencesOfString:yearComponent withString:@""];
		}
	}

	NSRange range = [originalFormat rangeOfString:@" d,"];
	if (range.location != NSNotFound) {
		return [originalFormat stringByReplacingOccurrencesOfString:@" d," withString:@""];
	}
	range = [originalFormat rangeOfString:@"'Ngày' dd 'tháng' M"];
	if (range.location != NSNotFound) {
		return [originalFormat stringByReplacingOccurrencesOfString:@"'Ngày' dd 'tháng' M" withString:@"'Tháng' M"];
	}

	return [self formatStringByRemovingComponent:@"d" formFormat:originalFormat];
}

- (NSString *)formatStringByRemovingComponent:(NSString *)componentSpecifier formFormat:(NSString *)originalFormat {
	NSMutableArray *formatComponents = [[originalFormat componentsSeparatedByString:@" "] mutableCopy];
	NSUInteger indexOfComponent = [formatComponents indexOfObjectPassingTest:^BOOL(NSString *obj, NSUInteger idx, BOOL *stop) {
		return [obj rangeOfString:componentSpecifier].location != NSNotFound;
	}];
	if (indexOfComponent != NSNotFound) {
		[formatComponents removeObjectAtIndex:indexOfComponent];
	}
	NSInteger idx = 0;
	NSMutableString *convertedFormat = [NSMutableString new];
	for (NSString *component in formatComponents) {
		[convertedFormat appendFormat:@"%@%@", component, idx == [formatComponents count] - 1 ? @"" : @" "];
		idx++;
	}
	return [convertedFormat stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",.، "]];
}

- (NSString *)customFullStyleFormat {
	[self setDateStyle:NSDateFormatterFullStyle];
	NSMutableString *dateFormat = [self.dateFormat mutableCopy];
	[dateFormat replaceOccurrencesOfString:@"EEEE" withString:@"E" options:0 range:NSMakeRange(0, [dateFormat length])];
	[dateFormat replaceOccurrencesOfString:@"MMMM" withString:@"MMM" options:0 range:NSMakeRange(0, [dateFormat length])];
	return dateFormat;
}

- (NSString *)customFullWithTimeStyleFormat {
	[self setDateStyle:NSDateFormatterFullStyle];
	[self setTimeStyle:NSDateFormatterShortStyle];
	NSMutableString *dateFormat = [self.dateFormat mutableCopy];
	[dateFormat replaceOccurrencesOfString:@"EEEE" withString:@"E" options:0 range:NSMakeRange(0, [dateFormat length])];
	[dateFormat replaceOccurrencesOfString:@"MMMM" withString:@"MMM" options:0 range:NSMakeRange(0, [dateFormat length])];
	return dateFormat;
}

@end
