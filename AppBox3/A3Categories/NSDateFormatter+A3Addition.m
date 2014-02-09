//
//  NSDateFormatter(A3Addition)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/8/14 3:40 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "NSDateFormatter+A3Addition.h"


@implementation NSDateFormatter (A3Addition)

- (NSString *)formatStringByRemovingYearComponent:(NSString *)originalFormat {
	NSArray *replaceArray = @[
			@"y 'm'. ", @"'de' y", @"y 'оны' ", @" y 'г'.", @" y 'ж'.", @" 'di' y", @"y년 ", @" y 'р'.",
			@"G y د ", @" G y", @" y G", @"y年", @"སྤྱི་ལོ་y ", @"y թ., ", @" 'lia' y", @" 'năm' y",
			@"y. 'gada' ", @"G y د ", @"G y "
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

	NSMutableArray *formatComponents = [[originalFormat componentsSeparatedByString:@" "] mutableCopy];
	NSUInteger indexOfYearComponent = [formatComponents indexOfObjectPassingTest:^BOOL(NSString *obj, NSUInteger idx, BOOL *stop) {
		return [obj rangeOfString:@"y"].location != NSNotFound;
	}];
	if (indexOfYearComponent != NSNotFound) {
		[formatComponents removeObjectAtIndex:indexOfYearComponent];
	}
	NSInteger idx = 0;
	NSMutableString *convertedFormat = [NSMutableString new];
	for (NSString *component in formatComponents) {
		[convertedFormat appendFormat:@"%@%@", component, idx == [formatComponents count] - 1 ? @"" : @" "];
		idx++;
	}
	return [convertedFormat stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",.، "]];
}

@end
