//
//  A3Categories.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3Categories.h"

@implementation NSString (FetchedGroupByString)

- (NSString *)stringGroupByFirstInitial {
    NSString *temp = [self uppercaseString];
    
    if (!temp.length || temp.length == 1)
        return temp;
    return [temp substringToIndex:1];
}

- (NSNumber *)numberFromCurrencyFormattedStringWithCurrencyCode:(NSString *)currencyCode {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSString *myCurrencyCode = currencyCode;
	if (myCurrencyCode == nil) {
		if ([[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"MT"]) {
			[numberFormatter setCurrencyCode:@"EUR"];
			[numberFormatter setCurrencySymbol:@"€"];
		} else {
			[numberFormatter setCurrencyCode:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode]];
		}
	}
	[numberFormatter setCurrencyCode:myCurrencyCode];
	return [numberFormatter numberFromString:self];
}

- (float)floatValueEx {
	NSError *error;
	NSString *pattern = @"([\\d\\s,\\.]+)";
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];

	NSNumberFormatter *decimalStyleFormatter = [[NSNumberFormatter alloc] init];
	[decimalStyleFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	NSString *numberString;
	NSRange range;

//#ifdef DEBUG
//	NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
//	for (NSTextCheckingResult *result in matches) {
//		FNLOG(@"%@", [string substringWithRange:result.range]);
//	}
//#endif

	double result = 0.0;

	range = [regex rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
	if (!NSEqualRanges(range, NSMakeRange(NSNotFound, 0) )) {
		numberString = [self substringWithRange:range];
		result = [[decimalStyleFormatter numberFromString:numberString] doubleValue];
	}
	return result;
}

@end
